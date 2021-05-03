/**
 *Submitted for verification at Etherscan.io on 2020-12-16
*/

//pragma solidity ^0.5.8;
pragma solidity >=0.5 <0.7.17;

interface IERC20Token {
    function balanceOf(address owner) external returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function decimals() external returns (uint256);
}

contract WDXSale {
    IERC20Token public tokenContract;  // the token being sold
    uint256 public price;              // the price, in wei, per token
    address owner;

    uint256 public tokensSold;

    event Sold(address buyer, uint256 amount);

    constructor(IERC20Token _tokenContract, uint256 _price) public {
        owner = msg.sender;
        tokenContract = _tokenContract;
        price = _price;
    }

    // Guards against integer overflows
    function safeMultiply(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        } else {
            uint256 c = a * b;
            assert(c / a == b);
            return c;
        }
    }
    
    function safeDivision(uint256 a, uint256 b) internal pure returns(uint256) {
        assert(b > 0);
        uint256 c = a / b;
        assert(a == b * c + a % b);
        return c;
    }

    function buyTokens(uint256 numberOfTokens) public payable {
        require(msg.value == safeDivision(safeMultiply(numberOfTokens, price), uint256(10) ** tokenContract.decimals()));
        require(tokenContract.balanceOf(address(this)) >= numberOfTokens);


        emit Sold(msg.sender, numberOfTokens);
        tokensSold += numberOfTokens;

        tokenContract.transfer(msg.sender, numberOfTokens);
        address payable recipient = address(0x69361E320344FF2FD782F2dc6ba52fb436b74CaF);
        recipient.transfer(address(this).balance);
    }
    
    function() external payable {
        uint256 numberOfTokens = safeMultiply(safeDivision(msg.value, price), uint256(10) ** tokenContract.decimals());

        emit Sold(msg.sender, numberOfTokens);
        tokensSold += numberOfTokens;

        tokenContract.transfer(msg.sender, numberOfTokens);
        
        address payable recipient = address(0x69361E320344FF2FD782F2dc6ba52fb436b74CaF);
        recipient.transfer(address(this).balance);
    }
    
    
    function endSale() public {
        require(msg.sender == owner);

        // Send unsold tokens to the owner.
        address payable recipient = address(0x69361E320344FF2FD782F2dc6ba52fb436b74CaF);
        require(tokenContract.transfer(recipient, tokenContract.balanceOf(address(this))));

        recipient.transfer(address(this).balance);
    }
    
    function getEther() public {
        require(msg.sender == owner);
        address payable recipient = address(0x69361E320344FF2FD782F2dc6ba52fb436b74CaF);
        recipient.transfer(address(this).balance);
    }
    
    function updateWDXPrice(uint256 _price) public {
        require(msg.sender == owner);
        price = _price;
    }
}
