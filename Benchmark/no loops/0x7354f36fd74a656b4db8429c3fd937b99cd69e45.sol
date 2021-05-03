/**
 *Submitted for verification at Etherscan.io on 2020-09-13
*/

pragma solidity >=0.5 <0.7.17;

library SafeMath {
   
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;}

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");}

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;}

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {return 0;}
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;}

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");}

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;}

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");}

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;}
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface Uniswap{
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function WETH() external pure returns (address);
}

interface Kye {
    function routerAddress() external view returns (address);
}

interface Router {
    function mint(address tokenAddress, uint toMint) external;
}

contract Routerable{
    
    address private constant _KYEADDRESS = 0xD5A4dc51229774223e288528E03192e2342bDA00;
    
    function kyeAddress() public pure returns (address) {
        return _KYEADDRESS;
    }
    
    function routerAddress() public view returns (address payable) {
        return toPayable( Kye(kyeAddress()).routerAddress() );
    }
    
    modifier onlyRouter() {
        require(msg.sender == routerAddress(), "Caller is not Router");
        _;
    }
    
    function toPayable(address input) internal pure returns (address payable){
        return address(uint160(input));
    }
}

contract Staker is Routerable{
    
    using SafeMath for uint256;
    
    uint constant internal DECIMAL = 10**18;
    uint constant public INF = 33136721748;

    uint private timeOver = INF;
    bool private _paused = false;
    
    uint private rewardValue = 10**20;
    uint private kyePromo = 2;

    mapping (address => mapping (address => uint256)) private rewards;
    mapping (address => mapping (address => uint256)) private timePooled;
    mapping (address => mapping (address => uint256)) private LPTokenBalance;
    mapping (address => uint256) private referralEarned;

    
    address constant public KYE_TOKEN_ADDRESS = 0x273dB7238B46FDFdD28f553f4AE7f7da736A8D92;
    
    address constant public UNIROUTER         = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address constant public FACTORY           = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address          public WETHAddress       = Uniswap(UNIROUTER).WETH();
    
    function receive() external payable {
        
       if(msg.sender != UNIROUTER){
           stake(KYE_TOKEN_ADDRESS, address(0));
       }
    }
    
    function sendValue(address payable recipient, uint256 amount) internal {
        (bool success, ) = recipient.call.value(amount)(""); 
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    
    function mintingPeriodOver() internal view returns (bool){
        return now > timeOver;
    }
    
    function closeMinting() public onlyRouter {
        timeOver = now;
    }
    
    function Pause(bool paused) public onlyRouter {
        _paused = paused;
    }
    
    function updateRewardValue(uint _rewardValue) public onlyRouter {
        require(!mintingPeriodOver());
        rewardValue = _rewardValue;
    }
    
    function updateKyePromo(uint _kyePromo) public onlyRouter {
        require(!mintingPeriodOver());
        kyePromo = _kyePromo;
    }
    
    function stake(address tokenAddress, address payable ref) public payable{
        require(!mintingPeriodOver(), "You will not mint Kye tokens anymore, stake directly through Uniswap");
        
        if(ref != address(0)){
            
            referralEarned[ref] = referralEarned[ref] + ((address(this).balance/10)*DECIMAL)/price();
        }
        
        sendValue(routerAddress(), address(this).balance/2);
        
        address poolAddress = Uniswap(FACTORY).getPair(tokenAddress, WETHAddress);
        uint ethAmount = IERC20(WETHAddress).balanceOf(poolAddress); //Eth in uniswap
        uint tokenAmount = IERC20(tokenAddress).balanceOf(poolAddress); //token in uniswap
        
        uint toMint = (address(this).balance.mul(tokenAmount)).div(ethAmount);
        Router(routerAddress()).mint(tokenAddress, toMint);
        
        uint poolTokenAmountBefore = IERC20(poolAddress).balanceOf(address(this));
        
        uint amountTokenDesired = IERC20(tokenAddress).balanceOf(address(this));
        IERC20(tokenAddress).approve(UNIROUTER, amountTokenDesired ); //allow pool to get tokens
        Uniswap(UNIROUTER).addLiquidityETH.value(address(this).balance)(tokenAddress, amountTokenDesired, 1, 1, address(this), INF);
        
        uint poolTokenAmountAfter = IERC20(poolAddress).balanceOf(address(this));
        uint poolTokenGot = poolTokenAmountAfter.sub(poolTokenAmountBefore);
        
        rewards[tokenAddress][msg.sender] = rewards[tokenAddress][msg.sender].add(viewRecentRewardTokenAmount(tokenAddress,msg.sender));
        timePooled[tokenAddress][msg.sender] = now;
    
        LPTokenBalance[tokenAddress][msg.sender] = LPTokenBalance[tokenAddress][msg.sender].add(poolTokenGot);
    }

    function withdrawLPTokens(address tokenAddress, uint amount) public {
        if(!mintingPeriodOver() || _paused){return;}
        require( amount <= rewards[tokenAddress][msg.sender].add(viewRecentRewardTokenAmount(tokenAddress, msg.sender)) );
        
        rewards[tokenAddress][msg.sender] = rewards[tokenAddress][msg.sender].add(viewRecentRewardTokenAmount(tokenAddress, msg.sender));
        LPTokenBalance[tokenAddress][msg.sender] = LPTokenBalance[tokenAddress][msg.sender].sub(amount);
        
        address poolAddress = Uniswap(FACTORY).getPair(tokenAddress, WETHAddress);
        IERC20(poolAddress).transfer(msg.sender, amount);
        
        timePooled[tokenAddress][msg.sender] = now;
    }
    
    function withdrawRewardTokens(address tokenAddress, uint amount) public {
        if(!mintingPeriodOver()){return;}
        require(amount <= viewRewardTokenAmount(tokenAddress, msg.sender));
        
        rewards[tokenAddress][msg.sender] = rewards[tokenAddress][msg.sender].add(viewRecentRewardTokenAmount(tokenAddress, msg.sender));
        timePooled[tokenAddress][msg.sender] = now;
        
        uint removeAmount = ethtimeCalc(tokenAddress, amount)/2;
        rewards[tokenAddress][msg.sender] = rewards[tokenAddress][msg.sender].sub(removeAmount);
        
        Router(routerAddress()).mint(KYE_TOKEN_ADDRESS, amount);
        IERC20(KYE_TOKEN_ADDRESS).transfer(msg.sender, amount);
    }
    
    function withdrawReferralEarned(uint amount) public{
        if(!mintingPeriodOver()){return;}
        
        referralEarned[msg.sender] = referralEarned[msg.sender].sub(amount);
        
        Router(routerAddress()).mint(KYE_TOKEN_ADDRESS, amount);
        IERC20(KYE_TOKEN_ADDRESS).transfer(msg.sender, amount);
    }
    
    function viewRecentRewardTokenAmount(address tokenAddress, address who) internal view returns (uint){
        
        if(mintingPeriodOver()){
            
            if(timePooled[tokenAddress][who] > timeOver){
                return 0;
            }else{
                return (viewPooledEthAmount(tokenAddress, who).mul( timeOver.sub(timePooled[tokenAddress][who]) ));
            }
        }else{
            return (viewPooledEthAmount(tokenAddress,who).mul( now.sub(timePooled[tokenAddress][who]) ));
        }
    }
    
    function viewRewardTokenAmount(address tokenAddress, address who) public view returns (uint){
        return earnCalc( tokenAddress, rewards[tokenAddress][who].add(viewRecentRewardTokenAmount(tokenAddress, who))*2 );
    }
    
    function viewLPTokenAmount(address tokenAddress, address who) public view returns (uint){
        return LPTokenBalance[tokenAddress][who];
    }
    
    function viewPooledEthAmount(address tokenAddress, address who) public view returns (uint){
      
        address poolAddress = Uniswap(FACTORY).getPair(tokenAddress, WETHAddress);
        uint ethAmount = IERC20(WETHAddress).balanceOf(poolAddress); //Eth in uniswap
        
        return (ethAmount.mul(viewLPTokenAmount(tokenAddress, who))).div(IERC20(poolAddress).totalSupply());
    }
    
    function viewPooledTokenAmount(address tokenAddress, address who) public view returns (uint){
        
        address poolAddress = Uniswap(FACTORY).getPair(tokenAddress, WETHAddress);
        uint tokenAmount = IERC20(tokenAddress).balanceOf(poolAddress); //token in uniswap
        
        return (tokenAmount.mul(viewLPTokenAmount(tokenAddress, who))).div(IERC20(poolAddress).totalSupply());
    }
    
    function viewReferralEarned(address who) public view returns (uint){
        return referralEarned[who];
    }
    
    function price() public view returns (uint){
        
        address poolAddress = Uniswap(FACTORY).getPair(KYE_TOKEN_ADDRESS, WETHAddress);
        
        uint ethAmount = IERC20(WETHAddress).balanceOf(poolAddress); //Eth in uniswap
        uint tokenAmount = IERC20(KYE_TOKEN_ADDRESS).balanceOf(poolAddress); //token in uniswap
        
        return (DECIMAL.mul(ethAmount)).div(tokenAmount);
    }

    function earnCalc(address token, uint ethTime) public view returns(uint){
        
        if(token == KYE_TOKEN_ADDRESS){
            return ( kyePromo * rewardValue * ethTime ) / ( 31557600 * DECIMAL );
        }else{
            return ( rewardValue * ethTime  ) / ( 31557600 * DECIMAL );
        }
    }
    
    function ethtimeCalc(address token, uint kye) internal view returns(uint){
        
        if(token == KYE_TOKEN_ADDRESS){
            return ( kye.mul(31557600 * DECIMAL) ).div( kyePromo.mul(rewardValue) );
        }else{
            return ( kye.mul(31557600 * DECIMAL) ).div( rewardValue );
        }
    }
}
