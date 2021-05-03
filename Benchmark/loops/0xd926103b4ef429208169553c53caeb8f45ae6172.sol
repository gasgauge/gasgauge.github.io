/**
 *Submitted for verification at Etherscan.io on 2020-12-26
*/

//pragma solidity 0.5.8;
pragma solidity >=0.5 <0.7.17;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256)
    {
        if (a == 0)
        {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256)
    {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256)
    {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256)
    {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function ceil(uint256 a, uint256 m) internal pure returns (uint256)
    {
        uint256 c = add(a, m);
        uint256 d = sub(c, 1);
        return mul(div(d, m), m);
    }
}

// File: contracts/interfaces/IERC20.sol

//pragma solidity 0.5.8;
pragma solidity >=0.5 <0.7.17;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/utilities/ERC20Detailed.sol

//pragma solidity 0.5.8;
pragma solidity >=0.5 <0.7.17;


contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

// File: contracts/utilities/TransferAndCallFallBack.sol

//pragma solidity 0.5.8;
pragma solidity >=0.5 <0.7.17;

contract TransferAndCallFallBack {
    function receiveToken(address from, uint256 tokens, address token, bytes memory data) public returns (bool);
}

// File: contracts/utilities/ApproveAndCallFallBack.sol

//pragma solidity 0.5.8;
pragma solidity >=0.5 <0.7.17;

contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public returns (bool);
}

// File: contracts/libraries/Address.sol

//pragma solidity 0.5.8;
pragma solidity >=0.5 <0.7.17;

library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call.value(value)(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }


    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.3._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.3._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

// File: contracts/libraries/SafeERC20.sol

//pragma solidity 0.5.8;
pragma solidity >=0.5 <0.7.17;




library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
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
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: contracts/UPLINK.sol

//pragma solidity 0.5.8;
pragma solidity >=0.5 <0.7.17;








