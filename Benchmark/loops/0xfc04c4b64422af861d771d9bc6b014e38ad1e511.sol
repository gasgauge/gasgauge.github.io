/**

 *Submitted for verification at Etherscan.io on 2020-06-28

*/



//pragma solidity >=0.5.0 <0.6.0;
pragma solidity >=0.5 <0.7.17;



contract InternalModule {



    address[] _authAddress;



    address payable public _defaultReciver = address(0x2E5600376D4F07F13Ea69Caf416FB2F7B6659897);



    address payable[] public _contractOwners = [

        address(0xc99D13544297d5baD9e0b0Ca0E94A4E614312F33)

    ];



    constructor() public {

        _contractOwners.push(msg.sender);

    }



    modifier OwnerOnly() {



        bool exist = false;

        for ( uint i = 0; i < _contractOwners.length; i++ ) {

            if ( _contractOwners[i] == msg.sender ) {

                exist = true;

                break;

            }

        }



        require(exist); _;

    }



    modifier DAODefense() {

        uint256 size;

        address payable safeAddr = msg.sender;

        assembly {size := extcodesize(safeAddr)}

        require( size == 0, "DAO_Warning" );

        _;

    }



    modifier APIMethod() {



        bool exist = false;



        for (uint i = 0; i < _authAddress.length; i++) {

            if ( _authAddress[i] == msg.sender ) {

                exist = true;

                break;

            }

        }



        require(exist); _;

    }



    function AuthAddresses() external view returns (address[] memory authAddr) {

        return _authAddress;

    }



    function AddAuthAddress(address _addr) external OwnerOnly {

        _authAddress.push(_addr);

    }



    function DelAuthAddress(address _addr) external OwnerOnly {



        for (uint i = 0; i < _authAddress.length; i++) {

            if (_authAddress[i] == _addr) {

                for (uint j = 0; j < _authAddress.length - 1; j++) {

                    _authAddress[j] = _authAddress[j+1];

                }

                delete _authAddress[_authAddress.length - 1];

                _authAddress.length--;

                return ;

            }

        }



    }











}







//pragma solidity >=0.5.1 <0.7.0;
pragma solidity >=0.5 <0.7.17;



contract KState {



    address private _KDeveloper;

    address internal _KIMPLAddress;



    address[] _KAuthAddress;



    address payable public _KDefaultReciver = address(0x2E5600376D4F07F13Ea69Caf416FB2F7B6659897);



    address payable[] public _KContractOwners = [

        address(0xc99D13544297d5baD9e0b0Ca0E94A4E614312F33)

    ];



    bool public _KContractBroken;

    mapping (address => bool) _KWithdrawabledAddress;



    constructor() public {

        _KDeveloper = msg.sender;

        _KContractOwners.push(msg.sender);

    }



    modifier KWhenBroken() {

        require(_KContractBroken); _;

    }



    modifier KWhenNotBroken() {

        require(!_KContractBroken); _;

    }



    modifier KOwnerOnly() {



        bool exist = false;



        for ( uint i = 0; i < _KContractOwners.length; i++ ) {

            if ( _KContractOwners[i] == msg.sender ) {

                exist = true;

                break;

            }

        }



        require(exist); _;

    }



    function KSetContractBroken(bool broken) external KOwnerOnly {

        _KContractBroken = broken;

    }



    modifier KDAODefense() {

        uint256 size;

        address payable safeAddr = msg.sender;

        assembly {size := extcodesize(safeAddr)}

        require( size == 0, "DAO_Warning" );

        _;

    }



    modifier KAPIMethod() {



        bool exist = false;



        for (uint i = 0; i < _KAuthAddress.length; i++) {

            if ( _KAuthAddress[i] == msg.sender ) {

                exist = true;

                break;

            }

        }



        require(exist); _;

    }



    function KAuthAddresses() external view returns (address[] memory authAddr) {

        return _KAuthAddress;

    }



    function KAddAuthAddress(address _addr) external KOwnerOnly {

        _KAuthAddress.push(_addr);

    }



    modifier KDeveloperOnly {

        require(msg.sender == _KDeveloper); _;

    }



    function KSetImplAddress(address impl) external KDeveloperOnly {

        _KIMPLAddress = impl;

    }



    function KGetImplAddress() external view KDeveloperOnly returns (address) {

        return _KIMPLAddress;

    }



}



contract KDoctor is KState {

    modifier write {_;}

}



contract KContract is KState {



    modifier write {



        if ( _KIMPLAddress != address(0x0) ) {



            (, bytes memory ret) = address(_KIMPLAddress).delegatecall(msg.data);



            assembly {

                return( add(ret, 0x20), mload(ret) )

            }



        } else {

            _;

        }

    }

}







//pragma solidity >=0.4.22 <0.7.0;
pragma solidity >=0.5 <0.7.17;



