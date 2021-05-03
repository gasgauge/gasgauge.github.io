/*
  Copyright 2020 Swap Holdings Ltd.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/
pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;





/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


/**
 * @title Index: A List of Locators
 * @notice The Locators are sorted in reverse order based on the score
 * meaning that the first element in the list has the largest score
 * and final element has the smallest
 * @dev A mapping is used to mimic a circular linked list structure
 * where every mapping Entry contains a pointer to the next
 * and the previous
 */
contract Index is Ownable {
  /**
   * @notice Index Entry
   * @param score uint256
   * @param locator bytes32
   * @param prev address Previous address in the linked list
   * @param next address Next address in the linked list
   */
  struct Entry {
    bytes32 locator;
    uint256 score;
    address prev;
    address next;
  }

  // The number of entries in the index
  uint256 public length;

  // Identifier to use for the head of the list
  address internal constant HEAD = address(uint160(2**160 - 1));

  // Mapping of an identifier to its entry
  mapping(address => Entry) public entries;

  /**
   * @notice Contract Events
   */
  event SetLocator(
    address indexed identifier,
    uint256 score,
    bytes32 indexed locator
  );

  event UnsetLocator(address indexed identifier);

  /**
   * @notice Contract Constructor
   */
  constructor() public {
    // Create initial entry.
    entries[HEAD] = Entry(bytes32(0), 0, HEAD, HEAD);
  }

  /**
   * @notice Set a Locator
   * @param identifier address On-chain address identifying the owner of a locator
   * @param score uint256 Score for the locator being set
   * @param locator bytes32 Locator
   */
  function setLocator(
    address identifier,
    uint256 score,
    bytes32 locator
  ) external onlyOwner {
    // Ensure the entry does not already exist.
    require(!_hasEntry(identifier), "ENTRY_ALREADY_EXISTS");

    _setLocator(identifier, score, locator);

    // Increment the index length.
    length = length + 1;
    emit SetLocator(identifier, score, locator);
  }

  /**
   * @notice Unset a Locator
   * @param identifier address On-chain address identifying the owner of a locator
   */
  function unsetLocator(address identifier) external onlyOwner {
    _unsetLocator(identifier);

    // Decrement the index length.
    length = length - 1;
    emit UnsetLocator(identifier);
  }

  /**
   * @notice Update a Locator
   * @dev score and/or locator do not need to be different from old values
   * @param identifier address On-chain address identifying the owner of a locator
   * @param score uint256 Score for the locator being set
   * @param locator bytes32 Locator
   */
  function updateLocator(
    address identifier,
    uint256 score,
    bytes32 locator
  ) external onlyOwner {
    // Don't need to update length as it is not used in set/unset logic
    _unsetLocator(identifier);
    _setLocator(identifier, score, locator);

    emit SetLocator(identifier, score, locator);
  }

  /**
   * @notice Get a Score
   * @param identifier address On-chain address identifying the owner of a locator
   * @return uint256 Score corresponding to the identifier
   */
  function getScore(address identifier) external view returns (uint256) {
    return entries[identifier].score;
  }

  /**
   * @notice Get a Locator
   * @param identifier address On-chain address identifying the owner of a locator
   * @return bytes32 Locator information
   */
  function getLocator(address identifier) external view returns (bytes32) {
    return entries[identifier].locator;
  }

  /**
   * @notice Get a Range of Locators
   * @dev start value of 0x0 starts at the head
   * @param cursor address Cursor to start with
   * @param limit uint256 Maximum number of locators to return
   * @return bytes32[] List of locators
   * @return uint256[] List of scores corresponding to locators
   * @return address The next cursor to provide for pagination
   */
  function getLocators(address cursor, uint256 limit)
    external
    view
    returns (
      bytes32[] memory locators,
      uint256[] memory scores,
      address nextCursor
    )
  {
    address identifier;

    // If a valid cursor is provided, start there.
    if (cursor != address(0) && cursor != HEAD) {
      // Check that the provided cursor exists.
      if (!_hasEntry(cursor)) {
	  //Editted by Gas Gauge
        //return (new bytes32[](0), new uint256[](0), address(0));
      }
      // Set the starting identifier to the provided cursor.
      identifier = cursor;
    } else {
      identifier = entries[HEAD].next;
    }

    // Although it's not known how many entries are between `cursor` and the end
    // We know that it is no more than `length`
    uint256 size =  limit;
	//Editted by Gas Gauge
	//(length < limit) ? length : limit;

    locators = new bytes32[](size);
    scores = new uint256[](size);

    // Iterate over the list until the end or size.
    uint256 i;
    while (i < size && identifier != HEAD) {
      locators[i] = entries[identifier].locator;
      scores[i] = entries[identifier].score;
      i = i + 1;
      identifier = entries[identifier].next;
    }

    return (locators, scores, identifier);
  }

  /**
   * @notice Internal function to set a Locator
   * @param identifier address On-chain address identifying the owner of a locator
   * @param score uint256 Score for the locator being set
   * @param locator bytes32 Locator
   */
  function _setLocator(
    address identifier,
    uint256 score,
    bytes32 locator
  ) internal {
    // Disallow locator set to 0x0 to ensure list integrity.
    require(locator != bytes32(0), "LOCATOR_MUST_BE_SENT");

    // Find the first entry with a lower score.
    address nextEntry = _getEntryLowerThan(score);

    // Link the new entry between previous and next.
    address prevEntry = entries[nextEntry].prev;
    entries[prevEntry].next = identifier;
    entries[nextEntry].prev = identifier;
    entries[identifier] = Entry(locator, score, prevEntry, nextEntry);
  }

  /**
   * @notice Internal function to unset a Locator
   * @param identifier address On-chain address identifying the owner of a locator
   */
  function _unsetLocator(address identifier) internal {
    // Ensure the entry exists.
    require(_hasEntry(identifier), "ENTRY_DOES_NOT_EXIST");

    // Link the previous and next entries together.
    address prevUser = entries[identifier].prev;
    address nextUser = entries[identifier].next;
    entries[prevUser].next = nextUser;
    entries[nextUser].prev = prevUser;

    // Delete entry from the index.
    delete entries[identifier];
  }

  /**
   * @notice Check if the Index has an Entry
   * @param identifier address On-chain address identifying the owner of a locator
   * @return bool True if the identifier corresponds to an Entry in the list
   */
  function _hasEntry(address identifier) internal view returns (bool) {
    return entries[identifier].locator != bytes32(0);
  }

  /**
   * @notice Returns the largest scoring Entry Lower than a Score
   * @param score uint256 Score in question
   * @return address Identifier of the largest score lower than score
   */
  function _getEntryLowerThan(uint256 score) internal view returns (address) {
    address identifier = entries[HEAD].next;

    // Head indicates last because the list is circular.
    if (score == 0) {
      return HEAD;
    }

    // Iterate until a lower score is found.
    while (score <= entries[identifier].score) {
      identifier = entries[identifier].next;
    }
    return identifier;
  }
}



