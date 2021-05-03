/**
 *Submitted for verification at Etherscan.io on 2020-12-16
*/

/**
 *Submitted for verification at Etherscan.io on 12-15-2020
*/

/*
    Copyright 2020 Charge Factory.
    SPDX-License-Identifier: Apache-2.0
*/
//pragma solidity 0.6.9;
pragma solidity >=0.5 <0.7.17;
pragma experimental ABIEncoderV2;

// helper/SafeMath.sol
/**
 * @title SafeMath
 * @author Charge Breeder
 *
 * @notice Math operations with safety checks that revert on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "MUL_ERROR");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "DIVIDING_ERROR");
        return a / b;
    }

    function divCeil(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 quotient = div(a, b);
        uint256 remainder = a - quotient * b;
        if (remainder > 0) {
            return quotient + 1;
        } else {
            return quotient;
        }
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SUB_ERROR");
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "ADD_ERROR");
        return c;
    }

    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = x / 2 + 1;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}

// helper/AggregatorV3Interface.sol
interface AggregatorV3Interface {

  function decimals() external view returns (uint8);
  function description() external view returns (string memory);
  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}

// File: contracts/interfaces/IUniswapV2Pair.sol

//pragma solidity >=0.5.0;
pragma solidity >=0.5 <0.7.17;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

// lib/Ownable.sol
/**
 * @title Ownable
 * @author Charge Breeder
 *
 * @notice Ownership related functions
 */
contract Ownable {
    address public _OWNER_;
    address public _NEW_OWNER_;

    // ============ Events ============

    event OwnershipTransferPrepared(address indexed previousOwner, address indexed newOwner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // ============ Modifiers ============

    modifier onlyOwner() {
        require(msg.sender == _OWNER_, "NOT_OWNER");
        _;
    }

    // ============ Functions ============

    constructor() internal {
        _OWNER_ = msg.sender;
        emit OwnershipTransferred(address(0), _OWNER_);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "INVALID_OWNER");
        emit OwnershipTransferPrepared(_OWNER_, newOwner);
        _NEW_OWNER_ = newOwner;
    }

    function claimOwnership() external {
        require(msg.sender == _NEW_OWNER_, "INVALID_CLAIM");
        emit OwnershipTransferred(_OWNER_, _NEW_OWNER_);
        _OWNER_ = _NEW_OWNER_;
        _NEW_OWNER_ = address(0);
    }
}

