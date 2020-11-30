const REA = artifacts.require("REA_paper_inv");
const Inventory = artifacts.require("Inventory");
const DAI = artifacts.require("Dai");

const BigNumber = require('./bignumber.js');

contract("Materialization of REA with inventory", accounts => {

	let bank = accounts[0];
    let tax      	 = accounts[1];
    let buyer	 	 = accounts[2];
    let seller	 	 = accounts[3];
    
    let inventory;
	let dai;

    beforeEach('Setup for each test', async function() {    
		// Setup currency, cap = 1000000.000000000000000000
		dai = await DAI.new({from: bank});

		// Transfer 100000 dai to the buyer. Recall 18 decimals.
		await dai.transfer(buyer, BigNumber(100000).times(1e18), {from: bank});

		inventory = await Inventory.new(dai.address, {from: tax});

        await inventory.createItemType("Green sports bike");
		await inventory.createItemType("Red sports bike");

		// Create 11 green bikes of price 1200 and 5 Red of price 800 
		for (let i = 0 ; i < 11; i++){
			await inventory.createItem(0, "#" + i, BigNumber(1200).times(1e18), {from: seller});
			if (i < 5){
				await inventory.createItem(1, "#" + i, BigNumber(800).times(1e18), {from: seller});
			}
		}
	});

	async function cleanDeliveries(_deliveries, _inventory){
		let itemTypes = Object.keys(_deliveries);
		for (let i = 0; i < itemTypes.length; i++){
			let desc = await _inventory.getTypeDescription(itemTypes[i]);
			_deliveries[desc] = _deliveries[itemTypes[i]];
			delete _deliveries[itemTypes[i]];
		}
	}

	async function materializeREA(_rea, _currency){
		// 1. Find Find those payments not linked to a delivery, 
		// sum their seller amounts which becomes “productsreceivable”  	- This is the transactionAmount of the contracts i am seller in  
		// and sum their VAT amounts which become “prepaid VAT-out”			- This is the vatAmount of the contracts i am seller in.
		// 2. For payments matched by deliveries, sum their VAT amounts which become “Vat-in” for Seller and Vatout for buyer
		// 3. For delivery, get delivery quantity and multiply by actual price. 
		// This becomes “sales” for seller and “purchases” for buyer. 		- This is the transactionAmount of the contracts.  
		// Also send summed quantities of deliveries to seller so they can use internal costs to calculate cost-of-goods sold - I have not done this yet.

		let detail_state = BigNumber(await _rea.Business_Process_Detail_state())
		let isDelivered = detail_state == 10 || detail_state == 12;
		let isDespatched = isDelivered || detail_state == 9;

		let data = {};
		data["productsreceivable"] = 0;
		data["prepaidVatOut"] = 0;
		if (!isDelivered){ // Point 1
			data["productsreceivable"] = BigNumber(await _rea.transactionAmount()).div(1e18).toString()
			data["prepaidVatOut"] = BigNumber(await _rea.vatAmount()).div(1e18).toString()
		} else { // Point 2, 3
			let vat = BigNumber(await _rea.vatAmount()).div(1e18).toString() 
			data["sellerVatIn"] = vat;
			data["buyerVatOut"] = vat;
			let amount = BigNumber(await _rea.transactionAmount()).div(1e18).toString()
			data["sales"] = amount;
			data["purchases"] = amount;
		}

		if (isDespatched){
			let numItemTypes = BigNumber(await _rea.orderItemTypesLength());
			let deliveries = {};
			for (let i = 0; i < numItemTypes; i++){
				let itemType = BigNumber(await _rea.orderItemTypes(i));
				if (deliveries[itemType.toNumber()] == undefined){
					deliveries[itemType.toNumber()] = 0;
				}
				deliveries[itemType.toNumber()] = deliveries[itemType.toNumber()] + 1;
			}
			data["deliveries"] = deliveries	
		}
		
		let res = await _rea.computeSumAndVat();
		data["expectedVat"] = BigNumber(res["vat"]).div(1e18).toString();
		data["expectedAmount"] = BigNumber(res["sum"]).div(1e18).toString();

		data["balance"] = BigNumber(await _currency.balanceOf(_rea.address)).div(1e18).toString();
		
		return data;
	}

	async function materialization(_reas, _currency, _inventory){
		// Notice we have only one trade here.
		data = {};

		data["deals"] = {};

		for (let i = 0 ; i < _reas.length; i++){
			_rea = _reas[i];
			let rea_res = await materializeREA(_rea, _currency);
			data["deals"][_rea.address] = rea_res;
		}

		// 4. Can we get a present wallet balance for the buyer and seller (after the transactions)? 
		// These become “currency balance” which is part of cash account structure.
		let buyerAddr = await _rea.buyer();
		let sellerAddr = await _rea.seller();
		let taxAddr = await _inventory.getTaxAuthority();
		data["sellerBalance"] = BigNumber(await _currency.balanceOf(sellerAddr)).div(1e18).toString();
		data["buyerBalance"] = BigNumber(await _currency.balanceOf(buyerAddr)).div(1e18).toString();
		data["taxBalance"] = BigNumber(await _currency.balanceOf(taxAddr)).div(1e18).toString();

		// 5. What do I own?

		// The buyer owns everything he have received in contract. Meaning that we can simply loop over the deliveries where he was buyer
		let trade_keys = Object.keys(data["deals"]);
		let buyerDeliveries = {};
		for (let i = 0 ; i < trade_keys.length; i++){
			let _deliveries = data["deals"][trade_keys[i]]["deliveries"];
			if (_deliveries == undefined) continue;
			let itemKeys = Object.keys(_deliveries);
			for (let j = 0 ; j < itemKeys.length; j++){
				let itemType = itemKeys[j];
				if (buyerDeliveries[itemType] == undefined){
					buyerDeliveries[itemType] = 0;
				}
				buyerDeliveries[itemType] = buyerDeliveries[itemType] + _deliveries[itemType];
			}
			await cleanDeliveries(_deliveries, _inventory)
			console.log("Deliv: ", _deliveries)
		}
		await cleanDeliveries(buyerDeliveries, _inventory);
		data["buyerItems"] = buyerDeliveries;

		// Get all the items that the seller owns. The computation here is done in the most inefficient manner. Forgive my sins.
		// This should be updated for the real case, i.e., when itemState == 1, we need to look at the contract, as it could be owned by the buyer if despatched.
		let sellerItems = {};
		let itemTypesLength = BigNumber(await _inventory.getItemTypesLength());
		for (let i = 0 ; i < itemTypesLength; i++){
			let itemLength = BigNumber(await _inventory.getItemsLength(i));
			for (let j = 0 ; j < itemLength; j++){
				let item = await _inventory.getItem(i, j);
				let itemSeller = item[1];
				let itemState = item[0];
				if (itemState > 1){
					continue;
				}
				if (sellerItems[i] == undefined){
					sellerItems[i] = 0;
				}
				sellerItems[i] = sellerItems[i] + 1;
			}
		}
		await cleanDeliveries(sellerItems, _inventory);
		data["sellerItems"]= sellerItems;

		return data;
	}

	it("Happy path, no negotiation", async () => {
		// Create REA smart contract with between seller and buyer with the specified inventory.
		let rea = await REA.new(inventory.address, seller, {from: buyer})
		let rea2 = await REA.new(inventory.address, seller, {from: buyer})

		let materializaTrades = true;

		if (materializaTrades){
			let initial = await materialization([rea, rea2], dai, inventory);
			console.log("--- Initial materialization ---");
			console.log(initial);
		}

		// Request a catalogue 
		await rea.request_catalogue({from: buyer});
		
		// Return of a catalogue
		await rea.catalogue({from: seller});
		
		// Request a quotation (#8)
		await rea.request_quotation({from: buyer});

		// Return of a quotation (#9)
		await rea.quotation({from: seller});
		
		// Purchase order (#10)
		await rea.order([0, 0, 0, 0, 0, 0, 0, 0, 0, 0], {from: buyer});
		
        // Approve the rea contract to progress items owned by the seller.
        await inventory.approve(rea.address, {from: seller});

		// Accept purchase order (#11)
		await rea.response_simple_accept([0, 1, 2, 3, 4, 5, 6, 7, 8, 9], {from: seller});

		let balance = await dai.balanceOf(buyer);
		await dai.approve(rea.address, balance, {from: buyer});

		// Indication of payment (#12)
		await rea.remittance_advice({from: buyer});
		
		// Despatch of goods / Advance Shipping Notice (#13)
		await rea.despatch_advice({from: seller});
		
		// Receipt of goods (#14)
		await rea.receipt_advice({from: buyer});
		
		// Invoice - demand for payment (#15)
		await rea.invoice({from: seller});

		if (materializaTrades){
			let intermediate = await materialization([rea, rea2], dai, inventory);
			console.log("--- Intermediate materialization ---")
			console.log(intermediate)
		}

		balance = await dai.balanceOf(buyer);

		await dai.approve(rea2.address, balance, {from: buyer});
		
		await rea2.request_catalogue({from: buyer});

		await rea2.catalogue({from: seller});

		// #16
		await rea2.request_quotation({from: buyer}); 

		// #17
		await rea2.quotation({from: seller});

		// #18
		await rea2.order([1, 1, 1, 1, 1], {from: buyer});

		await inventory.approve(rea2.address, {from: seller});

		// #19
		await rea2.response_simple_accept([0, 1, 2, 3, 4], {from: seller});

		// Indication of payment (#20)
		await rea2.remittance_advice({from: buyer});

		if (materializaTrades){
			let finalRes = await materialization([rea, rea2], dai, inventory);
			console.log("--- Final materialization ---")
			console.log(finalRes);
		}

		//// The scenario stops here ////
		return;

		// Despatch of goods / Advance Shipping Notice 
		await rea2.despatch_advice({from: seller});
		
		// Receipt of goods
		await rea2.receipt_advice({from: buyer});
		
		// Invoice - demand for payment
		await rea2.invoice({from: seller});

		if (!materializaTrades){
			finalRes = await materialization([rea, rea2], dai, inventory);
			console.log("--- The extra materialization ---")
			console.log(finalRes);
		}

	});
	
});