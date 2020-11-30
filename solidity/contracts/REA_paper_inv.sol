pragma solidity 0.7.3;

import "./SafeMath.sol";
import "./IERC20.sol";
import "./Inventory.sol";

contract REA_paper_inv {

	using SafeMath for uint256;

    enum Business_Process_Overview {
        None,
        planning,
        identification,
        negotiation,
        actualization,
        post_actualization
    }
    enum Business_Process_Detail {
        None,
        catalogue_requested,
        catalogue_received,
        quotation_requested,
        quotation_received,
        order_received,
        counter_order_received,
        order_accepted,
        paid,
        despatched,
        goods_received,
        abandoned,
        completed
    }

    Business_Process_Overview public Business_Process_Overview_state;
    Business_Process_Detail public Business_Process_Detail_state;

    Inventory inventory;
    uint[] public orderItemTypes;
    uint[] public orderItems;
    address public seller;
    address public buyer;
	uint public vatAmount;
	uint public transactionAmount;

    constructor(address _inventory, address _seller) {
        inventory = Inventory(_inventory);
        seller = _seller;
        buyer = msg.sender;
    }

    function orderItemTypesLength() public view returns(uint){
        return orderItemTypes.length;
    }

    function request_catalogue() public {
		require(msg.sender == buyer, "Not buyer");

        bool _Business_Process_Overview_state
         = Business_Process_Overview_state == Business_Process_Overview.None;
        require(
            _Business_Process_Overview_state,
            "Business Process Overview not satisfied, cannot run request_catalogue"
        );

        bool _Business_Process_Detail_state = Business_Process_Detail_state ==
            Business_Process_Detail.None;
        require(
            _Business_Process_Detail_state,
            "Business Process Detail not satisfied, cannot run request_catalogue"
        );

        Business_Process_Overview_state = Business_Process_Overview.planning;
        Business_Process_Detail_state = Business_Process_Detail
            .catalogue_requested;
    }

    function request_quotation() public {
		require(msg.sender == buyer, "Not buyer");
            bool _Business_Process_Overview_state
         = Business_Process_Overview_state ==
            Business_Process_Overview.planning;
        require(
            _Business_Process_Overview_state,
            "Business Process Overview not satisfied, cannot run request_quotation"
        );

        bool _Business_Process_Detail_state = Business_Process_Detail_state ==
            Business_Process_Detail.catalogue_received;
        require(
            _Business_Process_Detail_state,
            "Business Process Detail not satisfied, cannot run request_quotation"
        );

        Business_Process_Overview_state = Business_Process_Overview
            .identification;
        Business_Process_Detail_state = Business_Process_Detail
            .quotation_requested;
    }

    function abandon() public {
		require(msg.sender == buyer || msg.sender == seller, "Not buyer or seller");

            bool _Business_Process_Overview_state
         = Business_Process_Overview_state ==
            Business_Process_Overview.planning ||
            Business_Process_Overview_state ==
            Business_Process_Overview.identification ||
            Business_Process_Overview_state ==
            Business_Process_Overview.negotiation ||
            Business_Process_Overview_state ==
            Business_Process_Overview.actualization;
        require(
            _Business_Process_Overview_state,
            "Business Process Overview not satisfied, cannot run abandon"
        );

        bool _Business_Process_Detail_state = Business_Process_Detail_state ==
            Business_Process_Detail.catalogue_requested ||
            Business_Process_Detail_state ==
            Business_Process_Detail.catalogue_received ||
            Business_Process_Detail_state ==
            Business_Process_Detail.quotation_requested ||
            Business_Process_Detail_state ==
            Business_Process_Detail.quotation_received ||
            Business_Process_Detail_state ==
            Business_Process_Detail.counter_order_received ||
            Business_Process_Detail_state ==
            Business_Process_Detail.order_accepted ||
            Business_Process_Detail_state == Business_Process_Detail.paid ||
            Business_Process_Detail_state ==
            Business_Process_Detail.despatched ||
            Business_Process_Detail_state ==
            Business_Process_Detail.goods_received;
        require(
            _Business_Process_Detail_state,
            "Business Process Detail not satisfied, cannot run abandon"
        );

        Business_Process_Overview_state = Business_Process_Overview
            .post_actualization;
        Business_Process_Detail_state = Business_Process_Detail.abandoned;
    }

    function quotation() public {
		require(msg.sender == seller, "Not seller");

            bool _Business_Process_Overview_state
         = Business_Process_Overview_state ==
            Business_Process_Overview.identification;
        require(
            _Business_Process_Overview_state,
            "Business Process Overview not satisfied, cannot run quotation"
        );

        bool _Business_Process_Detail_state = Business_Process_Detail_state ==
            Business_Process_Detail.quotation_requested;
        require(
            _Business_Process_Detail_state,
            "Business Process Detail not satisfied, cannot run quotation"
        );

        Business_Process_Overview_state = Business_Process_Overview.negotiation;
        Business_Process_Detail_state = Business_Process_Detail
            .quotation_received;
    }

    function response_simple_accept(uint[] calldata _orderItems) public {
		require(msg.sender == seller, "Not seller");

            bool _Business_Process_Overview_state
         = Business_Process_Overview_state ==
            Business_Process_Overview.negotiation;
        require(
            _Business_Process_Overview_state,
            "Business Process Overview not satisfied, cannot run response_simple_accept"
        );

        bool _Business_Process_Detail_state = Business_Process_Detail_state ==
            Business_Process_Detail.order_received;
        require(
            _Business_Process_Detail_state,
            "Business Process Detail not satisfied, cannot run response_simple_accept"
        );

        require(orderItemTypes.length == _orderItems.length, "Lengths do not match");

        for(uint i = 0; i < orderItemTypes.length; i++){
            require(inventory.reserveItem(orderItemTypes[i], _orderItems[i]), "Could not reserve item");
        }

        orderItems = _orderItems;

        Business_Process_Overview_state = Business_Process_Overview
            .actualization;
        Business_Process_Detail_state = Business_Process_Detail.order_accepted;
    }

    function invoice() public {
		require(msg.sender == seller, "Not seller");

            bool _Business_Process_Overview_state
         = Business_Process_Overview_state ==
            Business_Process_Overview.actualization;
        require(
            _Business_Process_Overview_state,
            "Business Process Overview not satisfied, cannot run invoice"
        );

        bool _Business_Process_Detail_state = Business_Process_Detail_state ==
            Business_Process_Detail.goods_received;
        require(
            _Business_Process_Detail_state,
            "Business Process Detail not satisfied, cannot run invoice"
        );

        // TODO: Make that actual transfer of funds.
        IERC20(inventory.getCurrencyAddress()).transfer(seller, transactionAmount);
		IERC20(inventory.getCurrencyAddress()).transfer(inventory.getTaxAuthority(), vatAmount);        

        Business_Process_Overview_state = Business_Process_Overview
            .post_actualization;
        Business_Process_Detail_state = Business_Process_Detail.completed;
    }

    function catalogue() public {
		require(msg.sender == seller, "Not seller");
        bool _Business_Process_Detail_state = Business_Process_Detail_state ==
            Business_Process_Detail.catalogue_requested;
        require(
            _Business_Process_Detail_state,
            "Business Process Detail not satisfied, cannot run catalogue"
        );

        Business_Process_Detail_state = Business_Process_Detail
            .catalogue_received;
    }

    function order(uint[] calldata _itemTypes) public {
        require(msg.sender == buyer, "Not buyer");

        bool _Business_Process_Detail_state = Business_Process_Detail_state ==
            Business_Process_Detail.quotation_received ||
            Business_Process_Detail_state ==
            Business_Process_Detail.counter_order_received;
        require(
            _Business_Process_Detail_state,
            "Business Process Detail not satisfied, cannot run order"
        );

        orderItemTypes = _itemTypes;

        Business_Process_Detail_state = Business_Process_Detail.order_received;
    }

    function response_counter(uint[] calldata _itemTypes) public {
        require(msg.sender == seller, "Not seller");
        bool _Business_Process_Detail_state = Business_Process_Detail_state ==
            Business_Process_Detail.order_received;
        require(
            _Business_Process_Detail_state,
            "Business Process Detail not satisfied, cannot run response_counter"
        );

        orderItemTypes = _itemTypes;

        Business_Process_Detail_state = Business_Process_Detail
            .counter_order_received;
    }

    function response_simple_reject() public {
        require(msg.sender == seller, "Not seller");
            bool _Business_Process_Overview_state
         = Business_Process_Overview_state ==
            Business_Process_Overview.negotiation;
        require(
            _Business_Process_Overview_state,
            "Business Process Overview not satisfied, cannot run response_simple_reject"
        );

        bool _Business_Process_Detail_state = Business_Process_Detail_state ==
            Business_Process_Detail.order_received;
        require(
            _Business_Process_Detail_state,
            "Business Process Detail not satisfied, cannot run response_simple_reject"
        );

        Business_Process_Overview_state = Business_Process_Overview
            .post_actualization;
        Business_Process_Detail_state = Business_Process_Detail.abandoned;
    }

    function remittance_advice() public {
		require(msg.sender == buyer, "Not buyer");
        bool _Business_Process_Detail_state = Business_Process_Detail_state ==
            Business_Process_Detail.order_accepted;
        require(
            _Business_Process_Detail_state,
            "Business Process Detail not satisfied, cannot run remittance_advice"
        );

        uint sum;
		uint vat;
		(sum, vat) = computeSumAndVat();

        // TODO: Contract takes funds 
        uint totalFunds = sum.add(vat);

        IERC20(inventory.getCurrencyAddress()).transferFrom(msg.sender, address(this), totalFunds);

		//IERC20(inventory.getCurrencyAddress()).transferFrom(msg.sender, seller, sum);
		//IERC20(inventory.getCurrencyAddress()).transferFrom(msg.sender, inventory.getTaxAuthority(), vat);

		vatAmount = vat;
		transactionAmount = sum;

        Business_Process_Detail_state = Business_Process_Detail.paid;
    }

    function computeSumAndVat() public view returns(uint sum, uint vat){
		sum = 0;
		for (uint i = 0; i < orderItems.length; i++){
            uint price = inventory.getItemPrice(orderItemTypes[i], orderItems[i]);
			sum = sum.add(price);
		}
		vat = sum.mul(25).div(100);
	}

    function despatch_advice() public {
		require(msg.sender == seller, "Not seller");
        bool _Business_Process_Detail_state = Business_Process_Detail_state ==
            Business_Process_Detail.paid;
        require(
            _Business_Process_Detail_state,
            "Business Process Detail not satisfied, cannot run despatch_advice"
        );

        Business_Process_Detail_state = Business_Process_Detail.despatched;
    }

    function receipt_advice() public {
		require(msg.sender == buyer, "Not buyer");
        bool _Business_Process_Detail_state = Business_Process_Detail_state ==
            Business_Process_Detail.despatched;
        require(
            _Business_Process_Detail_state,
            "Business Process Detail not satisfied, cannot run receipt_advice"
        );

        for(uint i = 0; i < orderItemTypes.length; i++){
            require(inventory.exchangeItem(orderItemTypes[i], orderItems[i]), "Could not exchange item");
        }

        Business_Process_Detail_state = Business_Process_Detail.goods_received;
    }
}