// NewOracleProxy.sol
contract NewOracleProxy is Ownable {
        using SafeMath for uint256;

    string public oracleName;
    uint8  public oracleDecimal;

    address public chainlink;
    address public uniswapPair;
    uint256 public chainlinkThreshold;
    bool    public uniswapPairReverse;

    uint256 public T0 = 900;
    uint256 public RATIO = 2;

    uint256 public uniswapPriceCumulativeLast;
    uint256 public uniswapPriceLast;
    uint32  public uniswapBlockTimestampLast;

    event DevivationTooBig (uint256 _chainlinPrice, uint256 _dexPrice);

    constructor(address _chainlink,
                address _uniswapPair,
                string memory _name, 
                uint256 _chainlinkThreshold,
                bool _uniswapPairReverse) public {
        chainlink = _chainlink;
        uniswapPair = _uniswapPair;
        oracleName = _name;
        oracleDecimal =  18;
        chainlinkThreshold = _chainlinkThreshold;
        uniswapPairReverse = _uniswapPairReverse;

        (uniswapPriceCumulativeLast, uniswapPriceLast, uniswapBlockTimestampLast)
                = _getUniswapPrice(uniswapPair, uniswapPairReverse);
    }

    // administration
    function setT0(uint256 t0) external onlyOwner {
        T0 = t0;
    }

    function setRATIO(uint256 ratio) external onlyOwner {
        RATIO = ratio;
    }

    // oracle
    function getChainlinkPrice() external view returns (uint256, uint256) {
        (, int256 answer, , uint256 updateTimestamp, ) 
            = AggregatorV3Interface(chainlink).latestRoundData();
        uint8 chainlinkDecimal = AggregatorV3Interface(chainlink).decimals(); 
        uint256 price = uint256(answer);

        if (chainlinkDecimal > oracleDecimal) {
            price = price.div(10 ** uint256(chainlinkDecimal - oracleDecimal));
        } else if (chainlinkDecimal < oracleDecimal) {
            price = price.mul(10 ** uint256(oracleDecimal - chainlinkDecimal));
        } 

        return (price, updateTimestamp);
    }

    // return price with decimal 18
    function getUniswapPrice(address pair, bool reverse) external view
        returns (uint256, uint32) {
        (uint256 priceCumulative,  , uint32 blockTimestamp) = _getUniswapPrice(pair, reverse);
        return (priceCumulative, blockTimestamp);
    }

    // return price with decimal 18
    function _getUniswapPrice(address pair, bool reverse) internal view
        returns (uint256, uint256, uint32) {
        // unit = (2 ** 112) / (1e18)
        uint256 unit = 5192296858534827;

        uint256 price0 = IUniswapV2Pair(pair).price0CumulativeLast();
        uint256 price1 = IUniswapV2Pair(pair).price1CumulativeLast();
        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = IUniswapV2Pair(pair).getReserves(); 

        // decimal 18
        uint256 priceLast = 10 ** 18;

        // check pair token are in the same order?
        if (reverse == false) {
            priceLast = priceLast.mul(reserve1).div(reserve0);
            return (price0.div(unit).div(10**12), priceLast.div(10**12), uint32(blockTimestampLast % 2 ** 32));
        } else {
            priceLast = priceLast.mul(reserve0).div(reserve1);
            return (price1.div(unit).mul(10**12), priceLast.mul(10**12), uint32(blockTimestampLast % 2 ** 32));
        }
    }

    function getPrice() external returns (uint256, uint8) {

        uint256 uniswapPriceCumulative;
        uint256 uniswapPrice;
        uint32  uniswapBlockTimestamp;

        uint256 targetPrice;
        uint256 chainlinkPrice;
        uint256 chainlinkTimestamp;
        uint256 dexPrice;

        uint256 deltaT;
        uint256 deviation;
        uint8   deviationLevel;

        (chainlinkPrice, chainlinkTimestamp) = this.getChainlinkPrice();

        (uniswapPriceCumulative, ,uniswapBlockTimestamp) 
                        = _getUniswapPrice(uniswapPair, uniswapPairReverse);

        if (uniswapBlockTimestamp != uniswapBlockTimestampLast) {
            uniswapPrice = uniswapPriceCumulative.sub(uniswapPriceCumulativeLast).
                div(uniswapBlockTimestamp-uniswapBlockTimestampLast);
        } else {
            uniswapPrice = uniswapPriceLast;
        }
        dexPrice = uniswapPrice;

        // dexPrice is newer than oraclePrice
        if (uint256(uniswapBlockTimestampLast) >= chainlinkTimestamp) {
            // detaT = (uniswapBlockTimestamp + uniswapBlockTimestampLast)/2 - oracleTimestamp
            deltaT = uint256((uniswapBlockTimestamp + uniswapBlockTimestampLast)/2).sub(chainlinkTimestamp);
        } else {
            deltaT = 0;
            dexPrice = chainlinkPrice;
        }

        // last step
        deviationLevel = 0;
        if (dexPrice > chainlinkPrice) {
            deviation = dexPrice.sub(chainlinkPrice).mul(10 ** 18).div(chainlinkPrice);
            if (deviation > chainlinkThreshold.mul(RATIO)) {
                targetPrice = chainlinkPrice;
                // set to biggest
                //deviationLevel = uint8(deviation.div(chainlinkThreshold));
                deviationLevel = 255;
                emit DevivationTooBig(chainlinkPrice, dexPrice);
            } else {
                // targetPrice = (chainlinkPrice * T0 + dexPrice * deltaT) / (T0 + deltaT)
                targetPrice = chainlinkPrice.mul(T0).add(dexPrice.mul(deltaT)).div(deltaT.add(T0)); 
            }
        } else if (dexPrice < chainlinkPrice) {
            deviation = chainlinkPrice.sub(dexPrice).mul(10 ** 18).div(dexPrice);
            if (deviation > chainlinkThreshold.mul(RATIO)) {
                targetPrice = chainlinkPrice;
                // set to biggest
                //deviationLevel = uint8(deviation/chainlinkThreshold);
                deviationLevel = 255;
                emit DevivationTooBig(chainlinkPrice, dexPrice);
            } else {
                // targetPrice = (chainlinkPrice * T0 + dexPrice * deltaT) / (T0 + deltaT)
                targetPrice = chainlinkPrice.mul(T0).add(dexPrice.mul(deltaT)).div(deltaT.add(T0)); 
            }
        } else {
            // dexPrice == chainlinkPrice
            targetPrice = chainlinkPrice;
        }

        if (uniswapBlockTimestamp != uniswapBlockTimestampLast) {
            uniswapPriceCumulativeLast = uniswapPriceCumulative;
            uniswapPriceLast = uniswapPrice;
            uniswapBlockTimestampLast = uniswapBlockTimestamp;
        }

        return (targetPrice, deviationLevel);
    }
}
