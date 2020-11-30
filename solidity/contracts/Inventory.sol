pragma solidity 0.7.3;

contract Inventory {

	enum ItemState {available, reserved, exchanged}

	struct Item {
		ItemState state;
		address seller;
		string description;
		uint price;
	}

	address owner;
	mapping(address => bool) verifiedSellers;
	
	mapping(uint => string) typeDescription;
	uint typeLength;
	
	mapping(uint => uint) itemCounts;
	mapping(uint => mapping(uint => Item)) items;
	
	mapping(address => address) behaveAsSeller;
	
	address currency;

	constructor(address _currency) {
		owner = msg.sender;
		currency = _currency;
	}

	modifier onlyOwner {
		require(msg.sender == owner, "not owner");
		_;
	}
	
	modifier canProgress(uint _itemType, uint _item) {
	    address seller = items[_itemType][_item].seller;
	    require(seller == msg.sender || seller == behaveAsSeller[msg.sender], "Not seller or approved ny seller");
        _;
	}
	
	function approve(address _other) public returns(bool){
	    require(behaveAsSeller[_other] == address(0), "Not zero address");
	    behaveAsSeller[_other] = msg.sender;
        return true;
	}

	// Create a new ItemType
	function createItemType(string calldata _description) public returns(uint){
	    typeDescription[typeLength] = _description;
	    typeLength++;
	    return typeLength - 1;
	}

	function createItem(uint _itemType, string calldata _description, uint _price) public returns(uint){
	    require(_itemType < typeLength, "ItemType out of bounds");
	    uint index = itemCounts[_itemType]; 
        items[_itemType][index].seller = msg.sender;
        items[_itemType][index].description = _description;
		items[_itemType][index].price = _price;
        itemCounts[_itemType]++;
		return index;
	}

	function reserveItem(uint _itemType, uint _item) public canProgress(_itemType, _item) returns(bool){
	    require(_itemType < typeLength, "ItemType out of bounds");
	    require(_item < itemCounts[_itemType], "Item out of bounds");
	    require(items[_itemType][_item].state == ItemState.available, "Item is not available");
	    items[_itemType][_item].state = ItemState.reserved;
		return true;
	}

	function unreserveItem(uint _itemType, uint _item) public canProgress(_itemType, _item) returns(bool){
	    require(_itemType < typeLength, "ItemType out of bounds");
	    require(_item < itemCounts[_itemType], "Item out of bounds");
	    require(items[_itemType][_item].state == ItemState.reserved, "Item is not reserved");
	    items[_itemType][_item].state = ItemState.available;
		return true;
	}

	function exchangeItem(uint _itemType, uint _item) public canProgress(_itemType, _item) returns(bool){
	    require(_itemType < typeLength, "ItemType out of bounds");
	    require(_item < itemCounts[_itemType], "Item out of bounds");
	    require(items[_itemType][_item].state == ItemState.reserved, "Item is not reserved");
	    items[_itemType][_item].state = ItemState.exchanged;
		return true;
	}

	// Getters //

	function getItemTypesLength() public view returns(uint){
		return typeLength;
	}
	
	function getTypeDescription(uint _itemType) public view returns(string memory){
	    require(_itemType < typeLength, "ItemType out of bounds");
	    return typeDescription[_itemType];
	}
    
	function getItemsLength(uint _itemType) public view returns(uint){
	    require(_itemType < typeLength, "ItemType out of bounds");
		return itemCounts[_itemType];
	}

	function getItemState(uint _itemType, uint _item) public view returns(ItemState){
	    require(_itemType < typeLength, "ItemType out of bounds");
	    require(_item < itemCounts[_itemType], "Item out of bounds");
		return items[_itemType][_item].state;
	}

	function getItemSeller(uint _itemType, uint _item) public view returns(address) {
	    require(_itemType < typeLength, "ItemType out of bounds");
	    require(_item < itemCounts[_itemType], "Item out of bounds");
		return items[_itemType][_item].seller;
	}

	function getItemDescription(uint _itemType, uint _item) public view returns(string memory) {
	    require(_itemType < typeLength, "ItemType out of bounds");
	    require(_item < itemCounts[_itemType], "Item out of bounds");
		return items[_itemType][_item].description;
	}

	function getItemPrice(uint _itemType, uint _item) public view returns(uint) {
	    require(_itemType < typeLength, "ItemType out of bounds");
	    require(_item < itemCounts[_itemType], "Item out of bounds");
		return items[_itemType][_item].price;
	}
	
	function getItem(uint _itemType, uint _item) public view returns(ItemState, address, string memory, uint){
	    require(_itemType < typeLength, "ItemType out of bounds");
	    require(_item < itemCounts[_itemType], "Item out of bounds");
	    Item storage item = items[_itemType][_item];
        return (item.state, item.seller, item.description, item.price);
	}


	// Adding and removing sellers //

	function isVerified(address _seller) public view returns(bool){
		return verifiedSellers[_seller];
	}

	function verifySeller(address _seller) public onlyOwner returns(bool){
		verifiedSellers[_seller] = true;
		return true;
	}

	function unverifySeller(address _seller) public onlyOwner returns(bool){
		verifiedSellers[_seller] = false;
		return true;
	}

	// Get service
	function getCurrencyAddress() public view returns(address){
		return currency;
	}

	function getTaxAuthority() public view returns(address) {
		return owner;
	}

}