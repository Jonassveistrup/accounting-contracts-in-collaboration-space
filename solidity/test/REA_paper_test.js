const REA = artifacts.require("REA_Paper");

contract("Simple statemachine for REA", accounts => {
	it("Simple 'happy path' walk through pre-payment business process", async () => {
		// Mapping names to addresses
		let buyer	 = accounts[0];
		let seller	 = accounts[1];

		// Creating a contract on the blockchain
		let rea = await REA.new({from: buyer})

		// Request a catalogue
		await rea.request_catalogue({from: buyer});
		
		// Return of a catalogue
		await rea.catalogue({from: seller});
		
		// Request of quoatation
		await rea.request_quotation({from: buyer});
		
		// REturn of quotation
		await rea.quotation({from: seller});
		
		// Purchase order
		await rea.order({from: buyer});
		
		// Return of a counter offer
		await rea.response_counter({from: seller});
		
		// Revised purchase order
		await rea.order({from: buyer});
		
		// Accept purchase order
		await rea.response_simple_accept({from: seller});
		
		// Indication of payment
		await rea.remittance_advice({from: buyer});
		
		// Despatch of goods / Advance Shipping Notice
		await rea.despatch_advice({from: seller});
		
		// Receipt of goods
		await rea.receipt_advice({from: buyer});
		
		// Invoice - demand for payment
		await rea.invoice({from: seller});
		
	});
});