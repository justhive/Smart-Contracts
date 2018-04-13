pragma solidity ^0.4.18;


import "./PausableERC827Token.sol";

/**
 * @title JustHiveToken
 * @dev JustHiveToken implementation
 * The token inherits from the PausableToken contract
 */
contract JustHiveToken is PausableERC827Token {

  string public constant name = "JustHiveToken"; // solium-disable-line uppercase
  string public constant symbol = "JHT"; // solium-disable-line uppercase
  uint8 public constant decimals = 18; // solium-disable-line uppercase

  uint256 public constant INITIAL_SUPPLY = 500000000 * (10 ** uint256(decimals));

  /**
   * @dev Constructor that gives msg.sender all of existing tokens.
   */
  function JustHiveToken() public {
    totalSupply_ = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
    Transfer(0x0, msg.sender, INITIAL_SUPPLY);
  }

}
