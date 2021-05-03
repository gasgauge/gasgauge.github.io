/**
 *Submitted for verification at Etherscan.io on 2019-09-06
*/

//pragma solidity ^0.5.11;
pragma solidity >=0.5 <0.7.17;

    // Public-Sale for #3277-12000 stage of Voken2.0
    //
    // More info:
    //   https://vision.network
    //   https://voken.io
    //
    // Contact us:
    //   [email protected]
    //   [email protected]


    /**
     * @dev Uint256 wrappers over Solidity's arithmetic operations with added overflow checks.
     */
    library SafeMath256 {
        /**
         * @dev Returns the addition of two unsigned integers, reverting on overflow.
         */
        function add(uint256 a, uint256 b) internal pure returns (uint256) {
            uint256 c = a + b;
            require(c >= a, "SafeMath: addition overflow");

            return c;
        }

        /**
         * @dev Returns the subtraction of two unsigned integers, reverting on
         * overflow (when the result is negative).
         */
        function sub(uint256 a, uint256 b) internal pure returns (uint256) {
            return sub(a, b, "SafeMath: subtraction overflow");
        }

        /**
         * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
         * overflow (when the result is negative).
         */
        function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
            require(b <= a, errorMessage);
            uint256 c = a - b;

            return c;
        }

        /**
         * @dev Returns the multiplication of two unsigned integers, reverting on overflow.
         */
        function mul(uint256 a, uint256 b) internal pure returns (uint256) {
            if (a == 0) {
                return 0;
            }

            uint256 c = a * b;
            require(c / a == b, "SafeMath: multiplication overflow");

            return c;
        }

        /**
         * @dev Returns the integer division of two unsigned integers. Reverts on
         * division by zero. The result is rounded towards zero.
         */
        function div(uint256 a, uint256 b) internal pure returns (uint256) {
            return div(a, b, "SafeMath: division by zero");
        }

        /**
         * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
         * division by zero. The result is rounded towards zero.
         */
        function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
            // Solidity only automatically asserts when dividing by 0
            require(b > 0, errorMessage);
            return a / b;
        }

        /**
         * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
         * Reverts when dividing by zero.
         */
        function mod(uint256 a, uint256 b) internal pure returns (uint256) {
            return mod(a, b, "SafeMath: modulo by zero");
        }

        /**
         * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
         * Reverts with custom message when dividing by zero.
         */
        function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
            require(b != 0, errorMessage);
            return a % b;
        }
    }


    /**
     * @dev Uint16 wrappers over Solidity's arithmetic operations with added overflow checks.
     */
    library SafeMath16 {
        /**
         * @dev Returns the addition of two unsigned integers, reverting on overflow.
         */
        function add(uint16 a, uint16 b) internal pure returns (uint16) {
            uint16 c = a + b;
            require(c >= a, "SafeMath: addition overflow");

            return c;
        }

        /**
         * @dev Returns the subtraction of two unsigned integers, reverting on
         * overflow (when the result is negative).
         */
        function sub(uint16 a, uint16 b) internal pure returns (uint16) {
            return sub(a, b, "SafeMath: subtraction overflow");
        }

        /**
         * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
         * overflow (when the result is negative).
         */
        function sub(uint16 a, uint16 b, string memory errorMessage) internal pure returns (uint16) {
            require(b <= a, errorMessage);
            uint16 c = a - b;

            return c;
        }

        /**
         * @dev Returns the multiplication of two unsigned integers, reverting on overflow.
         */
        function mul(uint16 a, uint16 b) internal pure returns (uint16) {
            if (a == 0) {
                return 0;
            }

            uint16 c = a * b;
            require(c / a == b, "SafeMath: multiplication overflow");

            return c;
        }

        /**
         * @dev Returns the integer division of two unsigned integers. Reverts on
         * division by zero. The result is rounded towards zero.
         */
        function div(uint16 a, uint16 b) internal pure returns (uint16) {
            return div(a, b, "SafeMath: division by zero");
        }

        /**
         * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
         * division by zero. The result is rounded towards zero.
         */
        function div(uint16 a, uint16 b, string memory errorMessage) internal pure returns (uint16) {
            // Solidity only automatically asserts when dividing by 0
            require(b > 0, errorMessage);
            return a / b;
        }

        /**
         * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
         * Reverts when dividing by zero.
         */
        function mod(uint16 a, uint16 b) internal pure returns (uint16) {
            return mod(a, b, "SafeMath: modulo by zero");
        }

        /**
         * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
         * Reverts with custom message when dividing by zero.
         */
        function mod(uint16 a, uint16 b, string memory errorMessage) internal pure returns (uint16) {
            require(b != 0, errorMessage);
            return a % b;
        }
    }


    /**
     * @title Roles
     * @dev Library for managing addresses assigned to a Role.
     */
    library Roles {
        struct Role {
            mapping (address => bool) bearer;
        }

        /**
         * @dev Give an account access to this role.
         */
        function add(Role storage role, address account) internal {
            require(!has(role, account), "Roles: account already has role");
            role.bearer[account] = true;
        }

        /**
         * @dev Remove an account's access to this role.
         */
        function remove(Role storage role, address account) internal {
            require(has(role, account), "Roles: account does not have role");
            role.bearer[account] = false;
        }

        /**
         * @dev Check if an account has this role.
         * @return bool
         */
        function has(Role storage role, address account) internal view returns (bool) {
            require(account != address(0), "Roles: account is the zero address");
            return role.bearer[account];
        }
    }

    /**
     * @dev Contract module which provides a basic access control mechanism, where
     * there is an account (an owner) that can be granted exclusive access to
     * specific functions.
     */
    contract Ownable {
        address internal _owner;
        address internal _newOwner;

        event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
        event OwnershipAccepted(address indexed previousOwner, address indexed newOwner);


        /**
         * @dev Initializes the contract setting the deployer as the initial owner.
         */
        constructor () internal {
            _owner = msg.sender;
            emit OwnershipTransferred(address(0), _owner);
        }

        /**
         * @dev Returns the addresses of the current and new owner.
         */
        function owner() public view returns (address currentOwner, address newOwner) {
            currentOwner = _owner;
            newOwner = _newOwner;
        }

        /**
         * @dev Throws if called by any account other than the owner.
         */
        modifier onlyOwner() {
            require(isOwner(msg.sender), "Ownable: caller is not the owner");
            _;
        }

        /**
         * @dev Returns true if the caller is the current owner.
         */
        function isOwner(address account) public view returns (bool) {
            return account == _owner;
        }

        /**
         * @dev Transfers ownership of the contract to a new account (`newOwner`).
         *
         * IMPORTANT: Need to run {acceptOwnership} by the new owner.
         */
        function _transferOwnership(address newOwner) internal {
            require(newOwner != address(0), "Ownable: new owner is the zero address");

            emit OwnershipTransferred(_owner, newOwner);
            _newOwner = newOwner;
        }

        /**
         * @dev Transfers ownership of the contract to a new account (`newOwner`).
         *
         * Can only be called by the current owner.
         */
        function transferOwnership(address newOwner) public onlyOwner {
            _transferOwnership(newOwner);
        }

        /**
         * @dev Accept ownership of the contract.
         *
         * Can only be called by the new owner.
         */
        function acceptOwnership() public {
            require(msg.sender == _newOwner, "Ownable: caller is not the new owner address");
            require(msg.sender != address(0), "Ownable: caller is the zero address");

            emit OwnershipAccepted(_owner, msg.sender);
            _owner = msg.sender;
            _newOwner = address(0);
        }

        /**
         * @dev Rescue compatible ERC20 Token
         *
         * Can only be called by the current owner.
         */
        function rescueTokens(address tokenAddr, address recipient, uint256 amount) external onlyOwner {
            IERC20 _token = IERC20(tokenAddr);
            require(recipient != address(0), "Rescue: recipient is the zero address");
            uint256 balance = _token.balanceOf(address(this));

            require(balance >= amount, "Rescue: amount exceeds balance");
            _token.transfer(recipient, amount);
        }

        /**
         * @dev Withdraw Ether
         *
         * Can only be called by the current owner.
         */
        function withdrawEther(address payable recipient, uint256 amount) external onlyOwner {
            require(recipient != address(0), "Withdraw: recipient is the zero address");

            uint256 balance = address(this).balance;

            require(balance >= amount, "Withdraw: amount exceeds balance");
            recipient.transfer(amount);
        }
    }


    /**
     * @dev Base contract which allows children to implement an emergency stop mechanism.
     */
    contract Pausable is Ownable {
        bool private _paused;

        event Paused(address account);
        event Unpaused(address account);


        /**
         * @dev Constructor
         */
        constructor () internal {
            _paused = false;
        }

        /**
         * @return Returns true if the contract is paused, false otherwise.
         */
        function paused() public view returns (bool) {
            return _paused;
        }

        /**
         * @dev Modifier to make a function callable only when the contract is not paused.
         */
        modifier whenNotPaused() {
            require(!_paused, "Paused");
            _;
        }

        /**
         * @dev Sets paused state.
         *
         * Can only be called by the current owner.
         */
        function setPaused(bool value) external onlyOwner {
            _paused = value;

            if (_paused) {
                emit Paused(msg.sender);
            } else {
                emit Unpaused(msg.sender);
            }
        }
    }


    /**
     * @dev Part of ERC20 interface.
     */
    interface IERC20 {
        function balanceOf(address account) external view returns (uint256);
        function transfer(address recipient, uint256 amount) external returns (bool);
    }


    /**
     * @title Voken2.0 interface.
     */
    interface IVoken2 {
        function balanceOf(address owner) external view returns (uint256);
        function transfer(address to, uint256 value) external returns (bool);
        function mint(address account, uint256 amount) external returns (bool);
        function mintWithAllocation(address account, uint256 amount, address allocationContract) external returns (bool);
        function whitelisted(address account) external view returns (bool);
        function whitelistReferee(address account) external view returns (address payable);
        function whitelistReferralsCount(address account) external view returns (uint256);
    }


    /**
     * @dev Interface of an allocation contract
     */
    interface IAllocation {
        function reservedOf(address account) external view returns (uint256);
    }


    /**
     * @dev Allocation for VOKEN
     */
    library Allocations {
        struct Allocation {
            uint256 amount;
            uint256 timestamp;
        }
    }


    /**
     * @title VokenShareholders interface.
     */
    interface VokenShareholders {
        //
    }


    /**
     * @title Voken Public Sale v2.0
     */
    contract VokenPublicSale2 is Ownable, Pausable, IAllocation {
        using SafeMath16 for uint16;
        using SafeMath256 for uint256;
        using Roles for Roles.Role;
        using Allocations for Allocations.Allocation;

        // Proxy
        Roles.Role private _proxies;

        // Addresses
        IVoken2 private _VOKEN = IVoken2(0xFfFAb974088Bd5bF3d7E6F522e93Dd7861264cDB);
        VokenShareholders private _SHAREHOLDERS = VokenShareholders(0x7712F76D2A52141D44461CDbC8b660506DCAB752);
        address payable private _TEAM;

        // Referral rewards, 35% for 15 levels
        uint16[15] private REWARDS_PCT = [6, 6, 5, 4, 3, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1];

        // Limit
        uint16[] private LIMIT_COUNTER = [1, 3, 10, 50, 100, 200, 300];
        uint256[] private LIMIT_WEIS = [100 ether, 50 ether, 40 ether, 30 ether, 20 ether, 10 ether, 5 ether];
        uint256 private LIMIT_WEI_MIN = 3 ether;

        // Gas
        uint24 private GAS_MIN = 5970000;
        uint24 private GAS_EX = 1500000;

        // Price
        uint256 private VOKEN_USD_PRICE_START = 1000;       // $      0.00100 USD
        uint256 private VOKEN_USD_PRICE_STEP = 10;          // $    + 0.00001 USD
        uint256 private STAGE_USD_CAP_START = 100000000;    // $    100 USD
        uint256 private STAGE_USD_CAP_STEP = 1000000;       // $     +1 USD
        uint256 private STAGE_USD_CAP_MAX = 15100000000;    // $ 15,100 USD

        // 1 Ether|Voken = xx.xxxxxx USD, with 6 decimals
        uint256 private _etherUsdPrice;
        uint256 private _vokenUsdPrice;

        // Progress
        uint16 private SEASON_MAX = 100;    // 100 seasons max
        uint16 private SEASON_LIMIT = 20;   // 20 season total
        uint16 private SEASON_STAGES = 600; // each 600 stages is a season
        uint16 private STAGE_MAX = SEASON_STAGES.mul(SEASON_MAX);
        uint16 private STAGE_LIMIT = SEASON_STAGES.mul(SEASON_LIMIT);
        uint16 private _stage;
        uint16 private _season;

        // Sum
        uint256 private _txs;
        uint256 private _vokenIssued;
        uint256 private _vokenIssuedTxs;
        uint256 private _vokenBonus;
        uint256 private _vokenBonusTxs;
        uint256 private _weiSold;
        uint256 private _weiRewarded;
        uint256 private _weiShareholders;
        uint256 private _weiTeam;
        uint256 private _weiPended;

        // Shareholders ratio
        uint256 private SHAREHOLDERS_RATIO_START = 15000000;    // 15%, with 8 decimals
        uint256 private SHAREHOLDERS_RATIO_DISTANCE = 50000000; // 50%, with 8 decimals
        uint256 private _shareholdersRatio;

        // Cache
        bool private _cacheWhitelisted;
        uint256 private _cacheWeiShareholders;
        uint256 private _cachePended;
        uint16[] private _cacheRewards;
        address payable[] private _cacheReferees;

        // Allocations
        mapping (address => Allocations.Allocation[]) private _allocations;

        // Account
        mapping (address => uint256) private _accountVokenIssued;
        mapping (address => uint256) private _accountVokenBonus;
        mapping (address => uint256) private _accountVokenReferral;
        mapping (address => uint256) private _accountVokenReferrals;
        mapping (address => uint256) private _accountWeiPurchased;
        mapping (address => uint256) private _accountWeiRewarded;

        // Stage
        mapping (uint16 => uint256) private _stageUsdSold;
        mapping (uint16 => uint256) private _stageVokenIssued;
        mapping (uint16 => uint256) private _stageVokenBonus;

        // Season
        mapping (uint16 => uint256) private _seasonWeiSold;
        mapping (uint16 => uint256) private _seasonWeiRewarded;
        mapping (uint16 => uint256) private _seasonWeiShareholders;
        mapping (uint16 => uint256) private _seasonWeiPended;
        mapping (uint16 => uint256) private _seasonVokenIssued;
        mapping (uint16 => uint256) private _seasonVokenBonus;

        // Account in season
        mapping (uint16 => mapping (address => uint256)) private _vokenSeasonAccountIssued;
        mapping (uint16 => mapping (address => uint256)) private _vokenSeasonAccountBonus;
        mapping (uint16 => mapping (address => uint256)) private _vokenSeasonAccountReferral;
        mapping (uint16 => mapping (address => uint256)) private _vokenSeasonAccountReferrals;
        mapping (uint16 => mapping (address => uint256)) private _weiSeasonAccountPurchased;
        mapping (uint16 => mapping (address => uint256)) private _weiSeasonAccountReferrals;
        mapping (uint16 => mapping (address => uint256)) private _weiSeasonAccountRewarded;

        // Season wei limit accounts
        mapping (uint16 => mapping (uint256 => address[])) private _seasonLimitAccounts;
        mapping (uint16 => address[]) private _seasonLimitWeiMinAccounts;

        // Referrals
        mapping (uint16 => address[]) private _seasonAccounts;
        mapping (uint16 => address[]) private _seasonReferrals;
        mapping (uint16 => mapping (address => bool)) private _seasonHasAccount;
        mapping (uint16 => mapping (address => bool)) private _seasonHasReferral;
        mapping (uint16 => mapping (address => address[])) private _seasonAccountReferrals;
        mapping (uint16 => mapping (address => mapping (address => bool))) private _seasonAccountHasReferral;

        // Events
        event ProxyAdded(address indexed account);
        event ProxyRemoved(address indexed account);
        event StageClosed(uint256 _stageNumber);
        event SeasonClosed(uint16 _seasonNumber);
        event AuditEtherPriceUpdated(uint256 value, address indexed account);

        event Log(uint256 value);

        /**
         * @dev Throws if called by account which is not a proxy.
         */
        modifier onlyProxy() {
            require(isProxy(msg.sender), "ProxyRole: caller does not have the Proxy role");
            _;
        }

        /**
         * @dev Returns true if the `account` has the Proxy role.
         */
        function isProxy(address account) public view returns (bool) {
            return _proxies.has(account);
        }

        /**
         * @dev Give an `account` access to the Proxy role.
         *
         * Can only be called by the current owner.
         */
        function addProxy(address account) public onlyOwner {
            _proxies.add(account);
            emit ProxyAdded(account);
        }

        /**
         * @dev Remove an `account` access from the Proxy role.
         *
         * Can only be called by the current owner.
         */
        function removeProxy(address account) public onlyOwner {
            _proxies.remove(account);
            emit ProxyRemoved(account);
        }

        /**
         * @dev Returns the VOKEN address.
         */
        function VOKEN() public view returns (IVoken2) {
            return _VOKEN;
        }

        /**
         * @dev Returns the shareholders contract address.
         */
        function SHAREHOLDERS() public view returns (VokenShareholders) {
            return _SHAREHOLDERS;
        }

        /**
         * @dev Returns the team wallet address.
         */
        function TEAM() public view returns (address) {
            return _TEAM;
        }

        /**
         * @dev Returns the main status.
         */
        function status() public view returns (uint16 stage,
                                               uint16 season,
                                               uint256 etherUsdPrice,
                                               uint256 vokenUsdPrice,
                                               uint256 shareholdersRatio) {
            if (_stage > STAGE_MAX) {
                stage = STAGE_MAX;
                season = SEASON_MAX;
            }
            else {
                stage = _stage;
                season = _season;
            }

            etherUsdPrice = _etherUsdPrice;
            vokenUsdPrice = _vokenUsdPrice;
            shareholdersRatio = _shareholdersRatio;
        }

        /**
         * @dev Returns the sum.
         */
        function sum() public view returns(uint256 vokenIssued,
                                           uint256 vokenBonus,
                                           uint256 weiSold,
                                           uint256 weiRewarded,
                                           uint256 weiShareholders,
                                           uint256 weiTeam,
                                           uint256 weiPended) {
            vokenIssued = _vokenIssued;
            vokenBonus = _vokenBonus;

            weiSold = _weiSold;
            weiRewarded = _weiRewarded;
            weiShareholders = _weiShareholders;
            weiTeam = _weiTeam;
            weiPended = _weiPended;
        }

        /**
         * @dev Returns the transactions' counter.
         */
        function transactions() public view returns(uint256 txs,
                                                    uint256 vokenIssuedTxs,
                                                    uint256 vokenBonusTxs) {
            txs = _txs;
            vokenIssuedTxs = _vokenIssuedTxs;
            vokenBonusTxs = _vokenBonusTxs;
        }

        /**
         * @dev Returns the `account` data.
         */
        function queryAccount(address account) public view returns (uint256 vokenIssued,
                                                                    uint256 vokenBonus,
                                                                    uint256 vokenReferral,
                                                                    uint256 vokenReferrals,
                                                                    uint256 weiPurchased,
                                                                    uint256 weiRewarded) {
            vokenIssued = _accountVokenIssued[account];
            vokenBonus = _accountVokenBonus[account];
            vokenReferral = _accountVokenReferral[account];
            vokenReferrals = _accountVokenReferrals[account];
            weiPurchased = _accountWeiPurchased[account];
            weiRewarded = _accountWeiRewarded[account];
        }

        /**
         * @dev Returns the stage data by `stageIndex`.
         */
        function stage(uint16 stageIndex) public view returns (uint256 vokenUsdPrice,
                                                               uint256 shareholdersRatio,
                                                               uint256 vokenIssued,
                                                               uint256 vokenBonus,
                                                               uint256 vokenCap,
                                                               uint256 vokenOnSale,
                                                               uint256 usdSold,
                                                               uint256 usdCap,
                                                               uint256 usdOnSale) {
            if (stageIndex <= STAGE_LIMIT) {
                vokenUsdPrice = _calcVokenUsdPrice(stageIndex);
                shareholdersRatio = _calcShareholdersRatio(stageIndex);

                vokenIssued = _stageVokenIssued[stageIndex];
                vokenBonus = _stageVokenBonus[stageIndex];
                vokenCap = _stageVokenCap(stageIndex);
                vokenOnSale = vokenCap.sub(vokenIssued);

                usdSold = _stageUsdSold[stageIndex];
                usdCap = _stageUsdCap(stageIndex);
                usdOnSale = usdCap.sub(usdSold);
            }
        }

        /**
         * @dev Returns the season data by `seasonNumber`.
         */
        function season(uint16 seasonNumber) public view returns (uint256 vokenIssued,
                                                                  uint256 vokenBonus,
                                                                  uint256 weiSold,
                                                                  uint256 weiRewarded,
                                                                  uint256 weiShareholders,
                                                                  uint256 weiPended) {
            if (seasonNumber <= SEASON_LIMIT) {
                vokenIssued = _seasonVokenIssued[seasonNumber];
                vokenBonus = _seasonVokenBonus[seasonNumber];

                weiSold = _seasonWeiSold[seasonNumber];
                weiRewarded = _seasonWeiRewarded[seasonNumber];
                weiShareholders = _seasonWeiShareholders[seasonNumber];
                weiPended = _seasonWeiPended[seasonNumber];
            }
        }

        /**
         * @dev Returns the `account` data of #`seasonNumber` season.
         */
        function accountInSeason(address account, uint16 seasonNumber) public view returns (uint256 vokenIssued,
                                                                                            uint256 vokenBonus,
                                                                                            uint256 vokenReferral,
                                                                                            uint256 vokenReferrals,
                                                                                            uint256 weiPurchased,
                                                                                            uint256 weiReferrals,
                                                                                            uint256 weiRewarded) {
            if (seasonNumber > 0 && seasonNumber <= SEASON_LIMIT) {
                vokenIssued = _vokenSeasonAccountIssued[seasonNumber][account];
                vokenBonus = _vokenSeasonAccountBonus[seasonNumber][account];
                vokenReferral = _vokenSeasonAccountReferral[seasonNumber][account];
                vokenReferrals = _vokenSeasonAccountReferrals[seasonNumber][account];
                weiPurchased = _weiSeasonAccountPurchased[seasonNumber][account];
                weiReferrals = _weiSeasonAccountReferrals[seasonNumber][account];
                weiRewarded = _weiSeasonAccountRewarded[seasonNumber][account];
            }
        }

        /**
         * @dev Referral accounts in a season by `seasonNumber`.
         */
        function seasonReferrals(uint16 seasonNumber) public view returns (address[] memory) {
            return _seasonReferrals[seasonNumber];
        }

        /**
         * @dev Referral accounts in a season by `seasonNumber` of `account`.
         */
        function seasonAccountReferrals(uint16 seasonNumber, address account) public view returns (address[] memory) {
            return _seasonAccountReferrals[seasonNumber][account];
        }

        /**
         * @dev Voken price in USD, by `stageIndex`.
         */
        function _calcVokenUsdPrice(uint16 stageIndex) private view returns (uint256) {
            return VOKEN_USD_PRICE_START.add(VOKEN_USD_PRICE_STEP.mul(stageIndex));
        }

        /**
         * @dev Returns the shareholders ratio by `stageIndex`.
         */
        function _calcShareholdersRatio(uint16 stageIndex) private view returns (uint256) {
            return SHAREHOLDERS_RATIO_START.add(SHAREHOLDERS_RATIO_DISTANCE.mul(stageIndex).div(STAGE_MAX));
        }

        /**
         * @dev Returns the dollor cap of `stageIndex`.
         */
        function _stageUsdCap(uint16 stageIndex) private view returns (uint256) {
            uint256 __usdCap = STAGE_USD_CAP_START.add(STAGE_USD_CAP_STEP.mul(stageIndex));

            if (__usdCap > STAGE_USD_CAP_MAX) {
                return STAGE_USD_CAP_MAX;
            }

            return __usdCap;
        }

        /**
         * @dev Returns the Voken cap of `stageIndex`.
         */
        function _stageVokenCap(uint16 stageIndex) private view returns (uint256) {
            return _stageUsdCap(stageIndex).mul(1000000).div(_calcVokenUsdPrice(stageIndex));
        }

        /**
         * @dev Returns an {uint256} by `value` * _shareholdersRatio / 100000000
         */
        function _2shareholders(uint256 value) private view returns (uint256) {
            return value.mul(_shareholdersRatio).div(100000000);
        }

        /**
         * @dev wei => USD, by `weiAmount`.
         */
        function _wei2usd(uint256 weiAmount) private view returns (uint256) {
            return weiAmount.mul(_etherUsdPrice).div(1 ether);
        }

        /**
         * @dev USD => wei, by `usdAmount`.
         */
        function _usd2wei(uint256 usdAmount) private view returns (uint256) {
            return usdAmount.mul(1 ether).div(_etherUsdPrice);
        }

        /**
         * @dev USD => voken, by `usdAmount`.
         */
        function _usd2voken(uint256 usdAmount) private view returns (uint256) {
            return usdAmount.mul(1000000).div(_vokenUsdPrice);
        }

        /**
         * @dev Returns the season number by `stageIndex`.
         */
        function _seasonNumber(uint16 stageIndex) private view returns (uint16) {
            if (stageIndex > 0) {
                uint16 __seasonNumber = stageIndex.div(SEASON_STAGES);

                if (stageIndex.mod(SEASON_STAGES) > 0) {
                    return __seasonNumber.add(1);
                }

                return __seasonNumber;
            }

            return 1;
        }

        /**
         * Close the current stage.
         */
        function _closeStage() private {
            _stage = _stage.add(1);
            emit StageClosed(_stage);

            // Close current season
            uint16 __seasonNumber = _seasonNumber(_stage);
            if (_season < __seasonNumber) {
                _season = __seasonNumber;
                emit SeasonClosed(_season);
            }

            _vokenUsdPrice = _calcVokenUsdPrice(_stage);
            _shareholdersRatio = _calcShareholdersRatio(_stage);
        }

        /**
         * @dev Update audit ether price.
         */
        function updateEtherUsdPrice(uint256 value) external onlyProxy {
            _etherUsdPrice = value;
            emit AuditEtherPriceUpdated(value, msg.sender);
        }

        /**
         * @dev Update team wallet address.
         */
        function updateTeamWallet(address payable account) external onlyOwner {
            _TEAM = account;
        }

        /**
         * @dev Returns current max wei value.
         */
        function weiMax() public view returns (uint256) {
            for(uint16 i = 0; i < LIMIT_WEIS.length; i++) {
                if (_seasonLimitAccounts[_season][i].length < LIMIT_COUNTER[i]) {
                    return LIMIT_WEIS[i];
                }
            }

            return LIMIT_WEI_MIN;
        }

        /**
         * @dev Returns the {limitIndex} and {weiMax}.
         */
        function _limit(uint256 weiAmount) private view returns (uint256 __wei) {
            uint256 __purchased = _weiSeasonAccountPurchased[_season][msg.sender];
            for(uint16 i = 0; i < LIMIT_WEIS.length; i++) {
                if (__purchased >= LIMIT_WEIS[i]) {
                    return 0;
                }

                if (__purchased < LIMIT_WEIS[i]) {
                    __wei = LIMIT_WEIS[i].sub(__purchased);
                    if (weiAmount >= __wei && _seasonLimitAccounts[_season][i].length < LIMIT_COUNTER[i]) {
                        return __wei;
                    }
                }
            }

            if (__purchased < LIMIT_WEI_MIN) {
                return LIMIT_WEI_MIN.sub(__purchased);
            }
        }

        /**
         * @dev Updates the season limit accounts, or wei min accounts.
         */
        function _updateSeasonLimits() private {
            uint256 __purchased = _weiSeasonAccountPurchased[_season][msg.sender];
            if (__purchased > LIMIT_WEI_MIN) {
                for(uint16 i = 0; i < LIMIT_WEIS.length; i++) {
                    if (__purchased >= LIMIT_WEIS[i]) {
                        _seasonLimitAccounts[_season][i].push(msg.sender);
                        return;
                    }
                }
            }

            else if (__purchased == LIMIT_WEI_MIN) {
                _seasonLimitWeiMinAccounts[_season].push(msg.sender);
                return;
            }
        }

        /**
         * @dev Returns the accounts of wei limit, by `seasonNumber` and `limitIndex`.
         */
        function seasonLimitAccounts(uint16 seasonNumber, uint16 limitIndex) public view returns (uint256 weis, address[] memory accounts) {
            if (limitIndex < LIMIT_WEIS.length) {
                weis = LIMIT_WEIS[limitIndex];
                accounts = _seasonLimitAccounts[seasonNumber][limitIndex];
            }

            else {
                weis = LIMIT_WEI_MIN;
                accounts = _seasonLimitWeiMinAccounts[seasonNumber];
            }
        }

        /**
         * @dev constructor
         */
        constructor () public {
            _stage = 3277;
            _season = _seasonNumber(_stage);
            _vokenUsdPrice = _calcVokenUsdPrice(_stage);
            _shareholdersRatio = _calcShareholdersRatio(_stage);

            _TEAM = msg.sender;
            addProxy(msg.sender);
        }

        /**
         * @dev Receive ETH, and excute the exchange.
         */
        function () external payable whenNotPaused {
            require(gasleft() >= GAS_MIN, "VokenPublicSale: Gas is not enough");
            require(_etherUsdPrice > 0, "VokenPublicSale2: Audit ETH price is zero");
            require(_stage <= STAGE_MAX, "VokenPublicSale2: Voken Public-Sale Completled");

            uint256 __usdAmount;
            uint256 __usdRemain;
            uint256 __usdUsed;
            uint256 __weiUsed;
            uint256 __voken;

            // Limit
            uint256 __weiMax = _limit(msg.value);
            if (__weiMax < msg.value) {
                __usdAmount = _wei2usd(__weiMax);
            }
            else {
                __usdAmount = _wei2usd(msg.value);
            }

            __usdRemain = __usdAmount;

            if (__usdRemain > 0) {
                // cache
                _cache();

                // USD => Voken
                while (gasleft() > GAS_EX && __usdRemain > 0 && _stage <= STAGE_LIMIT) {
                    uint256 __txVokenIssued;
                    (__txVokenIssued, __usdRemain) = _tx(__usdRemain);
                    __voken = __voken.add(__txVokenIssued);
                }

                // Used
                __usdUsed = __usdAmount.sub(__usdRemain);
                __weiUsed = _usd2wei(__usdUsed);

                // Whitelist
                if (_cacheWhitelisted && __voken > 0) {
                    _mintVokenBonus(__voken);

                    for(uint16 i = 0; i < _cacheReferees.length; i++) {
                        address payable __referee = _cacheReferees[i];
                        uint256 __weiReward = __weiUsed.mul(_cacheRewards[i]).div(100);

                        __referee.transfer(__weiReward);
                        _weiRewarded = _weiRewarded.add(__weiReward);
                        _accountWeiRewarded[__referee] = _accountWeiRewarded[__referee].add(__weiReward);
                    }

                    if (_cachePended > 0) {
                        _weiPended = _weiPended.add(__weiUsed.mul(_cachePended).div(100));
                    }
                }

                // Counter
                if (__weiUsed > 0) {
                    _txs = _txs.add(1);
                    _weiSold = _weiSold.add(__weiUsed);
                    _accountWeiPurchased[msg.sender] = _accountWeiPurchased[msg.sender].add(__weiUsed);

                    // Wei for SHAREHOLDERS
                    _weiShareholders = _weiShareholders.add(_cacheWeiShareholders);
                    (bool __bool,) = address(_SHAREHOLDERS).call.value(_cacheWeiShareholders)("");
                    assert(__bool);

                    // Wei for TEAM
                    uint256 __weiTeam = _weiSold.sub(_weiRewarded).sub(_weiShareholders).sub(_weiPended).sub(_weiTeam);
                    _weiTeam = _weiTeam.add(__weiTeam);
                    _TEAM.transfer(__weiTeam);

                    // Update season limits
                    _updateSeasonLimits();
                }

                // Reset cache
                _resetCache();
            }

            // If wei remains, refund.
            uint256 __weiRemain = msg.value.sub(__weiUsed);
            if (__weiRemain > 0) {
                msg.sender.transfer(__weiRemain);
            }
        }

        /**
         * @dev Cache.
         */
        function _cache() private {
            if (!_seasonHasAccount[_season][msg.sender]) {
                _seasonAccounts[_season].push(msg.sender);
                _seasonHasAccount[_season][msg.sender] = true;
            }

            _cacheWhitelisted = _VOKEN.whitelisted(msg.sender);
            if (_cacheWhitelisted) {
                address __account = msg.sender;
                for(uint16 i = 0; i < REWARDS_PCT.length; i++) {
                    address __referee = _VOKEN.whitelistReferee(__account);

                    if (__referee != address(0) && __referee != __account && _VOKEN.whitelistReferralsCount(__referee) > i) {
                        if (!_seasonHasReferral[_season][__referee]) {
                            _seasonReferrals[_season].push(__referee);
                            _seasonHasReferral[_season][__referee] = true;
                        }

                        if (!_seasonAccountHasReferral[_season][__referee][__account]) {
                            _seasonAccountReferrals[_season][__referee].push(__account);
                            _seasonAccountHasReferral[_season][__referee][__account] = true;
                        }

                        _cacheReferees.push(address(uint160(__referee)));
                        _cacheRewards.push(REWARDS_PCT[i]);
                    }
                    else {
                        _cachePended = _cachePended.add(REWARDS_PCT[i]);
                    }

                    __account = __referee;
                }
            }
        }

        /**
         * @dev Reset cache.
         */
        function _resetCache() private {
            delete _cacheWeiShareholders;

            if (_cacheWhitelisted) {
                delete _cacheWhitelisted;
                delete _cacheReferees;
                delete _cacheRewards;
                delete _cachePended;
            }
        }

        /**
         * @dev USD => Voken
         */
        function _tx(uint256 __usd) private returns (uint256 __voken, uint256 __usdRemain) {
            uint256 __stageUsdCap = _stageUsdCap(_stage);
            uint256 __usdUsed;

            // in stage
            if (_stageUsdSold[_stage].add(__usd) <= __stageUsdCap) {
                __usdUsed = __usd;

                (__voken, ) = _calcExchange(__usdUsed);
                _mintVokenIssued(__voken);

                // close stage, if stage dollor cap reached
                if (__stageUsdCap == _stageUsdSold[_stage]) {
                    _closeStage();
                }
            }

            // close stage
            else {
                __usdUsed = __stageUsdCap.sub(_stageUsdSold[_stage]);

                (__voken, ) = _calcExchange(__usdUsed);
                _mintVokenIssued(__voken);

                _closeStage();

                __usdRemain = __usd.sub(__usdUsed);
            }
        }

        /**
         * @dev USD => voken & wei, and make records.
         */
        function _calcExchange(uint256 __usd) private returns (uint256 __voken, uint256 __wei) {
            __wei = _usd2wei(__usd);
            __voken = _usd2voken(__usd);

            uint256 __weiShareholders = _usd2wei(_2shareholders(__usd));

            // Stage: usd
            _stageUsdSold[_stage] = _stageUsdSold[_stage].add(__usd);

            // Season: wei
            _seasonWeiSold[_season] = _seasonWeiSold[_season].add(__wei);

            // Season: wei pended
            if (_cachePended > 0) {
                _seasonWeiPended[_season] = _seasonWeiPended[_season].add(__wei.mul(_cachePended).div(100));
            }

            // Season shareholders: wei
            _seasonWeiShareholders[_season] = _seasonWeiShareholders[_season].add(__weiShareholders);

            // Cache
            _cacheWeiShareholders = _cacheWeiShareholders.add(__weiShareholders);

            // Season => account: wei
            _weiSeasonAccountPurchased[_season][msg.sender] = _weiSeasonAccountPurchased[_season][msg.sender].add(__wei);

            // season referral account
            if (_cacheWhitelisted) {
                for (uint16 i = 0; i < _cacheRewards.length; i++) {
                    address __referee = _cacheReferees[i];
                    uint256 __weiReward = __wei.mul(_cacheRewards[i]).div(100);

                    // 
                    if (i == 0) {
                        _accountVokenReferral[__referee] = _accountVokenReferral[__referee].add(__voken);
                        _vokenSeasonAccountReferral[_season][__referee] = _vokenSeasonAccountReferral[_season][__referee].add(__voken);
                    }

                    // season
                    _seasonWeiRewarded[_season] = _seasonWeiRewarded[_season].add(__weiReward);

                    // season => account
                    _accountVokenReferrals[__referee] = _accountVokenReferrals[__referee].add(__voken);
                    _vokenSeasonAccountReferrals[_season][__referee] = _vokenSeasonAccountReferrals[_season][__referee].add(__voken);
                    _weiSeasonAccountReferrals[_season][__referee] = _weiSeasonAccountReferrals[_season][__referee].add(__wei);
                    _weiSeasonAccountRewarded[_season][__referee] = _weiSeasonAccountRewarded[_season][__referee].add(__weiReward);
                }
            }
        }

        /**
         * @dev Mint Voken issued.
         */
        function _mintVokenIssued(uint256 amount) private {
            // Global
            _vokenIssued = _vokenIssued.add(amount);
            _vokenIssuedTxs = _vokenIssuedTxs.add(1);

            // Account
            _accountVokenIssued[msg.sender] = _accountVokenIssued[msg.sender].add(amount);

            // Stage
            _stageVokenIssued[_stage] = _stageVokenIssued[_stage].add(amount);

            // Season
            _seasonVokenIssued[_season] = _seasonVokenIssued[_season].add(amount);
            _vokenSeasonAccountIssued[_season][msg.sender] = _vokenSeasonAccountIssued[_season][msg.sender].add(amount);

            // Mint
            assert(_VOKEN.mint(msg.sender, amount));
        }

        /**
         * @dev Mint Voken bonus.
         */
        function _mintVokenBonus(uint256 amount) private {
            // Global
            _vokenBonus = _vokenBonus.add(amount);
            _vokenBonusTxs = _vokenBonusTxs.add(1);

            // Account
            _accountVokenBonus[msg.sender] = _accountVokenBonus[msg.sender].add(amount);

            // Stage
            _stageVokenBonus[_stage] = _stageVokenBonus[_stage].add(amount);

            // Season
            _seasonVokenBonus[_season] = _seasonVokenBonus[_season].add(amount);
            _vokenSeasonAccountBonus[_season][msg.sender] = _vokenSeasonAccountBonus[_season][msg.sender].add(amount);

            // Mint with allocation
            Allocations.Allocation memory __allocation;
            __allocation.amount = amount;
            __allocation.timestamp = now;
            _allocations[msg.sender].push(__allocation);
            assert(_VOKEN.mintWithAllocation(msg.sender, amount, address(this)));
        }

        /**
         * @dev Returns the reserved amount of VOKEN by `account`.
         */
        function reservedOf(address account) public view returns (uint256) {
            Allocations.Allocation[] memory __allocations = _allocations[account];

            uint256 __len = __allocations.length;
            if (__len > 0) {
                uint256 __vokenIssued = _accountVokenIssued[account];
                uint256 __vokenBonus = _accountVokenBonus[account];
                uint256 __vokenReferral = _accountVokenReferral[account];
                uint256 __vokenBalance = _VOKEN.balanceOf(account);

                // balance fixed, by Voken issued.
                if (__vokenIssued < __vokenBalance) {
                    __vokenBalance = __vokenBalance.sub(__vokenIssued);
                }
                else {
                    __vokenBalance = 0;
                }

                // balance fixed, by Voken bonus.
                if (__vokenBonus < __vokenBalance) {
                    __vokenBalance = __vokenBalance.sub(__vokenBonus);
                }
                else {
                    __vokenBalance = 0;
                }

                uint256 __reserved;
                for (uint256 i = 0; i < __len; i++) {
                    // Voken reserved.
                    Allocations.Allocation memory __allocation = __allocations[i];
                    __reserved = __reserved.add(__allocation.amount);
                    if (now >= __allocation.timestamp.add(90 days)) {
                        // default: 180 days.
                        uint256 __distance = 180 days;

                        // shorten the distance, by Voken referral, at least 120 days.
                        if (__vokenReferral > __allocation.amount) {
                            __distance = __distance.sub(__vokenReferral.div(__allocation.amount).mul(1 days));
                            if (__distance > 120 days) {
                                __distance = 120 days;
                            }
                        }

                        // shorten the distance, by Voken holding
                        if (__vokenBalance > __allocation.amount) {
                            __distance = __distance.sub(__vokenBalance.div(__allocation.amount).mul(30 days));
                        }

                        // at least: 90 days
                        if (__distance > 90 days) {
                            __distance = 90 days;
                        }

                        // calc reserved
                        uint256 __timestamp = __allocation.timestamp.add(__distance);
                        if (now > __timestamp) {
                            uint256 __passed = now.sub(__timestamp).div(1 days).add(1);

                            if (__passed > 30) {
                                __reserved = __reserved.sub(__allocation.amount);
                            }
                            else {
                                __reserved = __reserved.sub(__allocation.amount.mul(__passed).div(30));
                            }
                        }
                    }
                }

                return __reserved;
            }

            return 0;
        }
    }
