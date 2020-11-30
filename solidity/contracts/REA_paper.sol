pragma solidity 0.7.3;

contract REA_paper {
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

    function request_catalogue() public {

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

    function response_simple_accept() public {

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

        Business_Process_Overview_state = Business_Process_Overview
            .actualization;
        Business_Process_Detail_state = Business_Process_Detail.order_accepted;
    }

    function invoice() public {

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

        Business_Process_Overview_state = Business_Process_Overview
            .post_actualization;
        Business_Process_Detail_state = Business_Process_Detail.completed;
    }

    function catalogue() public {
        bool _Business_Process_Detail_state = Business_Process_Detail_state ==
            Business_Process_Detail.catalogue_requested;
        require(
            _Business_Process_Detail_state,
            "Business Process Detail not satisfied, cannot run catalogue"
        );

        Business_Process_Detail_state = Business_Process_Detail
            .catalogue_received;
    }

    function order() public {
        bool _Business_Process_Detail_state = Business_Process_Detail_state ==
            Business_Process_Detail.quotation_received ||
            Business_Process_Detail_state ==
            Business_Process_Detail.counter_order_received;
        require(
            _Business_Process_Detail_state,
            "Business Process Detail not satisfied, cannot run order"
        );

        Business_Process_Detail_state = Business_Process_Detail.order_received;
    }

    function response_counter() public {
        bool _Business_Process_Detail_state = Business_Process_Detail_state ==
            Business_Process_Detail.order_received;
        require(
            _Business_Process_Detail_state,
            "Business Process Detail not satisfied, cannot run response_counter"
        );

        Business_Process_Detail_state = Business_Process_Detail
            .counter_order_received;
    }

    function response_simple_reject() public {

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
        bool _Business_Process_Detail_state = Business_Process_Detail_state ==
            Business_Process_Detail.order_accepted;
        require(
            _Business_Process_Detail_state,
            "Business Process Detail not satisfied, cannot run remittance_advice"
        );

        Business_Process_Detail_state = Business_Process_Detail.paid;
    }

    function despatch_advice() public {
        bool _Business_Process_Detail_state = Business_Process_Detail_state ==
            Business_Process_Detail.paid;
        require(
            _Business_Process_Detail_state,
            "Business Process Detail not satisfied, cannot run despatch_advice"
        );

        Business_Process_Detail_state = Business_Process_Detail.despatched;
    }

    function receipt_advice() public {
        bool _Business_Process_Detail_state = Business_Process_Detail_state ==
            Business_Process_Detail.despatched;
        require(
            _Business_Process_Detail_state,
            "Business Process Detail not satisfied, cannot run receipt_advice"
        );

        Business_Process_Detail_state = Business_Process_Detail.goods_received;
    }
}
