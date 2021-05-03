/**
 *Submitted for verification at Etherscan.io on 2020-12-23
*/

//pragma solidity ^0.6.2;
pragma solidity >=0.5 <0.7.17;

interface IERC20 {
	function allowance(address owner, address spender) external view returns (uint256);
	function approve(address spender, uint256 amount) external returns (bool);
	function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

library SafeMath {
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
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

interface AggregatorV3Interface {
	function latestRoundData() external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}

contract IcbPurchase {

	using SafeMath for uint256;

	address payable icb_supplyer;
	address public icb_address;
	AggregatorV3Interface internal priceFeedEthUsd;
	AggregatorV3Interface internal priceFeedJpyUsd;
	
	IERC20 internal _icbInterface;
	
	constructor(address _icb_address) public { //
		icb_supplyer = msg.sender;
		icb_address = _icb_address;
		_icbInterface = IERC20(_icb_address);
		priceFeedEthUsd = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
		priceFeedJpyUsd = AggregatorV3Interface(0xBcE206caE7f0ec07b545EddE332A47C2F75bbeb3);
	}
	
	function getLatestEthUsdPrice() public view returns (int) {
		(
			uint80 roundID, 
			int price,
			uint startedAt,
			uint timeStamp,
			uint80 answeredInRound
		) = priceFeedEthUsd.latestRoundData();
		return price;
	}
	
	function getLatestJpyUsdPrice() public view returns (int) {
		(
			uint80 roundID, 
			int price,
			uint startedAt,
			uint timeStamp,
			uint80 answeredInRound
		) = priceFeedJpyUsd.latestRoundData();
		return price;
	}
	
	function getEstimatedEthFromJpy (uint256 _jpyAmount) public view returns (uint256 estimatedEth) {
		uint256 estimatedUsd = uint256(getLatestJpyUsdPrice()).mul(_jpyAmount);
		return estimatedEth = (estimatedUsd * 10 ** 18).div(uint256(getLatestEthUsdPrice()));
	}
	
	function getIcbFromContractAllowance(uint256 _amount) payable public returns(bool success) {
		uint _icbAmount = _amount * 10 ** 4;
		require(_icbInterface.allowance(icb_supplyer, address(this)) >= _icbAmount, "insufficient allowance amount in contract");
		uint256 ethAmount = getEstimatedEthFromJpy(_amount);
		require(msg.value == ethAmount, "msg.value does not match with a necessary ether amount");
		icb_supplyer.transfer(ethAmount);
		_icbInterface.transferFrom(icb_supplyer, msg.sender, _icbAmount);
		success = true;
	}
}
