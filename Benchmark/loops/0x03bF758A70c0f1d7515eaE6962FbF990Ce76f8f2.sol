/**
 *Submitted for verification at Etherscan.io on 2020-09-30
*/

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

// File: contracts/modules/Fraction.sol

//pragma solidity =0.5.16;
pragma solidity >=0.5 <0.7.17;
    /**
     * @dev Implementation of a Fraction number operation library.
     */
library Fraction {
//    using Fraction for fractionNumber;
    int256 constant private sqrtNum = 1<<120;
    int256 constant private shl = 80;
    uint8 constant private PRECISION   = 32;  // fractional bits
    uint256 constant private FIXED_ONE = uint256(1) << PRECISION; // 0x100000000
    uint256 constant private FIXED_TWO = uint256(2) << PRECISION; // 0x200000000
    uint256 constant private MAX_VAL   = uint256(1) << (256 - PRECISION); // 0x0000000100000000000000000000000000000000000000000000000000000000

    struct fractionNumber{
        int256 numerator;
        int256 denominator;
    }
    /**
     * @dev Check if fraction is negative.
     */
    function isNeg(fractionNumber memory a)  internal pure returns (bool) {
	    return a.numerator<0 != a.denominator < 0;
    }
    /**
     * @dev fraction absolute value operator.
     */
    function abs(fractionNumber memory a) internal pure returns (fractionNumber memory){
        if (a.numerator<0){
            a.numerator = -a.numerator;
        }
        if(a.denominator<0){
            a.denominator = -a.denominator;
        }
        return a;
    }
    /**
     * @dev fraction reciprocal operator.
     */
    function invert(fractionNumber memory a) internal pure returns (fractionNumber memory){
        return fractionNumber(a.denominator,a.numerator);
    }
    /**
     * @dev fraction square root operator.
     */
    function sqrt(fractionNumber memory a) internal pure returns (fractionNumber memory) {
        require(a.numerator>=0 && a.denominator>=0,"Sqrt must input a positive value");
        return fractionNumber(int256(sqrt(uint256(a.numerator))),int256(sqrt(uint256(a.denominator))));
    }
    /**
     * @dev fraction division operator.
     */
    function div(fractionNumber memory a,fractionNumber memory b) internal pure returns (fractionNumber memory) {
        return safeFractionNumber(fractionDiv(a,b));
    }
    /**
     * @dev fraction Multiplication operator.
     */
    function mul(fractionNumber memory a,fractionNumber memory b) internal pure returns (fractionNumber memory) {
        return safeFractionNumber(fractionMul(a,b));
    }
    /**
     * @dev fraction Addition operator.
     */
    function add(fractionNumber memory a,fractionNumber memory b) internal pure returns (fractionNumber memory)  {
        return safeFractionNumber(fractionAdd(a,b));
    }
    /**
     * @dev fraction Subtraction operator.
     */
    function sub(fractionNumber memory a,fractionNumber memory b) internal pure returns (fractionNumber memory)  {
        return safeFractionNumber(fractionSub(a,b));
    }

    function zoomOut(fractionNumber memory a, int256 rate) internal pure returns (fractionNumber memory) {
        require(a.denominator>rate,"fraction number is overflow");
        return fractionNumber(a.numerator/rate,a.denominator/rate);
    }
    function zoomin(fractionNumber memory a, int256 rate) internal pure returns (fractionNumber memory) {
        return safeFractionNumber(fractionNumber(a.numerator*rate,a.denominator*rate));
    }
    /**
     * @dev fraction Natural logarithm operator.
     */
    function ln(fractionNumber memory a)  internal pure returns (fractionNumber memory) {
        uint256 _x = uint256((a.numerator << PRECISION)/a.denominator);
        return fractionNumber(int256(fixedLoge(_x)),int256(FIXED_ONE));
    }

    function safeFractionNumber(fractionNumber memory a) internal pure returns (fractionNumber memory) {
        int256 num = a.numerator >= 0 ? a.numerator : -a.numerator;
        int256 deno = a.denominator >= 0 ? a.denominator : -a.denominator;
        if(deno>num){
            if (deno>sqrtNum) {
                num = deno>>shl;
                return zoomOut(a,num);
            }
        } else {
            if (num>sqrtNum) {
                num = num>>shl;
                return zoomOut(a,num);
            }
        }
        return a;
    }
    function fractionDiv(fractionNumber memory a,fractionNumber memory b) internal pure returns (fractionNumber memory) {
        return fractionNumber(a.numerator*b.denominator,a.denominator*b.numerator);
    }
    function fractionMul(fractionNumber memory a,fractionNumber memory b) internal pure returns (fractionNumber memory) {
        return fractionNumber(a.numerator*b.numerator,a.denominator*b.denominator);
    }
    function fractionAdd(fractionNumber memory a,fractionNumber memory b) internal pure returns (fractionNumber memory) {
        return fractionNumber(a.numerator*b.denominator+b.numerator*a.denominator,a.denominator*b.denominator);
    }
    function fractionSub(fractionNumber memory a,fractionNumber memory b) internal pure returns (fractionNumber memory) {
        return fractionNumber(a.numerator*b.denominator-b.numerator*a.denominator,a.denominator*b.denominator);
    }
    /**
     * @dev Standard normal cumulative distribution function
     */
    function normsDist(fractionNumber memory xNum) internal pure returns (fractionNumber memory) {
        bool _isNeg = isNeg(xNum);
        if (_isNeg) {
            xNum = abs(xNum);
        }
        int256 value = xNum.numerator/xNum.denominator;
        if (value > 10){
            return _isNeg ? fractionNumber(0,1) : fractionNumber(1,1);
        }
        fractionNumber[5] memory b = [
            fractionNumber(31938153,1e8),
            fractionNumber(-356563782,1e9),
            fractionNumber(1781477937,1e9),
            fractionNumber(-1821255978,1e9),
            fractionNumber(1330274429,1e9)];
        fractionNumber memory t = mul(xNum,fractionNumber(2316419, 1e7));
        t.numerator += t.denominator;
        t = invert(t);
        xNum = mul(xNum,xNum);
        xNum.denominator *= -2;
        xNum = exp(xNum);
        xNum = mul(fractionNumber(39894228040143267793,1e20),xNum);
        fractionNumber memory secondArg = fractionNumber(0,1);
        fractionNumber memory tt = t;
        for (uint256 i = 0; i < b.length; i++) {
            secondArg = add(secondArg,mul(b[i],tt));
            tt = mul(tt,t);
        }
        xNum = mul(xNum,secondArg);
        if (!_isNeg) {
            xNum.numerator = xNum.denominator - xNum.numerator;
        }
        return xNum;
    }
    function pow(fractionNumber memory _x,fractionNumber memory _y) internal pure returns (fractionNumber memory){
        _x = mul(ln(_x),_y);
        return exp(_x);
    }
    /**
     * @dev fraction exponential operator.
     */
    function exp(fractionNumber memory _x) internal pure returns (fractionNumber memory){
        bool _isNeg = isNeg(_x);
        if (_isNeg) {
            _x = abs(_x);
        }
        _x = safeFractionNumber(_x);
        _x.numerator = _x.numerator << PRECISION;
        _x =  fractionExp_sub(_x);
        if (_isNeg) {
            _x = invert(_x);
        }
        return _x;
    }
    /**
     * @dev an auxiliary function for fraction e exponential operator.
     *      recursive function, calculate exp(x) = exp(x/2)*exp(x-x/2)
     */
    function fractionExp_sub(fractionNumber memory _x) internal pure returns (fractionNumber memory){
        uint256 intValue = uint256(_x.numerator/_x.denominator);
        if (intValue > 0x386bfdba29){
            fractionNumber memory _x1 = fractionNumber(_x.numerator/2,_x.denominator);
            fractionNumber memory _x2 = fractionNumber(_x.numerator-_x1.numerator,_x.denominator);
            _x1 = fractionExp_sub(_x1);
            _x2 = fractionExp_sub(_x2);
            return mul(_x1,_x2);
        }else{
            return fractionNumber(int256(fixedExp(intValue)),int256(FIXED_ONE));
        }
    }
    //This is where all your gas goes, sorry
    //Not sorry, you probably only paid 1 gwei
    function sqrt(uint x) internal pure returns (uint y) {
        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
    function ln(uint256 _x)  internal pure returns (fractionNumber memory) {
        _x = _x << PRECISION;
        return fractionNumber(int256(fixedLoge(_x)),int256(FIXED_ONE));
    }
        /**
        input range:
            [0x100000000,uint256_max]
        output range:
            [0, 0x9b43d4f8d6]

        This method asserts outside of bounds

    */
    function fixedLoge(uint256 _x) internal pure returns (uint256 logE) {
        /*
        Since `fixedLog2_min` output range is max `0xdfffffffff`
        (40 bits, or 5 bytes), we can use a very large approximation
        for `ln(2)`. This one is used since it’s the max accuracy
        of Python `ln(2)`

        0xb17217f7d1cf78 = ln(2) * (1 << 56)

        */
        //Cannot represent negative numbers (below 1)
        require(_x >= FIXED_ONE,"loge function input is too small");

        uint256 _log2 = fixedLog2(_x);
        logE = (_log2 * 0xb17217f7d1cf78) >> 56;
    }

    /**
        Returns log2(x >> 32) << 32 [1]
        So x is assumed to be already upshifted 32 bits, and
        the result is also upshifted 32 bits.

        [1] The function returns a number which is lower than the
        actual value

        input-range :
            [0x100000000,uint256_max]
        output-range:
            [0,0xdfffffffff]

        This method asserts outside of bounds

    */
    function fixedLog2(uint256 _x) internal pure returns (uint256) {
        // Numbers below 1 are negative.
        require( _x >= FIXED_ONE,"Log2 input is too small");

        uint256 hi = 0;
        while (_x >= FIXED_TWO) {
            _x >>= 1;
            hi += FIXED_ONE;
        }

        for (uint8 i = 0; i < PRECISION; ++i) {
            _x = (_x * _x) / FIXED_ONE;
            if (_x >= FIXED_TWO) {
                _x >>= 1;
                hi += uint256(1) << (PRECISION - 1 - i);
            }
        }

        return hi;
    }

    /**
        fixedExp is a ‘protected’ version of `fixedExpUnsafe`, which
        asserts instead of overflows
    */
    function fixedExp(uint256 _x) internal pure returns (uint256) {
        require(_x <= 0x386bfdba29,"exp function input is overflow");
        return fixedExpUnsafe(_x);
    }
       /**
        fixedExp
        Calculates e^x according to maclauren summation:

        e^x = 1+x+x^2/2!...+x^n/n!

        and returns e^(x>>32) << 32, that is, upshifted for accuracy

        Input range:
            - Function ok at    <= 242329958953
            - Function fails at >= 242329958954

        This method is is visible for testcases, but not meant for direct use.

        The values in this method been generated via the following python snippet:

        def calculateFactorials():
            “”"Method to print out the factorials for fixedExp”“”

            ni = []
            ni.append( 295232799039604140847618609643520000000) # 34!
            ITERATIONS = 34
            for n in range( 1,  ITERATIONS,1 ) :
                ni.append(math.floor(ni[n - 1] / n))
            print( “\n        “.join([“xi = (xi * _x) >> PRECISION;\n        res += xi * %s;” % hex(int(x)) for x in ni]))

    */
    function fixedExpUnsafe(uint256 _x) internal pure returns (uint256) {

        uint256 xi = FIXED_ONE;
        uint256 res = 0xde1bc4d19efcac82445da75b00000000 * xi;

        xi = (xi * _x) >> PRECISION;
        res += xi * 0xde1bc4d19efcb0000000000000000000;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x6f0de268cf7e58000000000000000000;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x2504a0cd9a7f72000000000000000000;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x9412833669fdc800000000000000000;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x1d9d4d714865f500000000000000000;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x4ef8ce836bba8c0000000000000000;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0xb481d807d1aa68000000000000000;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x16903b00fa354d000000000000000;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x281cdaac677b3400000000000000;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x402e2aad725eb80000000000000;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x5d5a6c9f31fe24000000000000;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x7c7890d442a83000000000000;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x9931ed540345280000000000;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0xaf147cf24ce150000000000;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0xbac08546b867d000000000;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0xbac08546b867d00000000;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0xafc441338061b8000000;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x9c3cabbc0056e000000;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x839168328705c80000;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x694120286c04a0000;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x50319e98b3d2c400;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x3a52a1e36b82020;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x289286e0fce002;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x1b0c59eb53400;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x114f95b55400;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0xaa7210d200;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x650139600;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x39b78e80;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x1fd8080;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x10fbc0;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x8c40;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x462;
        xi = (xi * _x) >> PRECISION;
        res += xi * 0x22;

        return res / 0xde1bc4d19efcac82445da75b00000000;
    }
}

// File: contracts/interfaces/IVolatility.sol

//pragma solidity =0.5.16;
pragma solidity >=0.5 <0.7.17;

interface IVolatility {
    function calculateIv(uint32 underlying,uint8 optType,uint256 expiration,uint256 currentPrice,uint256 strikePrice)external view returns (uint256,uint256);
}
contract ImportVolatility is Ownable{
    IVolatility internal _volatility;
    function getVolatilityAddress() public view returns(address){
        return address(_volatility);
    }
    function setVolatilityAddress(address volatility)public onlyOwner{
        _volatility = IVolatility(volatility);
    }
}

// File: contracts/optionsPrice.sol

//pragma solidity =0.5.16;
pragma solidity >=0.5 <0.7.17;



/**
 * @title Options price calculation contract.
 * @dev calculate options' price, using B-S formulas.
 *
 */
contract OptionsPrice is ImportVolatility{
    using Fraction for Fraction.fractionNumber;
    // one year seconds
    int256 constant internal Year = 365 days;
    // constant value in B-S formulas.
    int256 constant internal YearSqrt = 561569230;
    // rate in B-S formulas.
    Fraction.fractionNumber internal rate = Fraction.fractionNumber(0,1000);

    Fraction.fractionNumber internal ratioR2 = Fraction.fractionNumber(4,1);
    /**
     * @dev constructor function , setting contract address.
     * @param ivContract implied volatility contract address
     */
    constructor (address ivContract) public{
        setVolatilityAddress(ivContract);
    }

    /**
     * @dev get B_S formulas r
     */
    function getRate()public view returns(int256,int256){
        return (rate.numerator,rate.denominator);
    }
    /**
     * @dev set B_S formulas r
     */
    function setRate(int256 numerator,int256 denominator)public onlyOwner{
        rate.numerator = numerator;
        rate.denominator = denominator;
    }
        /**
     * @dev get options price ratio for R2
     */
    function getRatioR2()public view returns(int256,int256){
        return (ratioR2.numerator,ratioR2.denominator);
    }
    /**
     * @dev set options price ratio for R2
     */
    function setRatioR2(int256 numerator,int256 denominator)public onlyOwner{
        ratioR2.numerator = numerator;
        ratioR2.denominator = denominator;
    }
    /**
     * @dev calculate option's price using B_S formulas
     * @param currentPrice current underlying price.
     * @param strikePrice option's strike price.
     * @param expiration option's expiration left time. Equal option's expiration timestamp - now.
     * @param underlying option's underlying id, 1 for BTC, 2 for ETH.
     * @param optType option's type, 0 for CALL, 2 for PUT.
     */
    function getOptionsPrice(uint256 currentPrice, uint256 strikePrice, uint256 expiration,uint32 underlying,uint8 optType)public view returns (uint256){
        (uint256 ivNumerator,uint256 ivDenominator) = _volatility.calculateIv(underlying,optType,expiration,currentPrice,strikePrice);
        Fraction.fractionNumber memory _iv = Fraction.fractionNumber(int256(ivNumerator),int256(ivDenominator));
        if (optType == 0) {
            return callOptionsPrice(currentPrice,strikePrice,expiration,rate,_iv);
        }else if (optType == 1){
            return putOptionsPrice(currentPrice,strikePrice,expiration,rate,_iv);
        }else{
            require(optType<2," Must input 0 for call option or 1 for put option");
        }
    }
    /**
     * @dev calculate option's price using B_S formulas with user input iv.
     * @param currentPrice current underlying price.
     * @param strikePrice option's strike price.
     * @param expiration option's expiration left time. Equal option's expiration timestamp - now.
     * @param ivNumerator user input iv numerator.
     * @param ivDenominator user input iv denominator.
     * @param optType option's type, 0 for CALL, 2 for PUT.
     */
    function getOptionsPrice_iv(uint256 currentPrice, uint256 strikePrice, uint256 expiration,
            uint256 ivNumerator,uint256 ivDenominator,uint8 optType)public view returns (uint256){
        Fraction.fractionNumber memory _iv = Fraction.fractionNumber(int256(ivNumerator),int256(ivDenominator));
        if (optType == 0) {
            return callOptionsPrice(currentPrice,strikePrice,expiration,rate,_iv);
        }else if (optType == 1){
            return putOptionsPrice(currentPrice,strikePrice,expiration,rate,_iv);
        }else{
            require(optType<2," Must input 0 for call option or 1 for put option");
        }
    }
    /**
     * @dev An auxiliary function, calculate parameter d1 and d2 in B_S formulas.
     * @param currentPrice current underlying price.
     * @param strikePrice option's strike price.
     * @param expiration option's expiration left time. Equal option's expiration timestamp - now.
     * @param r parameter r in B_S formulas.
     * @param derta implied volatility value in B-S formulas.
     */
    function calculateD1D2(uint256 currentPrice, uint256 strikePrice, uint256 expiration,
         Fraction.fractionNumber memory r, Fraction.fractionNumber memory derta)
            internal pure returns (Fraction.fractionNumber memory, Fraction.fractionNumber memory) {
        Fraction.fractionNumber memory d1 = (currentPrice == strikePrice) ? Fraction.fractionNumber(0,1) :
            Fraction.ln(currentPrice).sub(Fraction.ln(strikePrice));
        Fraction.fractionNumber memory derta2 = derta.mul(derta);
        derta2.denominator = derta2.denominator*2;
        derta2 = derta2.add(r);
        derta2 = derta2.mul(Fraction.fractionNumber(int256(expiration),Year));
        d1 = d1.add(derta2);
        derta2 = Fraction.fractionNumber(int256(Fraction.sqrt(expiration*1e10)),YearSqrt).mul(derta);
        d1 = d1.div(derta2);
        derta2 = d1.sub(derta2);
        return (d1, derta2);
    }
    /**
     * @dev An auxiliary function, calculate put option price using B_S formulas.
     * @param currentPrice current underlying price.
     * @param strikePrice option's strike price.
     * @param expiration option's expiration left time. Equal option's expiration timestamp - now.
     * @param r parameter r in B_S formulas.
     * @param derta implied volatility value in B-S formulas.
     */
    //L*pow(e,-rT)*(1-N(d2)) - S*(1-N(d1))
    function putOptionsPrice(uint256 currentPrice, uint256 strikePrice, uint256 expiration,
            Fraction.fractionNumber memory r, Fraction.fractionNumber memory derta)
                internal pure returns (uint256) {
       (Fraction.fractionNumber memory d1, Fraction.fractionNumber memory d2) = calculateD1D2(currentPrice, strikePrice, expiration, r, derta);
        d1 = d1.normsDist();
        d2 = d2.normsDist();
        d1.numerator = (d1.denominator - d1.numerator)*int256(currentPrice);
        d2.numerator = (d2.denominator - d2.numerator)*int256(strikePrice);
        if (r.numerator == 0){
            d1 = d2.sub(d1);
        }else{
            r = r.mul(Fraction.fractionNumber(int256(expiration),Year));
    //        r = r.exp().invert();
            d1 = d2.div(r.exp()).sub(d1);
        }
        return uint256(d1.numerator/d1.denominator);
    }
    /**
     * @dev An auxiliary function, calculate call option price using B_S formulas.
     * @param currentPrice current underlying price.
     * @param strikePrice option's strike price.
     * @param expiration option's expiration left time. Equal option's expiration timestamp - now.
     * @param r parameter r in B_S formulas.
     * @param derta implied volatility value in B-S formulas.
     */
    //S*N(d1)-L*pow(e,-rT)*N(d2)
    function callOptionsPrice(uint256 currentPrice, uint256 strikePrice, uint256 expiration,
            Fraction.fractionNumber memory r, Fraction.fractionNumber memory derta)
                internal pure returns (uint256) {
       (Fraction.fractionNumber memory d1, Fraction.fractionNumber memory d2) = calculateD1D2(currentPrice, strikePrice, expiration, r, derta);
        d1 = d1.normsDist();
        d2 = d2.normsDist();
        d1.numerator = d1.numerator*int256(currentPrice);
        d2.numerator = d2.numerator*int256(strikePrice);
//        r = r.exp().invert();
        if (r.numerator == 0){
            d1 = d1.sub(d2);
        }else{
            r = r.mul(Fraction.fractionNumber(int256(expiration),Year));
    //        r = r.exp().invert();
            d1 = d1.sub(d2.div(r.exp()));
        }
        return uint256(d1.numerator/d1.denominator);
    }
    function calOptionsPriceRatio(uint256 selfOccupied,uint256 totalOccupied,uint256 totalCollateral) public view returns (uint256,uint256){
        //r1 + 0.5
        if (selfOccupied*2<=totalOccupied){
            return(1,1);
        }
        //r1 + 0.5
        Fraction.fractionNumber memory r1 = Fraction.fractionNumber(int256(selfOccupied*2+totalOccupied),int256(totalOccupied*2));
        Fraction.fractionNumber memory r2 = Fraction.fractionNumber(int256(totalOccupied),int256(totalCollateral)).mul(ratioR2);
        //pow(r1,r2)
        r1 = r1.pow(r2);
        return (uint256(r1.numerator),uint256(r1.denominator));
    }
}
