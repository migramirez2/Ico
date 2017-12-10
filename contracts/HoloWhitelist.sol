pragma solidity ^0.4.15;
import "zeppelin-solidity/contracts/ownership/Ownable.sol";

// This contract holds a mapping of known funders with:
// * a boolean flag for whitelist status
// * number of reserved tokens for each day
contract HoloWhitelist is Ownable {
  address public updater;

  struct KnownFunder {
    bool whitelisted;
    mapping(uint => uint256) reservedTokensPerDay;
  }

  mapping(address => KnownFunder) knownFunders;

  modifier onlyUpdater {
    require(msg.sender == updater);
    _;
  }

  function HoloWhitelist() {
    updater = tx.origin;
  }

  function setUpdater(address new_updater) onlyOwner {
    updater = new_updater;
  }

  // Adds funders to the whitelist in batches.
  function whitelist(address[] funders) onlyUpdater {
    for (uint i = 0; i < funders.length; i++) {
        knownFunders[funders[i]].whitelisted = true;
    }
  }

  // Removes funders from the whitelist in batches.
  function unwhitelist(address[] funders) onlyUpdater {
    for (uint i = 0; i < funders.length; i++) {
        knownFunders[funders[i]].whitelisted = false;
    }
  }

  // Stores reserved tokens for several funders in a batch
  // but all for the same day.
  // * day is 0-based
  function setReservedTokens(uint day, address[] funders, uint256[] reservedTokens) onlyUpdater {
    for (uint i = 0; i < funders.length; i++) {
        knownFunders[funders[i]].reservedTokensPerDay[day] = reservedTokens[i];
    }
  }

  // Used in HoloSale to check if funder is allowed
  function isWhitelisted(address funder) returns (bool) {
    return knownFunders[funder].whitelisted;
  }

  // Used in HoloSale to get reserved tokens per funder
  // and per day.
  // * day is 0-based
  function reservedTokens(address funder, uint day) returns (uint256) {
    return knownFunders[funder].reservedTokensPerDay[day];
  }


}
