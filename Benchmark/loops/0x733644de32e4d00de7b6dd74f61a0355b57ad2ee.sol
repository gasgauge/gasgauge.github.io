/**

 *Submitted for verification at Etherscan.io on 2019-09-27

*/



//pragma solidity ^0.5.8;
pragma solidity >=0.5 <0.7.17;



contract IERC1271 {

  function isValidSignature(

    bytes memory _messageHash,

    bytes memory _signature)

    public

    view

    returns (bytes4 magicValue);

}



/**

 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.

 *

 * These functions can be used to verify that a message was signed by the holder

 * of the private keys of a given address.

 */

library ECDSA {

    /**

     * @dev Returns the address that signed a hashed message (`hash`) with

     * `signature`. This address can then be used for verification purposes.

     *

     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:

     * this function rejects them by requiring the `s` value to be in the lower

     * half order, and the `v` value to be either 27 or 28.

     *

     * (.note) This call _does not revert_ if the signature is invalid, or

     * if the signer is otherwise unable to be retrieved. In those scenarios,

     * the zero address is returned.

     *

     * (.warning) `hash` _must_ be the result of a hash operation for the

     * verification to be secure: it is possible to craft signatures that

     * recover to arbitrary addresses for non-hashed data. A safe way to ensure

     * this is by receiving a hash of the original message (which may otherwise)

     * be too long), and then calling `toEthSignedMessageHash` on it.

     */

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        // Check the signature length

        if (signature.length != 65) {

            return (address(0));

        }



        // Divide the signature in r, s and v variables

        bytes32 r;

        bytes32 s;

        uint8 v;



        // ecrecover takes the signature parameters, and the only way to get them

        // currently is to use assembly.

        // solhint-disable-next-line no-inline-assembly

        assembly {

            r := mload(add(signature, 0x20))

            s := mload(add(signature, 0x40))

            v := byte(0, mload(add(signature, 0x60)))

        }



        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature

        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines

        // the valid range for s in (281): 0 < s < secp256k1n ÷ 2 + 1, and for v in (282): v ∈ {27, 28}. Most

        // signatures from current libraries generate a unique signature with an s-value in the lower half order.

        //

        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value

        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or

        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept

        // these malleable signatures as well.

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {

            return address(0);

        }



        if (v != 27 && v != 28) {

            return address(0);

        }



        // If the signature is valid (and not malleable), return the signer address

        return ecrecover(hash, v, r, s);

    }



    /**

     * @dev Returns an Ethereum Signed Message, created from a `hash`. This

     * replicates the behavior of the

     * [`eth_sign`](https://github.com/ethereum/wiki/wiki/JSON-RPC#eth_sign)

     * JSON-RPC method.

     *

     * See `recover`.

     */

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        // 32 is the length in bytes of hash,

        // enforced by the type signature above

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));

    }

}



/**

 * @dev Wrappers over Solidity's arithmetic operations with added overflow

 * checks.

 *

 * Arithmetic operations in Solidity wrap on overflow. This can easily result

 * in bugs, because programmers usually assume that an overflow raises an

 * error, which is the standard behavior in high level programming languages.

 * `SafeMath` restores this intuition by reverting the transaction when an

 * operation overflows.

 *

 * Using this library instead of the unchecked operations eliminates an entire

 * class of bugs, so it's recommended to use it always.

 */

library SafeMath {

    /**

     * @dev Returns the addition of two unsigned integers, reverting on

     * overflow.

     *

     * Counterpart to Solidity's `+` operator.

     *

     * Requirements:

     * - Addition cannot overflow.

     */

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        require(c >= a, "SafeMath: addition overflow");



        return c;

    }



    /**

     * @dev Returns the subtraction of two unsigned integers, reverting on

     * overflow (when the result is negative).

     *

     * Counterpart to Solidity's `-` operator.

     *

     * Requirements:

     * - Subtraction cannot overflow.

     */

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");

        uint256 c = a - b;



        return c;

    }



    /**

     * @dev Returns the multiplication of two unsigned integers, reverting on

     * overflow.

     *

     * Counterpart to Solidity's `*` operator.

     *

     * Requirements:

     * - Multiplication cannot overflow.

     */

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the

        // benefit is lost if 'b' is also tested.

        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

        if (a == 0) {

            return 0;

        }



        uint256 c = a * b;

        require(c / a == b, "SafeMath: multiplication overflow");



        return c;

    }



    /**

     * @dev Returns the integer division of two unsigned integers. Reverts on

     * division by zero. The result is rounded towards zero.

     *

     * Counterpart to Solidity's `/` operator. Note: this function uses a

     * `revert` opcode (which leaves remaining gas untouched) while Solidity

     * uses an invalid opcode to revert (consuming all remaining gas).

     *

     * Requirements:

     * - The divisor cannot be zero.

     */

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        // Solidity only automatically asserts when dividing by 0

        require(b > 0, "SafeMath: division by zero");

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold



        return c;

    }



    /**

     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),

     * Reverts when dividing by zero.

     *

     * Counterpart to Solidity's `%` operator. This function uses a `revert`

     * opcode (which leaves remaining gas untouched) while Solidity uses an

     * invalid opcode to revert (consuming all remaining gas).

     *

     * Requirements:

     * - The divisor cannot be zero.

     */

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: modulo by zero");

        return a % b;

    }

}



