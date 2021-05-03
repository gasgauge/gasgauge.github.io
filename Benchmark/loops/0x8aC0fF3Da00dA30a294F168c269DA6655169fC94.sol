/**
 *Submitted for verification at Etherscan.io on 2020-09-19
*/

//pragma solidity 0.5.12;
pragma solidity >=0.5 <0.7.17;

library SafeMath {
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function div(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y > 0, "ds-math-div-overflow");
        z = x / y;
    }
}

interface IERC20 {
    function balanceOf(address _owner) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);
}

interface ILendingPoolCore {
    function getReserveAvailableLiquidity(address _reserve)
        external
        view
        returns (uint256);

    function getReserveCurrentLiquidityRate(address _reserve)
        external
        view
        returns (uint256);

    function getReserveCurrentVariableBorrowRate(address _reserve)
        external
        view
        returns (uint256);
}

interface ICToken {
    function supplyRatePerBlock() external view returns (uint256);

    function borrowRatePerBlock() external view returns (uint256);

    function getCash() external view returns (uint256);

    function comptroller() external view returns (address);

    function exchangeRateCurrent() external returns (uint256);
}

interface IUSR {

    function totalUnderlying() external returns (uint256);

    function balanceOfUnderlying(address owner) external returns (uint256);

    function underlyingToken() external view returns (address);
}

interface IDFProtocolView {

    function getColStatus() external view returns (address[] memory, uint[] memory);
}

interface IComptroller {
    function compSpeeds(address _cToken) external view returns (uint256);

    function getCompAddress() external view returns (address);
}

interface IDToken {
    function token() external view returns (address);

    function getBaseData()
        external
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        );

    function getHandlerInfo()
        external
        returns (
            address[] memory,
            uint256[] memory,
            uint256[] memory
        );

    function swapModel() external view returns (address);
}

interface ISwapModel {
    function getSwapAmount(
        address _tokenA,
        address _tokenB,
        uint256 _amount
    ) external view returns (uint256);
}

interface IDTokenController {
    function getDToken(address _token) external view returns (address);
}

interface IHandler {
    function dTokenController() external view returns (address);

    function cTokens(address _token) external view returns (address);

    function aaveLendingPoolCore() external view returns (address);

    function USR() external view returns (address);
}

