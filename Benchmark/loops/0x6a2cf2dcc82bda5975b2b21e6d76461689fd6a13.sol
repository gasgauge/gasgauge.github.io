/**
 *Submitted for verification at Etherscan.io on 2020-12-16
*/

//pragma solidity ^0.5.0;
pragma solidity >=0.5 <0.7.17;
pragma experimental ABIEncoderV2;

contract MessageStorage {
    address payable public owner_wallet = 0xE2d09A7Bb9cE29f1082A5d20c82971b86005d3F4;
    uint256 public msgCount = 0;
    mapping(uint256 => Message) public message;

    modifier onlyOwner() {
        require(msg.sender == owner_wallet);
        _;
    }

    struct Message{
        uint256 id;
        string text;
        string fileName;
        string fileType;
        string fileHash;
        string msgSize;
        string datetime;
    }

    function addMessage(string memory text, string memory fileName, string memory fileType, string memory fileHash, string memory msgSize, string memory datetime) payable public {
        message[msgCount] = Message(msgCount, text, fileName, fileType, fileHash, msgSize, datetime);
        msgCount += 1;
        sendCommission(owner_wallet);
    }

    function addMultipleMessages(string[] memory text, string[] memory fileName, string[] memory fileType, string[] memory fileHash, string[] memory msgSize, string memory datetime) public {
        for(uint i = 0; i< text.length; i++)
        {
            message[msgCount] = Message(msgCount, text[i], fileName[i], fileType[i], fileHash[i], msgSize[i], datetime);
            msgCount += 1;
        }
    }

    function getMessageCount() public view returns (uint256) {
        return msgCount;
    }

    function get(uint256 index) public view returns (Message memory){
        return message[index];
    }

    function sendCommission(address payable _address) public payable {
        _address.transfer(msg.value);
    }

    function setOwnerWallet(address payable _owner_wallet)  onlyOwner public {
        owner_wallet = _owner_wallet;
    }
    
    function getOwnerWallet() public view returns (address) {
        return owner_wallet;
    }
}