/**

 * @title Initializable

 *

 * @dev Helper contract to support initializer functions. To use it, replace

 * the constructor with a function that has the `initializer` modifier.

 * WARNING: Unlike constructors, initializer functions must be manually

 * invoked. This applies both to deploying an Initializable contract, as well

 * as extending an Initializable contract via inheritance.

 * WARNING: When used with inheritance, manual care must be taken to not invoke

 * a parent initializer twice, or ensure that all initializers are idempotent,

 * because this is not dealt with automatically as with constructors.

 */

contract Initializable {



  /**

   * @dev Indicates that the contract has been initialized.

   */

  bool private initialized;



  /**

   * @dev Indicates that the contract is in the process of being initialized.

   */

  bool private initializing;



  /**

   * @dev Modifier to use in the initializer function of a contract.

   */

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");



    bool isTopLevelCall = !initializing;

    if (isTopLevelCall) {

      initializing = true;

      initialized = true;

    }



    _;



    if (isTopLevelCall) {

      initializing = false;

    }

  }



  /// @dev Returns true if and only if the function is running in the constructor

  function isConstructor() private view returns (bool) {

    // extcodesize checks the size of the code stored in an address, and

    // address returns the current address. Since the code is still not

    // deployed when running a constructor, any checks on its code size will

    // yield zero, making it an effective way to detect if a contract is

    // under construction or not.

    uint256 cs;

    assembly { cs := extcodesize(address) }

    return cs == 0;

  }



  // Reserved storage space to allow for layout changes in the future.

  uint256[50] private ______gap;

}



