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



/**
 * @title ITransferHandler: interface for token transfers
 */
interface ITransferHandler {
  /**
   * @notice Function to wrap token transfer for different token types
   * @param from address Wallet address to transfer from
   * @param to address Wallet address to transfer to
   * @param amount uint256 Amount for ERC-20
   * @param id token ID for ERC-721
   * @param token address Contract address of token
   * @return bool on success of the token transfer
   */
  function transferTokens(
    address from,
    address to,
    uint256 amount,
    uint256 id,
    address token
  ) external returns (bool);
}

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




/**
 * @title Types: Library of Swap Protocol Types and Hashes
 */
library Types {
  struct Order {
    uint256 nonce; // Unique per order and should be sequential
    uint256 expiry; // Expiry in seconds since 1 January 1970
    Party signer; // Party to the trade that sets terms
    Party sender; // Party to the trade that accepts terms
    Party affiliate; // Party compensated for facilitating (optional)
    Signature signature; // Signature of the order
  }

  struct Party {
    bytes4 kind; // Interface ID of the token
    address wallet; // Wallet address of the party
    address token; // Contract address of the token
    uint256 amount; // Amount for ERC-20 or ERC-1155
    uint256 id; // ID for ERC-721 or ERC-1155
  }

  struct Signature {
    address signatory; // Address of the wallet used to sign
    address validator; // Address of the intended swap contract
    bytes1 version; // EIP-191 signature version
    uint8 v; // `v` value of an ECDSA signature
    bytes32 r; // `r` value of an ECDSA signature
    bytes32 s; // `s` value of an ECDSA signature
  }

  bytes internal constant EIP191_HEADER = "\x19\x01";

  bytes32 internal constant DOMAIN_TYPEHASH =
    keccak256(
      abi.encodePacked(
        "EIP712Domain(",
        "string name,",
        "string version,",
        "address verifyingContract",
        ")"
      )
    );

  bytes32 internal constant ORDER_TYPEHASH =
    keccak256(
      abi.encodePacked(
        "Order(",
        "uint256 nonce,",
        "uint256 expiry,",
        "Party signer,",
        "Party sender,",
        "Party affiliate",
        ")",
        "Party(",
        "bytes4 kind,",
        "address wallet,",
        "address token,",
        "uint256 amount,",
        "uint256 id",
        ")"
      )
    );

  bytes32 internal constant PARTY_TYPEHASH =
    keccak256(
      abi.encodePacked(
        "Party(",
        "bytes4 kind,",
        "address wallet,",
        "address token,",
        "uint256 amount,",
        "uint256 id",
        ")"
      )
    );

  /**
   * @notice Hash an order into bytes32
   * @dev EIP-191 header and domain separator included
   * @param order Order The order to be hashed
   * @param domainSeparator bytes32
   * @return bytes32 A keccak256 abi.encodePacked value
   */
  function hashOrder(Order calldata order, bytes32 domainSeparator)
    external
    pure
    returns (bytes32)
  {
    return
      keccak256(
        abi.encodePacked(
          EIP191_HEADER,
          domainSeparator,
          keccak256(
            abi.encode(
              ORDER_TYPEHASH,
              order.nonce,
              order.expiry,
              keccak256(
                abi.encode(
                  PARTY_TYPEHASH,
                  order.signer.kind,
                  order.signer.wallet,
                  order.signer.token,
                  order.signer.amount,
                  order.signer.id
                )
              ),
              keccak256(
                abi.encode(
                  PARTY_TYPEHASH,
                  order.sender.kind,
                  order.sender.wallet,
                  order.sender.token,
                  order.sender.amount,
                  order.sender.id
                )
              ),
              keccak256(
                abi.encode(
                  PARTY_TYPEHASH,
                  order.affiliate.kind,
                  order.affiliate.wallet,
                  order.affiliate.token,
                  order.affiliate.amount,
                  order.affiliate.id
                )
              )
            )
          )
        )
      );
  }

  /**
   * @notice Hash domain parameters into bytes32
   * @dev Used for signature validation (EIP-712)
   * @param name bytes
   * @param version bytes
   * @param verifyingContract address
   * @return bytes32 returns a keccak256 abi.encodePacked value
   */
  function hashDomain(
    bytes calldata name,
    bytes calldata version,
    address verifyingContract
  ) external pure returns (bytes32) {
    return
      keccak256(
        abi.encode(
          DOMAIN_TYPEHASH,
          keccak256(name),
          keccak256(version),
          verifyingContract
        )
      );
  }
}

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
 * @title TransferHandlerRegistry: holds registry of contract to
 * facilitate token transfers
 */