library UserRelation {



    struct MainDB {



        uint totalAddresses;



        mapping ( address => address ) _recommerMapping;



        mapping ( address => address[] ) _recommerList;



        mapping ( address => uint256 ) _recommerCountMapping;



        mapping ( bytes6 => address ) _shortCodeMapping;



        mapping ( address => bytes6 ) _addressShotCodeMapping;

    }



    function Init(MainDB storage self) internal {



        address rootAddr = address(0xdead);

        bytes6 rootCode = 0x303030303030;





        self._recommerMapping[rootAddr] = address(0xdeaddead);

        self._shortCodeMapping[rootCode] = rootAddr;

        self._addressShotCodeMapping[rootAddr] = rootCode;

    }





    function GetIntroducer( MainDB storage self, address _owner ) internal view returns (address) {

        return self._recommerMapping[_owner];

    }





    function RecommendList( MainDB storage self, address _owner ) internal view returns ( address[] memory list, uint256 len ) {

        return (self._recommerList[_owner], self._recommerList[_owner].length );

    }





    function RegisterShortCode( MainDB storage self, address _owner, bytes6 shortCode ) internal returns (bool) {





        if ( self._shortCodeMapping[shortCode] != address(0x0) ) {

            return false;

        }





        if ( self._addressShotCodeMapping[_owner] != bytes6(0x0) ) {

            return false;

        }





        self._shortCodeMapping[shortCode] = _owner;

        self._addressShotCodeMapping[_owner] = shortCode;



        return true;

    }





    function ShortCodeToAddress( MainDB storage self, bytes6 shortCode ) internal view returns (address) {

        return self._shortCodeMapping[shortCode];

    }





    function AddressToShortCode( MainDB storage self, address addr ) internal view returns (bytes6) {

        return self._addressShotCodeMapping[addr];

    }















    function AddRelation( MainDB storage self, address owner, address recommer ) internal returns (int) {





        if ( recommer == owner )  {

            require(false, "-1");

            return -1;

        }





        require( recommer != owner, "-1" );





        require( self._recommerMapping[owner] == address(0x0), "-2");





        if ( recommer != address(0xdead) ) {

            require( self._recommerMapping[recommer] != address(0x0), "-3");

        }





        self._recommerMapping[owner] = recommer;



        self._recommerList[recommer].push(owner);



        self._recommerCountMapping[recommer] ++;



        self.totalAddresses++;



        return 0;

    }

















    function AddRelationEx( MainDB storage self, address owner, address recommer, bytes6 regShoutCode ) internal returns (int) {



        if ( !RegisterShortCode(self, owner, regShoutCode) ) {

            return -4;

        }



        return AddRelation(self, owner, recommer);

    }





    function TeamMemberTotal( MainDB storage self, address _addr ) internal view returns (uint256) {

        return self._recommerCountMapping[_addr];

    }



}







//pragma solidity >=0.4.22 <0.7.0;
pragma solidity >=0.5 <0.7.17;