library BytesLib {

    function concat(

        bytes memory _preBytes,

        bytes memory _postBytes

    )

        internal

        pure

        returns (bytes memory)

    {

        bytes memory tempBytes;



        assembly {

            // Get a location of some free memory and store it in tempBytes as

            // Solidity does for memory variables.

            tempBytes := mload(0x40)



            // Store the length of the first bytes array at the beginning of

            // the memory for tempBytes.

            let length := mload(_preBytes)

            mstore(tempBytes, length)



            // Maintain a memory counter for the current write location in the

            // temp bytes array by adding the 32 bytes for the array length to

            // the starting location.

            let mc := add(tempBytes, 0x20)

            // Stop copying when the memory counter reaches the length of the

            // first bytes array.

            let end := add(mc, length)



            for {

                // Initialize a copy counter to the start of the _preBytes data,

                // 32 bytes into its memory.

                let cc := add(_preBytes, 0x20)

            } lt(mc, end) {

                // Increase both counters by 32 bytes each iteration.

                mc := add(mc, 0x20)

                cc := add(cc, 0x20)

            } {

                // Write the _preBytes data into the tempBytes memory 32 bytes

                // at a time.

                mstore(mc, mload(cc))

            }



            // Add the length of _postBytes to the current length of tempBytes

            // and store it as the new length in the first 32 bytes of the

            // tempBytes memory.

            length := mload(_postBytes)

            mstore(tempBytes, add(length, mload(tempBytes)))



            // Move the memory counter back from a multiple of 0x20 to the

            // actual end of the _preBytes data.

            mc := end

            // Stop copying when the memory counter reaches the new combined

            // length of the arrays.

            end := add(mc, length)



            for {

                let cc := add(_postBytes, 0x20)

            } lt(mc, end) {

                mc := add(mc, 0x20)

                cc := add(cc, 0x20)

            } {

                mstore(mc, mload(cc))

            }



            // Update the free-memory pointer by padding our last write location

            // to 32 bytes: add 31 bytes to the end of tempBytes to move to the

            // next 32 byte block, then round down to the nearest multiple of

            // 32. If the sum of the length of the two arrays is zero then add 

            // one before rounding down to leave a blank 32 bytes (the length block with 0).

            mstore(0x40, and(

              add(add(end, iszero(add(length, mload(_preBytes)))), 31),

              not(31) // Round down to the nearest 32 bytes.

            ))

        }



        return tempBytes;

    }



    function concatStorage(bytes storage _preBytes, bytes memory _postBytes) internal {

        assembly {

            // Read the first 32 bytes of _preBytes storage, which is the length

            // of the array. (We don't need to use the offset into the slot

            // because arrays use the entire slot.)

            let fslot := sload(_preBytes_slot)

            // Arrays of 31 bytes or less have an even value in their slot,

            // while longer arrays have an odd value. The actual length is

            // the slot divided by two for odd values, and the lowest order

            // byte divided by two for even values.

            // If the slot is even, bitwise and the slot with 255 and divide by

            // two to get the length. If the slot is odd, bitwise and the slot

            // with -1 and divide by two.

            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)

            let mlength := mload(_postBytes)

            let newlength := add(slength, mlength)

            // slength can contain both the length and contents of the array

            // if length < 32 bytes so let's prepare for that

            // v. http://solidity.readthedocs.io/en/latest/miscellaneous.html#layout-of-state-variables-in-storage

            switch add(lt(slength, 32), lt(newlength, 32))

            case 2 {

                // Since the new array still fits in the slot, we just need to

                // update the contents of the slot.

                // uint256(bytes_storage) = uint256(bytes_storage) + uint256(bytes_memory) + new_length

                sstore(

                    _preBytes_slot,

                    // all the modifications to the slot are inside this

                    // next block

                    add(

                        // we can just add to the slot contents because the

                        // bytes we want to change are the LSBs

                        fslot,

                        add(

                            mul(

                                div(

                                    // load the bytes from memory

                                    mload(add(_postBytes, 0x20)),

                                    // zero all bytes to the right

                                    exp(0x100, sub(32, mlength))

                                ),

                                // and now shift left the number of bytes to

                                // leave space for the length in the slot

                                exp(0x100, sub(32, newlength))

                            ),

                            // increase length by the double of the memory

                            // bytes length

                            mul(mlength, 2)

                        )

                    )

                )

            }

            case 1 {

                // The stored value fits in the slot, but the combined value

                // will exceed it.

                // get the keccak hash to get the contents of the array

                mstore(0x0, _preBytes_slot)

                let sc := add(keccak256(0x0, 0x20), div(slength, 32))



                // save new length

                sstore(_preBytes_slot, add(mul(newlength, 2), 1))



                // The contents of the _postBytes array start 32 bytes into

                // the structure. Our first read should obtain the `submod`

                // bytes that can fit into the unused space in the last word

                // of the stored array. To get this, we read 32 bytes starting

                // from `submod`, so the data we read overlaps with the array

                // contents by `submod` bytes. Masking the lowest-order

                // `submod` bytes allows us to add that value directly to the

                // stored value.



                let submod := sub(32, slength)

                let mc := add(_postBytes, submod)

                let end := add(_postBytes, mlength)

                let mask := sub(exp(0x100, submod), 1)



                sstore(

                    sc,

                    add(

                        and(

                            fslot,

                            0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00

                        ),

                        and(mload(mc), mask)

                    )

                )



                for {

                    mc := add(mc, 0x20)

                    sc := add(sc, 1)

                } lt(mc, end) {

                    sc := add(sc, 1)

                    mc := add(mc, 0x20)

                } {

                    sstore(sc, mload(mc))

                }



                mask := exp(0x100, sub(mc, end))



                sstore(sc, mul(div(mload(mc), mask), mask))

            }

            default {

                // get the keccak hash to get the contents of the array

                mstore(0x0, _preBytes_slot)

                // Start copying to the last used word of the stored array.

                let sc := add(keccak256(0x0, 0x20), div(slength, 32))



                // save new length

                sstore(_preBytes_slot, add(mul(newlength, 2), 1))



                // Copy over the first `submod` bytes of the new data as in

                // case 1 above.

                let slengthmod := mod(slength, 32)

                let mlengthmod := mod(mlength, 32)

                let submod := sub(32, slengthmod)

                let mc := add(_postBytes, submod)

                let end := add(_postBytes, mlength)

                let mask := sub(exp(0x100, submod), 1)



                sstore(sc, add(sload(sc), and(mload(mc), mask)))

                

                for { 

                    sc := add(sc, 1)

                    mc := add(mc, 0x20)

                } lt(mc, end) {

                    sc := add(sc, 1)

                    mc := add(mc, 0x20)

                } {

                    sstore(sc, mload(mc))

                }



                mask := exp(0x100, sub(mc, end))



                sstore(sc, mul(div(mload(mc), mask), mask))

            }

        }

    }



    function slice(

        bytes memory _bytes,

        uint _start,

        uint _length

    )

        internal

        pure

        returns (bytes memory)

    {

        require(_bytes.length >= (_start + _length));



        bytes memory tempBytes;



        assembly {

            switch iszero(_length)

            case 0 {

                // Get a location of some free memory and store it in tempBytes as

                // Solidity does for memory variables.

                tempBytes := mload(0x40)



                // The first word of the slice result is potentially a partial

                // word read from the original array. To read it, we calculate

                // the length of that partial word and start copying that many

                // bytes into the array. The first word we copy will start with

                // data we don't care about, but the last `lengthmod` bytes will

                // land at the beginning of the contents of the new array. When

                // we're done copying, we overwrite the full first word with

                // the actual length of the slice.

                let lengthmod := and(_length, 31)



                // The multiplication in the next line is necessary

                // because when slicing multiples of 32 bytes (lengthmod == 0)

                // the following copy loop was copying the origin's length

                // and then ending prematurely not copying everything it should.

                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))

                let end := add(mc, _length)



                for {

                    // The multiplication in the next line has the same exact purpose

                    // as the one above.

                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)

                } lt(mc, end) {

                    mc := add(mc, 0x20)

                    cc := add(cc, 0x20)

                } {

                    mstore(mc, mload(cc))

                }



                mstore(tempBytes, _length)



                //update free-memory pointer

                //allocating the array padded to 32 bytes like the compiler does now

                mstore(0x40, and(add(mc, 31), not(31)))

            }

            //if we want a zero-length slice let's just return a zero-length array

            default {

                tempBytes := mload(0x40)



                mstore(0x40, add(tempBytes, 0x20))

            }

        }



        return tempBytes;

    }



    function toAddress(bytes memory _bytes, uint _start) internal  pure returns (address) {

        require(_bytes.length >= (_start + 20));

        address tempAddress;



        assembly {

            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)

        }



        return tempAddress;

    }



    function toUint8(bytes memory _bytes, uint _start) internal  pure returns (uint8) {

        require(_bytes.length >= (_start + 1));

        uint8 tempUint;



        assembly {

            tempUint := mload(add(add(_bytes, 0x1), _start))

        }



        return tempUint;

    }



    function toUint16(bytes memory _bytes, uint _start) internal  pure returns (uint16) {

        require(_bytes.length >= (_start + 2));

        uint16 tempUint;



        assembly {

            tempUint := mload(add(add(_bytes, 0x2), _start))

        }



        return tempUint;

    }



    function toUint32(bytes memory _bytes, uint _start) internal  pure returns (uint32) {

        require(_bytes.length >= (_start + 4));

        uint32 tempUint;



        assembly {

            tempUint := mload(add(add(_bytes, 0x4), _start))

        }



        return tempUint;

    }



    function toUint64(bytes memory _bytes, uint _start) internal  pure returns (uint64) {

        require(_bytes.length >= (_start + 8));

        uint64 tempUint;



        assembly {

            tempUint := mload(add(add(_bytes, 0x8), _start))

        }



        return tempUint;

    }



    function toUint96(bytes memory _bytes, uint _start) internal  pure returns (uint96) {

        require(_bytes.length >= (_start + 12));

        uint96 tempUint;



        assembly {

            tempUint := mload(add(add(_bytes, 0xc), _start))

        }



        return tempUint;

    }



    function toUint128(bytes memory _bytes, uint _start) internal  pure returns (uint128) {

        require(_bytes.length >= (_start + 16));

        uint128 tempUint;



        assembly {

            tempUint := mload(add(add(_bytes, 0x10), _start))

        }



        return tempUint;

    }



    function toUint(bytes memory _bytes, uint _start) internal  pure returns (uint256) {

        require(_bytes.length >= (_start + 32));

        uint256 tempUint;



        assembly {

            tempUint := mload(add(add(_bytes, 0x20), _start))

        }



        return tempUint;

    }



    function toBytes32(bytes memory _bytes, uint _start) internal  pure returns (bytes32) {

        require(_bytes.length >= (_start + 32));

        bytes32 tempBytes32;



        assembly {

            tempBytes32 := mload(add(add(_bytes, 0x20), _start))

        }



        return tempBytes32;

    }



    function equal(bytes memory _preBytes, bytes memory _postBytes) internal pure returns (bool) {

        bool success = true;



        assembly {

            let length := mload(_preBytes)



            // if lengths don't match the arrays are not equal

            switch eq(length, mload(_postBytes))

            case 1 {

                // cb is a circuit breaker in the for loop since there's

                //  no said feature for inline assembly loops

                // cb = 1 - don't breaker

                // cb = 0 - break

                let cb := 1



                let mc := add(_preBytes, 0x20)

                let end := add(mc, length)



                for {

                    let cc := add(_postBytes, 0x20)

                // the next line is the loop condition:

                // while(uint(mc < end) + cb == 2)

                } eq(add(lt(mc, end), cb), 2) {

                    mc := add(mc, 0x20)

                    cc := add(cc, 0x20)

                } {

                    // if any of these checks fails then arrays are not equal

                    if iszero(eq(mload(mc), mload(cc))) {

                        // unsuccess:

                        success := 0

                        cb := 0

                    }

                }

            }

            default {

                // unsuccess:

                success := 0

            }

        }



        return success;

    }



    function equalStorage(

        bytes storage _preBytes,

        bytes memory _postBytes

    )

        internal

        view

        returns (bool)

    {

        bool success = true;



        assembly {

            // we know _preBytes_offset is 0

            let fslot := sload(_preBytes_slot)

            // Decode the length of the stored array like in concatStorage().

            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)

            let mlength := mload(_postBytes)



            // if lengths don't match the arrays are not equal

            switch eq(slength, mlength)

            case 1 {

                // slength can contain both the length and contents of the array

                // if length < 32 bytes so let's prepare for that

                // v. http://solidity.readthedocs.io/en/latest/miscellaneous.html#layout-of-state-variables-in-storage

                if iszero(iszero(slength)) {

                    switch lt(slength, 32)

                    case 1 {

                        // blank the last byte which is the length

                        fslot := mul(div(fslot, 0x100), 0x100)



                        if iszero(eq(fslot, mload(add(_postBytes, 0x20)))) {

                            // unsuccess:

                            success := 0

                        }

                    }

                    default {

                        // cb is a circuit breaker in the for loop since there's

                        //  no said feature for inline assembly loops

                        // cb = 1 - don't breaker

                        // cb = 0 - break

                        let cb := 1



                        // get the keccak hash to get the contents of the array

                        mstore(0x0, _preBytes_slot)

                        let sc := keccak256(0x0, 0x20)



                        let mc := add(_postBytes, 0x20)

                        let end := add(mc, mlength)



                        // the next line is the loop condition:

                        // while(uint(mc < end) + cb == 2)

                        for {} eq(add(lt(mc, end), cb), 2) {

                            sc := add(sc, 1)

                            mc := add(mc, 0x20)

                        } {

                            if iszero(eq(sload(sc), mload(mc))) {

                                // unsuccess:

                                success := 0

                                cb := 0

                            }

                        }

                    }

                }

            }

            default {

                // unsuccess:

                success := 0

            }

        }



        return success;

    }

}





