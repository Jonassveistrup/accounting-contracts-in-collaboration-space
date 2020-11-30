# Artefacts supporting a scenario running on a DBTR

This directory contains the following artefacts documenting the running of a particular pre-payment purchasing scenario on an ISO/IEC 15944-21 Distributed Business Transaction Repository (DBTR) tracking an ISO/IEC 15944-4 Business Transaction:

- `scenario-paper.pdf` (start here)
  - a human-oriented output rendering of the history of the states of each of the numerous instantiated and yet-to-be-instantiated state machines as they transition in response to stimuli associated with business events
- `scenario-paper.xml`
  - a machine-readable input coding of the scenario's business events and each of the DBTR stimuli and properties associated with the events
- `dbtr-paper.xml`
  - a machine-readable input coding of all of the available state machines in the DBTR that may or may not be triggered by stimuli from a scenario of business events
- `scenario.rnc`
  - the XML document model schema constraining the expression of a scenario of multiple business events and their associated DBTR state machine stimuli
- `dbtr.rnc`
  - the XML document model schema constraining the expression of all of a given DBTR's state machines and their associated state changes
- `scenario-paper.dbtr-history.xml`
  - a machine-readable diagnostic review of the history of all of the DBTR transitions triggered by all of the scenario's business event stimuli
## Narration for the `scenario-paper.pdf` history

﻿This PDF renders all of the instances a set of state machines in a particular distributed business transaction repository, complete with their specific properties and values. 

On the first page, the top line titles the particular DBTR state machine definition that is in play for the choreography of business events. Below a graphical state machine legend are all of the state machine definitions illuminating each of the available states and how any given stimulus sent to the state machine changes the current state. In the top right, a circled letter R indicates that the state machine is reusable, that is, an instance of the state machine can be reused across multiple scenarios once it has been defined. In the top left, a circled letter C indicates that the state machine is completed, that is, the particular instance of the state machine will never be able to change its state or its properties. The identifier of a particular instance of a state machine is underscored and boldfaced. 

Visual cues indicate changes in values. When viewed in colour, any change is marked in red. When viewed in black and white, machines that change are boxed with dashed lines, state changes are marked with a checkmark, and property changes are marked with a tilde character. Old state changes are marked with an x, and old property changes are marked with an equal sign.

Below the DBTR title is the title of the scenario that is played out on the remaining pages.

On the remaining pages, the choreography of business events is the conversation for action for a given scenario. Each statement in the conversation for action is shown next to the business event sequence number. Listed below the statement are all of the stimuli triggered by the business event. What follows is the current status of all of the instances of state machines, or where there is yet to be an instance, the definitions of state machines.

The conversation for action begins with a few "behind the scenes" business events, not associated with UBL documents in this example, to establish the reusable state machine instances that are needed later.

First, we need a resource type with which to value other resource types. The Dai resource type is instantiated as being a cryptocurrency that is par with the US dollar.

Next, we establish all of the economic agent types. We end up with three instances of agent types, one with the role of being the buyer, one with the role of being the seller, and one being the role of the tax authority.

Next, we establish all of the economic agents that are using those types. Party100 is Bill's Bikes Manufacturing in the role of the seller. Party200 is Jonas's Bike Shop in the role of the buyer, and his wallet is initialized with 100000 Dai to start. Party 300 is the Danish Tax Agency in the role of the tax authority. The balances of both the seller and tax agency start at zero for illustrative purposes.

Note the conventions of uninstantiated state machines in gray, unchanged state machines in solid black, and changed state machines in dashed red.

Next, we establish all of the product resource types. GreenSportBike and RedSportBike each have a suggested price with a suggested tax in the given currency of the Dai. Green sport bikes have a suggested retail price of 1200 Dai each, while red sport bikes retail at 800 Dai.

Next we establish an inventory of green bikes, each with a unique serial number that in this example serves also as its identifier. There are 11 bikes available. All are owned by Party100, the seller party.

