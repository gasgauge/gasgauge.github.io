/**
 *Submitted for verification at Etherscan.io on 2020-09-30
*/

// File: contracts/modules/SafeMath.sol

//pragma solidity =0.5.16;
pragma solidity >=0.5 <0.7.17;

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)

library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'SafeMath: addition overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'SafeMath: substraction underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'SafeMath: multiplication overflow');
    }
}

// File: contracts/modules/SafeInt256.sol

//pragma solidity =0.5.16;
pragma solidity >=0.5 <0.7.17;
library SafeInt256 {
    function add(int256 x, int256 y) internal pure returns (int256 z) {
        require(((z = x + y) >= x) == (y >= 0), 'SafeInt256: addition overflow');
    }

    function sub(int256 x, int256 y) internal pure returns (int256 z) {
        require(((z = x - y) <= x) == (y >= 0), 'SafeInt256: substraction underflow');
    }

    function mul(int256 x, int256 y) internal pure returns (int256 z) {
        require(y == 0 || (z = x * y) / y == x, 'SafeInt256: multiplication overflow');
    }
}

// File: contracts/modules/Ownable.sol

//pragma solidity =0.5.16;
pragma solidity >=0.5 <0.7.17;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/modules/Halt.sol

//pragma solidity =0.5.16;
pragma solidity >=0.5 <0.7.17;


contract Halt is Ownable {

    bool private halted = false;

    modifier notHalted() {
        require(!halted,"This contract is halted");
        _;
    }

    modifier isHalted() {
        require(halted,"This contract is not halted");
        _;
    }

    /// @notice function Emergency situation that requires
    /// @notice contribution period to stop or not.
    function setHalt(bool halt)
        public
        onlyOwner
    {
        halted = halt;
    }
}

// File: contracts/modules/whiteList.sol

//pragma solidity =0.5.16;
pragma solidity >=0.5 <0.7.17;
    /**
     * @dev Implementation of a whitelist which filters a eligible uint32.
     */
library whiteListUint32 {
    /**
     * @dev add uint32 into white list.
     * @param whiteList the storage whiteList.
     * @param temp input value
     */

    function addWhiteListUint32(uint32[] storage whiteList,uint32 temp) internal{
        if (!isEligibleUint32(whiteList,temp)){
            whiteList.push(temp);
        }
    }
    /**
     * @dev remove uint32 from whitelist.
     */
    function removeWhiteListUint32(uint32[] storage whiteList,uint32 temp)internal returns (bool) {
        uint256 len = whiteList.length;
        uint256 i=0;
        for (;i<len;i++){
            if (whiteList[i] == temp)
                break;
        }
        if (i<len){
            if (i!=len-1) {
                whiteList[i] = whiteList[len-1];
            }
            whiteList.length--;
            return true;
        }
        return false;
    }
    function isEligibleUint32(uint32[] memory whiteList,uint32 temp) internal pure returns (bool){
        uint256 len = whiteList.length;
        for (uint256 i=0;i<len;i++){
            if (whiteList[i] == temp)
                return true;
        }
        return false;
    }
    function _getEligibleIndexUint32(uint32[] memory whiteList,uint32 temp) internal pure returns (uint256){
        uint256 len = whiteList.length;
        uint256 i=0;
        for (;i<len;i++){
            if (whiteList[i] == temp)
                break;
        }
        return i;
    }
}
    /**
     * @dev Implementation of a whitelist which filters a eligible uint256.
     */
library whiteListUint256 {
    // add whiteList
    function addWhiteListUint256(uint256[] storage whiteList,uint256 temp) internal{
        if (!isEligibleUint256(whiteList,temp)){
            whiteList.push(temp);
        }
    }
    function removeWhiteListUint256(uint256[] storage whiteList,uint256 temp)internal returns (bool) {
        uint256 len = whiteList.length;
        uint256 i=0;
        for (;i<len;i++){
            if (whiteList[i] == temp)
                break;
        }
        if (i<len){
            if (i!=len-1) {
                whiteList[i] = whiteList[len-1];
            }
            whiteList.length--;
            return true;
        }
        return false;
    }
    function isEligibleUint256(uint256[] memory whiteList,uint256 temp) internal pure returns (bool){
        uint256 len = whiteList.length;
        for (uint256 i=0;i<len;i++){
            if (whiteList[i] == temp)
                return true;
        }
        return false;
    }
    function _getEligibleIndexUint256(uint256[] memory whiteList,uint256 temp) internal pure returns (uint256){
        uint256 len = whiteList.length;
        uint256 i=0;
        for (;i<len;i++){
            if (whiteList[i] == temp)
                break;
        }
        return i;
    }
}
    /**
     * @dev Implementation of a whitelist which filters a eligible address.
     */
library whiteListAddress {
    // add whiteList
    function addWhiteListAddress(address[] storage whiteList,address temp) internal{
        if (!isEligibleAddress(whiteList,temp)){
            whiteList.push(temp);
        }
    }
    function removeWhiteListAddress(address[] storage whiteList,address temp)internal returns (bool) {
        uint256 len = whiteList.length;
        uint256 i=0;
        for (;i<len;i++){
            if (whiteList[i] == temp)
                break;
        }
        if (i<len){
            if (i!=len-1) {
                whiteList[i] = whiteList[len-1];
            }
            whiteList.length--;
            return true;
        }
        return false;
    }
    function isEligibleAddress(address[] memory whiteList,address temp) internal pure returns (bool){
        uint256 len = whiteList.length;
        for (uint256 i=0;i<len;i++){
            if (whiteList[i] == temp)
                return true;
        }
        return false;
    }
    function _getEligibleIndexAddress(address[] memory whiteList,address temp) internal pure returns (uint256){
        uint256 len = whiteList.length;
        uint256 i=0;
        for (;i<len;i++){
            if (whiteList[i] == temp)
                break;
        }
        return i;
    }
}