contract Account is Initializable, IERC1271 {

    using SafeMath for uint256;

    using ECDSA for bytes32;

    using BytesLib for bytes;



    address[] public authKeysArray;

    mapping(address => uint256) public authKeysArrayIndex;

    mapping(address => bool) public authKeys;

    uint256 public nonce;

    uint256 public CHAIN_ID;



    // bytes4(keccak256("isValidSignature(bytes,bytes)")

    bytes4 constant internal VALID_SIG = 0x20c13b0b;

    bytes4 constant internal INVALID_SIG = 0xffffffff;



    event FundsReceived(address indexed sender, uint256 indexed value);

    event AddedAuthKey(address indexed authKey);

    event RemovedAuthKey(address indexed authKey);

    event SwappedAuthKeys(address indexed oldAuthKey, address indexed newAuthKey);



    // Invalid Sigs

    event InvalidAuthkey();

    event InvalidTransactionDataSigner();

    // Invalid Firewalls

    event OverDailyLimit();

    // Invalid Tx

    event CallFailed(bytes32 encodedData);



    modifier onlyValidAuthKeyOrSelf {

        _validateAuthKey(msg.sender);

        _;

    }



    function initialize() public initializer {

        CHAIN_ID = 1;

    }



    function () external payable {

        emit FundsReceived(msg.sender, msg.value);

    }



    /**

     *  Getters

     */



    /// @dev Return the length of the authKeysArray

    function getAuthKeysArrayLength() public view returns (uint256) {

        return authKeysArray.length;

    }



    /// @dev Get the current nonce of the contract

    function getNonce() public view returns (uint256) {

        return nonce;

    }



    /**

     *  Public functions

     */



    /// @dev Execute a transaction

    /// @notice This is to be called directly by an AuthKey

    /// @param _destination Destination of the transaction

    /// @param _value Value of the transaction

    /// @param _data Data of the transaction

    /// @param _gasLimit Gas limit of the transaction

    function executeTransaction(

        address _destination,

        uint256 _value,

        bytes memory _data,

        uint256 _gasLimit

    )

        public

        onlyValidAuthKeyOrSelf

        returns (bytes memory)

    {

        return _executeTransaction(_destination, _value, _data, _gasLimit);

    }



    /// @dev Add an auth key to the list of auth keys

    /// @param _authKey Address of the auth key to add

    function addAuthKey(address _authKey) public onlyValidAuthKeyOrSelf {

        require(!authKeys[_authKey], "Auth key already added");

        authKeys[_authKey] = true;

        authKeysArray.push(_authKey);

        authKeysArrayIndex[_authKey] = authKeysArray.length - 1;

        emit AddedAuthKey(_authKey);

    }



    /// @dev Add multiple auth keys to the list of auth keys

    /// @param _authKeys Array of addresses to add to the auth keys list

    function addMultipleAuthKeys(address[] memory _authKeys) public onlyValidAuthKeyOrSelf {

        for (uint256 i = 0; i < _authKeys.length; i++) {

            addAuthKey(_authKeys[i]);

        }

    }



    /// @dev Remove an auth key from the list of auth keys

    /// @param _authKey Address of the auth key to remove

    function removeAuthKey(address _authKey) public onlyValidAuthKeyOrSelf {

        require(authKeys[_authKey], "Auth key not yet added");

        require(getAuthKeysArrayLength() > 1, "Cannot remove last auth key");

        authKeys[_authKey] = false;

        _removeAuthKeyFromArray(_authKey);

        authKeysArrayIndex[_authKey] = 0;

        emit RemovedAuthKey(_authKey);

    }



    /// @dev Remove multiple auth keys to the list of auth keys

    /// @param _authKeys Array of addresses to remove to the auth keys list

    function removeMultipleAuthKeys(address[] memory _authKeys) public onlyValidAuthKeyOrSelf {

        for (uint256 i = 0; i < _authKeys.length; i++) {

            removeAuthKey(_authKeys[i]);

        }

    }



    /// @dev Swap one authKey for a non-authKey

    /// @param _oldAuthKey An existing authKey

    /// @param _newAuthKey A non-existing authKey

    function swapAuthKeys(

        address _oldAuthKey,

        address _newAuthKey

    )

        public

        onlyValidAuthKeyOrSelf

    {

        require(authKeys[_oldAuthKey], "Old auth key does not exist");

        require(!authKeys[_newAuthKey], "New auth key already exists");

        addAuthKey(_newAuthKey);

        removeAuthKey(_oldAuthKey);

        emit SwappedAuthKeys(_oldAuthKey, _newAuthKey);

    }



    /// @dev Swap multiple auth keys to the list of auth keys

    /// @param _oldAuthKeys Array of addresses to remove to the auth keys list

    /// @param _newAuthKeys Array of addresses to add to the auth keys list

    function swapMultipleAuthKeys(

        address[] memory _oldAuthKeys,

        address[] memory _newAuthKeys

    )

        public

    {

        require(_oldAuthKeys.length == _newAuthKeys.length, "Input arrays not equal length");

        for (uint256 i = 0; i < _oldAuthKeys.length; i++) {

            swapAuthKeys(_oldAuthKeys[i], _newAuthKeys[i]);

        }

    }



    function isValidSignature(

        bytes memory _msg,

        bytes memory _signatures

    )

        public

        view

        returns (bytes4)

    {

        if (_signatures.length == 65) {

            return isValidAuthKeySignature(_msg, _signatures);

        } else if (_signatures.length == 130) {

            return isValidLoginKeySignature(_msg, _signatures);

        } else {

            revert("Invalid _signatures length");

        }

    }



    function isValidAuthKeySignature(

        bytes memory _msg,

        bytes memory _signature

    )

        public

        view

        returns (bytes4)

    {

        address authKeyAddress = getEthSignedMessageHash(_msg).recover(

            _signature

        );



        if(authKeys[authKeyAddress]) {

            return VALID_SIG;

        } else {

            return INVALID_SIG;

        }

    }



    function isValidLoginKeySignature(

        bytes memory _msg,

        bytes memory _signatures

    )

        public

        view

        returns (bytes4)

    {

        bytes memory msgHashSignature = _signatures.slice(0, 65);

        bytes memory loginKeyAuthorizationSignature = _signatures.slice(65, 65);



        address loginKeyAddress = getEthSignedMessageHash(_msg).recover(

            msgHashSignature

        );



        bytes32 loginKeyAuthorizationMessageHash = keccak256(abi.encodePacked(

            loginKeyAddress

        )).toEthSignedMessageHash();



        address authorizationSigner = loginKeyAuthorizationMessageHash.recover(

            loginKeyAuthorizationSignature

        );



        if(authKeys[authorizationSigner]) {

            return VALID_SIG;

        } else {

            return INVALID_SIG;

        }

    }



    /**

     *  Internal functions

     */



    /// Remove an authKey from the authKeys array

    /// @param _authKey authKey to remove

    function _removeAuthKeyFromArray(address _authKey) internal {

        uint256 index = authKeysArrayIndex[_authKey];



        for (uint256 i = index; i < authKeysArray.length - 1; i++) {

            authKeysArray[i] = authKeysArray[i + 1];

        }



        delete authKeysArray[authKeysArray.length - 1];

        authKeysArray.length--;

    }



    /// @dev Validate an authKey

    /// @param _authKey Address of the auth key to validate

    function _validateAuthKey(address _authKey) internal view {

        require(authKeys[_authKey] == true || msg.sender == address(this), "Auth key is invalid");

    }



    /// @dev Validate signatures from an AuthKeyMetaTx

    /// @param _txDataMessageHash Ethereum signed message of the transaction

    /// @param _transactionDataSignature Signed tx data

    function _validateAuthKeyMetaTxSigs(

        bytes32 _txDataMessageHash,

        bytes memory _transactionDataSignature

    )

        internal

        view

        returns (address)

    {

        address transactionDataSigner = _txDataMessageHash.recover(_transactionDataSignature);

        _validateAuthKey(transactionDataSigner);

        return transactionDataSigner;

    }



    /// @dev Validate signatures from an AuthKeyMetaTx

    /// @param _txDataMessageHash Ethereum signed message of the transaction

    /// @param _transactionDataSignature Signed tx data

    /// @param _loginKeyAuthorizationSignature Signed loginKey

    function validateLoginKeyMetaTxSigs(

        bytes32 _txDataMessageHash,

        bytes memory _transactionDataSignature,

        bytes memory _loginKeyAuthorizationSignature

    )

        public

        view

        returns (address)

    {

        address transactionDataSigner = _txDataMessageHash.recover(

            _transactionDataSignature

        );



        bytes32 loginKeyAuthorizationMessageHash = keccak256(abi.encodePacked(

            transactionDataSigner

        )).toEthSignedMessageHash();



        address authorizationSigner = loginKeyAuthorizationMessageHash.recover(

            _loginKeyAuthorizationSignature

        );

        _validateAuthKey(authorizationSigner);



        return transactionDataSigner;

    }



    /// @dev Execute a transaction without a refund

    /// @notice This is the transaction sent from the CBA

    /// @param _destination Destination of the transaction

    /// @param _value Value of the transaction

    /// @param _data Data of the transaction

    /// @param _gasLimit Gas limit of the transaction

    function _executeTransaction(

        address _destination,

        uint256 _value,

        bytes memory _data,

        uint256 _gasLimit

    )

        internal

        returns (bytes memory)

    {

        (bool success, bytes memory response) = _destination.call.gas(_gasLimit).value(_value)(_data);



        if (!success) {

            bytes32 encodedData = _encodeData(nonce, _destination, _value, _data);

            emit CallFailed(encodedData);

        }



        // Increment nonce here so that both relayed and non-relayed calls will increment nonce

        // Must be incremented after !success data encode in order to encode original nonce

        nonce++;



        return response;

    }



    /// @dev Execute a transaction with a refund

    /// @notice This is meant to be used by executeAuthKeyMetaTx when being called

    /// @notice from a relayer.

    /// @param _destination Destination of the transaction

    /// @param _value Value of the transaction

    /// @param _data Data of the transaction

    /// @param _gasPrice Gas price of the transaction

    /// @param _gasLimit Gas limit of the transaction

    /// @param _startGas Starting gas at the beginning of the transaction

    function _executeTransactionWithRefund(

        address _destination,

        uint256 _value,

        bytes memory _data,

        uint256 _gasPrice,

        uint256 _gasLimit,

        uint256 _startGas

    )

        internal

        returns (bytes memory)

    {

        bytes memory response = _executeTransaction(_destination, _value, _data, _gasLimit);

        _issueRefund(_startGas, _gasPrice);

        return response;

    }



    /// @dev Issue a refund

    /// @param _gasPrice Gas price to use when sending a refund

    function _issueRefund(

        uint256 _startGas,

        uint256 _gasPrice

    )

        internal

    {

        uint256 _gasUsed = _startGas.sub(gasleft());

        require(_gasUsed.mul(_gasPrice) <= address(this).balance, "Insufficient gas for refund");

        msg.sender.transfer(_gasUsed.mul(_gasPrice));

    }



    /// @dev Encode data for a failed transaction

    /// @param _nonce Nonce of the transaction

    /// @param _destination Destination of the transaction

    /// @param _value Value of the transaction

    /// @param _data Data of the transaction

    function _encodeData(

        uint256 _nonce,

        address _destination,

        uint256 _value,

        bytes memory _data

    )

        internal

        pure

        returns (bytes32)

    {

        return keccak256(abi.encodePacked(

            _nonce,

            _destination,

            _value,

            _data

        ));

    }



    /// @dev Adds ETH signed message prefix to bytes message and hashes it

    /// @param _msg the bytes message before adding the prefix

    /// @return the prefixed and hashed message

    function getEthSignedMessageHash(bytes memory _msg) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", uint2str(_msg.length), _msg));

    }



    /// @dev Convert uint to string

    /// @param _num uint to be converted

    /// @return the string equivalent of the uint

    function uint2str(uint _num) private pure returns (string memory _uintAsString) {

        if (_num == 0) {

            return "0";

        }

        uint i = _num;

        uint j = _num;

        uint len;

        while (j != 0) {

            len++;

            j /= 10;

        }

        bytes memory bstr = new bytes(len);

        uint k = len - 1;

        while (i != 0) {

            bstr[k--] = byte(uint8(48 + i % 10));

            i /= 10;

        }

        return string(bstr);

    }

}



