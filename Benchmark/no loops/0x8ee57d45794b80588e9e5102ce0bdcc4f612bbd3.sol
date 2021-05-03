/**
 *Submitted for verification at Etherscan.io on 2020-09-13
*/

pragma solidity >=0.5 <0.7.17;


interface ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes20 data) external;
}
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    require(c / a == b);
    return c;
  }
  function mult(uint256 x, uint256 y) internal pure returns (uint256) {
      if (x == 0) {
          return 0;
      }

      uint256 z = x * y;
      require(z / x == y, "Mult overflow");
      return z;
  }
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }
  function divRound(uint256 x, uint256 y) internal pure returns (uint256) {
      require(y != 0, "Div by zero");
      uint256 r = x / y;
      if (x % y != 0) {
          r = r + 1;
      }

      return r;
  }
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);
    return c;
  }

  function ceil(uint256 a, uint256 m) internal pure returns (uint256) {
    uint256 c = add(a,m);
    uint256 d = sub(c,1);
    return mul(div(d,m),m);
  }
}
interface ERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  function approveAndCall(address spender, uint tokens, bytes calldata data) external returns (bool success);
  function transferFrom(address from, address to, uint256 value) external returns (bool);
  function burn(uint256 amount) external;

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}







contract ConTribute is ApproveAndCallFallBack{

    mapping(address => bool) internal ambassadors_;

    uint256 constant internal ambassadorMaxPurchase_ = 2500e18;

    mapping(address => uint256) internal ambassadorAccumulatedQuota_;

    bool public onlyAmbassadors = true;

    uint256 ACTIVATION_TIME = now+100 days;

    modifier antiEarlyWhale(
        uint256 _amountOfERC20,
        address _customerAddress
    )
    {
        if (now >= ACTIVATION_TIME) {
            onlyAmbassadors = false;
        }

        if (onlyAmbassadors) {

            require((ambassadors_[_customerAddress] == true &&

            (ambassadorAccumulatedQuota_[_customerAddress] + _amountOfERC20) <=
                ambassadorMaxPurchase_));

            ambassadorAccumulatedQuota_[_customerAddress] =
                SafeMath.add(ambassadorAccumulatedQuota_[_customerAddress], _amountOfERC20);

            _;

        } else {
            //if (now < (ACTIVATION_TIME + 60 seconds)) {
            //    require(tx.gasprice <= 0.1 szabo);
            //}

            //not needed because it's already false if it gets to here
            //onlyAmbassadors = false;
            _;
        }
    }

    modifier onlyTokenHolders {
        require(myTokens() > 0);
        _;
    }

    modifier onlyDivis {
        require(myDividends(true) > 0);
        _;
    }

    event onDistribute(
        address indexed customerAddress,
        uint256 price
    );

    event onTokenPurchase(
        address indexed customerAddress,
        uint256 incomingERC20,
        uint256 tokensMinted,
        address indexed referredBy,
        uint timestamp
    );

    event onTokenSell(
        address indexed customerAddress,
        uint256 tokensBurned,
        uint256 ERC20Earned,
        uint timestamp
    );

    event onReinvestment(
        address indexed customerAddress,
        uint256 ERC20Reinvested,
        uint256 tokensMinted
    );

    event onWithdraw(
        address indexed customerAddress,
        uint256 ERC20Withdrawn
    );

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 tokens
    );

    string public name = "conTRIBUTE";

    string public symbol = "CTRBT";

    uint8 constant public decimals = 18;

    uint256 public entryFee_ = 5;// 5%

    uint256 public exitFee_ = 15; // 15%

    uint256 public referralFee_ = 20; // 1% from the 5% fee

    uint256 internal maintenanceFee_ = 0;//10; // 1% of the 10% fee

    address internal maintenanceAddress;

    uint256 constant internal magnitude = 2 ** 64;

    mapping(address => uint256) public tokenBalanceLedger_;

    mapping(address => uint256) public referralBalance_;

    mapping(address => uint256) public totalReferralEarnings_;

    mapping(address => int256) public payoutsTo_;

    mapping(address => uint256) public invested_;

    uint256 internal tokenSupply_;

    uint256 internal profitPerShare_;

    ERC20 erc20;

