const REA = artifacts.require("REA_paper_inv");
const Inventory = artifacts.require("Inventory");
const DAI = artifacts.require("Dai");

const BigNumber = require('./bignumber.js');

// TODO: 
// 1. 10 cykler etc, den skal være fuldkommen det han har stående i pdf.
// 2. Kort beskrivelse af test i 'it'.
// 3. Flere tests som viser at vi ikke kan gå "uden for" state machinen.
// 4. Lav screenshots i hvid.

contract("REA with inventory", accounts => {

	let bank = accounts[0];
    let tax      	 = accounts[1];
    let buyer	 	 = accounts[2];
    let seller	 	 = accounts[3];
    
    let inventory;
	let rea;
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
		// Create REA smart contract with between seller and buyer with the specified inventory.
		rea = await REA.new(inventory.address, seller, {from: buyer})
	});



	it("Happy path, no negotiation", async () => {
		// Request a catalogue
		await rea.request_catalogue({from: buyer});
		
		// Return of a catalogue
		await rea.catalogue({from: seller});
		
		// Request a quotation
		await rea.request_quotation({from: buyer});

		// Return of a quotation
		await rea.quotation({from: seller});
		
		// Purchase order
		await rea.order([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1], {from: buyer});
		
		// Approve the rea contract to progress items owned by the seller.
		await inventory.approve(rea.address, {from: seller});

		// Accept purchase order
		await rea.response_simple_accept([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4], {from: seller});

		let res = await rea.computeSumAndVat();
		let expectedVat = res["vat"];
		let expectedAmount = res["sum"];
		//console.log(expectedAmount, expectedVat);
	
		// Buyer allow contract to tranfser funds on his behalf
		let balance = await dai.balanceOf(buyer);
		await dai.approve(rea.address, balance, {from: buyer});

		// Indication of payment
		await rea.remittance_advice({from: buyer});
		
		// Despatch of goods / Advance Shipping Notice
		await rea.despatch_advice({from: seller});
		
		// Receipt of goods
		await rea.receipt_advice({from: buyer});
		
		// Invoice - demand for payment
		await rea.invoice({from: seller});

		//console.log(expectedVat.equal(expectedAmount));
		let taxBalance = BigNumber(await dai.balanceOf(tax));
		//console.log(taxBalance.toString());//.equal(expectedVat), "HMMMM");
		assert.equal(taxBalance.isEqualTo(BigNumber(expectedVat)), true, "Vat paid and to pay not matching");
		assert.equal(BigNumber(await dai.balanceOf(buyer)).isEqualTo(BigNumber(balance).minus(BigNumber(expectedAmount)).minus(BigNumber(expectedVat))), true, "Incorrect buyer balance");
	});
	
	it("Happy path with re-negotiation", async () => {
		// Request a catalogue
		await rea.request_catalogue({from: buyer});
		
		// Return of a catalogue
		await rea.catalogue({from: seller});
		
		// Request a quotation
		await rea.request_quotation({from: buyer});

		// Return of a quotation
		await rea.quotation({from: seller});
		
		// Purchase order
		await rea.order([0, 0, 0, 0, 0, 0, 0, 0, 0, 0], {from: buyer});
		
		// Return of a counter offer
		await rea.response_counter([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1], {from: seller});
		
		// Revised purchase order
		await rea.order([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1], {from: buyer});
				
		// Approve the rea contract to progress items owned by the seller.
		await inventory.approve(rea.address, {from: seller});

		// Accept purchase order
		await rea.response_simple_accept([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4],{from: seller});

		// Buyer allow contract to tranfser funds on his behalf
		let balance = await dai.balanceOf(buyer);
		await dai.approve(rea.address, balance, {from: buyer});

		// Indication of payment
		await rea.remittance_advice({from: buyer});

        // Despatch of goods / Advance Shipping Notice
		await rea.despatch_advice({from: seller});
		
		// Receipt of goods
		await rea.receipt_advice({from: buyer});
		
		// Invoice - demand for payment
		await rea.invoice({from: seller});	
	});
	
	it("Happy path with seller rejecting ", async () => {
		// Request a catalogue
		await rea.request_catalogue({from: buyer});
		
		// Return of a catalogue
		await rea.catalogue({from: seller});
		
		// Request a quotation
		await rea.request_quotation({from: buyer});

		// Return of a quotation
		await rea.quotation({from: seller});
		
		// Purchase order
		await rea.order([0, 0, 0, 0, 0, 0, 0, 0, 0, 0], {from: buyer});
		
		// Return of a counter offer
		await rea.response_counter([0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1], {from: seller});
		
		// Revised purchase order
		await rea.order([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1], {from: buyer});
		
		// Reject purchase order
		await rea.response_simple_reject({from: seller});

		let overviewState = await rea.Business_Process_Overview_state();
		assert.equal(overviewState.toNumber(), 5, "Overview not in post-actualization");

		let detailState = await rea.Business_Process_Detail_state();
		assert.equal(detailState.toNumber(), 11, "Detail not in abandon");		
    });
	
	it("Buyer with (amount < funds < vat + amount) unable to execute remittance_advice", async () => {
		// Request a catalogue
		await rea.request_catalogue({from: buyer});
				
		// Return of a catalogue
		await rea.catalogue({from: seller});

		// Request a quotation
		await rea.request_quotation({from: buyer});

		// Return of a quotation
		await rea.quotation({from: seller});

		// Purchase order
		await rea.order([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1], {from: buyer});
		
		// Approve the rea contract to progress items owned by the seller.
		await inventory.approve(rea.address, {from: seller});

		// Accept purchase order
		await rea.response_simple_accept([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4], {from: seller});

		let res = await rea.computeSumAndVat();
		let expectedVat = res["vat"];
		let expectedAmount = res["sum"];
		//console.log(expectedAmount, expectedVat);

		// Buyer allow contract to tranfser funds on his behalf
		let balance = await dai.balanceOf(buyer);

		await dai.transfer(bank, BigNumber(balance).minus(BigNumber(expectedAmount)).minus(1), {from: buyer});
		
		balance = await dai.balanceOf(buyer);
		await dai.approve(rea.address, balance, {from: buyer});

		// Indication of payment
		try {
			await rea.remittance_advice({from: buyer});
		} catch(err){
			return;
		}

		assert.fail("Should have reverted remittance");
	});

	it("Buyer unable to accept order on behalf of seller", async() => {
		// Request a catalogue
		await rea.request_catalogue({from: buyer});
		
		// Return of a catalogue
		await rea.catalogue({from: seller});
		
		// Request a quotation
		await rea.request_quotation({from: buyer});

		// Return of a quotation
		await rea.quotation({from: seller});
		
		// Purchase order
		await rea.order([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1], {from: buyer});
		
		// Accept purchase order
		try{
			await rea.response_simple_accept([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4], {from: buyer});
		} catch(err){
			return;
		}

		assert.fail("Buyer could progress state on behalf of seller");
	});

	it("Buyer unable to perform despatch", async() => {
		// Request a catalogue
		await rea.request_catalogue({from: buyer});
				
		// Return of a catalogue
		await rea.catalogue({from: seller});

		// Request a quotation
		await rea.request_quotation({from: buyer});

		// Return of a quotation
		await rea.quotation({from: seller});

		// Purchase order
		await rea.order([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1], {from: buyer});
		
		// Approve the rea contract to progress items owned by the seller.
		await inventory.approve(rea.address, {from: seller});

		// Accept purchase order
		await rea.response_simple_accept([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4], {from: seller});

		// Buyer allow contract to tranfser funds on his behalf
		let balance = await dai.balanceOf(buyer);
		await dai.approve(rea.address, balance, {from: buyer});

		// Indication of payment
		await rea.remittance_advice({from: buyer});

		// Despatch of goods / Advance Shipping Notice
		try{
			await rea.despatch_advice([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4], {from: buyer});
		} catch(err) {
			return;
		}

		assert.fail("The buyer could perform despatch advice");
	});

	it("Seller unable to perform receipt-advice", async() => {
		// Request a catalogue
		await rea.request_catalogue({from: buyer});
				
		// Return of a catalogue
		await rea.catalogue({from: seller});

		// Request a quotation
		await rea.request_quotation({from: buyer});

		// Return of a quotation
		await rea.quotation({from: seller});

		// Purchase order
		await rea.order([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1], {from: buyer});
		
		// Approve the rea contract to progress items owned by the seller.
		await inventory.approve(rea.address, {from: seller});

		// Accept purchase order
		await rea.response_simple_accept([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4], {from: seller});

		// Buyer allow contract to tranfser funds on his behalf
		let balance = await dai.balanceOf(buyer);
		await dai.approve(rea.address, balance, {from: buyer});

		// Indication of payment
		await rea.remittance_advice({from: buyer});

		// Despatch of goods / Advance Shipping Notice
		await rea.despatch_advice({from: seller});

		// Receipt of goods
		try{
			await rea.receipt_advice({from: seller});
		} catch(err){
			return;
		}

		assert.fail("The seller could perform receipt-advice");
	});

	it("Seller unable to double-spend items, e.g., have the same item in two orders", async () => {
		for(let i = 0 ; i < 2; i++){
			// New contract
			rea = await REA.new(inventory.address, seller, {from: buyer});

			// Request a catalogue
			await rea.request_catalogue({from: buyer});
					
			// Return of a catalogue
			await rea.catalogue({from: seller});

			// Request a quotation
			await rea.request_quotation({from: buyer});

			// Return of a quotation
			await rea.quotation({from: seller});

			// Purchase order
			await rea.order([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1], {from: buyer});
		
			// Approve the rea contract to progress items owned by the seller.
			await inventory.approve(rea.address, {from: seller});
			// Accept purchase order
			if (i > 0) {
				try{
					await rea.response_simple_accept([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4], {from: seller});
				} catch(err){
					return;
				}
				assert.fail("Seller is able to double-spend items");
			}
			await rea.response_simple_accept([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4], {from: seller});
			
			// Buyer allow contract to tranfser funds on his behalf
			let balance = await dai.balanceOf(buyer);
			await dai.approve(rea.address, balance, {from: buyer});

			// Indication of payment
			await rea.remittance_advice({from: buyer});
		
			// Despatch of goods / Advance Shipping Notice
			await rea.despatch_advice({from: seller});

			// Receipt of goods
			await rea.receipt_advice({from: buyer});

			// Invoice - demand for payment
			await rea.invoice({from: seller});
		}
	});

});