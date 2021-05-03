/**
 *Submitted for verification at Etherscan.io on 2020-09-16
*/

/***
 *    ██████╗ ███████╗ ██████╗  ██████╗ 
 *    ██╔══██╗██╔════╝██╔════╝ ██╔═══██╗
 *    ██║  ██║█████╗  ██║  ███╗██║   ██║
 *    ██║  ██║██╔══╝  ██║   ██║██║   ██║
 *    ██████╔╝███████╗╚██████╔╝╚██████╔╝
 *    ╚═════╝ ╚══════╝ ╚═════╝  ╚═════╝ 
 *    
 * https://dego.finance
                                  
* MIT License
* ===========
*
* Copyright (c) 2020 dego
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*/
// File: @openzeppelin/contracts/math/SafeMath.sol

//pragma solidity ^0.5.0;
pragma solidity >=0.5 <0.7.17;

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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
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
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: contracts/interface/IPowerStrategy.sol

//pragma solidity ^0.5.0;
pragma solidity >=0.5 <0.7.17;


interface IPowerStrategy {
    function lpIn(address sender, uint256 amount) external;
    function lpOut(address sender, uint256 amount) external;
    
    function getPower(address sender) view  external returns (uint256);
}

// File: contracts/library/Governance.sol

//pragma solidity ^0.5.0;
pragma solidity >=0.5 <0.7.17;

contract Governance {

    address public _governance;

    constructor() public {
        _governance = tx.origin;
    }

    event GovernanceTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyGovernance {
        require(msg.sender == _governance, "not governance");
        _;
    }

    function setGovernance(address governance)  public  onlyGovernance
    {
        require(governance != address(0), "new governance the zero address");
        emit GovernanceTransferred(_governance, governance);
        _governance = governance;
    }


}

// File: contracts/library/SegmentPowerStrategy.sol

//pragma solidity ^0.5.0;
pragma solidity >=0.5 <0.7.17;