contract TransferHandlerRegistry is Ownable {
  // Mapping of bytes4 to contract interface type
  mapping(bytes4 => ITransferHandler) public transferHandlers;

  /**
   * @notice Contract Events
   */
  event AddTransferHandler(bytes4 kind, address contractAddress);

  /**
   * @notice Adds handler to mapping
   * @param kind bytes4 Key value that defines a token type
   * @param transferHandler ITransferHandler
   */
  function addTransferHandler(bytes4 kind, ITransferHandler transferHandler)
    external
    onlyOwner
  {
    require(
      address(transferHandlers[kind]) == address(0),
      "HANDLER_EXISTS_FOR_KIND"
    );
    transferHandlers[kind] = transferHandler;
    emit AddTransferHandler(kind, address(transferHandler));
  }
}


interface ISwap {
  event Swap(
    uint256 indexed nonce,
    uint256 timestamp,
    address indexed signerWallet,
    uint256 signerAmount,
    uint256 signerId,
    address signerToken,
    address indexed senderWallet,
    uint256 senderAmount,
    uint256 senderId,
    address senderToken,
    address affiliateWallet,
    uint256 affiliateAmount,
    uint256 affiliateId,
    address affiliateToken
  );

  event Cancel(uint256 indexed nonce, address indexed signerWallet);

  event CancelUpTo(uint256 indexed nonce, address indexed signerWallet);

  event AuthorizeSender(
    address indexed authorizerAddress,
    address indexed authorizedSender
  );

  event AuthorizeSigner(
    address indexed authorizerAddress,
    address indexed authorizedSigner
  );

  event RevokeSender(
    address indexed authorizerAddress,
    address indexed revokedSender
  );

  event RevokeSigner(
    address indexed authorizerAddress,
    address indexed revokedSigner
  );

  /**
   * @notice Atomic Token Swap
   * @param order Types.Order
   */
  function swap(Types.Order calldata order) external;

  /**
   * @notice Cancel one or more open orders by nonce
   * @param nonces uint256[]
   */
  function cancel(uint256[] calldata nonces) external;

  /**
   * @notice Cancels all orders below a nonce value
   * @dev These orders can be made active by reducing the minimum nonce
   * @param minimumNonce uint256
   */
  function cancelUpTo(uint256 minimumNonce) external;

  /**
   * @notice Authorize a delegated sender
   * @param authorizedSender address
   */
  function authorizeSender(address authorizedSender) external;

  /**
   * @notice Authorize a delegated signer
   * @param authorizedSigner address
   */
  function authorizeSigner(address authorizedSigner) external;

  /**
   * @notice Revoke an authorization
   * @param authorizedSender address
   */
  function revokeSender(address authorizedSender) external;

  /**
   * @notice Revoke an authorization
   * @param authorizedSigner address
   */
  function revokeSigner(address authorizedSigner) external;

  function senderAuthorizations(address, address) external view returns (bool);

  function signerAuthorizations(address, address) external view returns (bool);

  function signerNonceStatus(address, uint256) external view returns (bytes1);

  function signerMinimumNonce(address) external view returns (uint256);

  function registry() external view returns (TransferHandlerRegistry);
}


/**
 * @title Swap: The Atomic Swap used on the AirSwap Network
 */