library Achievement {



    using UserRelation for UserRelation.MainDB;



    struct MainDB {







        uint latestVersion;





        uint currVersion;





        mapping(uint => mapping(address => uint) ) achievementMapping;





        mapping ( address => uint256 ) _vaildMemberCountMapping;





        mapping ( address => bool ) _vaildMembersMapping;





        mapping ( address => uint256 ) _despositTotalMapping;

    }





    function AppendAchievement( MainDB storage self, UserRelation.MainDB storage userRelation, address owner, uint value )

    internal {



        require(value > 0, "ValueIsZero");



        for (

            address parent = owner;

            parent != address(0x0) && parent != address(0xdead);

            parent = userRelation.GetIntroducer(parent)

        ) {

            self.achievementMapping[self.currVersion][parent] += value;

        }



    }





    function DivestmentAchievement( MainDB storage self, UserRelation.MainDB storage userRelation, address owner, uint value)

    internal {



        for (

            address parent = owner;

            parent != address(0x0) && parent != address(0xdaed);

            parent = userRelation.GetIntroducer(parent)

        ) {

            if ( self.achievementMapping[self.currVersion][parent] < value ) {

                self.achievementMapping[self.currVersion][parent] = 0;

            } else {

                self.achievementMapping[self.currVersion][parent] -= value;

            }

        }

    }



    function AchievementValueOfOwner( MainDB storage self, address owner )

    internal view

    returns (uint) {

        return self.achievementMapping[self.currVersion][owner];

    }





    function AchievementDistribution( MainDB storage self, UserRelation.MainDB storage userRelation, address owner)

    internal view

    returns (



        uint totalSum,



        uint large,



        uint len,



        address[] memory addrs,



        uint[] memory values

    ) {

        totalSum = self.achievementMapping[self.currVersion][owner];





        (addrs, len) = userRelation.RecommendList(owner);



        for ( uint i = 0; i < len; i++ ) {



            values[i] = self.achievementMapping[self.currVersion][addrs[i]];



            if ( self.achievementMapping[self.currVersion][addrs[i]] > large ) {

                large = self.achievementMapping[self.currVersion][addrs[i]];

            }

        }

    }





    function AchievementDynamicValue( MainDB storage self, UserRelation.MainDB storage userRelation, address owner)

    internal view

    returns (

        uint v

    ) {



        uint large;

        uint largeId;

        (address[] memory addrs, uint len) = userRelation.RecommendList(owner);

        uint[] memory values = new uint[](len);



        for ( uint i = 0; i < len; i++ ) {



            values[i] = self.achievementMapping[self.currVersion][addrs[i]];



            if ( self.achievementMapping[self.currVersion][addrs[i]] > large ) {

                large = self.achievementMapping[self.currVersion][addrs[i]];

                largeId = i;

            }

        }



        for ( uint i = 0; i < len; i++ ) {



            if ( i != largeId ) {



                if ( values[i] > 10000 ether ) {



                    v += ((values[i]) / 1 ether) + 90000;



                } else {



                    v += (values[i] / 1 ether) * 10;

                }



            } else {





                v += (values[i] / 1 ether) / 1000;

            }

        }



    }





    function ValidMembersCountOf( MainDB storage self, address _addr ) internal view returns (uint256) {

        return self._vaildMemberCountMapping[_addr];

    }



    function InvestTotalEtherOf( MainDB storage self, address _addr ) internal view returns (uint256) {

        return self._despositTotalMapping[_addr];

    }



    function DirectValidMembersCount( MainDB storage self, UserRelation.MainDB storage userRelation, address _addr ) internal view returns (uint256) {



        uint256 count = 0;

        address[] storage rlist = userRelation._recommerList[_addr];

        for ( uint i = 0; i < rlist.length; i++ ) {

            if ( self._vaildMembersMapping[rlist[i]] ) {

                count ++;

            }

        }



        return count;

    }





    function IsValidMember( MainDB storage self, address _addr ) internal view returns (bool) {

        return self._vaildMembersMapping[_addr];

    }



    function MarkValidAddress( MainDB storage self, UserRelation.MainDB storage userRelation, address _addr, uint256 _evalue ) external {



        if ( self._vaildMembersMapping[_addr] == false ) {







            address parent = userRelation._recommerMapping[_addr];



            for ( uint i = 0; i < 15; i++ ) {



                self._vaildMemberCountMapping[parent] ++;



                parent = userRelation._recommerMapping[parent];



                if ( parent == address(0x0) ) {

                    break;

                }

            }



            self._vaildMembersMapping[_addr] = true;

        }





        self._despositTotalMapping[_addr] += _evalue;

    }

}







//pragma solidity >=0.5.1 <0.6.0;
pragma solidity >=0.5 <0.7.17;







contract Recommend is KContract {



    UserRelation.MainDB _userRelation;

    using UserRelation for UserRelation.MainDB;



    constructor() public {

        _userRelation.Init();

    }



    function GetIntroducer( address _owner ) external view returns (address) {

        return _userRelation.GetIntroducer(_owner);

    }



    function RecommendList( address _owner) external view returns ( address[] memory list, uint256 len ) {

        return _userRelation.RecommendList(_owner);

    }



    function ShortCodeToAddress( bytes6 shortCode ) external view returns (address) {

        return _userRelation.ShortCodeToAddress(shortCode);

    }



    function AddressToShortCode( address _addr ) external view returns (bytes6) {

        return _userRelation.AddressToShortCode(_addr);

    }



    function TeamMemberTotal( address _addr ) external view returns (uint256) {

        return _userRelation.TeamMemberTotal(_addr);

    }



    function RegisterShortCode( bytes6 shortCode ) external write {

        require(_userRelation.RegisterShortCode(msg.sender, shortCode));

    }



    function BindRelation( address _recommer ) external write {

        require( _userRelation.AddRelation(msg.sender, _recommer) >= 0, "-1" );

    }



    function BindRelationEx( address _recommer, bytes6 shortCode ) external write{

        require( _userRelation.AddRelationEx(msg.sender, _recommer, shortCode) >= 0, "-1" );

    }



    function AddressesCount() external view returns (uint) {

        return _userRelation.totalAddresses;

    }

}







//pragma solidity >=0.5.1 <0.6.0;
pragma solidity >=0.5 <0.7.17;









