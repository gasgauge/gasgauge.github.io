/**
 *Submitted for verification at Etherscan.io on 2020-11-29
*/

//pragma solidity ^0.5.0;
pragma solidity >=0.5 <0.7.17;

/**
  * @title ArtDeco Finance
  *
  * @notice StakeLevel contract : Three segment for average reward
  * 
  */

/***
* 
* MIT License
* ===========
* Original work Copyright(c) 2020 dego
* Modified work Copyright 2020 ArtDeco
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

interface IStakeLevel {
    
    function supplyLP(address sender, uint256 amount) external;
    function withdrawLP(address sender, uint256 amount) external;
    function getSupplyWeight(address sender) view  external returns (uint256);
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

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

contract StakeLevel is IStakeLevel, Governance {
    using SafeMath for uint256;
    
    struct stakeArea {
        uint256 min;
        uint256 max;
    }
    struct joincountSeg {
        uint32 length;
        uint32 curCount;
    }
    struct playerInfo {
        uint256 amount;
        uint8 segIndex;
        uint32 playerId;
        uint32 offset;
    }

    // for APWR-ETH pair
    uint256 constant public  _stakeamountMaxValue = 3 * (10**18);
    // Low level : 0.0 ~ 0.9  ( 30 % )
    // Mid level : 0.9 ~ 1.2  ( 10 % )
    // High level: 1.2 ~ 3.0  ( 60 % )
    uint8[3] public _ruler = [3, 1, 6];
    uint8[3] public _weight_factor = [3, 5, 1];

    uint8 public _low = 1;
    uint8 public _mid = 2;
    uint8 public _high = 3;
   
    uint32 constant public _highMax = 50;
    uint32 constant public _midMax = 50;    
    uint32 public _base = 100;
    uint32 public _anchor = _base;
    uint32 public _grouthCondition = 100;
    uint32 public _grouthStep = 10;
    
    uint32 public _playerId = 0;

    address public _contractCaller = address(0x0);
    mapping(address => uint32) public _addressXId;
    mapping(uint8 => stakeArea) public _stakeArea;
    mapping(uint8 => joincountSeg) public _joincountSeg;
    mapping(uint8 => mapping(uint32 => uint32)) public _playerIds;
    mapping(uint32 => playerInfo) public _playerMap;
    
    /**
     * check Is pool invalid or not 
     */
    modifier isInvalidPool(){
        require( msg.sender==_contractCaller,"invalid pool address!");
        _;
    }

    constructor() public 
    { 
        initialoneTime();
    }

    function initialoneTime() internal
    {
        _playerId = 0;
        init_JoinCount_Seg();
        update_stakeArea_min_max_Ruler(_stakeamountMaxValue);
    }
    
    function supplyLP(address sender, uint256 amount) 
    isInvalidPool()
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

            //To Update join counting segment
            update_joincount_Segment();
        }

        settleJoinArea(playerId);
    }


    function withdrawLP(address sender, uint256 amount) 
    isInvalidPool()
    external{
        uint32 playerId = _addressXId[sender];
        if ( playerId > 0 ) {
            _playerMap[playerId].amount = _playerMap[playerId].amount.sub(amount);
        } else {
            return;
        }

        settleJoinArea(playerId);
    }


    function getSupplyWeight(address sender) 
    view external
    returns (uint256) {

        uint32 playerId = _addressXId[sender];
        if ( playerId > 0 ) {
            uint8 segment = _playerMap[playerId].segIndex;
            if(segment>0){
                return uint256(_weight_factor[segment-1]).mul(_playerMap[playerId].amount);
            }
        }

        return 0;
    }


    function setCaller( address caller ) public  onlyGovernance{
        _contractCaller = caller;
    }

    function update_stakeArea_min_max_Ruler( uint256 maxCount ) internal{

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
            _stakeArea[i].min = lastBegin + 1;
            _stakeArea[i].max = lastEnd;
            lastBegin = lastEnd;
        }
    }

    function init_JoinCount_Seg() internal {    

       _joincountSeg[_low].curCount = 0;
       _joincountSeg[_mid].curCount = 0;
       _joincountSeg[_high].curCount = 0;
       
       _joincountSeg[_low].length = 80;
       _joincountSeg[_mid].length = 10;
       _joincountSeg[_high].length = 10;
    }

    function update_joincount_Segment( ) internal {

        if (_playerId >= _grouthCondition+_anchor ) {
            if (_joincountSeg[_high].length + _grouthStep > _highMax) {
                _joincountSeg[_high].length = _highMax;
            } else {
                _joincountSeg[_high].length = _joincountSeg[_high].length+_grouthStep;
            }

            if (_joincountSeg[_mid].length + _grouthStep > _midMax) {
                _joincountSeg[_mid].length = _midMax;
            } else {
                _joincountSeg[_mid].length = _joincountSeg[_mid].length+_grouthStep;
            }
            _anchor = _playerId;
        }
    }

    function hasCountSegmentSlot(uint8 segIndex) internal view returns (bool){
        uint32 value = _joincountSeg[segIndex].length-_joincountSeg[segIndex].curCount;
        if (value > 0) {
            return true;
        } else {
            return false;
        }
    }

    function findSegmentMinPlayer(uint8 segIndex) internal view returns (uint32,uint256){
        uint256 firstMinAmount = _stakeArea[segIndex].max;
        uint256 secondMinAmount = _stakeArea[segIndex].max;
        uint32 minPlayerOffset = 0;
        for (uint8 i = 0; i < _joincountSeg[segIndex].curCount; i++) {
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

    function JoinsegmentSwap(uint32 playerId, uint8 segIndex) internal {

        uint8 oldSegIndex = _playerMap[playerId].segIndex;

        uint32 oldOffset = _playerMap[playerId].offset;
        uint32 tail = _joincountSeg[segIndex].curCount;

        _playerMap[playerId].segIndex = segIndex;
        _playerMap[playerId].offset = tail;

        _joincountSeg[segIndex].curCount = _joincountSeg[segIndex].curCount+1;
        _playerIds[segIndex][tail] = playerId;

        if (oldSegIndex>0 && segIndex != oldSegIndex && _playerIds[oldSegIndex][oldOffset] > 0) {

            uint32 originTail = _joincountSeg[oldSegIndex].curCount-1;
            uint32 originTailPlayer = _playerIds[oldSegIndex][originTail];

            if(originTailPlayer != playerId){

                _playerMap[originTailPlayer].segIndex = oldSegIndex;
                _playerMap[originTailPlayer].offset = oldOffset;
                _playerIds[oldSegIndex][oldOffset] = originTailPlayer;
            }

            _playerIds[oldSegIndex][originTail] = 0;
            _joincountSeg[oldSegIndex].curCount = _joincountSeg[oldSegIndex].curCount-1;
        }
    }

    // find the tail id of player, for swap to another area 
    function tail_findID_Seg( uint8 segIndex) internal returns (uint32){

        uint32 minPlayerOffset;
        uint256 secondMinAmount;
        (minPlayerOffset,secondMinAmount) = findSegmentMinPlayer(segIndex);
        _stakeArea[segIndex].min = secondMinAmount;

        uint32 leftPlayerId = _playerIds[segIndex][minPlayerOffset];

        //segment reset
        uint32 tail = _joincountSeg[segIndex].curCount - 1;
        uint32 tailPlayerId = _playerIds[segIndex][tail];
        _playerIds[segIndex][minPlayerOffset] = tailPlayerId;

        _playerMap[tailPlayerId].offset = minPlayerOffset;

        return leftPlayerId;
    }

    function joinHigh(uint32 playerId) internal {
        uint8 segIndex = _high;
        if (hasCountSegmentSlot(segIndex)) {
            JoinsegmentSwap(playerId, segIndex);
        } else {
            uint32 leftPlayerId = tail_findID_Seg(segIndex);
            joinMid(leftPlayerId);
            JoinsegmentSwap(playerId, segIndex);

        }
    }

    function joinMid(uint32 playerId) internal {
        uint8 segIndex = _mid;
        if (hasCountSegmentSlot(segIndex)) {
            JoinsegmentSwap(playerId, segIndex);
        } else {
            uint32 leftPlayerId = tail_findID_Seg(segIndex);
            joinLow(leftPlayerId);
            JoinsegmentSwap(playerId, segIndex);
        }
        _stakeArea[segIndex].max = _stakeArea[segIndex + 1].min;
    }

    function joinLow(uint32 playerId) internal {

        uint8 segIndex = _low;
        JoinsegmentSwap(playerId, segIndex);
        _stakeArea[segIndex].max = _stakeArea[segIndex + 1].min;
        //_low segment length update
        if( _joincountSeg[segIndex].curCount > _joincountSeg[segIndex].length){
            _joincountSeg[segIndex].length = _joincountSeg[segIndex].curCount;
        }
    }

    function settleJoinArea(uint32 playerId) internal {

        uint256 amount = _playerMap[playerId].amount;
        uint8 segIndex = 0;
        for (uint8 i = 1; i <= _high; i++) {
            if (amount < _stakeArea[i].max) {
                segIndex = i;
                break;
            }
        }
        if (segIndex == 0) {
            _stakeArea[_high].max = amount;
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

}
