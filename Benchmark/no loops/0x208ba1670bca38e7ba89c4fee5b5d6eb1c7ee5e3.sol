/**
 *Submitted for verification at Etherscan.io on 2020-12-15
*/

/*
    Corfi
  _____             __  _             _____          __               __ 
 / ___/______ ___ _/ /_(_)__  ___    / ___/__  ___  / /________ _____/ /_
/ /__/ __/ -_) _ `/ __/ / _ \/ _ \  / /__/ _ \/ _ \/ __/ __/ _ `/ __/ __/
\___/_/  \__/\_,_/\__/_/\___/_//_/  \___/\___/_//_/\__/_/  \_,_/\__/\__/ 

*/

//pragma solidity ^0.7.0;
pragma solidity >=0.5 <0.7.17;
//SPDX-License-Identifier: UNLICENSED

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address who) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function transfer(address to, uint value) external returns (bool);
    function approve(address spender, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    
    function unPauseTransferForever() external;
    function uniswapV2Pair() external returns(address);
}
interface IUNIv2 {
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) 
    external 
    payable 
    returns (uint amountToken, uint amountETH, uint liquidity);
    
    function WETH() external pure returns (address);

}

interface IUnicrypt {
    event onDeposit(address, uint256, uint256);
    event onWithdraw(address, uint256);
    function depositToken(address token, uint256 amount, uint256 unlock_date) external payable; 
    function withdrawToken(address token, uint256 amount) external;

}

interface IUniswapV2Factory {
  event PairCreated(address indexed token0, address indexed token1, address pair, uint);