// File: contracts/modules/AddressWhiteList.sol

//pragma solidity =0.5.16;
pragma solidity >=0.5 <0.7.17;


    /**
     * @dev Implementation of a whitelist filters a eligible address.
     */
contract AddressWhiteList is Halt {

    using whiteListAddress for address[];
    uint256 constant internal allPermission = 0xffffffff;
    uint256 constant internal allowBuyOptions = 1;
    uint256 constant internal allowSellOptions = 1<<1;
    uint256 constant internal allowExerciseOptions = 1<<2;
    uint256 constant internal allowAddCollateral = 1<<3;
    uint256 constant internal allowRedeemCollateral = 1<<4;
    // The eligible adress list
    address[] internal whiteList;
    mapping(address => uint256) internal addressPermission;
    /**
     * @dev Implementation of add an eligible address into the whitelist.
     * @param addAddress new eligible address.
     */
    function addWhiteList(address addAddress)public onlyOwner{
        whiteList.addWhiteListAddress(addAddress);
        addressPermission[addAddress] = allPermission;
    }
    function modifyPermission(address addAddress,uint256 permission)public onlyOwner{
        addressPermission[addAddress] = permission;
    }
    /**
     * @dev Implementation of revoke an invalid address from the whitelist.
     * @param removeAddress revoked address.
     */
    function removeWhiteList(address removeAddress)public onlyOwner returns (bool){
        addressPermission[removeAddress] = 0;
        return whiteList.removeWhiteListAddress(removeAddress);
    }
    /**
     * @dev Implementation of getting the eligible whitelist.
     */
    function getWhiteList()public view returns (address[] memory){
        return whiteList;
    }
    /**
     * @dev Implementation of testing whether the input address is eligible.
     * @param tmpAddress input address for testing.
     */
    function isEligibleAddress(address tmpAddress) public view returns (bool){
        return whiteList.isEligibleAddress(tmpAddress);
    }
    function checkAddressPermission(address tmpAddress,uint256 state) public view returns (bool){
        return  (addressPermission[tmpAddress]&state) == state;
    }
}

// File: contracts/modules/ReentrancyGuard.sol

//pragma solidity =0.5.16;
pragma solidity >=0.5 <0.7.17;
contract ReentrancyGuard {

  /**
   * @dev We use a single lock for the whole contract.
   */
  bool private reentrancyLock = false;
  /**
   * @dev Prevents a contract from calling itself, directly or indirectly.
   * @notice If you mark a function `nonReentrant`, you should also
   * mark it `external`. Calling one nonReentrant function from
   * another is not supported. Instead, you can implement a
   * `private` function doing the actual work, and a `external`
   * wrapper marked as `nonReentrant`.
   */
  modifier nonReentrant() {
    require(!reentrancyLock);
    reentrancyLock = true;
    _;
    reentrancyLock = false;
  }

}

// File: contracts/OptionsPool/IOptionsPool.sol

//pragma solidity =0.5.16;
pragma solidity >=0.5 <0.7.17;

interface IOptionsPool {
//    function getOptionBalances(address user) external view returns(uint256[]);

    function createOptions(address from,address settlement,uint256 type_ly_exp,uint256 strikePrice,uint256 underlyingPrice,
                uint256 amount)  external;
    function setSharedState(uint256 newFirstOption,int256[] calldata latestNetWorth,address[] calldata whiteList) external;
    function getCallTotalOccupiedCollateral() external view returns (uint256);
    function getPutTotalOccupiedCollateral() external view returns (uint256);
    function getTotalOccupiedCollateral() external view returns (uint256);
    function buyOptionCheck(uint256 expiration,uint32 underlying)external view;
    function burnOptions(address from,uint256 id,uint256 amount,uint256 optionPrice)external;
    function getOptionsById(uint256 optionsId)external view returns(uint256,address,uint8,uint32,uint256,uint256,uint256);
    function getExerciseWorth(uint256 optionsId,uint256 amount)external view returns(uint256);
    function calculatePhaseOptionsFall(uint256 lastOption,uint256 begin,uint256 end,address[] calldata whiteList) external view returns(int256[] memory);
    function getOptionInfoLength()external view returns (uint256);
    function getNetWrothCalInfo(address[] calldata whiteList)external view returns(uint256,int256[] memory);
    function calRangeSharedPayment(uint256 lastOption,uint256 begin,uint256 end,address[] calldata whiteList)external view returns(int256[] memory,uint256[] memory,uint256);
    function getNetWrothLatestWorth(address settlement)external view returns(int256);
    function getBurnedFullPay(uint256 optionID,uint256 amount) external view returns(address,uint256);

}
contract ImportOptionsPool is Ownable{
    IOptionsPool internal _optionsPool;
    function getOptionsPoolAddress() public view returns(address){
        return address(_optionsPool);
    }
    function setOptionsPoolAddress(address optionsPool)public onlyOwner{
        _optionsPool = IOptionsPool(optionsPool);
    }
}

// File: contracts/interfaces/IFNXOracle.sol

//pragma solidity =0.5.16;
pragma solidity >=0.5 <0.7.17;

interface IFNXOracle {
    /**
  * @notice retrieves price of an asset
  * @dev function to get price for an asset
  * @param asset Asset for which to get the price
  * @return uint mantissa of asset price (scaled by 1e8) or zero if unset or contract paused
  */
    function getPrice(address asset) external view returns (uint256);
    function getUnderlyingPrice(uint256 cToken) external view returns (uint256);
//    function getSellOptionsPrice(address oToken) external view returns (uint256);
//    function getBuyOptionsPrice(address oToken) external view returns (uint256);
}
contract ImportOracle is Ownable{
    IFNXOracle internal _oracle;
    function oraclePrice(address asset) internal view returns (uint256){
        uint256 price = _oracle.getPrice(asset);
        require(price >= 100 && price <= 1e30);
        return price;
    }
    function oracleUnderlyingPrice(uint256 cToken) internal view returns (uint256){
        uint256 price = _oracle.getUnderlyingPrice(cToken);
        require(price >= 100 && price <= 1e30);
        return price;
    }
    function getOracleAddress() public view returns(address){
        return address(_oracle);
    }
    function setOracleAddress(address oracle)public onlyOwner{
        _oracle = IFNXOracle(oracle);
    }
}

