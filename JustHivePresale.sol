pragma solidity ^0.4.18;

import "./RefundableSoftCapCrowdsale.sol";
import "zeppelin-solidity/contracts/crowdsale/emission/AllowanceCrowdsale.sol";
import "./IndividuallyCappedCrowdsale.sol";
import "./JustHiveToken.sol";

/**
 * @title JustHivePresale
 */
contract JustHivePresale is AllowanceCrowdsale, IndividuallyCappedCrowdsale, RefundableSoftCapCrowdsale  {

  address public opsAddress;
  mapping (address => uint8) public whitelist;
  uint256 public individualCap;

  /**
   * @dev Called if opsAddress changes
   */
  event OpsAddressChanged(address indexed _newAddress);

  /**
   * @dev Called if the whitelist is updated
   */
  event WhitelistUpdated(address indexed _account, uint8 _phase);
  
  /**
   * @dev Reverts if msg.sender is not opsAddress
   */
  modifier onlyOps {
    require(msg.sender == opsAddress);
    _;
  }

  /**
   * @dev Reverts if _beneficiary is not whitelisted with a phase greater than 0
   */
  modifier isWhitelisted(address _beneficiary) {
    require(whitelist[_beneficiary] > 0);
    _;
  }

  /**
   * @dev Contructor
   * @param _openingTime Time that the sale starts
   * @param _closingTime Time that the sale ends
   * @param _rate Number of tokens per wei
   * @param _wallet Wallet that will receive invested Ether once _goal is reached
   * @param _token Token to be distributed
   * @param _goal Soft cap
   * @param _tokenWallet Wallet with an allowance to distribute tokens
   */
  function JustHivePresale(uint256 _openingTime, uint256 _closingTime, uint256 _rate, address _wallet, JustHiveToken _token, uint256 _goal, address _tokenWallet, uint256 _individualCap) public
    Crowdsale(_rate, _wallet, _token)
    AllowanceCrowdsale(_tokenWallet)
    TimedCrowdsale(_openingTime, _closingTime)
    RefundableSoftCapCrowdsale(_goal)
  {
    individualCap = _individualCap;
  }

  /**
   * @dev Sets a specific user's maximum contribution.
   * @param _beneficiary Address to be capped
   * @param _cap Wei limit for individual contribution
   */
  function setUserCap(address _beneficiary, uint256 _cap) internal {
    caps[_beneficiary] = _cap;
  }

  /**
   * @dev Sets the operation address
   * @param _opsAddress Address of the operator that will be authorized to add
   *        addresses to the whitelist
   */
  function setOpsAddress(address _opsAddress) external onlyOwner returns (bool) {
    require(_opsAddress != address(0));
    require(_opsAddress != owner);

    opsAddress = _opsAddress; 

    OpsAddressChanged(_opsAddress);

    return true;
  }

  /**
   * @dev Adds a beneficiary to the whitelist
   * @param _beneficiary Address of the whitelisted individual
   * @param _phase Phase of the crowdsale that the individual was whitelisted
   */
  function updateWhitelist(address _beneficiary, uint8 _phase) external onlyOps returns (bool) {
    require(!hasClosed());
    require(_beneficiary != address(0));

    whitelist[_beneficiary] = _phase;

    setUserCap(_beneficiary, individualCap);

    WhitelistUpdated(_beneficiary, _phase);

    return true;
  }

  /**
   * @dev Extends parent behavior by requiring beneficiary to be whitelisted
   * @param _beneficiary Token recipient
   * @param _weiAmount Amount of wei sent to the contract
   */
  function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal isWhitelisted(_beneficiary) {
    super._preValidatePurchase(_beneficiary, _weiAmount);
  }
}
