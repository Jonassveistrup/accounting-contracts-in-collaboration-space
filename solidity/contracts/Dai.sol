pragma solidity 0.7.3;

import "./ERC20.sol";


/**
 * The DKK contract does this and that...
 */
contract Dai is ERC20 {
  constructor() ERC20("Dai", "Dai", 18) {
    _mint(msg.sender, 1000000000000000000000000);
  }
}

