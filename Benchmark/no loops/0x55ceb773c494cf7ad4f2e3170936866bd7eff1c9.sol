/**

 *Submitted for verification at Etherscan.io on 2020-12-19

*/



// SPDX-License-Identifier: -- 🎲 --



//pragma solidity ^0.7.5;
pragma solidity >=0.5 <0.7.17;



library SafeMath {



    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        require(c >= a, 'SafeMath: addition overflow');

        return c;

    }



    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, 'SafeMath: subtraction overflow');

        uint256 c = a - b;

        return c;

    }



    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {

            return 0;

        }



        uint256 c = a * b;

        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;

    }



    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, 'SafeMath: division by zero');

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;

    }



    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, 'SafeMath: modulo by zero');

        return a % b;

    }

}



library Math {



    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;

    }



    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;

    }



    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);

    }

}



contract Context {



    constructor() public{}



    function _msgSender() internal view returns (address payable) {

        return msg.sender;

    }



    function _msgData() internal view returns (bytes memory) {

        this;

        return msg.data;

    }

}



contract Ownable is Context {



    address private _owner;



    event OwnershipTransferred(

        address indexed previousOwner,

        address indexed newOwner

    );



    constructor() public {

        _owner = _msgSender();

        emit OwnershipTransferred(

            address(0),

            _owner

        );

    }



    function owner() public view returns (address) {

        return _owner;

    }



    modifier onlyOwner() {

        require(

            isOwner(),

            'Ownable: caller is not the owner'

        );

        _;

    }



    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;

    }



    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(

            _owner,

            address(0x0)

        );

        _owner = address(0x0);

    }



    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);

    }



    function _transferOwnership(address newOwner) internal {

        require(

            newOwner != address(0x0),

            'Ownable: new owner is the zero address'

        );

        emit OwnershipTransferred(_owner, newOwner);

        _owner = newOwner;

    }

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



library Address {



    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;

        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

        assembly { codehash := extcodehash(account) }

        return (codehash != 0x0 && codehash != accountHash);

    }



    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));

    }



    function sendValue(address payable recipient, uint256 amount) internal {

        require(

            address(this).balance >= amount,

            'Address: insufficient balance'

        );



        (bool success, ) = recipient.call.value(amount)('');



        require(

            success,

            'Address: unable to send value'

        );

    }

}



library SafeERC20 {



    using SafeMath for uint256;

    using Address for address;



    function safeTransfer(

        IERC20 token,

        address to,

        uint256 value

    )

        internal

    {

        callOptionalReturn(

            token,

            abi.encodeWithSelector(

                token.transfer.selector,

                to,

                value

            )

        );

    }



    function safeTransferFrom(

        IERC20 token,

        address from,

        address to,

        uint256 value

    )

        internal

    {

        callOptionalReturn(

            token,

            abi.encodeWithSelector(

                token.transferFrom.selector,

                from,

                to,

                value

            )

        );

    }



    function safeApprove(

        IERC20 token,

        address spender,

        uint256 value

    )

        internal

    {

        require(

            (value == 0) || (token.allowance(address(this), spender) == 0),

            'SafeERC20: approve from non-zero to non-zero allowance'

        );

        callOptionalReturn(

            token,

            abi.encodeWithSelector(

                token.approve.selector,

                spender,

                value

            )

        );

    }



    function safeIncreaseAllowance(

        IERC20 token,

        address spender,

        uint256 value

    )

        internal

    {

        uint256 newAllowance = token.allowance(

            address(this),

            spender

        ).add(value);



        callOptionalReturn(

            token,

            abi.encodeWithSelector(

                token.approve.selector,

                spender,

                newAllowance

            )

        );

    }



    function safeDecreaseAllowance(

        IERC20 token,

        address spender,

        uint256 value

    )

        internal

    {

        uint256 newAllowance = token.allowance(

            address(this),

            spender

        ).sub(value);



        callOptionalReturn(

            token,

            abi.encodeWithSelector(

                token.approve.selector,

                spender,

                newAllowance

            )

        );

    }



    function callOptionalReturn(

        IERC20 token,

        bytes memory data

    )

        private

    {

        require(

            address(token).isContract(),

            'SafeERC20: call to non-contract'

        );



        (bool success, bytes memory returndata) = address(token).call(data);

        require(

            success,

            'SafeERC20: low-level call failed'

        );



        if (returndata.length > 0) {

            require(

                abi.decode(returndata, (bool)),

                'SafeERC20: ERC20 operation did not succeed'

            );

        }

    }

}