contract TransactionLimit is Account {



    uint256 public dailyLimit;

    mapping(uint256 => uint256) public dailyLimitTracker;



    event DailySpendIncrease(uint256 indexed day, uint256 indexed spendIncrease);

    event DailyLimitChanged(address indexed authKey, uint256 indexed newDailyLimit);



    function initialize() public initializer {

        dailyLimit = 10 ether;

    }



    /**

     * Getters

     */



    /// @dev Gets the current day for the contract

    function getCurrentDay() public view returns (uint256) {

        return block.timestamp / 86400;

    }



    /// @dev Check if a user is within their daily limit

    function getIsWithinEthDailyTransactionLimit() public view returns (bool) {

        return getWillBeWithinEthDailyTransactionLimit(0);

    }



    /// @dev Check if a user will be within their daily limit after a transaction

    /// @param _value Value being sent with the current transaction

    function getWillBeWithinEthDailyTransactionLimit(uint256 _value) public view returns (bool) {

        uint256 currentDay = getCurrentDay();

        uint256 dailySpend = dailyLimitTracker[currentDay] + _value;

        if (dailySpend <= dailyLimit) {

            return true;

        }

        return false;

    }



    /**

     * Setters

     */



    /// @dev Change the daily limit for a user

    /// @dev _newDailyLimit New daily limit to set

    function changeDailyLimit(uint256 _newDailyLimit) public onlyValidAuthKeyOrSelf {

        dailyLimit = _newDailyLimit;

        emit DailyLimitChanged(msg.sender, dailyLimit);

    }



    /**

     * Internal functions

     */



    /// @dev Update the tracked balance for daily limit for a user

    /// @param _value Value being sent with the current transaction

    function updateEthDailyTransactionLimit(uint256 _value) internal {

        dailyLimitTracker[getCurrentDay()] += _value;

        emit DailySpendIncrease(getCurrentDay(), _value);

    }

}



