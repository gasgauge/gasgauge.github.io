/**
 *Submitted for verification at Etherscan.io on 2020-09-23
*/

// File: contracts/uniswapv2/interfaces/IUniswapV2Pair.sol

//pragma solidity >=0.5.0;
pragma solidity >=0.5 <0.7.17;

interface IUniswapV2Pair {
    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);


    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);

    function initialize(address, address) external;
}

// File: contracts/uniswapv2/interfaces/IUniswapV2Factory.sol

//pragma solidity >=0.5.0;
pragma solidity >=0.5 <0.7.17;

interface IUniswapV2Factory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeToSetter(address) external;
}

// File: contracts/uniswapv2/interfaces/ICrosschainPair.sol

//pragma solidity >=0.5.0;
pragma solidity >=0.5 <0.7.17;

interface ICrosschainPair {
    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);


    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);

    function initialize(address, address) external;
}

// File: contracts/uniswapv2/interfaces/ICrosschainFactory.sol

//pragma solidity >=0.5.0;
pragma solidity >=0.5 <0.7.17;

interface ICrosschainFactory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function migrator() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function getCfxReceiveAddr(address pair) external view returns (address cfxReceiveAddr);
    function WETH() external view returns (address);

    function setMigrator(address) external;
}

// File: contracts/Migrator.sol

//pragma solidity 0.6.12;
pragma solidity >=0.5 <0.7.17;






contract Migrator {
    address public master;
    ICrosschainFactory public factory;
    uint256 public notBeforeBlock;
    uint256 public desiredLiquidity = uint256(-1);
    mapping(address => bool) public originalFactories;
    address public operatorAddr;

    constructor(
        address _master,
        address[] memory _oldFactories,
        ICrosschainFactory _factory,
        uint256 _notBeforeBlock
    ) public {
        master = _master;
        factory = _factory;
        notBeforeBlock = _notBeforeBlock;

        operatorAddr = msg.sender;
        uint range = _oldFactories.length;
        require(range > 0, "Migrate: oldFactory Empty");

        for (uint i = 0; i < range; i++) {
            originalFactories[_oldFactories[i]] = true;
        }
    }

    function migrate(IUniswapV2Pair orig) public returns (ICrosschainPair) {
        require(msg.sender == master, "not from master access");
        require(block.number >= notBeforeBlock, "too early to migrate");
        require(originalFactories[orig.factory()], "not from old factory");
        address token0 = orig.token0();
        address token1 = orig.token1();
        ICrosschainPair pair = ICrosschainPair(factory.getPair(token0, token1));
        if (pair == ICrosschainPair(address(0))) {
            pair = ICrosschainPair(factory.createPair(token0, token1));
        }

        uint256 lp = orig.balanceOf(msg.sender);
        if (lp == 0) return pair;
        desiredLiquidity = lp;
        orig.transferFrom(msg.sender, address(orig), lp);
        orig.burn(address(pair));
        pair.mint(msg.sender);
        desiredLiquidity = uint256(-1);

        return pair;
    }

    function setOperatorAddr(address _operatorAddr) external {
        require(msg.sender == operatorAddr, 'MoonSwap: FORBIDDEN');
        operatorAddr = _operatorAddr;
    }

    // when config update, operator immediately change Factory
    function setOriginalFactory(address _factory, bool _status) external {
        require(msg.sender == operatorAddr, 'MoonSwap: FORBIDDEN');
        originalFactories[_factory] = _status;
    }
}
