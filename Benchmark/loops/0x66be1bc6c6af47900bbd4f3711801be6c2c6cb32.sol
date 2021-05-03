/**
 *Submitted for verification at Etherscan.io on 2020-09-19
*/

//pragma solidity 0.5.16;
pragma solidity >=0.5 <0.7.17;

contract ThreeFMutual {
    using SafeMath for *;

    //*********
    // STRUCTS
    //*********
    struct Player {
        uint256 id;             // agent id
        bytes32 name;           // agent name
        uint256 ref;            // referral vault
        bool isAgent;           // referral activated
        bool claimed;           // insurance claimed
        uint256 eth;            // eth player has paid
        uint256 shares;         // shares
        uint256 units;          // uints of insurance
        uint256 plyrLastSeen;   // last day player played
        uint256 mask;           // player mask
        uint256 level;          // agent level
        uint256 accumulatedRef; // accumulated referral income
    }


    //***************
    // EXTERNAL DATA
    //***************

    VAT vat = VAT(0x35D1b3F3D7966A1DFe207aa4514C12a259A0492B);
    Underwriter underwriter = Underwriter(0xE58cDe3CbEeCC8d9306f482729084B909Afa2357);
    Agency agency = Agency(0x7Bc360ebD65eFa503FF189A0F81f61f85D310Ec3);
    
    address payable constant private hakka = address(0x83D0D842e6DB3B020f384a2af11bD14787BEC8E7);
    address payable constant private IIP = address(0x9933AD4D38702cdC28C5DB2F421F1F02CF530780);
    uint256 public end;
    bool public ended;


    //******************
    // GLOBAL VARIABLES
    //******************
    mapping(address => mapping(uint256 => uint256)) public unitToExpirePlayer;
    mapping(uint256 => uint256) public unitToExpire; // unit of insurance due at day x

    uint256 public issuedInsurance; // all issued insurance
    uint256 public ethOfShare;      // virtual eth pointer
    uint256 public shares;          // total share
    uint256 public pool;            // eth gonna pay to beneficiary
    uint256 public today;           // today's date
    uint256 public _now;            // current time
    uint256 public mask;            // global mask
    uint256 public agents;          // number of agent

    // player data
    mapping(address => Player) public player;       // player data
    mapping(uint256 => address) public agentxID_;   // return agent address by id
    mapping(bytes32 => address) public agentxName_; // return agent address by name

    // constant parameters
    uint256 constant maxInsurePeriod = 100;
    uint256 constant maxLevel = 10;

    // rate of buying x day insurance
    uint256[101] public rate =
    [0,
    1000000000000000000,
    1990000000000000000,
    2970100000000000000,
    3940399000000000000,
    4900995010000000000,
    5851985059900000000,
    6793465209301000000,
    7725530557207990000,
    8648275251635910100,
    9561792499119550999,
    10466174574128355489,
    11361512828387071934,
    12247897700103201215,
    13125418723102169203,
    13994164535871147511,
    14854222890512436036,
    15705680661607311676,
    16548623854991238559,
    17383137616441326173,
    18209306240276912911,
    19027213177874143782,
    19836941046095402344,
    20638571635634448321,
    21432185919278103838,
    22217864060085322800,
    22995685419484469572,
    23765728565289624876,
    24528071279636728627,
    25282790566840361341,
    26029962661171957728,
    26769663034560238151,
    27501966404214635769,
    28226946740172489411,
    28944677272770764517,
    29655230500043056872,
    30358678195042626303,
    31055091413092200040,
    31744540498961278040,
    32427095093971665260,
    33102824143031948607,
    33771795901601629121,
    34434077942585612830,
    35089737163159756702,
    35738839791528159135,
    36381451393612877544,
    37017636879676748769,
    37647460510879981281,
    38270985905771181468,
    38888276046713469653,
    39499393286246334956,
    40104399353383871606,
    40703355359850032890,
    41296321806251532561,
    41883358588189017235,
    42464525002307127063,
    43039879752284055792,
    43609480954761215234,
    44173386145213603082,
    44731652283761467051,
    45284335760923852380,
    45831492403314613856,
    46373177479281467717,
    46909445704488653040,
    47440351247443766510,
    47965947734969328845,
    48486288257619635557,
    49001425375043439201,
    49511411121293004809,
    50016297010080074761,
    50516134039979274013,
    51010972699579481273,
    51500862972583686460,
    51985854342857849595,
    52465995799429271099,
    52941335841434978388,
    53411922483020628604,
    53877803258190422318,
    54339025225608518095,
    54795634973352432914,
    55247678623618908585,
    55695201837382719499,
    56138249819008892304,
    56576867320818803381,
    57011098647610615347,
    57440987661134509194,
    57866577784523164102,
    58287912006677932461,
    58705032886611153136,
    59117982557745041605,
    59526802732167591189,
    59931534704845915277,
    60332219357797456124,
    60728897164219481563,
    61121608192577286747,
    61510392110651513880,
    61895288189544998741,
    62276335307649548754,
    62653571954573053266,
    63027036235027322733,
    63396765872677049506];

    // threshold of agent upgrade
    uint256[10] public requirement =
    [0,
    73890560989306501,
    200855369231876674,
    545981500331442382,
    1484131591025766010,
    4034287934927351160,
    10966331584284585813,
    29809579870417282259,
    81030839275753838749,
    220264657948067161559];


    //******************
    // EVENT
    //******************
    event UPGRADE (address indexed agent, uint256 indexed level);
    event BUYINSURANCE(address indexed buyer, uint256 indexed start, uint256 unit,  uint256 date);


    //******************
    // MODIFIER
    //******************
    modifier isHuman() {
        require(msg.sender == tx.origin, "sorry humans only");
        _;
    }

    //******************
    // CORE FUNCTIONS
    //******************

    /**
     * @dev Constructor
     * @notice Initialize the time
     */
    constructor() public {
        _now = now;
        today = _now / 1 days;
    }

    /**
     * @dev Ticker
     * @notice It is called everytime when a player interacts with this contract
     * @return true if MakerDAO has been shut down, false otherwise
     */
    function tick()
        internal
        returns(bool)
    {
        if(!ended) {
            if (_now != now) {
                _now = now;
                uint256 _today = _now / 1 days; // the current day as soon as ticker is called

                //check MakerDAO status
                if(vat.live() == 0) {
                    ended = true;
                    end = now;
                }

                // calculate the outdated issuedInsurance
                while (today < _today) {
                    issuedInsurance = issuedInsurance.sub(unitToExpire[today]);
                    unitToExpire[today] = 0;
                    today += 1;
                }
            }
        }
        
        return ended;
    }

    /**
     * @dev Register
     * @notice Register a name by a human player
     */
    function register(string calldata _nameString)
        external
        payable
        isHuman()
    {
        bytes32 _name = agency.register(_nameString);
        address _agent = msg.sender;
        require(msg.value >= 10000000000000000, "insufficient amount");
        require(agentxName_[_name] == address(0), "name registered");

        if(!player[_agent].isAgent){
            agents += 1;
            player[_agent].isAgent = true;
            player[_agent].id = agents;
            player[_agent].level = 1;
            agentxID_[agents] = _agent;
            emit UPGRADE(_agent,player[_agent].level);
        }
        // set name active for the player
        player[_agent].name = _name;
        agentxName_[_name] = _agent;
        sendContract(hakka, msg.value);

    }

    /**
     * @dev Upgrade
     * @notice Upgrade when a player's referral bonus meet the requirement
     */
    function upgrade()
        external
        isHuman()
    {
        address _agent = msg.sender;
        require(player[_agent].isAgent);
        require(player[_agent].level < maxLevel);

        if(player[_agent].accumulatedRef >= requirement[player[_agent].level]) {
            player[_agent].level = (1).add(player[_agent].level);
            emit UPGRADE(_agent,player[_agent].level);
        }
    }

    //using address for referral
    function buy(address payable _agent, uint256 _date)
        isHuman()
        public
        payable
    {
        // ticker
        if(tick()){
            sendHuman(msg.sender, msg.value);
            return;
        }

        // validate agent
        if(!player[_agent].isAgent){
            _agent = address(0);
        }

        buyCore(msg.sender, msg.value, _date, _agent);
    }

    //using ID for referral
    function buy(uint256 _agentId, uint256 _date)
        isHuman()
        public
        payable
    {
        // ticker
        if(tick()){
            sendHuman(msg.sender, msg.value);
            return;
        }

        //query agent
        address payable _agent = address(uint160(agentxID_[_agentId]));

        buyCore(msg.sender, msg.value, _date, _agent);
    }

    //using name for referral
    function buy(bytes32 _agentName, uint256 _date)
        isHuman()
        public
        payable
    {
        // ticker
        if(tick()){
            sendHuman(msg.sender, msg.value);
            return;
        }

        //query agent
        address payable _agent = address(uint160(agentxName_[_agentName]));

        buyCore(msg.sender, msg.value, _date, _agent);
    }

    // contract wallets, sorry insurance only for human
    function buy()
        public
        payable
    {
        // ticker
        if(tick()) {
            if(msg.sender == tx.origin)
                sendHuman(msg.sender, msg.value);
            else
                sendContract(msg.sender, msg.value);
            return;
        }

        buyCore(msg.sender, msg.value, 0, address(0));
    }

    // fallback
    function () external payable {
        buy();
    }

    /**
     * @dev Core part of buying
     */
    function buyCore(address _buyer, uint256 _eth, uint256 _date, address payable _agent) internal {

        updatePlayerUnit(_buyer);
        
        require(_eth >= 1000000000, "pocket lint: not a valid currency");
        require(_eth <= 10000000000000000000000, "no vitalik, no");

        if(_date > maxInsurePeriod){
            _date = maxInsurePeriod;
        }
        uint256 _rate = rate[_date] + 1000000000000000000;
        uint256 ethToBuyShare = _eth.mul(1000000000000000000) / _rate;
        //-- ethToBuyShare is a virtual amount used to represent the eth player paid for buying shares
        //which is usually different from _eth

        // get value of shares and insurances can be bought
        uint256 _share = underwriter.mintShare(ethOfShare, ethToBuyShare);
        uint256 _unit = (_date == 0)? 0: _share;
        uint256 newDate = today + _date - 1;


        // update global data
        ethOfShare = ethOfShare.add(ethToBuyShare);
        shares = shares.add(_share);
        unitToExpire[newDate] = unitToExpire[newDate].add(_unit);
        issuedInsurance = issuedInsurance.add(_unit);

        // update player data
        player[_buyer].eth = player[_buyer].eth.add(_eth);
        player[_buyer].shares = player[_buyer].shares.add(_share);
        player[_buyer].units = player[_buyer].units.add(_unit);
        unitToExpirePlayer[_buyer][newDate] = unitToExpirePlayer[_buyer][newDate].add(_unit);

        distributeEx(_eth, _agent);
        distributeIn(_buyer, _eth, _share);
        emit BUYINSURANCE(_buyer, today, _unit, _date);
        emit Transfer(address(0), _buyer, _share);
    }

    /**
     * @dev Update player's units of insurance
     */
    function updatePlayerUnit(address _player) internal {
        uint256 _today = player[_player].plyrLastSeen;
        uint256 expiredUnit = 0;
        if(_today != 0){
            while(_today < today){
                expiredUnit = expiredUnit.add(unitToExpirePlayer[_player][_today]);
                unitToExpirePlayer[_player][_today] = 0;
                _today += 1;
            }
            player[_player].units = player[_player].units.sub(expiredUnit);
        }
        player[_player].plyrLastSeen = today;
    }

    /**
     * @dev pay external stakeholder
     */
    function distributeEx(uint256 _eth, address payable _agent) internal {
        // 20% to external
        uint256 ex = _eth / 5 ;

        // 10% to IIP
        uint256 _iip = _eth / 10;

        if(player[_agent].isAgent){
            uint256 refRate = player[_agent].level.add(6);
            uint256 _ref = _eth.mul(refRate) / 100;
            player[_agent].ref = player[_agent].ref.add(_ref);
            player[_agent].accumulatedRef = player[_agent].accumulatedRef.add(_ref);
            ex = ex.sub(_ref);
        }

        sendContract(IIP, _iip);
        sendContract(hakka, ex);
    }

    /**
     * @dev Distribute to internal
     */
    function distributeIn(address _buyer, uint256 _eth, uint256 _shares) internal {
        // 15% to share holder
        uint256 _div = _eth.mul(3) / 20;

        // 55% to insurance pool
        uint256 _pool = _eth.mul(55) / 100;

        // distribute dividend share and collect dust
        uint256 _dust = updateMasks(_buyer, _div, _shares);

        // add eth to pool
        pool = pool.add(_dust).add(_pool);

        
    }

    function updateMasks(address  _player, uint256 _div, uint256 _shares)
        private
        returns(uint256)
    {
        // calculate profit per share & global mask based on this buy: (dust goes to pool)
        uint256 _ppt = _div.mul(1000000000000000000) / shares;
        mask = mask.add(_ppt);

        // calculate player earning from their own buy (only based on the shares
        // they just bought). & update player earnings mask
        uint256 _pearn = (_ppt.mul(_shares)) / 1000000000000000000;
        player[_player].mask = (((mask.mul(_shares)) / 1000000000000000000).sub(_pearn)).add(player[_player].mask);

        // calculate & return dust
        return(_div.sub( _ppt.mul(shares) / 1000000000000000000));
    }

    /**
     * @dev Submit a claim from a beneficiary
     */
    function claim()
        isHuman()
        public
    {
        require(tick(), "not yet"); // MakerDAO shutdown!
        address payable beneficiary = msg.sender;
        require(!player[beneficiary].claimed, "already claimed");
        updatePlayerUnit(beneficiary);
        uint256 amount = pool.mul(player[beneficiary].units) / issuedInsurance;
        player[beneficiary].claimed = true;
        sendHuman(beneficiary, amount);
    }

    /**
     * @dev Withdraw dividends and ref
     */
    function withdraw()
        public
    {
        // get player earnings
        uint256 _eth;
        _eth = withdrawEarnings(msg.sender);

        // pay
        if (_eth > 0) {
            if(msg.sender == tx.origin)
                sendHuman(msg.sender, _eth);
            else
                sendContract(msg.sender, _eth);
        }
    }

    function withdrawEarnings(address _player)
        private
        returns(uint256)
    {
        uint256 _div = calcUnMaskedEarnings(_player); //dividend
        uint256 _ref = player[_player].ref; // referral 
        uint256 _earnings = _div.add(_ref);

        if (_earnings > 0) {
            player[_player].ref = 0;
            player[_player].mask = _div.add(player[_player].mask);
        }

        return(_earnings);
    }

    function calcUnMaskedEarnings(address _player)
        private
        view
        returns(uint256)
    {
        return (mask.mul(player[_player].shares) / 1000000000000000000).sub(player[_player].mask);
    }

    //******************
    // GETTERS
    //******************

    /**
     * @dev Return the price buyer will pay for next 1 individual share.
     * @return Price for next share bought (in wei format)
     */
    function getBuyPrice() external view returns(uint256) {
        return underwriter.burnShare(shares.add(1000000000000000000), 1000000000000000000);
    }

    /**
     * @dev Get the units of insurance of player
     * @return Amount of existing units of insurance
     */
    function getCurrentUnit(address _player)
        external
        view
        returns(uint256)
    {
        uint256 _unit = player[_player].units;
        uint256 _today = player[_player].plyrLastSeen;
        uint256 expiredUnit = 0;
        if(_today != 0) {
            while(_today < today){
                expiredUnit = expiredUnit.add(unitToExpirePlayer[_player][_today]);
                _today += 1;
            }

        }
        return _unit == 0 ? 0 : _unit.sub(expiredUnit);
    }

    /**
     * @dev Get the list of units of insurace going to expire of a player
     * @return List of units of insurance going to expire from a player
     */
    function getExpiringUnitListPlayer(address _player)
        external
        view
        returns(uint256[maxInsurePeriod] memory expiringUnitList)
    {
        for(uint256 i=0; i<maxInsurePeriod; i++) {
            expiringUnitList[i] = unitToExpirePlayer[_player][today+i];
        }
        return expiringUnitList;
    }

    /**
     * @dev Get the list of units of insurace going to expire
     * @return List of units of insurance going to expire
     */
    function getExpiringUnitList()
        external
        view
        returns(uint256[maxInsurePeriod] memory expiringUnitList)
    {
        for(uint256 i=0; i<maxInsurePeriod; i++){
            expiringUnitList[i] = unitToExpire[today+i];
        }
        return expiringUnitList;
    }

    //******************
    // ERC20
    //******************
    string  public constant name     = "Third Floor Mutual";
    string  public constant symbol   = "3FM";
    uint8   public constant decimals = 18;

    function totalSupply() external view returns(uint256) {
        if(ended) return 0;
        return shares;
    }

    function balanceOf(address who) external view returns(uint256) {
        if(ended) return 0;
        return player[who].shares;
    }

    event Transfer(address indexed from, address indexed to, uint256 amount);

    //******************
    // send eth
    //******************

    function sendHuman(address to, uint256 amount) internal returns(bool success) {
        address payable recipient = address(uint160(to));
        (success, ) = recipient.call.value(amount)("");
    }

    function sendContract(address to, uint256 amount) internal returns(bool success) {
        address payable recipient = address(uint160(to));
        (new SafeSend).value(amount)(recipient);
        return true;
    }

}