// File: contracts/interfaces/IOptionsPrice.sol

//pragma solidity =0.5.16;
pragma solidity >=0.5 <0.7.17;

interface IOptionsPrice {
    function getOptionsPrice(uint256 currentPrice, uint256 strikePrice, uint256 expiration,uint32 underlying,uint8 optType)external view returns (uint256);
    function getOptionsPrice_iv(uint256 currentPrice, uint256 strikePrice, uint256 expiration,
                uint256 ivNumerator,uint256 ivDenominator,uint8 optType)external view returns (uint256);
    function calOptionsPriceRatio(uint256 selfOccupied,uint256 totalOccupied,uint256 totalCollateral) external view returns (uint256,uint256);
}
contract ImportOptionsPrice is Ownable{
    IOptionsPrice internal _optionsPrice;
    function getOptionsPriceAddress() public view returns(address){
        return address(_optionsPrice);
    }
    function setOptionsPriceAddress(address optionsPrice)public onlyOwner{
        _optionsPrice = IOptionsPrice(optionsPrice);
    }
}

// File: contracts/CollateralPool/ICollateralPool.sol

//pragma solidity =0.5.16;
pragma solidity >=0.5 <0.7.17;

interface ICollateralPool {
    function getUserPayingUsd(address user)external view returns (uint256);
    function getUserInputCollateral(address user,address collateral)external view returns (uint256);
    //function getNetWorthBalance(address collateral)external view returns (int256);
    function getCollateralBalance(address collateral)external view returns (uint256);

    //add
    function addUserPayingUsd(address user,uint256 amount)external;
    function addUserInputCollateral(address user,address collateral,uint256 amount)external;
    function addNetWorthBalance(address collateral,int256 amount)external;
    function addCollateralBalance(address collateral,uint256 amount)external;
    //sub
    function subUserPayingUsd(address user,uint256 amount)external;
    function subUserInputCollateral(address user,address collateral,uint256 amount)external;
    function subNetWorthBalance(address collateral,int256 amount)external;
    function subCollateralBalance(address collateral,uint256 amount)external;
        //set
    function setUserPayingUsd(address user,uint256 amount)external;
    function setUserInputCollateral(address user,address collateral,uint256 amount)external;
    function setNetWorthBalance(address collateral,int256 amount)external;
    function setCollateralBalance(address collateral,uint256 amount)external;
    function transferPaybackAndFee(address recieptor,address settlement,uint256 payback,uint256 feeType)external;

    function transferPayback(address recieptor,address settlement,uint256 payback)external;
    function transferPaybackBalances(address account,uint256 redeemWorth,address[] calldata tmpWhiteList,uint256[] calldata colBalances,
        uint256[] calldata PremiumBalances,uint256[] calldata prices)external;
    function getCollateralAndPremiumBalances(address account,uint256 userTotalWorth,address[] calldata tmpWhiteList,
        uint256[] calldata _RealBalances,uint256[] calldata prices) external view returns(uint256[] memory,uint256[] memory);
    function addTransactionFee(address collateral,uint256 amount,uint256 feeType)external returns (uint256);

    function getRealBalance(address settlement)external view returns(int256);
    function getNetWorthBalance(address settlement)external view returns(uint256);
}
contract ImportCollateralPool is Ownable{
    ICollateralPool internal _collateralPool;
    function getCollateralPoolAddress() public view returns(address){
        return address(_collateralPool);
    }
    function setCollateralPoolAddress(address collateralPool)public onlyOwner{
        _collateralPool = ICollateralPool(collateralPool);
    }
}

// File: contracts/FPTCoin/IFPTCoin.sol

//pragma solidity =0.5.16;
pragma solidity >=0.5 <0.7.17;

interface IFPTCoin {
    function lockedBalanceOf(address account) external view returns (uint256);
    function lockedWorthOf(address account) external view returns (uint256);
    function getLockedBalance(address account) external view returns (uint256,uint256);
    function balanceOf(address account) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function mint(address account, uint256 amount) external;
    function burn(address account, uint256 amount) external;
    function addlockBalance(address account, uint256 amount,uint256 lockedWorth)external;
    function getTotalLockedWorth() external view returns (uint256);
    function addMinerBalance(address account,uint256 amount) external;
    function redeemLockedCollateral(address account,uint256 tokenAmount,uint256 leftCollateral)external returns (uint256,uint256);
}
contract ImportIFPTCoin is Ownable{
    IFPTCoin internal _FPTCoin;
    function getFPTCoinAddress() public view returns(address){
        return address(_FPTCoin);
    }
    function setFPTCoinAddress(address FPTCoinAddr)public onlyOwner{
        _FPTCoin = IFPTCoin(FPTCoinAddr);
    }
}

// File: contracts/modules/ImputRange.sol

//pragma solidity =0.5.16;
pragma solidity >=0.5 <0.7.17;


