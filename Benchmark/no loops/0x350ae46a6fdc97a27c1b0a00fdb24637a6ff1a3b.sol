/**
 *Submitted for verification at Etherscan.io on 2020-09-16
*/

// File: contracts/Lend/ProtocolInterface.sol

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.5 <0.7.17;

 contract ProtocolInterface {
    function deposit(
        address _user,
        uint256 _amount,
        address _token,
        address _cToken
    ) public ;

    function withdraw(
        address _user,
        uint256 _amount,
        address _token,
        address _cToken
    ) public ;
}

// File: contracts/interfaces/ERC20.sol

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.5 <0.7.17;

interface ERC20 {
     event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Transfer(address indexed _src, address indexed _dst, uint256 _amount);
    function totalSupply() external view returns (uint256 supply);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function transfer(address _to, uint256 _value) external returns (bool success);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);

    function approve(address _spender, uint256 _value) external returns (bool success);

    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    // function decimals() external view returns (uint256 digits);

   
}

// File: contracts/interfaces/CTokenInterface.sol

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.5 <0.7.17;


 contract CTokenInterface is ERC20 {
    function mint(uint256 mintAmount) external  returns (uint256);

    function mint() external  payable;

    function redeem(uint256 redeemTokens) external  returns (uint256);

    function redeemUnderlying(uint256 redeemAmount) external  returns (uint256);

    function borrow(uint256 borrowAmount) external  returns (uint256);

    function repayBorrow(uint256 repayAmount) external  returns (uint256);

    function repayBorrow() external  payable;

    function repayBorrowBehalf(address borrower, uint256 repayAmount)
        external
        
        returns (uint256);

    function repayBorrowBehalf(address borrower) external  payable;

    function liquidateBorrow(
        address borrower,
        uint256 repayAmount,
        address cTokenCollateral
    ) external  returns (uint256);

    function liquidateBorrow(address borrower, address cTokenCollateral) external  payable;

    function exchangeRateCurrent() external  returns (uint256);

    function supplyRatePerBlock() external  returns (uint256);

    function borrowRatePerBlock() external  returns (uint256);

    function totalReserves() external  returns (uint256);

    function reserveFactorMantissa() external  returns (uint256);

    function borrowBalanceCurrent(address account) external  returns (uint256);

    function totalBorrowsCurrent() external  returns (uint256);

    function getCash() external  returns (uint256);

    function balanceOfUnderlying(address owner) external  returns (uint256);
}

// File: contracts/Lend/compound/CompoundProtocol.sol

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.5 <0.7.17;
pragma experimental ABIEncoderV2;




/**
 * @notice CompoundProtocol
 * @author Solidefi
 */
contract CompoundProtocol is ProtocolInterface {
    CTokenInterface public cTokenContract;

    /**
     * @dev Deposit DAI to compound protocol return cDAI to user proxy wallet.
     * @param _user User proxy wallet address.
     * @param _amount Amount of DAI.
     */

    function deposit(
        address _user,
        uint256 _amount,
        address _token,
        address _cToken
    ) public  {
        cTokenContract = CTokenInterface(_cToken);

        require(ERC20(_token).transferFrom(_user, address(this), _amount), "Nothing to deposit");

        ERC20(_token).approve(_cToken, uint256(-1));
        require(cTokenContract.mint(_amount) == 0, "Failed to mint");
        cTokenContract.transfer(_user, cTokenContract.balanceOf(address(this)));
    }

    /**
     *@dev Withdraw DAI from Compound protcol return it to users EOA
     *@param _user User proxy wallet address.
     *@param _amount Amount of DAI.
     */
    function withdraw(
        address _user,
        uint256 _amount,
        address _token,
        address _cToken
    ) public  {
        cTokenContract = CTokenInterface(_cToken);
        require(
            cTokenContract.transferFrom(_user, address(this), ERC20(_cToken).balanceOf(_user)),
            "Nothing to withdraw"
        );
        cTokenContract.approve(_cToken, uint256(-1));
        require(cTokenContract.redeemUnderlying(_amount) == 0, "Reedem Failed");
        uint256 cDaiBalance = cTokenContract.balanceOf(address(this));
        if (cDaiBalance > 0) {
            cTokenContract.transfer(_user, cDaiBalance);
        }
        ERC20(_token).transfer(_user, _amount);
    }
}