contract RecommendSmallTeam is Recommend {



    Achievement.MainDB _achievementer;

    using Achievement for Achievement.MainDB;





    function API_AppendAchievement( address owner, uint value )

    external write KAPIMethod {

        _achievementer.AppendAchievement( _userRelation, owner, value );

    }





    function API_DivestmentAchievement( address owner, uint value)

    external write KAPIMethod {

        _achievementer.DivestmentAchievement( _userRelation, owner, value );

    }





    function AchievementValueOf( address owner )

    external view

    returns (uint) {

        return _achievementer.AchievementValueOfOwner(owner);

    }





    function AchievementDistributionOf( address owner)

    external view

    returns (



        uint totalSum,



        uint large,



        uint len,



        address[] memory addrs,



        uint[] memory values

    ) {

        return _achievementer.AchievementDistribution(_userRelation, owner );

    }





    function AchievementDynamicValue( address owner)

    external view

    returns ( uint ) {

        return _achievementer.AchievementDynamicValue(_userRelation, owner);

    }





    function ValidMembersCountOf( address _addr ) external view returns (uint256) {

        return _achievementer.ValidMembersCountOf(_addr);

    }



    function InvestTotalEtherOf( address _addr ) external view returns (uint256) {

        return _achievementer.InvestTotalEtherOf(_addr);

    }



    function DirectValidMembersCount( address _addr ) external view returns (uint256) {

        return _achievementer.DirectValidMembersCount(_userRelation, _addr);

    }





    function IsValidMember( address _addr ) external view returns (bool) {

        return _achievementer.IsValidMember(_addr);

    }



    function TotalAddresses() external view returns (uint) {

        return _userRelation.totalAddresses;

    }





    function API_MarkValid( address _addr, uint256 _evalue ) external KAPIMethod {

        return _achievementer.MarkValidAddress(_userRelation, _addr, _evalue);

    }





    function Developer_VersionInfo() external view returns (uint latest, uint curr) {

        return (_achievementer.latestVersion, _achievementer.currVersion);

    }



    function Developer_PushNewDataVersion() external write KDeveloperOnly {

        _achievementer.latestVersion++;

    }



    function Developer_SetDataVersion(uint v) external write KDeveloperOnly {

        _achievementer.currVersion = v;

    }



    function Developer_WriteRelation( address _parent, address[] calldata _children, bytes6[] calldata _shortCode, bool force ) external write KDeveloperOnly {



        for ( uint i = 0; i < _children.length; i++ ) {





            _userRelation._recommerMapping[_children[i]] = _parent;





            _userRelation._shortCodeMapping[_shortCode[i]] = _children[i];

            _userRelation._addressShotCodeMapping[_children[i]] = _shortCode[i];

        }



        if ( force ) {





            for ( uint i = 0; i < _children.length; i++ ) {

                _userRelation._recommerList[_parent].push(_children[i]);

            }





            _userRelation._recommerCountMapping[_parent] += _children.length;



        } else {





            _userRelation._recommerList[_parent] = _children;





            _userRelation._recommerCountMapping[_parent] = _children.length;

        }





        _userRelation.totalAddresses += _children.length;



    }

}







//pragma solidity >=0.5.0 <0.6.0;
pragma solidity >=0.5 <0.7.17;



contract TuringInterface

{

    function CallOnlyOnceInit( address roundAddress ) external;





    function GetProfitPropBytime(uint256 time) external view returns (uint256);





    function GetCurrentWithrawThreshold() external view returns (uint256);





    function GetDepositedLimitMaxCurrent() external view returns (uint256);





    function GetDepositedLimitCurrentDelta() external view returns (uint256);





    function Analysis() external;





    function API_SubDepositedLimitCurrent(uint256 v) external;





    function API_PowerOn() external;

}































//pragma solidity >=0.5.0 <0.6.0;
pragma solidity >=0.5 <0.7.17;



interface CostInterface {





    function CurrentCostProp() external view returns (uint);





    function WithdrawCost(uint value) external view returns (uint);

    function DepositedCost(uint value) external view returns (uint);

}



























//pragma solidity >=0.5.0 <0.6.0;
pragma solidity >=0.5 <0.7.17;



contract ERC20Interface

{

    uint256 public totalSupply;

    string  public name;

    uint8   public decimals;

    string  public symbol;



    function balanceOf(address _owner) public view returns (uint256 balance);

    function transfer(address _to, uint256 _value) public returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);



    function approve(address _spender, uint256 _value) public returns (bool success);

    function allowance(address _owner, address _spender) public view returns (uint256 remaining);



    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);





    function API_MoveToken(address _from, address _to, uint256 _value) external;

}





























//pragma solidity >=0.5.0 <0.6.0;
pragma solidity >=0.5 <0.7.17;



interface LevelSubInterface {





    function LevelOf( address _owner ) external view returns (uint256 lv);





    function CanUpgradeLv( address _rootAddr ) external view returns (int);





    function DoUpgradeLv( ) external returns (uint256);





    function ProfitHandle( address _owner, uint256 _amount ) external view returns ( uint256 len, address[] memory addrs, uint256[] memory profits );



    function PaymentToUpgradeNoder() external payable;



    function ManagerListOfLevel( uint256 lv ) external view returns (address[] memory addrs);

}







//pragma solidity >=0.5.0 <0.6.0;
pragma solidity >=0.5 <0.7.17;



interface LuckAssetsPoolInterface {





    function RewardsAmount() external view returns (uint256);





    function WithdrawRewards() external returns (uint256);



    function InPoolProp() external view returns (uint256);





    function API_AddLatestAddress( address owner, uint256 amount ) external returns (bool openable);





    function NeedPauseGame() external view returns (bool);

    function API_Reboot() external returns (bool);