contract LoginKeyMetaTxAccount is Account, TransactionLimit {



    /// @dev Check if a loginKey is valid

    /// @param transactionDataSigner loginKey that signed the tx data

    /// @param _loginKeyAuthorizationSignature Signed loginKey

    function isValidLoginKey(

        address transactionDataSigner,

        bytes memory _loginKeyAuthorizationSignature

    )

        public

        view

        returns (bool)

    {

        bytes32 loginKeyAuthorizationMessageHash = keccak256(abi.encodePacked(

            transactionDataSigner

        )).toEthSignedMessageHash();



        address authorizationSigner = loginKeyAuthorizationMessageHash.recover(

            _loginKeyAuthorizationSignature

        );



        return authKeys[authorizationSigner];

    }



    /// @dev Execute an loginKey meta transaction

    /// @param _destination Destination of the transaction

    /// @param _data Data of the transaction

    /// @param _value Value of the transaction

    /// @param _gasLimit Gas limit of the transaction

    /// @param _transactionDataSignature Signed tx data

    /// @param _loginKeyAuthorizationSignature Signed loginKey

    function executeLoginKeyMetaTx(

        address _destination,

        bytes memory _data,

        uint256 _value,

        uint256 _gasLimit,

        bytes memory _transactionDataSignature,

        bytes memory _loginKeyAuthorizationSignature

    )

        public

        returns (bytes memory)

    {

        uint256 startGas = gasleft();



        // This is only in loginKey because authKeys are not restricted by firewalls

        require(checkFirewall(_value), "Transaction blocked by the firewall");



        // Login key cannot upgrade the contract

        require(checkDestination(_destination), "Login key is not able to upgrade to proxy");



        // Update daily limits

        updateEthDailyTransactionLimit(_value);



        bytes32 _txDataMessageHash = keccak256(abi.encodePacked(

            address(this),

            msg.sig,

            CHAIN_ID,

            _destination,

            _data,

            _value,

            nonce,

            tx.gasprice,

            _gasLimit

        )).toEthSignedMessageHash();



        address transactionDataSigner = validateLoginKeyMetaTxSigs(

            _txDataMessageHash, _transactionDataSignature, _loginKeyAuthorizationSignature

        );



        bytes memory response = _executeTransactionWithRefund(

            _destination, _value, _data, tx.gasprice, _gasLimit, startGas

        );



        return response;

    }



    /// @dev Check to see if the transaction passes the firewall

    /// @param _value Value of the transaction being sent

    function checkFirewall(uint256 _value) public view returns (bool) {

        return getWillBeWithinEthDailyTransactionLimit(_value);

    }



    /// @dev Check to see if the destination is the proxy admin.

    /// @notice The login key is not able to upgrade the proxy

    /// @notice This transaction will throw if an upgrade is attempted

    /// @param _destination Destination address

    function checkDestination(address _destination) public view returns (bool) {

        address proxyAdminAddress;

        assembly {

            proxyAdminAddress := sload(0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103)

        }

        return (proxyAdminAddress != _destination);

    }

}



