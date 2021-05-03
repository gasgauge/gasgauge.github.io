/**

 *Submitted for verification at Etherscan.io on 2020-12-25

*/



//pragma solidity ^0.5.0;
pragma solidity >=0.5 <0.7.17;



/**

 * @dev Library for managing

 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive

 * types.

 */

library EnumerableSet {

    // To implement this library for multiple types with as little code

    // repetition as possible, we write it in terms of a generic Set type with

    // bytes32 values.

    // The Set implementation uses private functions, and user-facing

    // implementations (such as AddressSet) are just wrappers around the

    // underlying Set.

    // This means that we can only create new EnumerableSets for types that fit

    // in bytes32.



    struct Set {

        // Storage of set values

        bytes32[] _values;

        // Position of the value in the `values` array, plus 1 because index 0

        // means a value is not in the set.

        mapping(bytes32 => uint256) _indexes;

    }



    /**

     * @dev Add a value to a set. O(1).

     *

     * Returns true if the value was added to the set, that is if it was not

     * already present.

     */

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {

            set._values.push(value);

            // The value is stored at length-1, but we add 1 to all indexes

            // and use 0 as a sentinel value

            set._indexes[value] = set._values.length;

            return true;

        } else {

            return false;

        }

    }



    /**

     * @dev Removes a value from a set. O(1).

     *

     * Returns true if the value was removed from the set, that is if it was

     * present.

     */

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        // We read and store the value's index to prevent multiple reads from the same storage slot

        uint256 valueIndex = set._indexes[value];



        if (valueIndex != 0) {

            // Equivalent to contains(set, value)

            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in

            // the array, and then remove the last element (sometimes called as 'swap and pop').

            // This modifies the order of the array, as noted in {at}.



            uint256 toDeleteIndex = valueIndex - 1;

            uint256 lastIndex = set._values.length - 1;



            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs

            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.



            bytes32 lastvalue = set._values[lastIndex];



            // Move the last value to the index where the value to delete is

            set._values[toDeleteIndex] = lastvalue;

            // Update the index for the moved value

            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based



            // Delete the slot where the moved value was stored

            set._values.pop();



            // Delete the index for the deleted slot

            delete set._indexes[value];



            return true;

        } else {

            return false;

        }

    }



    /**

     * @dev Returns true if the value is in the set. O(1).

     */

    function _contains(Set storage set, bytes32 value)

        private

        view

        returns (bool)

    {

        return set._indexes[value] != 0;

    }



    /**

     * @dev Returns the number of values on the set. O(1).

     */

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;

    }



    /**

     * @dev Returns the value stored at position `index` in the set. O(1).

     *

     * Note that there are no guarantees on the ordering of values inside the

     * array, and it may change when more values are added or removed.

     *

     * Requirements:

     *

     * - `index` must be strictly less than {length}.

     */

    function _at(Set storage set, uint256 index)

        private

        view

        returns (bytes32)

    {

        require(

            set._values.length > index,

            "EnumerableSet: index out of bounds"

        );

        return set._values[index];

    }



    // Bytes32Set



    struct Bytes32Set {

        Set _inner;

    }



    /**

     * @dev Add a value to a set. O(1).

     *

     * Returns true if the value was added to the set, that is if it was not

     * already present.

     */

    function add(Bytes32Set storage set, bytes32 value)

        internal

        returns (bool)

    {

        return _add(set._inner, value);

    }



    /**

     * @dev Removes a value from a set. O(1).

     *

     * Returns true if the value was removed from the set, that is if it was

     * present.

     */

    function remove(Bytes32Set storage set, bytes32 value)

        internal

        returns (bool)

    {

        return _remove(set._inner, value);

    }



    /**

     * @dev Returns true if the value is in the set. O(1).

     */

    function contains(Bytes32Set storage set, bytes32 value)

        internal

        view

        returns (bool)

    {

        return _contains(set._inner, value);

    }



    /**

     * @dev Returns the number of values in the set. O(1).

     */

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);

    }



    /**

     * @dev Returns the value stored at position `index` in the set. O(1).

     *

     * Note that there are no guarantees on the ordering of values inside the

     * array, and it may change when more values are added or removed.

     *

     * Requirements:

     *

     * - `index` must be strictly less than {length}.

     */

    function at(Bytes32Set storage set, uint256 index)

        internal

        view

        returns (bytes32)

    {

        return _at(set._inner, index);

    }



    // AddressSet



    struct AddressSet {

        Set _inner;

    }



    /**

     * @dev Add a value to a set. O(1).

     *

     * Returns true if the value was added to the set, that is if it was not

     * already present.

     */

    function add(AddressSet storage set, address value)

        internal

        returns (bool)

    {

        return _add(set._inner, bytes32(uint256(value)));

    }



    /**

     * @dev Removes a value from a set. O(1).

     *

     * Returns true if the value was removed from the set, that is if it was

     * present.

     */

    function remove(AddressSet storage set, address value)

        internal

        returns (bool)

    {

        return _remove(set._inner, bytes32(uint256(value)));

    }



    /**

     * @dev Returns true if the value is in the set. O(1).

     */

    function contains(AddressSet storage set, address value)

        internal

        view

        returns (bool)

    {

        return _contains(set._inner, bytes32(uint256(value)));

    }



    /**

     * @dev Returns the number of values in the set. O(1).

     */

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);

    }



    /**

     * @dev Returns the value stored at position `index` in the set. O(1).

     *

     * Note that there are no guarantees on the ordering of values inside the

     * array, and it may change when more values are added or removed.

     *

     * Requirements:

     *

     * - `index` must be strictly less than {length}.

     */

    function at(AddressSet storage set, uint256 index)

        internal

        view

        returns (address)

    {

        return address(uint256(_at(set._inner, index)));

    }



    // UintSet



    struct UintSet {

        Set _inner;

    }



    /**

     * @dev Add a value to a set. O(1).

     *

     * Returns true if the value was added to the set, that is if it was not

     * already present.

     */

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));

    }



    /**

     * @dev Removes a value from a set. O(1).

     *

     * Returns true if the value was removed from the set, that is if it was

     * present.

     */

    function remove(UintSet storage set, uint256 value)

        internal

        returns (bool)

    {

        return _remove(set._inner, bytes32(value));

    }



    /**

     * @dev Returns true if the value is in the set. O(1).

     */

    function contains(UintSet storage set, uint256 value)

        internal

        view

        returns (bool)

    {

        return _contains(set._inner, bytes32(value));

    }



    /**

     * @dev Returns the number of values on the set. O(1).

     */

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);

    }



    /**

     * @dev Returns the value stored at position `index` in the set. O(1).

     *

     * Note that there are no guarantees on the ordering of values inside the

     * array, and it may change when more values are added or removed.

     *

     * Requirements:

     *

     * - `index` must be strictly less than {length}.

     */

    function at(UintSet storage set, uint256 index)

        internal

        view

        returns (uint256)

    {

        return uint256(_at(set._inner, index));

    }

}