//testnet token 0x6A401A535a55f2BDAaE34622E4c3046E638c0d6e
//mainnet token 0x6b785a0322126826d8226d77e173d75DAfb84d11
    constructor(address token,address extraAmbassador) public {
        maintenanceAddress = address(0xaEbbd80Fd7dAe979d965A3a5b09bBCD23eB40e5F);
        ambassadors_[extraAmbassador] = true;
        ambassadors_[0xaEbbd80Fd7dAe979d965A3a5b09bBCD23eB40e5F] = true;
        ambassadors_[0xf3850EA23B46fb4182d9cf60c938Da69aC2527d7] = true;
        ambassadors_[0x9bEDbd434cEAda2ce139335f21905f8fF7894C5D] = true;
        ambassadors_[0x1264EB4ad33ceF667C0fe2A84150b6a98fF4caf7] = true;
        erc20 = ERC20(token);
    }

    function activate() public{
      require(ambassadors_[msg.sender]);
      ACTIVATION_TIME = now;
    }
    /*
      allows playing without using approve
    */
    function receiveApproval(address from, uint256 tokens, address token, bytes20 data) public{
      require(msg.sender==address(erc20)); //calling address must be the token itself
      _buy(tokens,from,address(data)); //buy tokens on behalf of the user
    }
    function checkAndTransfer(
        uint256 _amount
    )
        private
    {
        require(
            erc20.transferFrom(
                msg.sender,
                address(this),
                _amount
            ) == true, "transfer must succeed"
        );
    }
    /*
      transfer from custom address, only use with _buy
    */
    function checkAndTransfer2(
        uint256 _amount,
        address _from
    )
        private
    {
        require(
            erc20.transferFrom(
                _from,
                address(this),
                _amount
            ) == true, "transfer must succeed"
        );
    }
    /*
      Private buy function for use by approveandcall, to purchase tokens on behalf of the user when msg.sender is the token
    */
    function _buy(
        uint256 _amount,
        address _sender,
        address _referredBy
    )
        private
        returns(uint256)
    {
        checkAndTransfer2(_amount,_sender);

        return purchaseTokens(
            _referredBy,
            _sender,
            _amount
        );
    }
    function buy(
        uint256 _amount,
        address _referredBy
    )
        public
        returns(uint256)
    {
        checkAndTransfer(_amount);

        return purchaseTokens(
            _referredBy,
            msg.sender,
            _amount
        );
    }

    function buyFor(
        uint256 _amount,
        address _customerAddress,
        address _referredBy
    )
        public
        returns(uint256)
    {
        checkAndTransfer(_amount);
        return purchaseTokens(
            _referredBy,
            _customerAddress,
            _amount
        );
    }


    function reinvest()
        onlyDivis
        public
    {
        address _customerAddress = msg.sender;

        uint256 _dividends = myDividends(false);

        payoutsTo_[_customerAddress] += (int256)(_dividends * magnitude);

        _dividends += referralBalance_[_customerAddress];

        referralBalance_[_customerAddress] = 0;

        uint256 _tokens = purchaseTokens(address(0), _customerAddress, _dividends);

        emit onReinvestment(_customerAddress, _dividends, _tokens);
    }

    function exit() external {

        address _customerAddress = msg.sender;

        uint256 _tokens = tokenBalanceLedger_[_customerAddress];

        if (_tokens > 0) sell(_tokens);

        withdraw();
    }

    function withdraw()
        onlyDivis
        public
    {
        address _customerAddress = msg.sender;

        uint256 _dividends = myDividends(false);

        payoutsTo_[_customerAddress] += (int256)(_dividends * magnitude);

        _dividends += referralBalance_[_customerAddress];

        referralBalance_[_customerAddress] = 0;

        erc20.transfer(_customerAddress, _dividends);

        emit onWithdraw(_customerAddress, _dividends);
    }

    function sell(
        uint256 _amountOfERC20s
    )
        onlyTokenHolders
        public
    {
        address _customerAddress = msg.sender;
        require(_amountOfERC20s <= tokenBalanceLedger_[_customerAddress]);

        uint256 _dividends = SafeMath.div(SafeMath.mul(_amountOfERC20s, exitFee_), 100);
        uint256 _taxedERC20 = SafeMath.sub(_amountOfERC20s, _dividends);

        tokenSupply_ = SafeMath.sub(tokenSupply_, _amountOfERC20s);

        tokenBalanceLedger_[_customerAddress] =
            SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfERC20s);

        int256 _updatedPayouts =
            (int256)(profitPerShare_ * _amountOfERC20s + (_taxedERC20 * magnitude));

        payoutsTo_[_customerAddress] -= _updatedPayouts;

        if (tokenSupply_ > 0) {
            profitPerShare_ = SafeMath.add(
                profitPerShare_, (_dividends * magnitude) / tokenSupply_
            );
        }

        emit Transfer(_customerAddress, address(0), _amountOfERC20s);
        emit onTokenSell(_customerAddress, _amountOfERC20s, _taxedERC20, now);
    }

    function totalERC20Balance()
        public
        view
        returns(uint256)
    {
        return erc20.balanceOf(address(this));
    }

    function totalSupply()
        public
        view
        returns(uint256)
    {
        return tokenSupply_;
    }

    function myTokens()
        public
        view
        returns(uint256)
    {
        address _customerAddress = msg.sender;
        return balanceOf(_customerAddress);
    }

    function myDividends(
        bool _includeReferralBonus
    )
        public
        view
        returns(uint256)
    {
        address _customerAddress = msg.sender;
        return _includeReferralBonus ? dividendsOf(_customerAddress) +
            referralBalance_[_customerAddress] : dividendsOf(_customerAddress);
    }

    function balanceOf(
        address _customerAddress
    )
        public
        view
        returns(uint256)
    {
        return tokenBalanceLedger_[_customerAddress];
    }

    function dividendsOf(
        address _customerAddress
    )
        public
        view
        returns(uint256)
    {
        return (uint256)((int256)(
            profitPerShare_ * tokenBalanceLedger_[_customerAddress]) -
            payoutsTo_[_customerAddress]) / magnitude;
    }

    function sellPrice()
        public
        view
        returns(uint256)
    {
        uint256 _erc20 = 1e18;
        uint256 _dividends = SafeMath.div(SafeMath.mul(_erc20, exitFee_), 100);
        uint256 _taxedERC20 = SafeMath.sub(_erc20, _dividends);

        return _taxedERC20;
    }

    function buyPrice()
        public
        view
        returns(uint256)
    {
        uint256 _erc20 = 1e18;
        uint256 _dividends = SafeMath.div(SafeMath.mul(_erc20, entryFee_), 100);
        uint256 _taxedERC20 = SafeMath.add(_erc20, _dividends);

        return _taxedERC20;
    }

    function getInvested()
        public
        view
        returns(uint256)
    {
        return invested_[msg.sender];
    }

    function totalReferralEarnings(
        address _client
    )
        public
        view
        returns(uint256)
    {
        return totalReferralEarnings_[_client];
    }
    //event DebugTest3(uint256 amount,address sender,address this,uint approved,uint balance);
    function donateTokens(uint256 todonate) public {
      require(tokenSupply_>0,"must be some shares in first to distribute to");
      //transfer tokens
      //emit DebugTest3(todonate,msg.sender,address(this),erc20.allowance(msg.sender,address(this)),erc20.balanceOf(msg.sender));
      checkAndTransfer(todonate);
      profitPerShare_ = SafeMath.add(profitPerShare_, (todonate * magnitude) / tokenSupply_);
    }
    function purchaseTokens(
        address _referredBy,
        address _customerAddress,
        uint256 _incomingERC20
    )
        internal
        antiEarlyWhale(_incomingERC20, _customerAddress)
        returns(uint256)
    {
        invested_[_customerAddress] += _incomingERC20;

        uint256 _undividedDividends =
            SafeMath.div(
                SafeMath.mul(
                    _incomingERC20, entryFee_
                ),
            100);

        uint256 _maintenance =
            SafeMath.div(
                SafeMath.mul(
                    _undividedDividends, maintenanceFee_
                ),
            100);


        uint256 _referralBonus =
            SafeMath.div(
                SafeMath.mul(
                    _undividedDividends, referralFee_
                ),
            100);

        uint256 _dividends =
            SafeMath.sub(
                _undividedDividends, SafeMath.add(
                    _referralBonus, _maintenance
                )
            );

        uint256 _amountOfERC20s =
            SafeMath.sub(_incomingERC20, _undividedDividends);

        uint256 _fee = _dividends * magnitude;

        require(
            _amountOfERC20s > 0 &&
            SafeMath.add(_amountOfERC20s, tokenSupply_) > tokenSupply_
        );

        referralBalance_[maintenanceAddress] =
            SafeMath.add(referralBalance_[maintenanceAddress], _maintenance);

        if (_referredBy != address(0) &&
            _referredBy != _customerAddress)
        {
            referralBalance_[_referredBy] =
                SafeMath.add(referralBalance_[_referredBy], _referralBonus);

            totalReferralEarnings_[_referredBy] =
                SafeMath.add(totalReferralEarnings_[_referredBy], _referralBonus);
        } else {
            _dividends = SafeMath.add(_dividends, _referralBonus);
            _fee = _dividends * magnitude;
        }

        if (tokenSupply_ > 0)
        {
            tokenSupply_ = SafeMath.add(tokenSupply_, _amountOfERC20s);

            profitPerShare_ += ((_dividends * magnitude) / (tokenSupply_));
            _fee = _fee - (_fee - (_amountOfERC20s * ((_dividends * magnitude) / (tokenSupply_))));

        } else {
            tokenSupply_ = _amountOfERC20s;
        }

        tokenBalanceLedger_[_customerAddress] =
            SafeMath.add(tokenBalanceLedger_[_customerAddress], _amountOfERC20s);

        int256 _updatedPayouts = (int256)((profitPerShare_ * _amountOfERC20s) - _fee);

        payoutsTo_[_customerAddress] += _updatedPayouts;

        emit Transfer(
            address(0),
            _customerAddress,
            _amountOfERC20s
        );

        emit onTokenPurchase(
            _customerAddress,
            _incomingERC20,
            _amountOfERC20s,
            _referredBy,
            now
        );

        return _amountOfERC20s;
    }

    function multiData()
    public
    view
    returns(
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256
    )
    {
        return (

        // [0] Total ERC20 in contract
        totalERC20Balance(),

        // [1] Total STAKE TOKEN supply
        totalSupply(),

        // [2] User STAKE TOKEN balance
        balanceOf(msg.sender),

        // [3] User ERC20 balance
        erc20.balanceOf(msg.sender),

        // [4] User divs
        dividendsOf(msg.sender),

        // [5] Buy price
        buyPrice(),

        // [6] Sell price
        sellPrice(),

        // [7] Total referral eranings
        totalReferralEarnings(msg.sender)
        );
    }
}
