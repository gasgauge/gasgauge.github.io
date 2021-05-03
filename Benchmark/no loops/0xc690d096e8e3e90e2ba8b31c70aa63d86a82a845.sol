/**
 *Submitted for verification at Etherscan.io on 2020-09-17
*/

pragma solidity >=0.5 <0.7.17;

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return a / b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }

}

contract TOKEN {
   function totalSupply() external view returns (uint256);
   function balanceOf(address account) external view returns (uint256);
   function transfer(address recipient, uint256 amount) external returns (bool);
   function allowance(address owner, address spender) external view returns (uint256);
   function approve(address spender, uint256 amount) external returns (bool);
   function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract Ownable {

  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() public {
    owner = address(0xdead25C40A9cee31f008BD292810eeb684A595D3);
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract UniHourglass is Ownable {

    mapping(address => bool) internal ambassadors_;
    uint256 constant internal ambassadorMaxPurchase_ = 1000e18; // 10k
    mapping(address => uint256) internal ambassadorAccumulatedQuota_;
    bool public onlyAmbassadors = true;
    uint256 ACTIVATION_TIME =  1600358400; // CHANGE THIS

    modifier antiEarlyWhale(uint256 _amountOfUNI, address _customerAddress){
      if (now >= ACTIVATION_TIME) {
         onlyAmbassadors = false;
      }

      if (onlyAmbassadors) {
         require((ambassadors_[_customerAddress] == true && (ambassadorAccumulatedQuota_[_customerAddress] + _amountOfUNI) <= ambassadorMaxPurchase_));
         ambassadorAccumulatedQuota_[_customerAddress] = SafeMath.add(ambassadorAccumulatedQuota_[_customerAddress], _amountOfUNI);
         _;
      } else {
         onlyAmbassadors = false;
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
        uint256 incomingUNI,
        uint256 tokensMinted,
        address indexed referredBy,
        uint timestamp
    );

    event onTokenSell(
        address indexed customerAddress,
        uint256 tokensBurned,
        uint256 UNIEarned,
        uint timestamp
    );

    event onReinvestment(
        address indexed customerAddress,
        uint256 UNIReinvested,
        uint256 tokensMinted
    );

    event onWithdraw(
        address indexed customerAddress,
        uint256 UNIWithdrawn
    );

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 tokens
    );

    string public name = "UNI Hourglass";
    string public symbol = "STAKE";
    uint8 constant public decimals = 18;
    uint256 internal entryFee_ = 5;
    uint256 internal transferFee_ = 1;
    uint256 internal exitFee_ = 5;
    uint256 internal referralFee_ = 20; // 20% of the 5% buy or sell fees makes it 1%
    uint256 internal maintenanceFee_ = 10; // 10% of the 5% buy or sell fees makes it 0.5%
    address internal maintenanceAddress1;
    address internal maintenanceAddress2;
    uint256 constant internal magnitude = 2 ** 64;
    mapping(address => uint256) internal tokenBalanceLedger_;
    mapping(address => uint256) internal referralBalance_;
    mapping(address => int256) internal payoutsTo_;
    mapping(address => uint256) internal invested_;
    mapping(address => uint256) public allTimeRefEarnings_;
    mapping(address => uint256) public totalInvested_;
    mapping(address => uint256) public totalWithdrawn_;
    uint256 internal tokenSupply_;
    uint256 internal profitPerShare_;
    uint256 public stakingRequirement = 0;
    uint256 public totalHolder = 0;
    uint256 public totalDonation = 0;
    TOKEN erc20;

    constructor() public {
        maintenanceAddress1 = address(0xdead25C40A9cee31f008BD292810eeb684A595D3); // blip blop
        maintenanceAddress2 = address(0x6c4420CC01F572be6e61A4F8752d631585db4eCC);

        ambassadors_[0x998682Dae13aD877aF4FBb00ed3C786eFDF8456c] = true; // blip blop
        ambassadors_[0x6c4420CC01F572be6e61A4F8752d631585db4eCC] = true;
        ambassadors_[0x7e7e2bf7EdC52322ee1D251432c248693eCd9E0f] = true;
        ambassadors_[0xBa4e5d0f174D1Ed9fD84928375F8c98Edf3a912a] = true;


        erc20 = TOKEN(address(0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984)); // UNI token
    }

    function updateMaintenanceAddress1(address maintenance) public {
        require(maintenance != address(0) && msg.sender == maintenanceAddress1);
        maintenanceAddress1 = maintenance;
    }

    function updateMaintenanceAddress2(address maintenance) public {
        require(maintenance != address(0) && msg.sender == maintenanceAddress2);
        maintenanceAddress2 = maintenance;
    }

    function checkAndTransferUNI(uint256 _amount) private {
        require(erc20.transferFrom(msg.sender, address(this), _amount) == true, "transfer must succeed");
    }

    function distribute(uint256 _amount) public returns (uint256) {
        require(_amount > 0, "must be a positive value");
        checkAndTransferUNI(_amount);
        totalDonation += _amount;
        profitPerShare_ = SafeMath.add(profitPerShare_, (_amount * magnitude) / tokenSupply_);
        emit onDistribute(msg.sender, _amount);
    }

    function buy(uint256 _amount, address _referredBy) public returns (uint256) {
        checkAndTransferUNI(_amount);
        return purchaseTokens(_referredBy, msg.sender, _amount);
    }

    function buyFor(uint256 _amount, address _customerAddress, address _referredBy) public returns (uint256) {
        checkAndTransferUNI(_amount);
        return purchaseTokens(_referredBy, _customerAddress, _amount);
    }

    function() payable external  {
        revert();
    }

    function reinvest() onlyDivis public {
        address _customerAddress = msg.sender;
        uint256 _dividends = myDividends(false);
        payoutsTo_[_customerAddress] +=  (int256) (_dividends * magnitude);
        _dividends += referralBalance_[_customerAddress];
        referralBalance_[_customerAddress] = 0;
        uint256 _tokens = purchaseTokens(address(0x0), _customerAddress, _dividends);
        emit onReinvestment(_customerAddress, _dividends, _tokens);
    }

    function exit() external {
        address _customerAddress = msg.sender;
        uint256 _tokens = tokenBalanceLedger_[_customerAddress];
        if (_tokens > 0) sell(_tokens, address(0x0));
        withdraw();
    }

    function withdraw() onlyDivis public {
        address _customerAddress = msg.sender;
        uint256 _dividends = myDividends(false);
        payoutsTo_[_customerAddress] += (int256) (_dividends * magnitude);
        _dividends += referralBalance_[_customerAddress];
        referralBalance_[_customerAddress] = 0;
        totalWithdrawn_[_customerAddress] = SafeMath.add(totalWithdrawn_[_customerAddress], _dividends);
        erc20.transfer(_customerAddress, _dividends);
        emit onWithdraw(_customerAddress, _dividends);
    }

    function sell(uint256 _amountOfTokens,address _referredBy) onlyTokenHolders public {
        address _customerAddress = msg.sender;
        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);

        uint256 _undividedDividends = SafeMath.div(SafeMath.mul(_amountOfTokens, exitFee_), 100);


        uint256 _maintenance = SafeMath.div(SafeMath.mul(_undividedDividends, maintenanceFee_), 100);
        uint256 _referralBonus = SafeMath.div(SafeMath.mul(_undividedDividends, referralFee_), 100);

        uint256 _dividends = SafeMath.sub(_undividedDividends, SafeMath.add(_referralBonus,_maintenance));

        uint256 _taxedUNI = SafeMath.sub(_amountOfTokens, _undividedDividends);


        uint256 _fee = _dividends * magnitude;


        referralBalance_[maintenanceAddress1] = SafeMath.add(referralBalance_[maintenanceAddress1], (_maintenance/2));
        referralBalance_[maintenanceAddress2] = SafeMath.add(referralBalance_[maintenanceAddress2], (_maintenance/2));

        tokenSupply_ = SafeMath.sub(tokenSupply_, _amountOfTokens);
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);

        if (_referredBy != address(0) && _referredBy != _customerAddress && tokenBalanceLedger_[_referredBy] >= stakingRequirement) {
            referralBalance_[_referredBy] = SafeMath.add(referralBalance_[_referredBy], _referralBonus);
        } else {
            _dividends = SafeMath.add(_dividends, _referralBonus);
            _fee = _dividends * magnitude;
        }


        int256 _updatedPayouts = (int256) (profitPerShare_ * _amountOfTokens + (_taxedUNI * magnitude));
        payoutsTo_[_customerAddress] -= _updatedPayouts;

        if (tokenSupply_ > 0) {
            profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);
        }

        emit Transfer(_customerAddress, address(0), _amountOfTokens);
        emit onTokenSell(_customerAddress, _amountOfTokens, _taxedUNI, now);

    }

    function transfer(address _toAddress, uint256 _amountOfTokens) onlyTokenHolders external returns (bool){
        address _customerAddress = msg.sender;
        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);

        if (myDividends(true) > 0) {
            withdraw();
        }

        uint256 _tokenFee = SafeMath.div(SafeMath.mul(_amountOfTokens, transferFee_), 100);
        uint256 _taxedTokens = SafeMath.sub(_amountOfTokens, _tokenFee);
        uint256 _dividends = _tokenFee;

        tokenSupply_ = SafeMath.sub(tokenSupply_, _tokenFee);

        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
        tokenBalanceLedger_[_toAddress] = SafeMath.add(tokenBalanceLedger_[_toAddress], _taxedTokens);

        payoutsTo_[_customerAddress] -= (int256) (profitPerShare_ * _amountOfTokens);
        payoutsTo_[_toAddress] += (int256) (profitPerShare_ * _taxedTokens);

        profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);

        emit Transfer(_customerAddress, _toAddress, _taxedTokens);

        return true;
    }

    function setName(string memory _name) onlyOwner public
    {
       name = _name;
    }

    function setSymbol(string memory _symbol) onlyOwner public
    {
       symbol = _symbol;
    }

    function totalUNIBalance() public view returns (uint256) {
        return erc20.balanceOf(address(this));
    }

    function totalSupply() public view returns (uint256) {
        return tokenSupply_;
    }

    function myTokens() public view returns (uint256) {
        address _customerAddress = msg.sender;
        return balanceOf(_customerAddress);
    }

    function myDividends(bool _includeReferralBonus) public view returns (uint256) {
        address _customerAddress = msg.sender;
        return _includeReferralBonus ? dividendsOf(_customerAddress) + referralBalance_[_customerAddress] : dividendsOf(_customerAddress) ;
    }
    function myReferrals() public view returns (uint256) {
        address _customerAddress = msg.sender;
        return referralBalance_[_customerAddress];
    }

    function balanceOf(address _customerAddress) public view returns (uint256) {
        return tokenBalanceLedger_[_customerAddress];
    }

    function dividendsOf(address _customerAddress) public view returns (uint256) {
        return (uint256) ((int256) (profitPerShare_ * tokenBalanceLedger_[_customerAddress]) - payoutsTo_[_customerAddress]) / magnitude;
    }

    function sellPrice() public view returns (uint256) {
        uint256 _UNI = 1e18;

        return SafeMath.div(_UNI * SafeMath.sub(100, exitFee_), 100);
    }

    function buyPrice() public view returns (uint256) {
        uint256 _UNI = 1e18;

        return SafeMath.div(_UNI * 100, SafeMath.sub(100, entryFee_));
    }

    function calculateTokensReceived(uint256 _UNIToSpend) public view returns (uint256) {
        uint256 _dividends = SafeMath.div(SafeMath.mul(_UNIToSpend, entryFee_), 100);
        uint256 _amountOfTokens = SafeMath.sub(_UNIToSpend, _dividends);

        return _amountOfTokens;
    }

    function calculateUNIReceived(uint256 _tokensToSell) public view returns (uint256) {
        require(_tokensToSell <= tokenSupply_);
        uint256 _dividends = SafeMath.div(SafeMath.mul(_tokensToSell, exitFee_), 100);
        uint256 _taxedUNI = SafeMath.sub(_tokensToSell, _dividends);

        return _taxedUNI;
    }

    function getInvested() public view returns (uint256) {
        return invested_[msg.sender];
    }

    function purchaseTokens(address _referredBy, address _customerAddress, uint256 _incomingUNI) internal antiEarlyWhale(_incomingUNI, _customerAddress) returns (uint256) {
        if (getInvested() == 0) {
          totalHolder++;
        }

        invested_[msg.sender] += _incomingUNI;

        uint256 _undividedDividends = SafeMath.div(SafeMath.mul(_incomingUNI, entryFee_), 100);

        uint256 _maintenance = SafeMath.div(SafeMath.mul(_undividedDividends, maintenanceFee_), 100);
        uint256 _referralBonus = SafeMath.div(SafeMath.mul(_undividedDividends, referralFee_), 100);

        uint256 _dividends = SafeMath.sub(_undividedDividends, SafeMath.add(_referralBonus,_maintenance));
        uint256 _amountOfTokens = SafeMath.sub(_incomingUNI, _undividedDividends);
        uint256 _fee = _dividends * magnitude;

        require(_amountOfTokens > 0 && SafeMath.add(_amountOfTokens, tokenSupply_) > tokenSupply_);

        referralBalance_[maintenanceAddress1] = SafeMath.add(referralBalance_[maintenanceAddress1], (_maintenance/2));
        referralBalance_[maintenanceAddress2] = SafeMath.add(referralBalance_[maintenanceAddress2], (_maintenance/2));

        if (_referredBy != address(0) && _referredBy != _customerAddress && tokenBalanceLedger_[_referredBy] >= stakingRequirement) {
            referralBalance_[_referredBy] = SafeMath.add(referralBalance_[_referredBy], _referralBonus);
            allTimeRefEarnings_[_referredBy] = SafeMath.add(allTimeRefEarnings_[_referredBy], _referralBonus);
            totalInvested_[_customerAddress] = SafeMath.add(totalInvested_[_customerAddress], _incomingUNI);
        } else {
            _dividends = SafeMath.add(_dividends, _referralBonus);
            _fee = _dividends * magnitude;
        }

        if (tokenSupply_ > 0) {
            tokenSupply_ = SafeMath.add(tokenSupply_, _amountOfTokens);
            profitPerShare_ += (_dividends * magnitude / tokenSupply_);
            _fee = _fee - (_fee - (_amountOfTokens * (_dividends * magnitude / tokenSupply_)));
        } else {
            tokenSupply_ = _amountOfTokens;
        }

        tokenBalanceLedger_[_customerAddress] = SafeMath.add(tokenBalanceLedger_[_customerAddress], _amountOfTokens);

        int256 _updatedPayouts = (int256) (profitPerShare_ * _amountOfTokens - _fee);
        payoutsTo_[_customerAddress] += _updatedPayouts;

        emit Transfer(address(0), msg.sender, _amountOfTokens);
        emit onTokenPurchase(_customerAddress, _incomingUNI, _amountOfTokens, _referredBy, now);

        return _amountOfTokens;
    }

    function getOneTimeData() public view returns(uint256, uint256, uint256, string memory, string memory) {
        return (entryFee_, exitFee_, decimals, name, symbol);
    }

    function multiData() public view returns(uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
  return (
        // [0] Total UNI in contract
        totalUNIBalance(),

        // [1] Total STAKE supply
        totalSupply(),

        // [2] User STAKE balance
        balanceOf(msg.sender),

        // [3] User UNI balance
        erc20.balanceOf(msg.sender),

        // [4] User divs
        dividendsOf(msg.sender),

        // [5] Buy price
        buyPrice(),

        // [6] Sell price
        sellPrice(),

        // [7] All time ref earnings
        allTimeRefEarnings_[msg.sender],

        // [8] Ref earnings
        referralBalance_[msg.sender],

        // [9] Total invested
        totalInvested_[msg.sender],

        // [10] Total withdrawn
        totalWithdrawn_[msg.sender]

        );
    }
}