/*

 * @title: SafeMath

 * @dev: Helper contract functions to arithmatic operations safely.

 */



library SafeMath {



    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        require(c >= a, "SafeMath: addition overflow");



        return c;

    }



    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");

        uint256 c = a - b;



        return c;

    }



}



 /*

 * @title: Token

 * @dev: Interface contract for ERC20 tokens

 */

contract Token {

    function totalSupply() public view returns (uint256 supply);



    function balanceOf(address _owner) public view returns (uint256 balance);



    function transfer(address _to, uint256 _value)

        public

        returns (bool success);



    function transferFrom(

        address _from,

        address _to,

        uint256 _value

    ) public returns (bool success);



    function approve(address _spender, uint256 _value)

        public

        returns (bool success);



    function allowance(address _owner, address _spender)

        public

        view

        returns (uint256 remaining);

    

    function burn(uint256 amount) public;



    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(

        address indexed _owner,

        address indexed _spender,

        uint256 _value

    );

}





contract GenesisValidator {

    using SafeMath for uint256;

    using EnumerableSet for EnumerableSet.AddressSet;



    constructor() public {

        owner = msg.sender;



        isRefundAble = false;

        isEnded = false;

    }

    

    address constant KAI_ADDRESS = 0xD9Ec3ff1f8be459Bb9369b4E79e9Ebcf7141C093;

    uint256 constant public HARD_CAP = 187500000000000000000000000; // 187.5M KAI

    

    address private owner;

    uint256 public currentCap;

    mapping (address => mapping(address => uint256)) public delAmount;

    mapping (address => uint256) public valAmount;

    mapping (address => EnumerableSet.AddressSet) private dels;

    bool public isRefundAble;

    bool public isEnded;



    // Functions with this modifier can only be executed by the owner

    modifier onlyOwner() {

        require(msg.sender == owner);

        _;

    }

    

    function depositKAI(address _valAddr, uint256 _amount) public {

        require(isEnded == false, "The campaign is ended");

        require(currentCap.add(_amount) <= HARD_CAP, 'Exceed limit total cap');

        require(Token(KAI_ADDRESS).transferFrom(msg.sender, address(this), _amount));



        if(!dels[_valAddr].contains(msg.sender)) {

            dels[_valAddr].add(msg.sender);

        }

        delAmount[msg.sender][_valAddr] += _amount;

        currentCap = currentCap.add(_amount);

        valAmount[_valAddr] +=  _amount;

    }

    

    function burnKAI() public onlyOwner {        

        Token(KAI_ADDRESS).burn(getBalanceKAIContract());

    }

    

    function withdrawKAI(address _valAddr) public {

        require(isRefundAble == true, "Is not withdrawable yet");

        require(delAmount[msg.sender][_valAddr] > 0, "Can only withdraw once");

    

        uint256 amount = delAmount[msg.sender][_valAddr];

        Token(KAI_ADDRESS).transfer(msg.sender, amount);

        delAmount[msg.sender][_valAddr] = 0;

    }

    

    function getBalanceKAIContract() public view returns (uint256) {

        return Token(KAI_ADDRESS).balanceOf(address(this));

    }

    

    function getDelegators(address _valAddr) public view returns (address[] memory, uint256[] memory) {

        uint256 totalDels = dels[_valAddr].length();

        address[] memory delegators = new address[](totalDels);

        uint256[] memory amount = new uint256[](totalDels);

        

        for (uint i=0; i<totalDels; i++){

            delegators[i] = dels[_valAddr].at(i);

            amount[i] = delAmount[delegators[i]][_valAddr];

        }

        return (delegators,amount);

    }



    function setIsRefundAble() public onlyOwner {

        isRefundAble = true;

    }

    

    function setIsEnded() public onlyOwner {

        isEnded = true;

    }



    function emergencyWithdrawalKAI(uint256 amount) public onlyOwner {

        Token(KAI_ADDRESS).transfer(msg.sender, amount);

    }  

}