contract Swap is ISwap {
  // Domain and version for use in signatures (EIP-712)
  bytes internal constant DOMAIN_NAME = "SWAP";
  bytes internal constant DOMAIN_VERSION = "2";

  // Unique domain identifier for use in signatures (EIP-712)
  bytes32 private _domainSeparator;

  // Possible nonce statuses
  bytes1 internal constant AVAILABLE = 0x00;
  bytes1 internal constant UNAVAILABLE = 0x01;

  // Mapping of sender address to a delegated sender address and bool
  mapping(address => mapping(address => bool)) public senderAuthorizations;

  // Mapping of signer address to a delegated signer and bool
  mapping(address => mapping(address => bool)) public signerAuthorizations;

  // Mapping of signers to nonces with value AVAILABLE (0x00) or UNAVAILABLE (0x01)
  mapping(address => mapping(uint256 => bytes1)) public signerNonceStatus;

  // Mapping of signer addresses to an optionally set minimum valid nonce
  mapping(address => uint256) public signerMinimumNonce;

  // A registry storing a transfer handler for different token kinds
  TransferHandlerRegistry public registry;

  /**
   * @notice Contract Constructor
   * @dev Sets domain for signature validation (EIP-712)
   * @param swapRegistry TransferHandlerRegistry
   */
  constructor(TransferHandlerRegistry swapRegistry) public {
    _domainSeparator = Types.hashDomain(
      DOMAIN_NAME,
      DOMAIN_VERSION,
      address(this)
    );
    registry = swapRegistry;
  }

  /**
   * @notice Atomic Token Swap
   * @param order Types.Order Order to settle
   */
  function swap(Types.Order calldata order) external {
    // Ensure the order is not expired.
    require(order.expiry > block.timestamp, "ORDER_EXPIRED");

    // Ensure the nonce is AVAILABLE (0x00).
    require(
      signerNonceStatus[order.signer.wallet][order.nonce] == AVAILABLE,
      "ORDER_TAKEN_OR_CANCELLED"
    );

    // Ensure the order nonce is above the minimum.
    require(
      order.nonce >= signerMinimumNonce[order.signer.wallet],
      "NONCE_TOO_LOW"
    );

    // Mark the nonce UNAVAILABLE (0x01).
    signerNonceStatus[order.signer.wallet][order.nonce] = UNAVAILABLE;

    // Validate the sender side of the trade.
    address finalSenderWallet;

    if (order.sender.wallet == address(0)) {
      /**
       * Sender is not specified. The msg.sender of the transaction becomes
       * the sender of the order.
       */
      finalSenderWallet = msg.sender;
    } else {
      /**
       * Sender is specified. If the msg.sender is not the specified sender,
       * this determines whether the msg.sender is an authorized sender.
       */
      require(
        isSenderAuthorized(order.sender.wallet, msg.sender),
        "SENDER_UNAUTHORIZED"
      );
      // The msg.sender is authorized.
      finalSenderWallet = order.sender.wallet;
    }

    // Validate the signer side of the trade.
    if (order.signature.v == 0) {
      /**
       * Signature is not provided. The signer may have authorized the
       * msg.sender to swap on its behalf, which does not require a signature.
       */
      require(
        isSignerAuthorized(order.signer.wallet, msg.sender),
        "SIGNER_UNAUTHORIZED"
      );
    } else {
      /**
       * The signature is provided. Determine whether the signer is
       * authorized and if so validate the signature itself.
       */
      require(
        isSignerAuthorized(order.signer.wallet, order.signature.signatory),
        "SIGNER_UNAUTHORIZED"
      );

      // Ensure the signature is valid.
      require(isValid(order, _domainSeparator), "SIGNATURE_INVALID");
    }
    // Transfer token from sender to signer.
    transferToken(
      finalSenderWallet,
      order.signer.wallet,
      order.sender.amount,
      order.sender.id,
      order.sender.token,
      order.sender.kind
    );

    // Transfer token from signer to sender.
    transferToken(
      order.signer.wallet,
      finalSenderWallet,
      order.signer.amount,
      order.signer.id,
      order.signer.token,
      order.signer.kind
    );

    // Transfer token from signer to affiliate if specified.
    if (order.affiliate.token != address(0)) {
      transferToken(
        order.signer.wallet,
        order.affiliate.wallet,
        order.affiliate.amount,
        order.affiliate.id,
        order.affiliate.token,
        order.affiliate.kind
      );
    }

    emit Swap(
      order.nonce,
      block.timestamp,
      order.signer.wallet,
      order.signer.amount,
      order.signer.id,
      order.signer.token,
      finalSenderWallet,
      order.sender.amount,
      order.sender.id,
      order.sender.token,
      order.affiliate.wallet,
      order.affiliate.amount,
      order.affiliate.id,
      order.affiliate.token
    );
  }

  /**
   * @notice Cancel one or more open orders by nonce
   * @dev Cancelled nonces are marked UNAVAILABLE (0x01)
   * @dev Emits a Cancel event
   * @dev Out of gas may occur in arrays of length > 400
   * @param nonces uint256[] List of nonces to cancel
   */
  function cancel(uint256[] calldata nonces) external {
    for (uint256 i = 0; i < nonces.length; i++) {
      if (signerNonceStatus[msg.sender][nonces[i]] == AVAILABLE) {
        signerNonceStatus[msg.sender][nonces[i]] = UNAVAILABLE;
        emit Cancel(nonces[i], msg.sender);
      }
    }
  }

  /**
   * @notice Cancels all orders below a nonce value
   * @dev Emits a CancelUpTo event
   * @param minimumNonce uint256 Minimum valid nonce
   */
  function cancelUpTo(uint256 minimumNonce) external {
    signerMinimumNonce[msg.sender] = minimumNonce;
    emit CancelUpTo(minimumNonce, msg.sender);
  }

  /**
   * @notice Authorize a delegated sender
   * @dev Emits an AuthorizeSender event
   * @param authorizedSender address Address to authorize
   */
  function authorizeSender(address authorizedSender) external {
    require(msg.sender != authorizedSender, "SELF_AUTH_INVALID");
    if (!senderAuthorizations[msg.sender][authorizedSender]) {
      senderAuthorizations[msg.sender][authorizedSender] = true;
      emit AuthorizeSender(msg.sender, authorizedSender);
    }
  }

  /**
   * @notice Authorize a delegated signer
   * @dev Emits an AuthorizeSigner event
   * @param authorizedSigner address Address to authorize
   */
  function authorizeSigner(address authorizedSigner) external {
    require(msg.sender != authorizedSigner, "SELF_AUTH_INVALID");
    if (!signerAuthorizations[msg.sender][authorizedSigner]) {
      signerAuthorizations[msg.sender][authorizedSigner] = true;
      emit AuthorizeSigner(msg.sender, authorizedSigner);
    }
  }

  /**
   * @notice Revoke an authorized sender
   * @dev Emits a RevokeSender event
   * @param authorizedSender address Address to revoke
   */
  function revokeSender(address authorizedSender) external {
    if (senderAuthorizations[msg.sender][authorizedSender]) {
      delete senderAuthorizations[msg.sender][authorizedSender];
      emit RevokeSender(msg.sender, authorizedSender);
    }
  }

  /**
   * @notice Revoke an authorized signer
   * @dev Emits a RevokeSigner event
   * @param authorizedSigner address Address to revoke
   */
  function revokeSigner(address authorizedSigner) external {
    if (signerAuthorizations[msg.sender][authorizedSigner]) {
      delete signerAuthorizations[msg.sender][authorizedSigner];
      emit RevokeSigner(msg.sender, authorizedSigner);
    }
  }

  /**
   * @notice Determine whether a sender delegate is authorized
   * @param authorizer address Address doing the authorization
   * @param delegate address Address being authorized
   * @return bool True if a delegate is authorized to send
   */
  function isSenderAuthorized(address authorizer, address delegate)
    internal
    view
    returns (bool)
  {
    return ((authorizer == delegate) ||
      senderAuthorizations[authorizer][delegate]);
  }

  /**
   * @notice Determine whether a signer delegate is authorized
   * @param authorizer address Address doing the authorization
   * @param delegate address Address being authorized
   * @return bool True if a delegate is authorized to sign
   */
  function isSignerAuthorized(address authorizer, address delegate)
    internal
    view
    returns (bool)
  {
    return ((authorizer == delegate) ||
      signerAuthorizations[authorizer][delegate]);
  }

  /**
   * @notice Validate signature using an EIP-712 typed data hash
   * @param order Types.Order Order to validate
   * @param domainSeparator bytes32 Domain identifier used in signatures (EIP-712)
   * @return bool True if order has a valid signature
   */
  function isValid(Types.Order memory order, bytes32 domainSeparator)
    internal
    pure
    returns (bool)
  {
    if (order.signature.version == bytes1(0x01)) {
      return
        order.signature.signatory ==
        ecrecover(
          Types.hashOrder(order, domainSeparator),
          order.signature.v,
          order.signature.r,
          order.signature.s
        );
    }
    if (order.signature.version == bytes1(0x45)) {
      return
        order.signature.signatory ==
        ecrecover(
          keccak256(
            abi.encodePacked(
              "\x19Ethereum Signed Message:\n32",
              Types.hashOrder(order, domainSeparator)
            )
          ),
          order.signature.v,
          order.signature.r,
          order.signature.s
        );
    }
    return false;
  }

  /**
   * @notice Perform token transfer for tokens in registry
   * @dev Transfer type specified by the bytes4 kind param
   * @dev ERC721: uses transferFrom for transfer
   * @dev ERC20: Takes into account non-standard ERC-20 tokens.
   * @param from address Wallet address to transfer from
   * @param to address Wallet address to transfer to
   * @param amount uint256 Amount for ERC-20
   * @param id token ID for ERC-721
   * @param token address Contract address of token
   * @param kind bytes4 EIP-165 interface ID of the token
   */
  function transferToken(
    address from,
    address to,
    uint256 amount,
    uint256 id,
    address token,
    bytes4 kind
  ) internal {
    // Ensure the transfer is not to self.
    require(from != to, "SELF_TRANSFER_INVALID");
    ITransferHandler transferHandler = registry.transferHandlers(kind);
    require(address(transferHandler) != address(0), "TOKEN_KIND_UNKNOWN");
    // delegatecall required to pass msg.sender as Swap contract to handle the
    // token transfer in the calling contract
    (bool success, bytes memory data) =
      address(transferHandler).delegatecall(
        abi.encodeWithSelector(
          transferHandler.transferTokens.selector,
          from,
          to,
          amount,
          id,
          token
        )
      );
    require(success && abi.decode(data, (bool)), "TRANSFER_FAILED");
  }
}