contract AuthKeyMetaTxAccount is Account {



    /// @dev Execute an authKey meta transaction

    /// @param _destination Destination of the transaction

    /// @param _data Data of the transaction

    /// @param _value Value of the transaction

    /// @param _gasLimit Gas limit of the transaction

    /// @param _transactionDataSignature Signed tx data

    function executeAuthKeyMetaTx(

        address _destination,

        bytes memory _data,

        uint256 _value,

        uint256 _gasLimit,

        bytes memory _transactionDataSignature

    )

        public

        returns (bytes memory)

    {

        uint256 startGas = gasleft();



        bytes32 _txDataMessageHash = keccak256(abi.encodePacked(

            address(this),

            msg.sig,

            CHAIN_ID,

            _destination,

            _data,

            _value,

            nonce,

            tx.gasprice,

            _gasLimit

        )).toEthSignedMessageHash();



        address transactionDataSigner = _validateAuthKeyMetaTxSigs(

            _txDataMessageHash, _transactionDataSignature

        );



        bytes memory response = _executeTransactionWithRefund(

            _destination, _value, _data, tx.gasprice, _gasLimit, startGas

        );



        return response;

    }

}



/**

 * AuthereumENSManager interface.

 */

contract AuthereumENSManager {

    function register(string calldata _label, address _owner, uint256 _salt) external {}

}



contract AuthereumAccount is Account, AuthKeyMetaTxAccount, LoginKeyMetaTxAccount, AuthereumENSManager {



    string constant public authereumVersion = "1.0.0";



    /// @dev Initialize the Authereum Account

    /// @param _authKey authKey that will own this account

    /// @param _authereumENSManager Address of the Authereum ENS Manager

    /// @param _label Label of the ENS name

    /// @param _salt User specific salt

    function initialize(

        address _authKey,

        address _authereumENSManager,

        string memory _label,

        uint256 _salt

    )

        public

        initializer

    {

        // Set the CHAIN_ID

        Account.initialize();

        TransactionLimit.initialize();



        // Add self as an authKey

        authKeys[_authKey] = true;

        authKeysArray.push(_authKey);

        authKeysArrayIndex[_authKey] = authKeysArray.length - 1;

        emit AddedAuthKey(_authKey);



        // Register user in ENS

        AuthereumENSManager(_authereumENSManager).register(_label, address(this), _salt);

    }

}