    function API_GameOver() external returns (bool);

    function API_Clear( address owner ) external;



    event Log_Winner( address owner, uint256 when, uint256 amount);

}





























//pragma solidity >=0.5.0 <0.6.0;
pragma solidity >=0.5 <0.7.17;



interface StatisticsInterface {





    function GetStaticProfitTotalAmount() external view returns (uint256);





    function GetDynamicProfitTotalAmount() external view returns (uint256);



    function API_AddStaticTotalAmount( address player, uint256 value ) external;



    function API_AddDynamicTotalAmount( address player, uint256 value ) external;



    function API_AddWinnerCount() external;

}







//pragma solidity >=0.5.0 <0.6.0;
pragma solidity >=0.5 <0.7.17;



library lib_math {



    function CurrentDayzeroTime() public view returns (uint256) {

        return (now / OneDay()) * OneDay();

    }



    function ConvertTimeToDay(uint256 t) public pure returns (uint256) {

        return (t / OneDay()) * OneDay();

    }



    function OneDay() public pure returns (uint256) {



        return 1 days;

    }



    function OneHours() public pure returns (uint256) {

        return 1 hours;

    }



}







//pragma solidity >=0.5.0 <0.6.0;
pragma solidity >=0.5 <0.7.17;























library DepositedHistory {



    struct DB {



        uint256 currentDepostiTotalAmount;



        mapping (address => DepositedRecord) map;



        mapping (address => EverIn[]) amountInputs;



        mapping (address => Statistics) totalMap;

    }



    struct Statistics {

        bool isExist;

        uint256 totalIn;

        uint256 totalOut;

    }



    struct EverIn {

        uint256 timeOfDayZero;

        uint256 amount;

    }



    struct DepositedRecord {





        uint256 createTime;





        uint256 latestDepositInTime;





        uint256 latestWithdrawTime;





        uint256 depositMaxLimit;





        uint256 currentEther;





        uint256 withdrawableTotal;





        uint256 canWithdrawProfix;





        uint8 profixMultiplier;

    }



    function MaxProfixDelta( DB storage self, address owner) public view returns (uint256) {



        if ( !isExist(self, owner) ) {

            return 0;

        }



        return (self.map[owner].currentEther * self.map[owner].profixMultiplier) - self.map[owner].withdrawableTotal;

    }



    function isExist( DB storage self, address owner ) public view returns (bool) {

        return self.map[owner].createTime != 0;

    }



    function Create( DB storage self, address owner, uint256 value, uint256 maxlimit, uint8 muler ) public returns (bool) {



        uint256 dayz = lib_math.CurrentDayzeroTime();



        if ( self.map[owner].createTime != 0 ) {

            return false;

        }



        self.map[owner] = DepositedRecord(dayz, dayz, dayz, maxlimit, value, 0, 0, muler);

        self.currentDepostiTotalAmount += value;



        if ( !self.totalMap[owner].isExist ) {

            self.totalMap[owner] = Statistics(true, value, 0);

        } else {

            self.totalMap[owner].totalIn += value;

        }



        self.amountInputs[owner].push( EverIn(lib_math.CurrentDayzeroTime(), value) );



        return true;

    }



    function Clear( DB storage self, address owner) internal {

        self.map[owner].createTime = 0;

        self.map[owner].currentEther = 0;

        self.map[owner].latestDepositInTime = 0;

        self.map[owner].latestWithdrawTime = 0;

        self.map[owner].depositMaxLimit = 0;

        self.map[owner].currentEther = 0;

        self.map[owner].withdrawableTotal = 0;

        self.map[owner].canWithdrawProfix = 0;

        self.map[owner].profixMultiplier = 0;

    }



    function AppendEtherValue( DB storage self, address owner, uint256 appendValue ) public returns (bool) {



        if ( self.map[owner].createTime == 0 ) {

            return false;

        }



        self.map[owner].currentEther += appendValue;

        self.map[owner].latestDepositInTime = now;

        self.currentDepostiTotalAmount += appendValue;

        self.totalMap[owner].totalIn += appendValue;



        EverIn storage lr = self.amountInputs[owner][ self.amountInputs[owner].length - 1 ];



        if ( lr.timeOfDayZero == lib_math.CurrentDayzeroTime() ) {

            lr.amount += appendValue;

        } else {

            self.amountInputs[owner].push( EverIn(lib_math.CurrentDayzeroTime(), lr.amount + appendValue) );

        }



        return true;

    }



    function PushWithdrawableTotalRecord( DB storage self, address owner, uint256 profix ) public returns (bool) {



        if ( self.map[owner].createTime == 0 ) {

            return false;

        }





        self.map[owner].canWithdrawProfix = 0;

        self.map[owner].withdrawableTotal += profix;

        self.map[owner].latestWithdrawTime = lib_math.CurrentDayzeroTime();



        self.totalMap[owner].totalOut += profix;



        if ( self.map[owner].withdrawableTotal > self.map[owner].currentEther * self.map[owner].profixMultiplier ) {

            self.map[owner].withdrawableTotal = self.map[owner].currentEther * self.map[owner].profixMultiplier;

        }



        return true;

    }



    function GetNearestTotoalInput( DB storage self, address owner, uint256 timeOfDayZero) public view returns (uint256) {



        EverIn memory lr = self.amountInputs[owner][self.amountInputs[owner].length - 1 ];





        if ( timeOfDayZero >= lr.timeOfDayZero ) {



            return lr.amount;



        } else {





            for ( uint256 i2 = self.amountInputs[owner].length; i2 >= 1; i2--) {



                uint256 i = i2 - 1;



                if ( self.amountInputs[owner][i].timeOfDayZero <= timeOfDayZero ) {

                    return self.amountInputs[owner][i].amount;

                }

            }

        }



        return 0;

    }

}