contract ImputRange is Ownable {

    //The maximum input amount limit.
    uint256 private maxAmount = 1e30;
    //The minimum input amount limit.
    uint256 private minAmount = 1e2;

    modifier InRange(uint256 amount) {
        require(maxAmount>=amount && minAmount<=amount,"input amount is out of input amount range");
        _;
    }
    /**
     * @dev Determine whether the input amount is within the valid range
     * @param Amount Test value which is user input
     */
    function isInputAmountInRange(uint256 Amount)public view returns (bool){
        return(maxAmount>=Amount && minAmount<=Amount);
    }
    /*
    function isInputAmountSmaller(uint256 Amount)public view returns (bool){
        return maxAmount>=amount;
    }
    function isInputAmountLarger(uint256 Amount)public view returns (bool){
        return minAmount<=amount;
    }
    */
    modifier Smaller(uint256 amount) {
        require(maxAmount>=amount,"input amount is larger than maximium");
        _;
    }
    modifier Larger(uint256 amount) {
        require(minAmount<=amount,"input amount is smaller than maximium");
        _;
    }
    /**
     * @dev get the valid range of input amount
     */
    function getInputAmountRange() public view returns(uint256,uint256) {
        return (minAmount,maxAmount);
    }
    /**
     * @dev set the valid range of input amount
     * @param _minAmount the minimum input amount limit
     * @param _maxAmount the maximum input amount limit
     */
    function setInputAmountRange(uint256 _minAmount,uint256 _maxAmount) public onlyOwner{
        minAmount = _minAmount;
        maxAmount = _maxAmount;
    }
}

// File: contracts/modules/Allowances.sol

//pragma solidity =0.5.16;
pragma solidity >=0.5 <0.7.17;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * each operator can be granted exclusive access to specific functions.
 *
 */
