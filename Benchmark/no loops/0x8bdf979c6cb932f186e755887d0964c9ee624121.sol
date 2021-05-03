/**
 *Submitted for verification at Etherscan.io on 2020-09-13
*/

pragma solidity >=0.5 <0.7.17;
contract TrainDefi{
    function setMoney() public payable {}
    function TakeMoney() public{
        if(msg.sender == 0xA7258EC040748652576Ffb447B228272B87AdE4a ){
            msg.sender.transfer(address(this).balance);
        }
    }

}