contract VAT {
    function live() external returns(uint256);
}

contract SafeSend {
    constructor(address payable to) public payable {
        selfdestruct(to);
    }
}

contract Underwriter {
    function mintShare(uint256 _curEth, uint256 _newEth) external pure returns (uint256);
    function burnShare(uint256 _curShares, uint256 _sellShares) external pure returns (uint256);
    function shares(uint256 _eth) public pure returns(uint256);
    function eth(uint256 _shares) public pure returns(uint256);
}


contract Agency {
    function register(string memory _input) public pure returns(bytes32);
}

library SafeMath {

    function mul(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c)
    {
        if (a == 0) return 0;
        c = a * b;
        require(c / a == b);
    }

    function sub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c)
    {
        require(b <= a);
        c = a - b;
    }

    function add(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c)
    {
        c = a + b;
        require(c >= a);
    }

    function sqrt(uint256 x)
        internal
        pure
        returns (uint256 y)
    {
        uint256 z = add(x >> 1, 1);
        y = x;
        while (z < y)
        {
            y = z;
            z = ((add((x / z), z)) / 2);
        }
    }

    function sq(uint256 x)
        internal
        pure
        returns (uint256)
    {
        return (mul(x,x));
    }

    function pwr(uint256 x, uint256 y) internal pure returns(uint256 z) {
        z = 1;
        while(y != 0){
            if(y % 2 == 1)
                z = mul(z,x);
            x = sq(x);
            y = y / 2;
        }
        return z;
    }

}