contract Allowances is Ownable {
    mapping (address => uint256) internal allowances;
    bool internal bValid = true;
    /**
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public onlyOwner{
        allowances[spender] = amount;
    }
    function allowance(address spender) public view returns (uint256) {
        return allowances[spender];
    }
    function setValid(bool _bValid) public onlyOwner{
        bValid = _bValid;
    }
    function checkAllowance(address spender, uint256 amount) public view returns(bool){
        return (!bValid) || (allowances[spender] >= amount);
    }
    modifier sufficientAllowance(address spender, uint256 amount){
        require((!bValid) || (allowances[spender] >= amount),"Allowances : user's allowance is unsufficient!");
        _;
    }
}

// File: contracts/ERC20/IERC20.sol

//pragma solidity =0.5.16;
pragma solidity >=0.5 <0.7.17;
/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/OptionsManager/ManagerData.sol

//pragma solidity =0.5.16;
pragma solidity >=0.5 <0.7.17;










/**
 * @title collateral calculate module
 * @dev A smart-contract which has operations of collateral and methods of calculate collateral occupation.
 *
 */
contract ManagerData is ReentrancyGuard,ImputRange,AddressWhiteList,Allowances,ImportIFPTCoin,
                ImportOracle,ImportOptionsPool,ImportCollateralPool,ImportOptionsPrice {
    // The minimum collateral rate for options. This value is thousandths.
    mapping (address=>uint256) collateralRate;
//    uint256 private collateralRate = 5000;
    /**
     * @dev Emitted when `from` added `amount` collateral and minted `tokenAmount` FPTCoin.
     */
    event AddCollateral(address indexed from,address indexed collateral,uint256 amount,uint256 tokenAmount);
    /**
     * @dev Emitted when `from` redeemed `allRedeem` collateral.
     */
    event RedeemCollateral(address indexed from,address collateral,uint256 allRedeem);

        /**
    * @dev input price valid range rate, thousandths.
    * the input price must greater than current price * minPriceRate /1000
    *       and less  than current price * maxPriceRate /1000
    * maxPriceRate is the maximum limit of the price valid range rate
    * maxPriceRate is the minimum limit of the price valid range rage
    */
    uint256 internal maxPriceRate = 1500;
    uint256 internal minPriceRate = 500;
    /**
     * @dev Emitted when `from` buy `optionAmount` option and create new option.
     * @param from user's account
     * @param settlement user's input settlement paid for buy new option.
     * @param optionId new option's id
     * @param optionPrice option's paid price
     * @param settlementAmount settement cost
     * @param optionAmount mint option token amount.
     */
    event BuyOption(address indexed from,address indexed settlement,uint256 indexed optionId,uint256 optionPrice,uint256 settlementAmount,uint256 optionAmount);
    /**
     * @dev Emitted when `from` sell `amount` option whose id is `optionId` and received sellValue,priced in usd.
     */
    event SellOption(address indexed from,uint256 indexed optionId,uint256 amount,uint256 sellValue);
    /**
     * @dev Emitted when `from` exercise `amount` option whose id is `optionId` and received sellValue,priced in usd.
     */
    event ExerciseOption(address indexed from,uint256 indexed optionId,uint256 amount,uint256 sellValue);
}

// File: contracts/OptionsManager/CollateralCal.sol

//pragma solidity =0.5.16;
pragma solidity >=0.5 <0.7.17;



/**
 * @title collateral calculate module
 * @dev A smart-contract which has operations of collateral and methods of calculate collateral occupation.
 *
 */
contract CollateralCal is ManagerData {
    using SafeMath for uint256;
    using SafeInt256 for int256;

    /**
     * @dev  The foundation owner want to set the minimum collateral occupation rate.
     * @param collateral collateral coin address
     * @param colRate The thousandths of the minimum collateral occupation rate.
     */
    function setCollateralRate(address collateral,uint256 colRate) public onlyOwner {
        addWhiteList(collateral);
        collateralRate[collateral] = colRate;
//        collateralRate = colRate;

    }
    /**
     * @dev Get the minimum collateral occupation rate.
     */
    function getCollateralRate(address collateral)public view returns (uint256) {
        return collateralRate[collateral];
    }
    /**
     * @dev Retrieve user's cost of collateral, priced in USD.
     * @param user input retrieved account
     */
    function getUserPayingUsd(address user)public view returns (uint256){
        return _collateralPool.getUserPayingUsd(user);
        //userCollateralPaying[user];
    }
    /**
     * @dev Retrieve user's amount of the specified collateral.
     * @param user input retrieved account
     * @param collateral input retrieved collateral coin address
     */
    function userInputCollateral(address user,address collateral)public view returns (uint256){
        return _collateralPool.getUserInputCollateral(user,collateral);
        //return userInputCollateral[user][collateral];
    }

    /**
     * @dev Retrieve user's current total worth, priced in USD.
     * @param account input retrieve account
     */
    function getUserTotalWorth(address account)public view returns (uint256){
        return getTokenNetworth().mul(_FPTCoin.balanceOf(account)).add(_FPTCoin.lockedWorthOf(account));
    }
    /**
     * @dev Retrieve FPTCoin's net worth, priced in USD.
     */
    function getTokenNetworth() public view returns (uint256){
        uint256 _totalSupply = _FPTCoin.totalSupply();
        if (_totalSupply == 0){
            return 1e8;
        }
        uint256 netWorth = getUnlockedCollateral()/_totalSupply;
        return netWorth>100 ? netWorth : 100;
    }
    /**
     * @dev Deposit collateral in this pool from user.
     * @param collateral The collateral coin address which is in whitelist.
     * @param amount the amount of collateral to deposit.
     */
    function addCollateral(address collateral,uint256 amount) nonReentrant notHalted  public payable {
        amount = getPayableAmount(collateral,amount);
        uint256 fee = _collateralPool.addTransactionFee(collateral,amount,3);
        amount = amount-fee;
        uint256 price = oraclePrice(collateral);
        uint256 userPaying = price*amount;
        require(checkAllowance(msg.sender,(_collateralPool.getUserPayingUsd(msg.sender)+userPaying)/1e8),
            "Allowances : user's allowance is unsufficient!");
        uint256 mintAmount = userPaying/getTokenNetworth();
        _collateralPool.addUserPayingUsd(msg.sender,userPaying);
        _collateralPool.addCollateralBalance(collateral,amount);
        _collateralPool.addUserInputCollateral(msg.sender,collateral,amount);
         _collateralPool.addNetWorthBalance(collateral,int256(amount));
        emit AddCollateral(msg.sender,collateral,amount,mintAmount);
        _FPTCoin.mint(msg.sender,mintAmount);
    }
    /**
     * @dev redeem collateral from this pool, user can input the prioritized collateral,he will get this coin,
     * if this coin is unsufficient, he will get others collateral which in whitelist.
     * @param tokenAmount the amount of FPTCoin want to redeem.
     * @param collateral The prioritized collateral coin address.
     */
    function redeemCollateral(uint256 tokenAmount,address collateral) nonReentrant notHalted InRange(tokenAmount) public {
        require(checkAddressPermission(collateral,allowRedeemCollateral) , "settlement is unsupported token");
        uint256 lockedAmount = _FPTCoin.lockedBalanceOf(msg.sender);
        require(_FPTCoin.balanceOf(msg.sender)+lockedAmount>=tokenAmount,"SCoin balance is insufficient!");
        uint256 userTotalWorth = getUserTotalWorth(msg.sender);
        uint256 leftCollateral = getLeftCollateral();
        (uint256 burnAmount,uint256 redeemWorth) = _FPTCoin.redeemLockedCollateral(msg.sender,tokenAmount,leftCollateral);
        tokenAmount -= burnAmount;
        burnAmount = 0;
        if (tokenAmount > 0){
            leftCollateral -= redeemWorth;

            if (lockedAmount > 0){
                tokenAmount = tokenAmount > lockedAmount ? tokenAmount - lockedAmount : 0;
            }
            (uint256 newRedeem,uint256 newWorth) = _redeemCollateral(tokenAmount,leftCollateral);
            if(newRedeem>0){
                burnAmount = newRedeem;
                redeemWorth += newWorth;
            }
        }
        _redeemCollateralWorth(collateral,redeemWorth,userTotalWorth);
        if (burnAmount>0){
            _FPTCoin.burn(msg.sender, burnAmount);
        }
    }
    /**
     * @dev The subfunction of redeem collateral.
     * @param leftAmount the left amount of FPTCoin want to redeem.
     * @param leftCollateral The left collateral which can be redeemed, priced in USD.
     */
    function _redeemCollateral(uint256 leftAmount,uint256 leftCollateral)internal returns (uint256,uint256){
        uint256 tokenNetWorth = getTokenNetworth();
        uint256 leftWorth = leftAmount*tokenNetWorth;
        if (leftWorth > leftCollateral){
            uint256 newRedeem = leftCollateral/tokenNetWorth;
            uint256 newWorth = newRedeem*tokenNetWorth;
            uint256 locked = leftAmount - newRedeem;
            _FPTCoin.addlockBalance(msg.sender,locked,locked*tokenNetWorth);
            return (newRedeem,newWorth);
        }
        return (leftAmount,leftWorth);
    }
    /**
     * @dev The auxiliary function of collateral calculation.
     * @param collateral the prioritized collateral which user input.
     * @return the collateral whitelist, in which the prioritized collateral is at the front.
     */
    function getTempWhiteList(address collateral) internal view returns (address[] memory) {
        address[] memory tmpWhiteList = whiteList;
        uint256 index = whiteListAddress._getEligibleIndexAddress(tmpWhiteList,collateral);
        if (index != 0){
            tmpWhiteList[index] = tmpWhiteList[0];
            tmpWhiteList[0] = collateral;
        }
        return tmpWhiteList;
    }
    /**
     * @dev The subfunction of redeem collateral. Calculate all redeem count and tranfer.
     * @param collateral the prioritized collateral which user input.
     * @param redeemWorth user redeem worth, priced in USD.
     * @param userTotalWorth user total worth, priced in USD.
     */
    function _redeemCollateralWorth(address collateral,uint256 redeemWorth,uint256 userTotalWorth) internal {
        if (redeemWorth == 0){
            return;
        }
        emit RedeemCollateral(msg.sender,collateral,redeemWorth);
        address[] memory tmpWhiteList = getTempWhiteList(collateral);
        (uint256[] memory colBalances,uint256[] memory PremiumBalances,uint256[] memory prices) =
                _getCollateralAndPremiumBalances(msg.sender,userTotalWorth,tmpWhiteList);
        _collateralPool.transferPaybackBalances(msg.sender,redeemWorth,tmpWhiteList,colBalances,
                PremiumBalances,prices);
    }
    /**
     * @dev Retrieve user's collateral worth in all collateral coin.
     * If user want to redeem all his collateral,and the vacant collateral is sufficient,
     * He can redeem each collateral amount in return list.
     * @param account the retrieve user's account;
     */
    function calCollateralWorth(address account)public view returns(uint256[] memory){
        uint256 worth = getUserTotalWorth(account);
        (uint256[] memory colBalances,uint256[] memory PremiumBalances,) =
        _getCollateralAndPremiumBalances(account,worth,whiteList);
        uint256 whiteLen = whiteList.length;
        for (uint256 i=0; i<whiteLen;i++){
            colBalances[i] = colBalances[i].add(PremiumBalances[i]);
        }
        return colBalances;
    }
    /**
     * @dev The auxiliary function for redeem collateral calculation.
     * @param account the retrieve user's account;
     * @param userTotalWorth user's total worth, priced in USD.
     * @param tmpWhiteList the collateral white list.
     * @return user's total worth in each collateral, priced in USD.
     */
    function _getCollateralAndPremiumBalances(address account,uint256 userTotalWorth,address[] memory tmpWhiteList) internal view returns(uint256[] memory,uint256[] memory,uint256[] memory){
        uint256[] memory prices = new uint256[](tmpWhiteList.length);
        uint256[] memory netWorthBalances = new uint256[](tmpWhiteList.length);
        for (uint256 i=0; i<tmpWhiteList.length;i++){
            if (checkAddressPermission(tmpWhiteList[i],0x0002)){
                netWorthBalances[i] = getNetWorthBalance(tmpWhiteList[i]);
            }
            prices[i] = oraclePrice(tmpWhiteList[i]);
        }
        (uint256[] memory colBalances,uint256[] memory PremiumBalances) = _collateralPool.getCollateralAndPremiumBalances(account,userTotalWorth,tmpWhiteList,
                netWorthBalances,prices);
        return (colBalances,PremiumBalances,prices);
    }
    /**
     * @dev Retrieve the occupied collateral worth, multiplied by minimum collateral rate, priced in USD.
     */
    function getOccupiedCollateral() public view returns(uint256){
        uint256 totalOccupied = _optionsPool.getTotalOccupiedCollateral();
        return calculateCollateral(totalOccupied);
    }
    /**
     * @dev Retrieve the available collateral worth, the worth of collateral which can used for buy options, priced in USD.
     */
    function getAvailableCollateral()public view returns(uint256){
        return safeSubCollateral(getUnlockedCollateral(),getOccupiedCollateral());
    }
    /**
     * @dev Retrieve the left collateral worth, the worth of collateral which can used for redeem collateral, priced in USD.
     */
    function getLeftCollateral()public view returns(uint256){
        return safeSubCollateral(getTotalCollateral(),getOccupiedCollateral());
    }
    /**
     * @dev Retrieve the unlocked collateral worth, the worth of collateral which currently used for options, priced in USD.
     */
    function getUnlockedCollateral()public view returns(uint256){
        return safeSubCollateral(getTotalCollateral(),_FPTCoin.getTotalLockedWorth());
    }
    /**
     * @dev The auxiliary function for collateral worth subtraction.
     */
    function safeSubCollateral(uint256 allCollateral,uint256 subCollateral)internal pure returns(uint256){
        return allCollateral > subCollateral ? allCollateral - subCollateral : 0;
    }
    /**
     * @dev The auxiliary function for calculate option occupied.
     * @param strikePrice option's strike price
     * @param underlyingPrice option's underlying price
     * @param amount option's amount
     * @param optType option's type, 0 for call, 1 for put.
     */
    function calOptionsOccupied(uint256 strikePrice,uint256 underlyingPrice,uint256 amount,uint8 optType)public view returns(uint256){
        uint256 totalOccupied = 0;
        if ((optType == 0) == (strikePrice>underlyingPrice)){ // call
            totalOccupied = strikePrice*amount;
        } else {
            totalOccupied = underlyingPrice*amount;
        }
        return calculateCollateral(totalOccupied);
    }
    /**
     * @dev Retrieve the total collateral worth, priced in USD.
     */
    function getTotalCollateral()public view returns(uint256){
        int256 totalNum = 0;
        uint whiteListLen = whiteList.length;
        for (uint256 i=0;i<whiteListLen;i++){
            address addr = whiteList[i];
            int256 price = int256(oraclePrice(addr));
            int256 netWorth = getRealBalance(addr);
            if (netWorth != 0){
                totalNum = totalNum.add(price.mul(netWorth));
            }
        }
        return totalNum>=0 ? uint256(totalNum) : 0;
    }
    /**
     * @dev Retrieve the balance of collateral, the auxiliary function for the total collateral calculation.
     */
    function getRealBalance(address settlement)public view returns(int256){
        return _collateralPool.getRealBalance(settlement);
    }
    function getNetWorthBalance(address settlement)public view returns(uint256){
        return _collateralPool.getNetWorthBalance(settlement);
    }
    /**
     * @dev the auxiliary function for payback.
     */
    function _paybackWorth(uint256 worth,uint256 feeType) internal {
        uint256 totalPrice = 0;
        uint whiteLen = whiteList.length;
        uint256[] memory balances = new uint256[](whiteLen);
        uint256 i=0;
        for(;i<whiteLen;i++){
            address addr = whiteList[i];
            if (checkAddressPermission(addr,allowSellOptions)){
                uint256 price = oraclePrice(addr);
                balances[i] = getNetWorthBalance(addr);
                //balances[i] = netWorthBalances[addr];
                totalPrice = totalPrice.add(price.mul(balances[i]));
            }
        }
        require(totalPrice>=worth && worth > 0,"payback settlement is insufficient!");
        for (i=0;i<whiteLen;i++){
            uint256 _payBack = balances[i].mul(worth)/totalPrice;
            _collateralPool.transferPaybackAndFee(msg.sender,whiteList[i],_payBack,feeType);
            //addr = whiteList[i];
            //netWorthBalances[addr] = balances[i].sub(_payBack);
            //_transferPaybackAndFee(msg.sender,addr,_payBack,feeType);
        }
    }
    /**
     * @dev the auxiliary function for getting user's transer
     */
    function getPayableAmount(address settlement,uint256 settlementAmount) internal returns (uint256) {
        require(checkAddressPermission(settlement,allowBuyOptions) , "settlement is unsupported token");
        uint256 colAmount = 0;
        if (settlement == address(0)){
            colAmount = msg.value;
            address payable poolAddr = address(uint160(address(_collateralPool)));
            poolAddr.transfer(msg.value);
        }else if (settlementAmount > 0){
            IERC20 oToken = IERC20(settlement);
            uint256 preBalance = oToken.balanceOf(address(this));
            oToken.transferFrom(msg.sender, address(this), settlementAmount);
            uint256 afterBalance = oToken.balanceOf(address(this));
            require(afterBalance-preBalance==settlementAmount,"settlement token transfer error!");
            colAmount = settlementAmount;
            oToken.transfer(address(_collateralPool),settlementAmount);
        }
        require(isInputAmountInRange(colAmount),"input amount is out of input amount range");
        return colAmount;
    }
    /**
     * @dev collateral occupation rate calculation
     *      collateral occupation rate = sum(collateral Rate * collateral balance) / sum(collateral balance)
     */
    function calculateCollateralRate()public view returns (uint256){
        uint256 totalCollateral = 0;
        uint256 totalRate = 0;
        uint whiteLen = whiteList.length;
        uint256 i=0;
        for(;i<whiteLen;i++){
            address addr = whiteList[i];
            uint256 balance = getNetWorthBalance(addr);
            if (balance > 0 && collateralRate[addr] > 0){
                balance = oraclePrice(addr)*balance;
                totalCollateral = totalCollateral.add(balance);
                totalRate = totalRate.add(balance/collateralRate[addr]);
            }
        }
        if (totalRate > 0){
            return totalCollateral/totalRate;
        }else{
            return 5000;
        }
    }
    /**
     * @dev the auxiliary function for collateral calculation
     */
    function calculateCollateral(uint256 amount)internal view returns (uint256){
        return calculateCollateralRate()*amount/1000;
    }
}

// File: contracts/modules/tuple64.sol

//pragma solidity =0.5.16;
pragma solidity >=0.5 <0.7.17;
library tuple64 {
    // add whiteList
    function getValue0(uint256 input) internal pure returns (uint256){
        return uint256(uint64(input));
    }
    function getValue1(uint256 input) internal pure returns (uint256){
        return uint256(uint64(input>>64));
    }
    function getValue2(uint256 input) internal pure returns (uint256){
        return uint256(uint64(input>>128));
    }
    function getValue3(uint256 input) internal pure returns (uint256){
        return uint256(uint64(input>>192));
    }
    function getTuple(uint256 input0,uint256 input1,uint256 input2,uint256 input3) internal pure returns (uint256){
        return input0+(input1<<64)+(input2<<128)+(input3<<192);
    }
    function getTuple3(uint256 input0,uint256 input1,uint256 input2) internal pure returns (uint256){
        return input0+(input1<<64)+(input2<<128);
    }
    function getTuple2(uint256 input0,uint256 input1) internal pure returns (uint256){
        return input0+(input1<<64);
    }
}

// File: contracts/OptionsManager/OptionsManagerV2.sol

//pragma solidity =0.5.16;
pragma solidity >=0.5 <0.7.17;



/**
 * @title Options manager contract for finnexus proposal v2.
 * @dev A Smart-contract to manage Options pool, collatral pool, mine pool, FPTCoin, etc.
 *
 */
contract OptionsManagerV2 is CollateralCal {
    using SafeMath for uint256;

    /**
    * @dev Options manager constructor. set other contract address
    * @param oracleAddr fnx oracle contract address.
    * @param optionsPriceAddr options price contract address
    * @param optionsPoolAddr optoins pool contract address
    * @param FPTCoinAddr FPTCoin contract address
    */
    constructor (address oracleAddr,address optionsPriceAddr,address optionsPoolAddr,address collateralPoolAddr,address FPTCoinAddr) public{
        _oracle = IFNXOracle(oracleAddr);
        _optionsPrice = IOptionsPrice(optionsPriceAddr);
        _optionsPool = IOptionsPool(optionsPoolAddr);
        _collateralPool = ICollateralPool(collateralPoolAddr);
        _FPTCoin = IFPTCoin(FPTCoinAddr);
    }
    function initialize() onlyOwner public {

    }
    function update() onlyOwner public {

    }
    /**
    * @dev retrieve input price valid range rate, thousandths.
    */
    function getPriceRateRange() public view returns(uint256,uint256) {
        return (minPriceRate,maxPriceRate);
    }
    /**
    * @dev set input price valid range rate, thousandths.
    */
    function setPriceRateRange(uint256 _minPriceRate,uint256 _maxPriceRate) public onlyOwner{
        minPriceRate = _minPriceRate;
        maxPriceRate = _maxPriceRate;
    }
    /**
    * @dev check user input price is in valid range.
    * @param strikePrice user input strikePrice
    * @param underlyingPrice current underlying price.
    */
    function checkStrikePrice(uint256 strikePrice,uint256 underlyingPrice)internal view{
        require(underlyingPrice*maxPriceRate/1000>=strikePrice && underlyingPrice*minPriceRate/1000<=strikePrice,
                "strikePrice is out of price range");
    }
    /**
    * @dev user buy option and create new option.
    * @param settlement user's settement coin address
    * @param settlementAmount amount of settlement user want fo pay.
    * @param strikePrice user input option's strike price
    * @param underlying user input option's underlying id, 1 for BTC,2 for ETH
    * @param expiration user input expiration,time limit from now
    * @param amount user input amount of new option user want to buy.
    * @param optType user input option type
    */
    function buyOption(address settlement,uint256 settlementAmount, uint256 strikePrice,uint32 underlying,
                uint256 expiration,uint256 amount,uint8 optType) nonReentrant notHalted InRange(amount) public payable{
        _optionsPool.buyOptionCheck(expiration,underlying);
        uint256 ty_ly_exp = tuple64.getTuple(uint256(optType),uint256(underlying),uint256(expiration),0);
        uint256 underlyingPrice = oracleUnderlyingPrice(underlying);
        checkStrikePrice(strikePrice,underlyingPrice);
        uint256 optionPrice = getOptionsPrice(underlyingPrice,strikePrice,expiration,underlying,amount,optType);
        _optionsPool.createOptions(msg.sender,settlement,ty_ly_exp,strikePrice,optionPrice,amount);
        buyOption_sub(settlement,settlementAmount,optionPrice,amount);
    }
    /**
    * @dev subfunction of buy option.
    * @param settlement user's settement coin address
    * @param settlementAmount amount of settlement user want fo pay.
    * @param optionPrice new option's price
    * @param amount user input amount of new option user want to buy.
    */
    function buyOption_sub(address settlement,uint256 settlementAmount,
            uint256 optionPrice,uint256 amount)internal{
        settlementAmount = getPayableAmount(settlement,settlementAmount);
        uint256 settlePrice = oraclePrice(settlement);
        uint256 allPay = amount*optionPrice;
        uint256 allPayUSd = allPay/1e8;
        allPay = allPay/settlePrice;
        uint256 fee = _collateralPool.addTransactionFee(settlement,allPay,0);
        require(settlementAmount>=allPay+fee,"settlement asset is insufficient!");
        settlementAmount = settlementAmount.sub(allPay+fee);
        if (settlementAmount > 0){
            _collateralPool.transferPayback(msg.sender,settlement,settlementAmount);
        }
        uint256 id =_optionsPool.getOptionInfoLength();
        _FPTCoin.addMinerBalance(msg.sender,allPayUSd);
        emit BuyOption(msg.sender,settlement,id,optionPrice,allPay,amount);
    }
    /**
    * @dev User sell option.
    * @param optionsId option's ID which was wanted to sell, must owned by user
    * @param amount user input amount of option user want to sell.
    */
    function sellOption(uint256 optionsId,uint256 amount) nonReentrant notHalted InRange(amount) public{
        (,,uint8 optType,uint32 underlying,uint256 expiration,uint256 strikePrice,) = _optionsPool.getOptionsById(optionsId);
        expiration = expiration.sub(now);
        uint256 currentPrice = oracleUnderlyingPrice(underlying);
        uint256 optPrice = _optionsPrice.getOptionsPrice(currentPrice,strikePrice,expiration,underlying,optType);
        _optionsPool.burnOptions(msg.sender,optionsId,amount,optPrice);
        uint256 allPay = optPrice*amount;
        (address settlement,uint256 fullPay) = _optionsPool.getBurnedFullPay(optionsId,amount);
        _collateralPool.addNetWorthBalance(settlement,int256(fullPay));
        _paybackWorth(allPay,1);
        emit SellOption(msg.sender,optionsId,amount,allPay);
    }
    /**
    * @dev User exercise option.
    * @param optionsId option's ID which was wanted to exercise, must owned by user
    * @param amount user input amount of option user want to exercise.
    */
    function exerciseOption(uint256 optionsId,uint256 amount) nonReentrant notHalted InRange(amount) public{
        uint256 allPay = _optionsPool.getExerciseWorth(optionsId,amount);
        require(allPay > 0,"This option cannot exercise");
        (,,uint8 optType,uint32 underlying,uint256 expiration,uint256 strikePrice,) = _optionsPool.getOptionsById(optionsId);
        expiration = expiration.sub(now);
        uint256 currentPrice = oracleUnderlyingPrice(underlying);
        uint256 optPrice = _optionsPrice.getOptionsPrice(currentPrice,strikePrice,expiration,underlying,optType);
        _optionsPool.burnOptions(msg.sender,optionsId,amount,optPrice);
        (address settlement,uint256 fullPay) = _optionsPool.getBurnedFullPay(optionsId,amount);
        _collateralPool.addNetWorthBalance(settlement,int256(fullPay));
        _paybackWorth(allPay,2);
        emit ExerciseOption(msg.sender,optionsId,amount,allPay);
    }
    function getOptionsPrice(uint256 underlyingPrice, uint256 strikePrice, uint256 expiration,
                    uint32 underlying,uint256 amount,uint8 optType) public view returns(uint256){
        uint256 buyOccupied = calOptionsOccupied(strikePrice,underlyingPrice,amount,optType);
        require(getAvailableCollateral()>=buyOccupied,"collateral is insufficient!");
        uint256 optPrice = _optionsPrice.getOptionsPrice(underlyingPrice,strikePrice,expiration,underlying,optType);
        uint256 selfOccupied = optType == 0 ? _optionsPool.getCallTotalOccupiedCollateral() : _optionsPool.getPutTotalOccupiedCollateral();
        selfOccupied = calculateCollateral(selfOccupied) + buyOccupied;
        uint256 totalOccupied = getOccupiedCollateral() + buyOccupied;
        uint256 totalCollateral = getUnlockedCollateral();
        (uint256 ratioNumerator,uint256 ratioDenominator) = _optionsPrice.calOptionsPriceRatio(selfOccupied,totalOccupied,totalCollateral);
        return optPrice*ratioNumerator/ratioDenominator;
    }
}
