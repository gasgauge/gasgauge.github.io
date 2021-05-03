/**
 *Submitted for verification at Etherscan.io on 2020-09-18
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
// File: contracts/interface/IPool.sol

//pragma solidity ^0.5.0;
pragma solidity >=0.5 <0.7.17;


interface IPool {
    function totalSupply( ) external view returns (uint256);
    function balanceOf( address player ) external view returns (uint256);
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

// File: contracts/governance/DegoVoteProxy.sol

//pragma solidity ^0.5.5;
pragma solidity >=0.5 <0.7.17;



contract DegoVoterProxy is Governance {
    
    struct info{
        IPool poolAddr;
        uint256 weight;
    }
    mapping(address => uint256) public _addr2Id;  
    mapping(uint256 => info) public _pools;  
    uint256 public _pID;       
    
    function decimals() external pure returns (uint8) {
        return uint8(18);
    }
    
    function name() external pure returns (string memory) {
        return "dego.voteproxy";
    }
    
    function symbol() external pure returns (string memory) {
        return "DEGOVOTE";
    }
    
    function totalSupply() external view returns (uint) {

        uint256 total = 0;
        for(uint256 i=1; i<=_pID; i++){
            if(_pools[i].weight>0){
                total  +=  _pools[i].poolAddr.totalSupply()*_pools[i].weight;
            }
        }
        return total; 
    }
    
    function balanceOf(address voter) external view returns (uint) {

        uint256 votes = 0;
        for(uint256 i=1; i<=_pID; i++){
            if(_pools[i].weight>0){
                votes  +=  _pools[i].poolAddr.balanceOf(voter)*_pools[i].weight;
            }
        }
        return votes;

    }

    function setPool(address pool, uint256 weight)  public  onlyGovernance{

        uint256 pID= _addr2Id[pool];
        if(pID == 0){
            _pID++;
            pID = _pID;
            _addr2Id[pool] = pID;
            _pools[pID].weight=weight;
            _pools[pID].poolAddr=IPool(pool);
        }
        else{
            _pools[pID].weight=weight;
        }

    }


    constructor() public {}
}
