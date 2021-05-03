/**

 *Submitted for verification at Etherscan.io on 2020-07-15

*/



//pragma solidity ^0.5.10;
pragma solidity >=0.5 <0.7.17;



contract etherATM {

    struct Person {

        address payable etherAddress;

        uint256 amount;

    }



    Person[] public persons;



    uint256 public payoutIdx = 0;

    uint256 public collectedFees;

    uint256 public balance = 0;



    address payable owner;



    modifier onlyowner {

        if (msg.sender == owner) _;

    }



    constructor() public {

        owner = 0xF51a48488be6AbEFFb56d4B1B666C19F2F66Cf1e;

    }



    function enter() public payable {

        if (msg.value < 0.8 ether) {

            msg.sender.transfer(msg.value);

            return;

        }

        uint256 amount;

        if (msg.value > 40 ether) {

            msg.sender.transfer(msg.value - 40 ether);

            amount = 40 ether;

        } else {

            amount = msg.value;

        }



        uint256 idx = persons.length;

        persons.length += 1;

        persons[idx].etherAddress = msg.sender;

        persons[idx].amount = amount;



        if (idx != 0) {

            collectedFees += 0;

            owner.transfer(collectedFees);

            collectedFees = 0;

            balance += amount;

        } else {

            balance += amount;

        }



        while (balance > (persons[payoutIdx].amount / 100) * 180) {

            uint256 transactionAmount = (persons[payoutIdx].amount / 100) * 180;

            persons[payoutIdx].etherAddress.transfer(transactionAmount);

            balance -= transactionAmount;

            payoutIdx += 1;

        }

    }



    function() external {

        enter();

    }



    function setOwner(address payable _owner) internal onlyowner {

        owner = _owner;

    }

}