Next we establish an inventory of red bikes in the same fashion.

Finally in our prelude we establish two economic event types that will be needed in the conversation for action, a delivery event for wholesale deliveries, and a payment event.

The conversation for action begins with the buyer asking "What inventory do you have?" by sending the document "Request for Catalogue" to the seller. This triggers the process overview and process detail for the conversation identified as "Process1". In overview, the planning phase has begun. In detail, the catalogue has been requested. None of the other state machines has changed because requesting a catalogue has no impact on any of them.

The seller responds "I have red and green bikes" by sending the document "Catalogue" to the buyer. In overview there is no change as it remains in the planning phase. In detail the process has moved to the catalogue being received. Again, none of the other state machines has changed.

The buyer likes what he sees and asks "Do you have the green bikes that I want?" by sending the document "Request for Quotation" to the seller. The process overview moves to identification and the process detail moves to quotation requested. At this point the economic contract dated on the day, June 1, is instantiated along with an economic commitment of a planned delivery to happen on June 15 for 10 green bikes from the seller as the sender to the buyer as the receiver.

The seller looks at his inventory and responds "Yes, I have the bikes you want" by returning the document "Quotation" to the buyer. This establishes the value of the contract to be 12000 Dai in cost and the associated tax. The process overview moves to "negotiation" phase and the process detail moves to "quotation-received".

The buyer responds to this with "Okay, here is an order for green bikes" by returning the document "Order" to the seller. The contract is modified with a new economic commitment of a planned payment for June 10 of the required amounts using a new economic resource of an allocation of sufficient funds to cover the purchase. This allocation is from the buyer party and is initialized as being available for the transaction. The process overview remains in the "negotiation" phase and the process detail moves to "order-received".

The seller responds "Deal! The order is acceptable" and in so doing the duality of planned payment and planned delivery proposed in the contract each become specified and "in play". At the same time, the economic resources of the individual bicycles are now reserved by the seller so as not to be designated for any other party, and the actual price and tax are recorded in case they might be different from the suggested price and tax. This moves the process overview to the "actualization" phase and the process detail to "order-accepted".

The buyer responds to the order "Okay, here is the payment" using the "Remittance" document with an advance payment indicated in a new economic event of type "Payment" named Pay1 as a fulfillment of the planned payment. This points to the allocation of funds that now are marked by the buyer as being reserved so as not to be designated for any other party. The funds are removed from the buyer's balance and now sit in the contract's wallet out of the hands of both the buyer and the seller. The process overview remains in the "actualization" phase and the process detail moves to "paid".

The seller comes back to the buyer "Thank you, I have despatched 10 green bikes" with a "Despatch Advice" document. The new economic event of type "Delivery" named "Del1" is instantiated as a fulfillment of the planned delivery. The process overview remains in the "actualization" phase and the process detail moves to "despatched".

The buyer comes back to the seller "Thank you, I have received 10 green bikes" with a "Receipt Advice" document. This triggers a number of changes.  The process overview remains in the "actualization" phase and the process detail moves to "goods-received". The delivery economic event completes, which also completes the delivery economic commitment. Importantly, all of the economic resources of the bikes themselves move to "exchanged" with the owner changing to the buyer party, the actual price at which the items were sold recorded, and the indication of which stock flow delivery acted to move the items to the new owner. All of these are in their final states and so the machines are marked as completed and they can no longer change.

The seller finishes the transaction saying to the buyer "We're square, here is your invoice".  The process overview moves to the "post-actualization" phase and the process detail moves to "completed". The economic event "Pay1" changes to "event-completed" in fulfillment of the economic commitment "PlayPay1" which changes to "commitment-complete". The contract's wallet balance reduces to zero and the amount is disbursed to the seller and tax authority wallets. Finally, the contract records the duality of the actual delivery with the actual payment and the contract, too, moves to its completed state.