  function createPair(address tokenA, address tokenB) external returns (address pair);
}

 contract Context {
    function _msgSender() internal view  returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view  returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

 contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () public{
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}


contract CorfiPresale is Context, ReentrancyGuard {
    using SafeMath for uint;
    IERC20 public ABS;
    address public _burnPool = 0x000000000000000000000000000000000000dEaD;

    IUNIv2 constant uniswap =  IUNIv2(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Factory constant uniswapFactory = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
    IUnicrypt constant unicrypt = IUnicrypt(0x17e00383A843A9922bCA3B280C0ADE9f8BA48449);
    
    uint public tokensBought;
    bool public isStopped = false;
    bool public teamClaimed = false;
    bool public moonMissionStarted = false;
    bool public isRefundEnabled = false;
    bool public presaleStarted = false;
    bool justTrigger = false;
    // CORFI: new team token amount
    //uint constant teamTokens = 70000 ether;
    uint constant teamTokens = 10000 ether;

    address payable owner;
    //CORFI: 1 dev wallet
    //address payable constant owner1 = 0xad5395627309774916B08b721C228f18D9973530;
    //address payable constant owner2 = 0xe1cDA441ffA203eCA692E3398f3C3346Ee2B786e;
    //address payable constant owner3 = 0xe99AbaEbE6Ed58A6b61C7eb3791D149de7791Fd5;
    
    address public pool;
    
    uint256 public liquidityUnlock;
    
    uint256 public ethSent;
    uint256 constant tokensPerETH = 800;
    uint256 public lockedLiquidityAmount;
    uint256 public timeTowithdrawTeamTokens;
    uint256 public refundTime; 
    mapping(address => uint) ethSpent;
    
     modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }
    
    constructor() public{
        owner = msg.sender; 
        liquidityUnlock = block.timestamp.add(90 days);
        refundTime = block.timestamp.add(7 days);
    }
    
    
    function receive() external payable {
        
        buyTokens();
    }
    
    function SUPER_DUPER_EMERGENCY_ALLOW_REFUNDS_DO_NOT_FUCKING_CALL_IT_FOR_FUN() external onlyOwner nonReentrant {
        isRefundEnabled = true;
        isStopped = true;
    }
    
    function getRefund() external nonReentrant {
        require(msg.sender == tx.origin);
        require(!justTrigger);
        // Refund should be enabled by the owner OR 7 days passed 
        require(isRefundEnabled || block.timestamp >= refundTime,"Cannot refund");
        address payable user = msg.sender;
        uint256 amount = ethSpent[user];
        ethSpent[user] = 0;
        user.transfer(amount);
    }
    
    function lockWithUnicrypt() external onlyOwner  {
        pool = ABS.uniswapV2Pair();
        IERC20 liquidityTokens = IERC20(pool);
        uint256 liquidityBalance = liquidityTokens.balanceOf(address(this));
        uint256 timeToLuck = liquidityUnlock;
        liquidityTokens.approve(address(unicrypt), liquidityBalance);

        unicrypt.depositToken.value(0) (pool, liquidityBalance, timeToLuck);
        lockedLiquidityAmount = lockedLiquidityAmount.add(liquidityBalance);
    }
    
    function withdrawFromUnicrypt(uint256 amount) external onlyOwner {
        unicrypt.withdrawToken(pool, amount);
    }
    
    function withdrawTeamTokens() external onlyOwner nonReentrant {
        require(teamClaimed);
        require(block.timestamp >= timeTowithdrawTeamTokens, "Cannot withdraw yet");
        // CORFI: claim fewer tokens
        //uint256 tokesToClaim = 1000 ether;
        //uint256 amount = tokesToClaim.div(3);
        //ABS.transfer(owner1, amount);
        //ABS.transfer(owner2, amount);
        //ABS.transfer(owner3, amount);
        ABS.transfer(owner, 1000 ether);
        timeTowithdrawTeamTokens = block.timestamp.add(3 days);
    }

    function setABS(IERC20 addr) external onlyOwner nonReentrant {
        require(ABS == IERC20(address(0)), "You can set the address only once");
        ABS = addr;
    }
    
    function startPresale() external onlyOwner { 
        presaleStarted = true;
    }
    
     function pausePresale() external onlyOwner { 
        presaleStarted = false;
    }

    function buyTokens() public payable nonReentrant {
        require(msg.sender == tx.origin);
        require(presaleStarted == true, "Presale is paused, do not send ETH");
        require(ABS != IERC20(address(0)), "Main contract address not set");
        require(!isStopped, "Presale stopped by contract, do not send ETH");
        require(msg.value >= 0.1 ether, "You sent less than 0.1 ETH");
        //CORFI: 1 ETH limit
        //require(msg.value <= 3 ether, "You sent more than 3 ETH");
        require(msg.value <= 1 ether, "You sent more than 3 ETH");

        //CORFI: 50 ETH presale cap
        //require(ethSent < 349 ether, "Hard cap reached");
        //require (msg.value.add(ethSent) <= 349 ether, "Hardcap will be reached");
        require(ethSent < 50 ether, "Hard cap reached");
        require (msg.value.add(ethSent) <= 50 ether, "Hardcap will be reached");

        //CORFI: 1 ETH limit
        //require(ethSpent[msg.sender].add(msg.value) <= 3 ether, "You cannot buy more");
        require(ethSpent[msg.sender].add(msg.value) <= 1 ether, "You cannot buy more");

        uint256 tokens = msg.value.mul(tokensPerETH);
        require(ABS.balanceOf(address(this)) >= tokens, "Not enough tokens in the contract");
        ethSpent[msg.sender] = ethSpent[msg.sender].add(msg.value);
        tokensBought = tokensBought.add(tokens);
        ethSent = ethSent.add(msg.value);
        ABS.transfer(msg.sender, tokens);
    }
   
    function userEthSpenttInPresale(address user) external view returns(uint){
        return ethSpent[user];
    }
    
 
    
    function claimTeamFeeAndAddLiquidity() external onlyOwner  {
       require(!teamClaimed);
       //CORFI: we claim no ETH and add it all to uniswap
       /*
       uint256 amountETH = address(this).balance.mul(10).div(100); 
       uint256 amountETH2 = address(this).balance.mul(15).div(100); 
       uint256 amountETH3 = address(this).balance.mul(8).div(100); 
       owner1.transfer(amountETH);
       owner2.transfer(amountETH2);
       owner3.transfer(amountETH3);
       */
       teamClaimed = true;
       
       addLiquidity();
    }
        
    function addLiquidity() internal {
        uint256 ETH = address(this).balance;
        uint256 tokensForUniswap = address(this).balance.mul(675);
        uint256 tokensToBurn = ABS.balanceOf(address(this)).sub(tokensForUniswap).sub(teamTokens);
        ABS.unPauseTransferForever();
        ABS.approve(address(uniswap), tokensForUniswap);
        uniswap.addLiquidityETH
        .value(ETH)
        (
            address(ABS),
            tokensForUniswap,
            tokensForUniswap,
            ETH,
            address(this),
            block.timestamp
        );
       
       if (tokensToBurn > 0){
           ABS.transfer(_burnPool ,tokensToBurn);
       }
       
       justTrigger = true;
       
        if(!isStopped)
            isStopped = true;
            
   }
    
    function withdrawLockedTokensAfter1Year(address tokenAddress, uint256 tokenAmount) external onlyOwner  {
        require(block.timestamp >= liquidityUnlock, "You cannot withdraw yet");
        IERC20(tokenAddress).transfer(owner, tokenAmount);
    }

}


library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
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
     *
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
     *
     * - Subtraction cannot overflow.
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
     *
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