contract SegmentPowerStrategy is IPowerStrategy, Governance {
    using SafeMath for uint256;
    ////
    struct degoSegment {
        uint256 min;
        uint256 max;
    }
    struct countSegment {
        uint32 length;
        uint32 curCount;
    }
    struct playerInfo {
        uint256 amount;
        uint8 segIndex;
        uint32 playerId;
        uint32 offset;
    }

    mapping(address => uint32) public _addressXId;
    mapping(uint8 => degoSegment) public _degoSegment;
    mapping(uint8 => countSegment) public _countSegment;
    mapping(uint8 => mapping(uint32 => uint32)) public _playerIds;
    mapping(uint32 => playerInfo) public _playerMap;

    uint8[3] public _ruler = [8, 1, 1];
    uint8[3] public _factor = [3, 5, 1];

    uint8 public _high = 3;
    uint8 public _mid = 2;
    uint8 public _low = 1;

    uint32 public _playerId = 0;
    uint32 public _base = 100;
    uint32 public _anchor = _base;
    uint32 public _grouthCondition = 100;
    uint32 public _grouthStep = 10;
    uint32 constant public _highMax = 50;
    uint32 constant public _midMax = 50;

    uint256 constant public  _initMaxValue = 100 * (10**18);  //500lp,10w usdt,100 eth

    address public _contractCaller = address(0x0);

    /**
     * check pool
     */
    modifier isNormalPool(){
        require( msg.sender==_contractCaller,"invalid pool address!");
        _;
    }

    constructor()
        public
    {
        _playerId = 0;

        initSegment();
        updateRuler(_initMaxValue);
    }

    function lpIn(address sender, uint256 amount) 
    isNormalPool()
    external {

        uint32 playerId = _addressXId[sender];
        if ( playerId > 0 ) {
            _playerMap[playerId].amount = _playerMap[playerId].amount.add(amount);
        } else {
            //new addr
            _playerId = _playerId+1;
            _addressXId[sender] = _playerId;

            playerId = _playerId;
            _playerMap[playerId].playerId = playerId;
            _playerMap[playerId].amount = amount;
            _playerMap[playerId].segIndex = 0;
            _playerMap[playerId].offset =  0;

            //update segment
            updateSegment();
        }

        settlePowerData(playerId);
    }

    function lpOut(address sender, uint256 amount) 
    isNormalPool()
    external{
        uint32 playerId = _addressXId[sender];
        if ( playerId > 0 ) {
            _playerMap[playerId].amount = _playerMap[playerId].amount.sub(amount);
        } else {
            return;
        }

        settlePowerData(playerId);
    }
    
    function getPower(address sender) 
    view external
    returns (uint256) {

        uint32 playerId = _addressXId[sender];
        if ( playerId > 0 ) {
            uint8 segment = _playerMap[playerId].segIndex;
            if(segment>0){
                return uint256(_factor[segment-1]).mul(_playerMap[playerId].amount);
            }
        }

        return 0;
    }


    function setCaller( address caller ) public  onlyGovernance{
        _contractCaller = caller;
    }

    function updateRuler( uint256 maxCount ) internal{

        uint256 lastBegin = 0;
        uint256 lastEnd = 0;
        uint256 splitPoint = 0;
        for (uint8 i = 1; i <= _ruler.length; i++) {
            splitPoint = maxCount * _ruler[i - 1]/10;
            if (splitPoint <= 0) {
                splitPoint = 1;
            }
            lastEnd = lastBegin + splitPoint;
            if (i == _ruler.length) {
                lastEnd = maxCount;
            }
            _degoSegment[i].min = lastBegin + 1;
            _degoSegment[i].max = lastEnd;
            lastBegin = lastEnd;
        }
    }

    function initSegment() internal {    

        _countSegment[_low].length = 80;
        _countSegment[_mid].length = 10;
        _countSegment[_high].length = 10;

        _countSegment[_low].curCount = 0;
        _countSegment[_mid].curCount = 0;
        _countSegment[_high].curCount = 0;
    }

    function updateSegment( ) internal {

        if (_playerId >= _grouthCondition+_anchor ) {
            if (_countSegment[_high].length + _grouthStep > _highMax) {
                _countSegment[_high].length = _highMax;
            } else {
                _countSegment[_high].length = _countSegment[_high].length+_grouthStep;
            }

            if (_countSegment[_mid].length + _grouthStep > _midMax) {
                _countSegment[_mid].length = _midMax;
            } else {
                _countSegment[_mid].length = _countSegment[_mid].length+_grouthStep;
            }
            _anchor = _playerId;
        }
    }

    function hasCountSegmentSlot(uint8 segIndex) internal view returns (bool){
        uint32 value = _countSegment[segIndex].length-_countSegment[segIndex].curCount;
        if (value > 0) {
            return true;
        } else {
            return false;
        }
    }

    function findSegmentMinPlayer(uint8 segIndex) internal view returns (uint32,uint256){
        uint256 firstMinAmount = _degoSegment[segIndex].max;
        uint256 secondMinAmount = _degoSegment[segIndex].max;
        uint32 minPlayerOffset = 0;
        for (uint8 i = 0; i < _countSegment[segIndex].curCount; i++) {
            uint32 playerId = _playerIds[segIndex][i];
            if( playerId==0 ){
                continue;
            }
            uint256 amount = _playerMap[playerId].amount;

            //find min amount;
            if ( amount < firstMinAmount) {
                if (firstMinAmount < secondMinAmount) {
                    secondMinAmount = firstMinAmount;
                }
                firstMinAmount = amount;
                minPlayerOffset = i;
            }else{
                //find second min amount
                if(amount < secondMinAmount ){
                    secondMinAmount = amount;
                }
            }
        }

        return (minPlayerOffset,secondMinAmount);
    }

    //swap the player data from old segment to the new segment
    function segmentSwap(uint32 playerId, uint8 segIndex) internal {

        uint8 oldSegIndex = _playerMap[playerId].segIndex;

        uint32 oldOffset = _playerMap[playerId].offset;
        uint32 tail = _countSegment[segIndex].curCount;

        _playerMap[playerId].segIndex = segIndex;
        _playerMap[playerId].offset = tail;

        _countSegment[segIndex].curCount = _countSegment[segIndex].curCount+1;
        _playerIds[segIndex][tail] = playerId;

        if (oldSegIndex>0 && segIndex != oldSegIndex && _playerIds[oldSegIndex][oldOffset] > 0) {

            uint32 originTail = _countSegment[oldSegIndex].curCount-1;
            uint32 originTailPlayer = _playerIds[oldSegIndex][originTail];

            if(originTailPlayer != playerId){

                _playerMap[originTailPlayer].segIndex = oldSegIndex;
                _playerMap[originTailPlayer].offset = oldOffset;
                _playerIds[oldSegIndex][oldOffset] = originTailPlayer;
            }

            _playerIds[oldSegIndex][originTail] = 0;
            _countSegment[oldSegIndex].curCount = _countSegment[oldSegIndex].curCount-1;
        }
    }

    //swap the player data with tail 
    function tailSwap( uint8 segIndex) internal returns (uint32){

        uint32 minPlayerOffset;
        uint256 secondMinAmount;
        (minPlayerOffset,secondMinAmount) = findSegmentMinPlayer(segIndex);
        _degoSegment[segIndex].min = secondMinAmount;

        uint32 leftPlayerId = _playerIds[segIndex][minPlayerOffset];

        //segmentSwap to reset
        uint32 tail = _countSegment[segIndex].curCount - 1;
        uint32 tailPlayerId = _playerIds[segIndex][tail];
        _playerIds[segIndex][minPlayerOffset] = tailPlayerId;

        _playerMap[tailPlayerId].offset = minPlayerOffset;

        return leftPlayerId;
    }

    function joinHigh(uint32 playerId) internal {
        uint8 segIndex = _high;
        if (hasCountSegmentSlot(segIndex)) {
            segmentSwap(playerId, segIndex);
        } else {
            uint32 leftPlayerId = tailSwap(segIndex);
            joinMid(leftPlayerId);
            segmentSwap(playerId, segIndex);

        }
    }

    function joinMid(uint32 playerId) internal {
        uint8 segIndex = _mid;
        if (hasCountSegmentSlot(segIndex)) {
            segmentSwap(playerId, segIndex);
        } else {
            uint32 leftPlayerId = tailSwap(segIndex);
            joinLow(leftPlayerId);
            segmentSwap(playerId, segIndex);
        }
        _degoSegment[segIndex].max = _degoSegment[segIndex + 1].min;
    }

    function joinLow(uint32 playerId) internal {

        uint8 segIndex = _low;
        segmentSwap(playerId, segIndex);
        _degoSegment[segIndex].max = _degoSegment[segIndex + 1].min;
        //_low segment length update
        if( _countSegment[segIndex].curCount > _countSegment[segIndex].length){
            _countSegment[segIndex].length = _countSegment[segIndex].curCount;
        }
    }

    function settlePowerData(uint32 playerId) internal {

        uint256 amount = _playerMap[playerId].amount;
        uint8 segIndex = 0;
        for (uint8 i = 1; i <= _high; i++) {
            if (amount < _degoSegment[i].max) {
                segIndex = i;
                break;
            }
        }
        if (segIndex == 0) {
            _degoSegment[_high].max = amount;
            segIndex = _high;
        }

        if (_playerMap[playerId].segIndex == segIndex) {
            return;
        }

        if (segIndex == _high) {
            joinHigh(playerId);
        } else if (segIndex == _mid) {
            joinMid(playerId);
        } else {
            joinLow(playerId);
        }
    }

    ////////////////////////////
}