contract LPTokenWrapper {



    using SafeMath for uint256;

    using SafeERC20 for IERC20;



    IERC20 public uni = IERC20(

        0x44c21F5DCB285D92320AE345C92e8B6204Be8CdF

    );



    uint256 private _totalSupply;

    mapping(address => uint256) private _balances;



    function totalSupply() public view returns (uint256) {

        return _totalSupply;

    }



    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];

    }



    function _stake(uint256 amount) internal {



        _totalSupply = _totalSupply.add(amount);



        _balances[msg.sender] =

        _balances[msg.sender].add(amount);



        uni.safeTransferFrom(

            msg.sender,

            address(this),

            amount

        );

    }



    function _withdraw(uint256 amount) internal {



        _totalSupply = _totalSupply.sub(amount);



        _balances[msg.sender] =

        _balances[msg.sender].sub(amount);



        uni.safeTransfer(

            msg.sender,

            amount

        );

    }

}



contract dgStaking3 is LPTokenWrapper, Ownable {



    using SafeMath for uint256;

    using SafeERC20 for IERC20;



    IERC20 public dg = IERC20(

        0xEE06A81a695750E71a662B51066F2c74CF4478a0

    );



    uint256 public constant DURATION = 5 weeks;

    

    uint256 public periodFinish;

    uint256 public rewardRate;

    uint256 public lastUpdateTime;

    uint256 public rewardPerTokenStored;



    mapping(address => uint256) public userRewardPerTokenPaid;

    mapping(address => uint256) public rewards;



    event RewardAdded(

        uint256 reward

    );



    event Staked(

        address indexed user,

        uint256 amount

    );



    event Withdrawn(

        address indexed user,

        uint256 amount

    );



    event RewardPaid(

        address indexed user,

        uint256 reward

    );



    modifier updateReward(address account) {



        rewardPerTokenStored = rewardPerToken();

        lastUpdateTime = lastTimeRewardApplicable();



        if (account != address(0)) {

            rewards[account] = earned(account);

            userRewardPerTokenPaid[account] = rewardPerTokenStored;

        }

        _;

    }



    function lastTimeRewardApplicable()

        public

        view

        returns (uint256)

    {

        return Math.min(

            block.timestamp,

            periodFinish

        );

    }



    function rewardPerToken()

        public

        view

        returns (uint256)

    {

        if (totalSupply() == 0) {

            return rewardPerTokenStored;

        }



        return rewardPerTokenStored.add(

            lastTimeRewardApplicable()

                .sub(lastUpdateTime)

                .mul(rewardRate)

                .mul(1e18)

                .div(totalSupply())

        );

    }



    function earned(

        address account

    )

        public

        view

        returns (uint256)

    {

        return balanceOf(account)

            .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))

            .div(1E18)

            .add(rewards[account]);

    }



    function stake(

        uint256 amount

    )

        public

        updateReward(msg.sender)

    {

        require(

            amount > 0,

            'Cannot stake 0'

        );



        _stake(amount);



        emit Staked(

            msg.sender,

            amount

        );

    }



    function withdraw(

        uint256 amount

    )

        public

        updateReward(msg.sender)

    {

        require(

            amount > 0,

            'Cannot withdraw 0'

        );



        _withdraw(amount);



        emit Withdrawn(

            msg.sender,

            amount

        );

    }



    function exit() external {

        withdraw(balanceOf(msg.sender));

        getReward();

    }



    function getReward()

        public

        updateReward(msg.sender)

        returns (uint256 reward)

    {

        reward = earned(msg.sender);

        if (reward > 0) {

            rewards[msg.sender] = 0;

            dg.safeTransfer(msg.sender, reward);

            emit RewardPaid(msg.sender, reward);

        }

    }



    function notifyRewardAmount(uint256 reward)

        external

        onlyOwner

        updateReward(address(0x0))

    {

        if (block.timestamp >= periodFinish) {

            rewardRate = reward.div(DURATION);

        } else {

            uint256 remaining = periodFinish.sub(block.timestamp);

            uint256 leftover = remaining.mul(rewardRate);

            rewardRate = reward.add(leftover).div(DURATION);

        }

        lastUpdateTime = block.timestamp;

        periodFinish = block.timestamp.add(DURATION);

        emit RewardAdded(reward);

    }

}