contract Uplink is ERC20Detailed {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowed;

    string constant tokenName = "Uplink";
    string constant tokenSymbol = "ULINK";
    uint8  constant tokenDecimals = 18;
    uint256 _totalSupply = 100000 * 18;

    // ------------------------------------------------------------------------

    address public contractOwner;

    uint256 public fullUnitsVested_total = 0;
    mapping(address => bool) public isVesting;

    uint256 _totalVestRewardsPerUnit = 0;
    mapping(address => uint256) private _totalVestRewardsPerUnit_positions;
    mapping(address => uint256) private _savedVestRewards;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // ------------------------------------------------------------------------

    bool public migrationActive = true;

    //these addresses won't be affected by burn,ie liquidity pools
    mapping(address => bool) public whitelist;

    event Whitelisted(address _addr, bool _whitelisted);

    // ------------------------------------------------------------------------

    constructor() public ERC20Detailed(tokenName, tokenSymbol, tokenDecimals)
    {
        contractOwner = msg.sender;
        _mint(msg.sender, 100000 * (10 ** uint256(tokenDecimals)));
    }


    // ------------------------------------------------------------------------

    modifier onlyOwner() {
        require(msg.sender == contractOwner, "only owner");
        _;
    }

    function transferOwnership(address newOwner) public {
        require(msg.sender == contractOwner);
        require(newOwner != address(0));
        emit OwnershipTransferred(contractOwner, newOwner);
        contractOwner = newOwner;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    function fullUnitsVested(address owner) external view returns (uint256) {
        return isVesting[owner] ? toFullUnits(_balances[owner]) : 0;
    }

    function toFullUnits(uint256 valueWithDecimals) public pure returns (uint256) {
        return valueWithDecimals.div(10 ** uint256(tokenDecimals));
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    function transfer(address to, uint256 value) public returns (bool) {
        _executeTransfer(msg.sender, to, value);
        return true;
    }

    function transferAndCall(address to, uint value, bytes memory data) public returns (bool) {
        require(transfer(to, value));
        require(TransferAndCallFallBack(to).receiveToken(msg.sender, value, address(this), data));
        return true;
    }


    function multiTransfer(address[] memory receivers, uint256[] memory values) public {
        require(receivers.length == values.length);
        for (uint256 i = 0; i < receivers.length; i++)
            _executeTransfer(msg.sender, receivers[i], values[i]);
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(value <= _allowed[from][msg.sender]);
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _executeTransfer(from, to, value);
        return true;
    }

    function transferFromAndCall(address from, address to, uint value, bytes memory data) public returns (bool) {
        require(transferFrom(from, to, value));
        require(TransferAndCallFallBack(to).receiveToken(from, value, address(this), data));
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function approveAndCall(address spender, uint tokens, bytes memory data) public returns (bool success) {
        require(approve(spender, tokens));
        require(ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].add(addedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool)
    {
        require(spender != address(0));
        _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].sub(subtractedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function _mint(address account, uint256 value) internal
    {
        require(value != 0);

        uint256 initalBalance = _balances[account];
        uint256 newBalance = initalBalance.add(value);

        _balances[account] = newBalance;
        _totalSupply = _totalSupply.add(value);

        //update full units vested
        if (isVesting[account])
        {
            uint256 fus_total = fullUnitsVested_total;
            fus_total = fus_total.sub(toFullUnits(initalBalance));
            fus_total = fus_total.add(toFullUnits(newBalance));
            fullUnitsVested_total = fus_total;
        }
        emit Transfer(address(0), account, value);
    }

    function burn(uint256 value) external
    {
        _burn(msg.sender, value);
    }

    function burnFrom(address account, uint256 value) external
    {
        require(value <= _allowed[account][msg.sender]);
        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);
        _burn(account, value);
    }

    function _burn(address account, uint256 value) internal
    {
        require(value != 0);
        require(value <= _balances[account]);

        uint256 initalBalance = _balances[account];
        uint256 newBalance = initalBalance.sub(value);

        _balances[account] = newBalance;
        _totalSupply = _totalSupply.sub(value);

        //update full units vested
        if (isVesting[account])
        {
            uint256 fus_total = fullUnitsVested_total;
            fus_total = fus_total.sub(toFullUnits(initalBalance));
            fus_total = fus_total.add(toFullUnits(newBalance));
            fullUnitsVested_total = fus_total;
        }

        emit Transfer(account, address(0), value);
    }

    /*
    *   transfer with additional burn and vest rewards
    *   the receiver gets 96% of the sent value
    *   4% are split to be burnt and distributed to holders
    */
    function _executeTransfer(address from, address to, uint256 value) private
    {
        require(value <= _balances[from]);
        require(to != address(0) && to != address(this));

        //Update sender and receivers vesting rewards - changing balances will change vest rewards shares
        updateVestRewardsFor(from);
        updateVestRewardsFor(to);

        uint256 fourPercent = 0;
        if (!whitelist[from] && !whitelist[to]) {
            fourPercent = value.mul(4).div(100);
            //set a minimum burn rate to prevent no-burn-txs due to precision loss
            if (fourPercent == 0 && value > 0)
                fourPercent = 1;
        }

        uint256 initalBalance_from = _balances[from];
        uint256 newBalance_from = initalBalance_from.sub(value);

        value = value.sub(fourPercent);

        uint256 initalBalance_to = from != to ? _balances[to] : newBalance_from;
        uint256 newBalance_to = initalBalance_to.add(value);

        //transfer
        _balances[from] = newBalance_from;
        _balances[to] = newBalance_to;
        emit Transfer(from, to, value);

        //update full units vested
        uint256 fus_total = fullUnitsVested_total;
        if (isVesting[from])
        {
            fus_total = fus_total.sub(toFullUnits(initalBalance_from));
            fus_total = fus_total.add(toFullUnits(newBalance_from));
        }
        if (isVesting[to])
        {
            fus_total = fus_total.sub(toFullUnits(initalBalance_to));
            fus_total = fus_total.add(toFullUnits(newBalance_to));
        }
        fullUnitsVested_total = fus_total;

        uint256 amountToBurn = fourPercent;

        if (fus_total > 0)
        {
            uint256 vestingRewards = fourPercent.div(2);
            //split up to rewards per unit in vest
            uint256 vestRewardsPerUnit = vestingRewards.div(fus_total);
            //apply rewards
            _totalVestRewardsPerUnit = _totalVestRewardsPerUnit.add(vestRewardsPerUnit);
            _balances[address(this)] = _balances[address(this)].add(vestingRewards);
            if (vestingRewards > 0)
                emit Transfer(msg.sender, address(this), vestingRewards);
            amountToBurn = amountToBurn.sub(vestingRewards);
        }

        //update total supply
        _totalSupply = _totalSupply.sub(amountToBurn);
        if (amountToBurn > 0)
            emit Transfer(msg.sender, address(0), amountToBurn);
    }

    //catch up with the current total rewards. This needs to be done before an addresses balance is changed
    function updateVestRewardsFor(address vester) private
    {
        _savedVestRewards[vester] = viewUnpaidVestRewards(vester);
        _totalVestRewardsPerUnit_positions[vester] = _totalVestRewardsPerUnit;
    }

    //get all rewards that have not been claimed yet
    function viewUnpaidVestRewards(address vester) public view returns (uint256)
    {
        if (!isVesting[vester])
            return _savedVestRewards[vester];
        uint256 newVestRewardsPerUnit = _totalVestRewardsPerUnit.sub(_totalVestRewardsPerUnit_positions[vester]);

        uint256 newVestRewards = newVestRewardsPerUnit.mul(toFullUnits(_balances[vester]));
        return _savedVestRewards[vester].add(newVestRewards);
    }

    //pay out unclaimed vest rewards
    function payoutVestRewards() public
    {
        updateVestRewardsFor(msg.sender);
        uint256 rewardsVest = _savedVestRewards[msg.sender];
        require(rewardsVest > 0 && rewardsVest <= _balances[address(this)]);

        _savedVestRewards[msg.sender] = 0;

        uint256 initalBalance_vester = _balances[msg.sender];
        uint256 newBalance_vester = initalBalance_vester.add(rewardsVest);

        //update full units vested
        if (isVesting[msg.sender])
        {
            uint256 fus_total = fullUnitsVested_total;
            fus_total = fus_total.sub(toFullUnits(initalBalance_vester));
            fus_total = fus_total.add(toFullUnits(newBalance_vester));
            fullUnitsVested_total = fus_total;
        }

        //transfer
        _mint(msg.sender, rewardsVest);
    }

    function enableVesting() public {
        _enableVesting(msg.sender);
    }

    function disableVesting() public {
        _disableVesting(msg.sender);
    }

    function enableVestingFor(address vester) public onlyOwner {
        _enableVesting(vester);
    }

    function disableVestingFor(address vester) public onlyOwner {
        _disableVesting(vester);
    }

    //enable vesting for target address
    function _enableVesting(address vester) private {
        require(!isVesting[vester]);
        updateVestRewardsFor(vester);
        isVesting[vester] = true;
        fullUnitsVested_total = fullUnitsVested_total.add(toFullUnits(_balances[vester]));
    }

    //disable vesting for target address
    function _disableVesting(address vester) private {
        require(isVesting[vester]);
        updateVestRewardsFor(vester);
        isVesting[vester] = false;
        fullUnitsVested_total = fullUnitsVested_total.sub(toFullUnits(_balances[vester]));
    }

    //no fees if receiver is whitelisted
    function setWhitelist(address _addr, bool _whitelisted) external onlyOwner {
        whitelist[_addr] = _whitelisted;
        emit Whitelisted(_addr, _whitelisted);
    }

    //migrate a list of balances
    function multiMigrateBalance(address[] memory receivers, uint256[] memory values) public {
        require(receivers.length == values.length);
        for (uint256 i = 0; i < receivers.length; i++)
            migrateBalance(receivers[i], values[i]);
    }

    //mint balance to a give address, only works as long as migrationmode is active
    function migrateBalance(address account, uint256 amount) public onlyOwner {
        require(migrationActive);
        _mint(account, amount);
    }

    //this will stop migration mode permanently
    function endMigration() public onlyOwner {
        migrationActive = false;
    }



// begin staking section



    address public owner;

    struct stakeTracker {
        uint256 lastBlockChecked;
        uint256 rewards;
        uint256 linkStaked;
    }

    uint256 private rewardsVar;
    address private linkAddress;

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    IERC20 private linkToken;

    uint256 private _totalLinkStaked;
    mapping(address => stakeTracker) private _stakedBalances;
    mapping(address => bool) blackListed;

    event Staked(address indexed user, uint256 amount, uint256 totalLinkStaked);
    event Withdrawn(address indexed user, uint256 amount);
    event Rewards(address indexed user, uint256 reward);

    modifier updateStakingReward(address account) {
        if (block.number > _stakedBalances[account].lastBlockChecked) {
            uint256 rewardBlocks = block.number
            .sub(_stakedBalances[account].lastBlockChecked);


            if (_stakedBalances[account].linkStaked > 0) {
                _stakedBalances[account].rewards = _stakedBalances[account].rewards
                .add(
                    _stakedBalances[account].linkStaked
                    .mul(rewardBlocks)
                    / rewardsVar);
            }

            _stakedBalances[account].lastBlockChecked = block.number;

            emit Rewards(account, _stakedBalances[account].rewards);
        }
        _;
    }

    /* in case someone mistakenly sent ERC20 tokens to the contract.
    */
    function withdrawERC20Tokens(address tokenAddress, uint256 amount) public onlyOwner
    {
        require(tokenAddress != linkAddress);
        require(tokenAddress != address(this));
        require(IERC20(tokenAddress).balanceOf(address(this)) >= amount);
        IERC20(tokenAddress).transfer(msg.sender, amount);
    }

    function setLinkAddress(address _linkAddress) public onlyOwner returns (uint256) {
        linkAddress = _linkAddress;
        linkToken = IERC20(_linkAddress);
    }

    function updatingStakingReward(address account) public returns (uint256) {
        if (block.number > _stakedBalances[account].lastBlockChecked) {
            uint256 rewardBlocks = block.number
            .sub(_stakedBalances[account].lastBlockChecked);


            if (_stakedBalances[account].linkStaked > 0) {
                _stakedBalances[account].rewards = _stakedBalances[account].rewards
                .add(
                    _stakedBalances[account].linkStaked
                    .mul(rewardBlocks)
                    / rewardsVar);
            }

            _stakedBalances[account].lastBlockChecked = block.number;

            emit Rewards(account, _stakedBalances[account].rewards);

        }
        return (_stakedBalances[account].rewards);
    }

    function getBlockNum() public view returns (uint256) {
        return block.number;
    }

    function getLastBlockCheckedNum(address _account) public view returns (uint256) {
        return _stakedBalances[_account].lastBlockChecked;
    }

    function getAddressStakeAmount(address _account) public view returns (uint256) {
        return _stakedBalances[_account].linkStaked;
    }

    function setRewardsVar(uint256 _amount) public onlyOwner {
        rewardsVar = _amount;
    }

    function totalStakedSupply() public view returns (uint256) {
        return _totalLinkStaked;
    }

    function myRewardsBalance(address account) public view returns (uint256) {
        if (block.number > _stakedBalances[account].lastBlockChecked) {
            uint256 rewardBlocks = block.number
            .sub(_stakedBalances[account].lastBlockChecked);


            if (_stakedBalances[account].linkStaked > 0) {
                return _stakedBalances[account].rewards
                .add(
                    _stakedBalances[account].linkStaked
                    .mul(rewardBlocks)
                    / rewardsVar);
            }
        }

    }

    function stake(uint256 amount) public updateStakingReward(msg.sender) {
        // Will prevent exchanges from staking;
        require(!blackListed[msg.sender]);
        _totalLinkStaked = _totalLinkStaked.add(amount);
        _stakedBalances[msg.sender].linkStaked = _stakedBalances[msg.sender].linkStaked.add(amount);
        linkToken.transferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount, _totalLinkStaked);
    }

    function withdraw(uint256 amount) public updateStakingReward(msg.sender) {
        _getReward(msg.sender);
        _totalLinkStaked = _totalLinkStaked.sub(amount);
        _stakedBalances[msg.sender].linkStaked = _stakedBalances[msg.sender].linkStaked.sub(amount);
        linkToken.transfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }

    function _getReward(address receiver) private {
        uint256 reward = _stakedBalances[receiver].rewards;
        _mint(receiver, reward);
        _stakedBalances[receiver].rewards = 0;
        emit Rewards(receiver, reward);
    }

    function getReward() public updateStakingReward(msg.sender) {
        _getReward(msg.sender);
    }

    // Will prevent exchanges from staking;
    function blackListAddress(address addr, bool blackList) external onlyOwner {
        blackListed[addr] = blackList;
    }

    function isBlackListed(address addr) public view returns (bool) {
        if (blackListed[addr] == true)
            return true;
        else
            return false;
    }
}
