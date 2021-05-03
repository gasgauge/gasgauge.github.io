/**

 *Submitted for verification at Etherscan.io on 2020-12-19

*/



// SPDX-License-Identifier: MIT



//pragma solidity >=0.6.0 <0.8.0;
pragma solidity >=0.5 <0.7.17;



pragma experimental ABIEncoderV2;



library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        require(c >= a, "SafeMath: addition overflow");



        return c;

    }



    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");

    }



    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);

        uint256 c = a - b;



        return c;

    }



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



    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");

    }



    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);

        return a % b;

    }

}



library Address {

    function isContract(address account) internal view returns (bool) {

        uint256 size;

        assembly { size := extcodesize(account) }

        return size > 0;

    }



    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");



        (bool success, ) = recipient.call.value(amount)("");

        require(success, "Address: unable to send value, recipient may have reverted");

    }



    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");

    }



    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);

    }



    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");

    }



    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");

        require(isContract(target), "Address: call to non-contract");



        (bool success, bytes memory returndata) = target.call.value(value)(data);

        return _verifyCallResult(success, returndata, errorMessage);

    }



    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");

    }



    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");



        (bool success, bytes memory returndata) = target.staticcall(data);

        return _verifyCallResult(success, returndata, errorMessage);

    }



    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");

    }



    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");



        (bool success, bytes memory returndata) = target.delegatecall(data);

        return _verifyCallResult(success, returndata, errorMessage);

    }



    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

        if (success) {

            return returndata;

        } else {

            if (returndata.length > 0) {

                assembly {

                    let returndata_size := mload(returndata)

                    revert(add(32, returndata), returndata_size)

                }

            } else {

                revert(errorMessage);

            }

        }

    }

}



interface IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);



    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);



    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

}



library SafeERC20 {

    using SafeMath for uint256;

    using Address for address;



    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));

    }



    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));

    }



    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),

            "SafeERC20: approve from non-zero to non-zero allowance"

        );

        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));

    }



    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);

        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));

    }



    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");

        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));

    }



    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {

            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");

        }

    }

}



 contract Context {

    function _msgSender() internal view  returns (address payable) {

        return msg.sender;

    }



    function _msgData() internal view  returns (bytes memory) {

        this;

        return msg.data;

    }

}



 contract Ownable is Context {

    address private _owner;



    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    constructor () public{

        address msgSender = _msgSender();

        _owner = msgSender;

        emit OwnershipTransferred(address(0), msgSender);

    }



    function owner() public view returns (address) {

        return _owner;

    }



    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");

        _;

    }



    function renounceOwnership() public  onlyOwner {

        emit OwnershipTransferred(_owner, address(0));

        _owner = address(0);

    }



    function transferOwnership(address newOwner) public  onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");

        emit OwnershipTransferred(_owner, newOwner);

        _owner = newOwner;

    }

}



contract Depository is Ownable {

    using SafeMath for uint256;

    using SafeERC20 for IERC20;



    uint256 private  _DURATION = 365 days;



    IERC20 private _token = IERC20(0xc878c93B5087887B908331Fcf8809B2C958cc5Ec); // ARK



    uint256 private _openingTime;



    struct Account {

        uint256 balances;

        uint256 released;

        uint256 releasedTime;

    }



    mapping (address => Account) private _accounts;



    event Deposited(address owner, uint256 amount);

    event Released(address owner, uint256 amount);



    constructor (uint256 openingTime_) public{

        require(openingTime_ > block.timestamp, "Depository: opening time is before current time");

        _openingTime = openingTime_;

    }



    function DURATION() external view returns (uint256) {

        return _DURATION;

    }



    function token() external view returns (IERC20) {

        return _token;

    }



    function openingTime() external view returns (uint256) {

        return _openingTime;

    }



    function accounts(address owner) external view returns (Account memory) {

        return _accounts[owner];

    }



    function deposit(address owner, uint256 amount) external onlyOwner {

        require(block.timestamp <_openingTime, "Depository::deposit: already closed");

        require(owner != address(0), "Depository::deposit: owner is the zero address");

        require(amount > 100 * 10 ** uint256(_token.decimals()), "Depository::deposit: tokens cannot be less than 100");



        Account storage account = _accounts[owner];

        if (account.balances > 0) {

            account.balances = account.balances.add(amount);

        } else {

            account.balances = amount;

            account.released = 0;

            account.releasedTime = _openingTime;

        }



        emit Deposited(owner, amount);

    }



    function release(address owner) external {

        uint256 unreleased = releasable(owner);

        require(unreleased > 0, "Depository::release: no tokens are due");



        Account storage account = _accounts[owner];

        require(account.releasedTime.add(24 hours) < block.timestamp, "Depository::release: can only be released once in 24 hours");



        account.balances = account.balances.sub(unreleased);

        account.released = account.released.add(unreleased);

        account.releasedTime = block.timestamp;



        _token.safeTransfer(owner, unreleased);



        emit Released(owner, unreleased);

    }



    function releasable(address owner) public view returns (uint256) {

        uint256 currentBalance = _accounts[owner].balances;

        uint256 totalBalance = currentBalance.add(_accounts[owner].released);



        if (block.timestamp < _openingTime) {

            return 0;

        }



        uint256 vestedAmount = 0;

        if (block.timestamp >= _openingTime.add(_DURATION)) {

            vestedAmount = totalBalance;

        } else {

            vestedAmount = (totalBalance.mul(block.timestamp.sub(_openingTime)).div(_DURATION));

        }



        return vestedAmount.sub(_accounts[owner].released);

    }

}