contract DTokenCommonData {
    using SafeMath for uint256;
    bool private initialized;
    address public owner;
    uint256 constant ONE = 1e18;
    uint256 constant doubleScale = 1e36;
    uint256 constant BlocksPerDay = 4 * 60 * 24;
    uint256 constant DaysPerYear = 365;

    mapping(address => bytes4) public handlers;

    constructor() public {
        initialize();
    }

    function initialize() public {
        require(!initialized, "initialize: Already initialized!");
        owner = msg.sender;
        initialized = true;
    }

    function rpow(uint256 x, uint256 n, uint256 base) public pure returns (uint256 z) {
        assembly {
            switch x case 0 {switch n case 0 {z := base} default {z := 0}}
            default {
                switch mod(n, 2) case 0 { z := base } default { z := x }
                let half := div(base, 2)  // for rounding.
                
                for { n := div(n, 2) } n { n := div(n,2) } {
                    let xx := mul(x, x)
                    if iszero(eq(div(xx, x), x)) { revert(0,0) }
                    let xxRound := add(xx, half)
                    if lt(xxRound, xx) { revert(0,0) }
                    x := div(xxRound, base)
                    if mod(n,2) {
                        let zx := mul(z, x)
                        if and(iszero(iszero(x)), iszero(eq(div(zx, x), z))) { revert(0,0) }
                        let zxRound := add(zx, half)
                        if lt(zxRound, zx) { revert(0,0) }
                        z := div(zxRound, base)
                    }
                }
            }
        }
    }

    function setHandler(address _handler, bytes4 _sig) external {
        require(msg.sender == owner, "setHandler: Permission denied!");
        handlers[_handler] = _sig;
    }

    function setHandlers(address[] calldata _handlers, bytes4[] calldata _sigs)
        external
    {
        require(msg.sender == owner, "setHandlers: Permission denied!");
        require(
            _handlers.length == _sigs.length && _handlers.length > 0,
            "setHandlers: handlers & indexs should not have 0 or different lengths"
        );
        for (uint256 i = 0; i < _handlers.length; i++)
            handlers[_handlers[i]] = _sigs[i];
    }

    function getDTokenApys(address[] calldata _dTokens)
        external
        returns (uint256[] memory)
    {
        uint256[] memory _apys = new uint256[](_dTokens.length);
        for (uint256 i = 0; i < _dTokens.length; i++)
            _apys[i] = getDTokenApy(_dTokens[i]);
        return _apys;
    }

    struct DTokenApyLocalVars {
        uint256 tokenBalance;
        uint256[] balances;
        uint256[] supplyApys;
        uint256[] borrowApys;
        uint256[] otherSupplyApys;
    }

    function getDTokenApy(address _dToken) public returns (uint256) {
        DTokenDataLocalVars memory _dTokenApy;
        (
            _dTokenApy.tokenBalance,
            ,
            ,
            _dTokenApy.balances,
            ,
            _dTokenApy.supplyApys,
            ,
            _dTokenApy.otherSupplyApys
        ) = getDTokenData(_dToken);
        if (_dTokenApy.tokenBalance == 0) return 0;
        uint256 _apy;
        for (uint256 i = 0; i < _dTokenApy.balances.length; i++)
            _apy = _dTokenApy.supplyApys[i].add(_dTokenApy.otherSupplyApys[i]).mul(_dTokenApy.balances[i]).div(_dTokenApy.tokenBalance).add(_apy);

        return _apy;
    }

    struct DTokenDataLocalVars {
        address token;
        uint256 tokenBalance;
        address[] handlers;
        uint256[] balances;
        uint256[] cashs;
        uint256[] supplyApys;
        uint256[] borrowApys;
        uint256[] otherSupplyApys;
    }

    function getDTokenData(address _dToken)
        public
        returns (
            uint256,
            uint256,
            address[] memory,
            uint256[] memory,
            uint256[] memory,
            uint256[] memory,
            uint256[] memory,
            uint256[] memory
        )
    {
        DTokenDataLocalVars memory _dTokenData;
        (, , , , uint256 _tokenBalance) = IDToken(_dToken).getBaseData();
        _dTokenData.token = IDToken(_dToken).token();
        (_dTokenData.handlers, _dTokenData.balances, ) = IDToken(_dToken)
            .getHandlerInfo();
        _dTokenData.cashs = new uint256[](_dTokenData.handlers.length);
        _dTokenData.supplyApys = new uint256[](_dTokenData.handlers.length);
        _dTokenData.borrowApys = new uint256[](_dTokenData.handlers.length);
        _dTokenData.otherSupplyApys = new uint256[](
            _dTokenData.handlers.length
        );
        for (uint256 i = 0; i < _dTokenData.handlers.length; i++)
            ( _dTokenData.cashs[i], _dTokenData.supplyApys[i], _dTokenData.borrowApys[i], _dTokenData.otherSupplyApys[i]) = getHandlerData(_dTokenData.handlers[i], _dTokenData.token);

        return (
            _tokenBalance,
            IERC20(_dToken).totalSupply(),
            _dTokenData.handlers,
            _dTokenData.balances,
            _dTokenData.cashs,
            _dTokenData.supplyApys,
            _dTokenData.borrowApys,
            _dTokenData.otherSupplyApys
        );
    }

    function getHandlerData(address _handler, address _token)
        public
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        (, bytes memory _data) = address(this).call(
            abi.encodeWithSelector(handlers[_handler], _handler, _token)
        );
        (
            uint256 _cash,
            uint256 _supplyApy,
            uint256 _borrowApy,
            uint256 _otherSupplyApy
        ) = abi.decode(_data, (uint256, uint256, uint256, uint256));
        return (_cash, _supplyApy, _borrowApy, _otherSupplyApy);
    }

    function InternalData(address _handler, address _token)
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (IERC20(_token).balanceOf(_handler), 0, 0, 0);
    }

    function CompoundData(address _handler, address _token)
        public
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        ICToken _cToken = ICToken(IHandler(_handler).cTokens(_token));
        return (
            _cToken.getCash(),
            rpow(
                (_cToken.supplyRatePerBlock() * BlocksPerDay + ONE),
                DaysPerYear,
                ONE
            ) - ONE,
            rpow(
                (_cToken.borrowRatePerBlock() * BlocksPerDay + ONE),
                DaysPerYear,
                ONE
            ) - ONE,
            getCompApy(_handler, _token)
        );
    }

    function AaveData(address _handler, address _token)
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        ILendingPoolCore lendingPoolCore = ILendingPoolCore(
            IHandler(_handler).aaveLendingPoolCore()
        );
        return (
            lendingPoolCore.getReserveAvailableLiquidity(_token),
            lendingPoolCore.getReserveCurrentLiquidityRate(_token) / 10**9,
            lendingPoolCore.getReserveCurrentVariableBorrowRate(_token) / 10**9,
            0
        );
    }

    function USRData(address _handler, address _token)
        public
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        _token;
        return (
            IUSR(IHandler(_handler).USR()).totalUnderlying(),
            getUSRInterestRate(_handler),
            0,
            0
        );
    }

    function getCompApy(address _handler, address _token)
        public
        returns (uint256)
    {
        address _cToken = IHandler(_handler).cTokens(_token);
        IComptroller _comptroller = IComptroller(
            ICToken(_cToken).comptroller()
        );
        IDToken _dToken = IDToken(
            IDTokenController(IHandler(_handler).dTokenController()).getDToken(
                _token
            )
        );
        uint256 _tokenAmount = ISwapModel(_dToken.swapModel()).getSwapAmount(
            _comptroller.getCompAddress(),
            _dToken.token(),
            ONE
        );
        _tokenAmount = _comptroller.compSpeeds(_cToken).mul(_tokenAmount).div(
            ONE
        );

        uint256 _tokenTotalAmountDoubleScale = IERC20(_cToken)
            .totalSupply()
            .mul(ICToken(_cToken).exchangeRateCurrent());
        if (_tokenTotalAmountDoubleScale == 0) return 0;

        uint256 _compApy = _tokenAmount.mul(doubleScale).div(
            _tokenTotalAmountDoubleScale
        );
        return rpow((_compApy * 45 * 6 * 24 + ONE), DaysPerYear, ONE) - ONE;
    }

    function getUSRInterestRate(address _handler) public returns(uint256) {

        uint256 _principal = IUSR(IHandler(_handler).USR()).totalUnderlying();

        return _principal > 0 ? getUSDxAnnualInterest(_handler).mul(ONE).div(_principal) : 0;
    }

    function getUSDxAnnualInterest(address _handler) public returns(uint256) {

        IDTokenController _dTokenController = IDTokenController(IHandler(_handler).dTokenController());

        (address[] memory _tokens, uint256[] memory _amounts) = IDFProtocolView(0x097Dd22173f0e382daE42baAEb9bDBC9fdf3396F).getColStatus();
        address _dToken;
        uint256 _decimals;
        uint256 _annualInterest;
        for (uint256 i = 0; i < _tokens.length; i++) {
            _dToken = _dTokenController.getDToken(_tokens[i]);
            if (_dToken == address(0))
                continue;

            _decimals = uint256(IERC20(_tokens[i]).decimals());
            _amounts[i] = _decimals > 18 ? _amounts[i] / 10 ** (_decimals - 18) : _amounts[i] * 10 ** (18 - _decimals);
            _annualInterest = _annualInterest.add(_amounts[i].mul(getDTokenApy(_dToken)).div(ONE));
		}

        return _annualInterest;
    }

    function test(address _handler) public returns (
            uint256,
            address[] memory,
            address[] memory,
            uint256[] memory,
            uint256[] memory
        ) {

        IDTokenController _dTokenController = IDTokenController(IHandler(_handler).dTokenController());

        (address[] memory _tokens, uint256[] memory _amounts) = IDFProtocolView(0x097Dd22173f0e382daE42baAEb9bDBC9fdf3396F).getColStatus();
		address[] memory _dTokens = new address[](_tokens.length);
        uint256[] memory _decimals = new uint[](_tokens.length);
        uint256 _annualInterest;
        for (uint256 i = 0; i < _tokens.length; i++) {
            _dTokens[i] = _dTokenController.getDToken(_tokens[i]);
            if (_dTokens[i] == address(0))
                continue;

            _decimals[i] = uint256(IERC20(_tokens[i]).decimals());
            _amounts[i] = _decimals[i] > 18 ? _amounts[i] / 10 ** (_decimals[i] - 18) : _amounts[i] * 10 ** (18 - _decimals[i]);
            _annualInterest = _annualInterest.add(_amounts[i].mul(getDTokenApy(_dTokens[i])).div(ONE));
		}

        return (_annualInterest, _tokens, _dTokens, _decimals, _amounts);
    }

}