contract Round is InternalModule {



    bool public isBroken = false;



    TuringInterface public _TuringInc;

    RecommendSmallTeam public _RecommendInc;

    ERC20Interface public _ERC20Inc;

    CostInterface public _CostInc;

    LevelSubInterface public _LevelSubInc;

    StatisticsInterface public _StatisticsInc;

    LuckAssetsPoolInterface public _luckPoolA;

    LuckAssetsPoolInterface public _luckPoolB;



    constructor (



        TuringInterface TuringInc,

        RecommendSmallTeam RecommendInc,

        ERC20Interface ERC20Inc,

        CostInterface CostInc,

        LevelSubInterface LevelSubInc,

        StatisticsInterface StatisticsInc,

        LuckAssetsPoolInterface luckPoolA,

        LuckAssetsPoolInterface luckPoolB



    ) public {



        _TuringInc = TuringInc;

        _RecommendInc = RecommendInc;

        _ERC20Inc = ERC20Inc;

        _CostInc = CostInc;

        _LevelSubInc = LevelSubInc;

        _StatisticsInc = StatisticsInc;

        _luckPoolA = luckPoolA;

        _luckPoolB = luckPoolB;



    }



    uint256 public _depositMinLimit = 1 ether;

    uint256 public _depositMaxLimit = 50 ether;

    uint8   public _profixMultiplier = 3;





    uint256[] public _dynamicProfits = [20, 15, 10, 5, 5, 5, 5, 5, 5, 5, 3, 3, 3, 3, 3];



    DepositedHistory.DB private _depostedHistory;

    using DepositedHistory for DepositedHistory.DB;





    uint256 public _beforBrokenedCostProp;





    mapping( address => bool ) _redressableMapping;



    event Log_ProfixHistory(address indexed owner, uint256 indexed value, uint8 indexed ptype, uint256 time);

    event Log_NewDeposited(address indexed owner, uint256 indexed time, uint256 indexed value);

    event Log_NewWinner(address indexed owner, uint256 indexed time, uint256 indexed baseAmount, uint8 mn);

    event Log_WithdrawProfix(address indexed addr, uint256 indexed time, uint256 indexed value, uint256 rvalue);





    modifier OnlyInBrokened() {

        require( isBroken );

        _;

    }





    modifier OnlyInPlaying() {

        require( !isBroken );

        _;

    }



    modifier PauseDisable() {

        require ( !_luckPoolA.NeedPauseGame() );

        _;

    }



    modifier DAODefense() {

        uint256 size;

        address payable safeAddr = msg.sender;

        assembly {size := extcodesize(safeAddr)}

        require( size == 0, "DAO_Warning" );

        _;

    }



    function GetEvenInRecord(address owner, uint256 index) external view returns ( uint256 time, uint256 total, uint256 len ) {



        return ( _depostedHistory.amountInputs[owner][index].timeOfDayZero, _depostedHistory.amountInputs[owner][index].amount, _depostedHistory.amountInputs[owner].length );

    }



    function Join() external payable OnlyInPlaying PauseDisable DAODefense {



        _TuringInc.Analysis();





        require( _RecommendInc.GetIntroducer(msg.sender) != address(0x0), "E01" );





        require( _TuringInc.GetDepositedLimitCurrentDelta() >= msg.value );

        _TuringInc.API_SubDepositedLimitCurrent( msg.value );





        require( msg.value >= _depositMinLimit, "E07" );





        uint256 cost = _CostInc.DepositedCost(msg.value);



        _ERC20Inc.transferFrom( msg.sender, address(0xdead), cost );



        if ( _depostedHistory.isExist(msg.sender) ) {



            DepositedHistory.DepositedRecord memory r = _depostedHistory.map[msg.sender];



            require( msg.value <= r.depositMaxLimit - r.currentEther);





            require( now - r.latestDepositInTime >= lib_math.OneDay() * 2 );



            _depostedHistory.AppendEtherValue(msg.sender, msg.value);



        } else {



            require( msg.value <= _depositMaxLimit );



            _depostedHistory.Create(msg.sender, msg.value, _depositMaxLimit, _profixMultiplier);

        }





        emit Log_NewDeposited( msg.sender, now, msg.value);





        if ( address(this).balance > 3000 ether ) {

            _TuringInc.API_PowerOn();

        }





        address payable lpiaddrA = address( uint160( address(_luckPoolA) ) );

        address payable lpiaddrB = address( uint160( address(_luckPoolB) ) );



        lpiaddrA.transfer(msg.value * _luckPoolA.InPoolProp() / 100);

        lpiaddrB.transfer(msg.value * _luckPoolB.InPoolProp() / 100);



        _luckPoolA.API_AddLatestAddress(msg.sender, msg.value);

        _luckPoolB.API_AddLatestAddress(msg.sender, msg.value);





        _RecommendInc.API_MarkValid( msg.sender, msg.value );



        return ;

    }





    function CurrentDepsitedTotalAmount() external view returns (uint256) {

        return _depostedHistory.currentDepostiTotalAmount;

    }



    function CurrentCanWithdrawProfix(address owner) public view returns (uint256 st, uint256 dy) {



        if ( !_depostedHistory.isExist(owner) ) {

            return (0, 0);

        }



        DepositedHistory.DepositedRecord memory r = _depostedHistory.map[owner];



        uint256 deltaDays = (lib_math.CurrentDayzeroTime() - r.latestWithdrawTime) / lib_math.OneDay();



        uint256 staticTotal = 0;



        for (uint256 i = 0; i < deltaDays; i++) {



            uint256 cday = lib_math.CurrentDayzeroTime() - (i * lib_math.OneDay());



            uint256 dp = _TuringInc.GetProfitPropBytime( cday );





            staticTotal = staticTotal + (_depostedHistory.GetNearestTotoalInput(owner, cday) * dp / 1000);

        }



        return (staticTotal, r.canWithdrawProfix);

    }



    function WithdrawProfix() external OnlyInPlaying PauseDisable DAODefense {



        DepositedHistory.DepositedRecord memory r = _depostedHistory.map[msg.sender];





        (uint256 stProfix, uint256 dyProfix) = CurrentCanWithdrawProfix(msg.sender);

        uint256 totalProfix =  stProfix + dyProfix;



        if ( _depostedHistory.MaxProfixDelta(msg.sender) < totalProfix ) {



            totalProfix = _depostedHistory.MaxProfixDelta(msg.sender);



            _StatisticsInc.API_AddWinnerCount();



            _depostedHistory.Clear(msg.sender);



            _depostedHistory.totalMap[msg.sender].totalOut += totalProfix;



            emit Log_NewWinner(msg.sender, now, r.currentEther, r.profixMultiplier);



        } else {

            _depostedHistory.PushWithdrawableTotalRecord(msg.sender, totalProfix);

        }





        uint256 realStProfix = totalProfix * _TuringInc.GetCurrentWithrawThreshold() / 100;

        uint256 cost = _CostInc.WithdrawCost( totalProfix );



        _ERC20Inc.transferFrom(msg.sender, address(0xdead), cost);



        msg.sender.transfer(realStProfix);



        emit Log_ProfixHistory(msg.sender, stProfix * _TuringInc.GetCurrentWithrawThreshold() / 100, 40, now);

        emit Log_WithdrawProfix(msg.sender, now, totalProfix, realStProfix);







        if ( stProfix <= 0 ) {

            return;

        }



        _StatisticsInc.API_AddStaticTotalAmount(msg.sender, stProfix);



        uint256 senderDepositedValue = r.currentEther;

        uint256 dyProfixBaseValue = stProfix;

        address parentAddr = msg.sender;

        for ( uint256 i = 0; i < _dynamicProfits.length; i++ ) {



            parentAddr = _RecommendInc.GetIntroducer(parentAddr);



            if ( parentAddr == address(0x0) ) {



                break;

            }





            uint256 pdmcount = _RecommendInc.DirectValidMembersCount( parentAddr );





            if ( pdmcount >= 6 || _LevelSubInc.LevelOf(parentAddr) > 0 ) {

                pdmcount = _dynamicProfits.length;

            }





            if ( (i + 1) > pdmcount ) {

                continue;

            }





            if ( _depostedHistory.isExist(parentAddr) ) {



                uint256 parentDyProfix = dyProfixBaseValue * _dynamicProfits[i] / 100;



                if ( senderDepositedValue > _depostedHistory.map[parentAddr].currentEther && _depostedHistory.map[parentAddr].currentEther < 30 ether ) {



                    parentDyProfix = parentDyProfix * ( _depostedHistory.map[parentAddr].currentEther * 100 / senderDepositedValue ) / 100;

                }





                emit Log_ProfixHistory(parentAddr, parentDyProfix, uint8(i), now);

                _depostedHistory.map[parentAddr].canWithdrawProfix += parentDyProfix;

                _StatisticsInc.API_AddDynamicTotalAmount(parentAddr, parentDyProfix);

            }

        }





        uint256 len = 0;

        address[] memory addrs;

        uint256[] memory profits;

        (len, addrs, profits) = _LevelSubInc.ProfitHandle( msg.sender, stProfix );

        for ( uint j = 0; j < len; j++ ) {



            if ( addrs[j] == address(0x0) ) {

                continue ;

            }



            if ( len - j < 3 ) {

                emit Log_ProfixHistory(addrs[j], profits[j], uint8( 30 + _LevelSubInc.LevelOf(addrs[j])), now);

            } else {

                emit Log_ProfixHistory(addrs[j], profits[j], uint8( 20 + _LevelSubInc.LevelOf(addrs[j])), now);

            }



            _depostedHistory.map[addrs[j]].canWithdrawProfix += profits[j];

            _StatisticsInc.API_AddDynamicTotalAmount(addrs[j], profits[j]);

        }

    }





    function TotalInOutAmount() external view returns (uint256 inEther, uint256 outEther) {

        return ( _depostedHistory.totalMap[msg.sender].totalIn, _depostedHistory.totalMap[msg.sender].totalOut );

    }





    function GetRedressInfo() external view OnlyInBrokened returns (uint256 total, bool withdrawable) {



        DepositedHistory.Statistics memory r = _depostedHistory.totalMap[msg.sender];



        if ( r.totalOut >= r.totalIn ) {

            return (0, false);

        }



        uint256 subEther = r.totalIn - r.totalOut;



        uint256 redtotal = (subEther * _beforBrokenedCostProp / 1 ether);



        return (redtotal, _redressableMapping[msg.sender]);

    }





    function DrawRedress() external OnlyInBrokened returns (bool) {



        DepositedHistory.Statistics memory r = _depostedHistory.totalMap[msg.sender];





        if ( r.totalOut >= r.totalIn ) {

            return false;

        }



        if ( !_redressableMapping[msg.sender] ) {



            _redressableMapping[msg.sender] = true;





            uint256 subEther = r.totalIn - r.totalOut;



            uint256 redtotal = (subEther * _beforBrokenedCostProp / 1 ether);





            _utopiaInc.API_AppendLockedDepositAmount(msg.sender, redtotal);



            return true;

        }



        return false;

    }



    function GetCurrentGameStatus() external view returns (

        uint256 createTime,

        uint256 latestDepositInTime,

        uint256 latestWithdrawTime,

        uint256 depositMaxLimit,

        uint256 currentEther,

        uint256 withdrawableTotal,

        uint256 canWithdrawProfix,

        uint8 profixMultiplier

    ) {

        createTime = _depostedHistory.map[msg.sender].createTime;

        latestDepositInTime = _depostedHistory.map[msg.sender].latestDepositInTime;

        latestWithdrawTime = _depostedHistory.map[msg.sender].latestWithdrawTime;

        depositMaxLimit = _depostedHistory.map[msg.sender].depositMaxLimit;

        currentEther = _depostedHistory.map[msg.sender].currentEther;

        withdrawableTotal = _depostedHistory.map[msg.sender].withdrawableTotal;

        canWithdrawProfix = _depostedHistory.map[msg.sender].canWithdrawProfix;

        profixMultiplier = _depostedHistory.map[msg.sender].profixMultiplier;

    }





    function Owner_TryResumeRound() external OwnerOnly {



        if ( address(this).balance < 100 ether ) {



            isBroken = true;



            _beforBrokenedCostProp = _CostInc.CurrentCostProp();



            _defaultReciver.transfer( address(this).balance );



            _luckPoolB.API_GameOver();



        } else {



            _luckPoolA.API_Reboot();

        }



    }



    function Redeem() external OnlyInPlaying PauseDisable DAODefense {



        DepositedHistory.Statistics storage tr = _depostedHistory.totalMap[msg.sender];



        DepositedHistory.DepositedRecord storage r = _depostedHistory.map[msg.sender];



        require(now - r.latestDepositInTime >= lib_math.OneDay() * 90 );



        require(tr.totalIn > tr.totalOut);



        uint256 deltaEther = tr.totalIn - tr.totalOut;



        require(address(this).balance >= deltaEther);



        _depostedHistory.Clear(msg.sender);



        tr.totalOut = tr.totalIn;



        msg.sender.transfer(deltaEther);

    }





    function Owner_SetProfixMultiplier(uint8 m) external OwnerOnly {

        _profixMultiplier = m;

    }



    function Owner_SetDepositLimit(uint256 min, uint256 max) external OwnerOnly {

        _depositMinLimit = min;

        _depositMaxLimit = max;

    }









    function Owner_SetDynamicProfits(uint d, uint p) external OwnerOnly {

        _dynamicProfits[d] = p;

    }



    UtopiaInterface _utopiaInc;

    function Owner_SetUtopiaInterface(UtopiaInterface inc) external OwnerOnly {

        _utopiaInc = inc;

    }



    function () payable external {}

}



interface UtopiaInterface {

    function API_AppendLockedDepositAmount(address owner, uint amount) external;

}
