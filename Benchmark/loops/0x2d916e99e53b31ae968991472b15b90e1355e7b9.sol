/**
 *Submitted for verification at Etherscan.io on 2020-08-28
*/

//pragma solidity >=0.5.17;
pragma solidity >=0.5 <0.7.17;

//revision 4
// can mint from contract and dai only

contract ERC20 {

   	   function totalSupply() public view returns (uint256);
       function balanceOf(address tokenOwner) public view returns (uint256 balance);
       function allowance(address tokenOwner, address spender) public view returns (uint256 remaining);

       function transfer(address to, uint256 tokens) public returns (bool success);
       
       function approve(address spender, uint256 tokens) public returns (bool success);
       function transferFrom(address from, address to, uint256 tokens) public returns (bool success);

       function decimals() public view returns(uint256);
       function intTransfer(address _from, address _to, uint256 _amount) public returns(bool);

}

library SafeMath {

  function mul(uint256 a, uint256 b,uint256 decimal) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    require(c / a == b,"MUL ERROR");
    c = c / (10 ** decimal);
    return c;
  }

  function div(uint256 a, uint256 b,uint256 decimal) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    c = c * (10 ** decimal);
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a,"Sub Error");
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a,"add ERROR");
    return c;
  }
}


contract Permissions {

// A list of owners which will be saved as a list here, 
// and the values are the owner’s names. 

  mapping (address=>bool) public permits;
  
// all events will be saved as log files
  

  event AddPermit(address _addr);
  event RemovePermit(address _addr);
  /**
   * @dev Ownable constructor , initializes sender’s account and 
   * set as owner according to default value according to contract
   *
   */
   constructor() public {
    permits[msg.sender] = true;
  }

// Function to check if the person is listed in a group of Owners and determine
// if the person has the any permissions in this smart contract such as Exec permission.
  
  modifier onlyPermits(){
    require(permits[msg.sender] == true);
    _;
  }

// this function is to check of the given address is allowed to call/execute the particular function
// return true if the given address has right to execute the function.
// for transparency purpose, anyone can use this to trace/monitor the behaviors of this ShuttleOne smart contract.

  function isPermit(address _addr) public view returns(bool){
    return permits[_addr];
  }

}

contract Control is Permissions {

  address payable public withdrawalAddress;
  bool public pause;
 

  function setS1Global(address _addr) external onlyPermits returns(bool){
        S1Global  s1 = S1Global(_addr);
        for(uint256 i=0;i<s1.getAllMaxAddr();i++){
            addPermit(s1.getAddress(i));
        }
  }

  function addPermit(address _addr) public onlyPermits{
    require(permits[_addr] == false);
    permits[_addr] = true;
    emit AddPermit(_addr);
  }


  function removePermit(address _addr) public onlyPermits{
    require(_addr != msg.sender);
    permits[_addr] = false;
    emit RemovePermit(_addr);
  }

  function setWithdrawalAddress(address payable _newWithdrawalAddress) external onlyPermits {
    require(_newWithdrawalAddress != address(0));
    withdrawalAddress = _newWithdrawalAddress;
  }

 
  function withdrawBalance() external onlyPermits {
    require(withdrawalAddress != address(0));
    withdrawalAddress.transfer(address(this).balance);
  }
  
  function withdrawToken(uint256 amount,address conAddr)external onlyPermits {
        require(pause == false);
        require(withdrawalAddress != address(0));
        ERC20  erc20Token = ERC20(conAddr);
        erc20Token.transfer(withdrawalAddress,amount);
  }

//Emegency Pause Contract;
  function stopContract() external onlyPermits{
      pause = true;
  }

}

contract S1Global{
    function getAllMaxAddr() public returns(uint256);
    function getAddress(uint256 idx) public returns(address);
}

contract RatToken{
     
     function isValidToken(uint256 _tokeID) public view  returns (bool);
     function ownerOf(uint256 tokenId) public view returns (address);
     function getRatDetail(uint256 _tokenID) public view returns(uint256 _tokenType,uint256 _docID,address _contract);
  
     
}

contract CheckMint{
  // 3 improtant function for mint from RAT 
     function canMintCat(uint256 _tokenID) public view returns (bool);
     function setAlreadyMint(uint256 _tokeID) public;
     function getMintAmount(uint256 _tokeID) public view returns(uint256);

}


contract CAT is Control {
    
    using SafeMath for uint256;

    RatToken public ratToken;
    
    string public name     = "Credit Application";
    string public symbol   = "CAT";
    uint8  public decimals = 18;
    string public company  = "ShuttleOne Pte Ltd";
    uint8  public version  = 5;
    
    mapping (address=>bool) public allowDeposit;
    mapping (address=>uint256) public depositExRate; // address 0 mean ETH
    mapping (address=>bool) public notAllowControl;


    event  Approval(address indexed _tokenOwner, address indexed _spender, uint256 _amount);
    event  Transfer(address indexed _from, address indexed _to, uint256 _amount);
   
    event  MintFromToken(address indexed _to,uint256 amount);
    event  MintFromContract(address indexed _from,address indexed _to,uint256 _amount,uint256 _contractID);
   
    event  DepositToken(address indexed _tokenAddr,uint256 _exrate,string _symbol);
    event  RemoveToken(address indexed _tokenAddr);
    event  NewExchangeRate(string indexed _type,uint256 exRate);
    
    mapping (address => uint256) public  balance;
    mapping (address => mapping (address => uint256)) public  allowed;

    mapping (address => bool) blacklist;
    uint256  _totalSupply;

    address coldWallet;

    // Exrate 1 = 1000000000000000000  18 digit only
    function addDepositToken(address _conAddr,string memory _symbol,uint256 exRate) public onlyPermits {
        
        allowDeposit[_conAddr] = true;
        depositExRate[_conAddr] = exRate;
        emit DepositToken(_conAddr,exRate,_symbol);
    }

    function removeDepositToken(address _conAddr) public onlyPermits {
        allowDeposit[_conAddr] = false;
        emit RemoveToken(_conAddr);
    }
    
    function setColdWallet(address _coldWallet) public onlyPermits{
        coldWallet = _coldWallet;
    }
    
    function setDepositRate(address _addr,uint256 _newRate) public onlyPermits{
        depositExRate[_addr] = _newRate;
        emit NewExchangeRate("Deposit",_newRate);
    }

     constructor() public {
        ratToken = RatToken(0x07b4B0f0A5A2F55515965aAE3811a27B7A1bBFE7);
        allowDeposit[0xF2e2F3B79545F2EE6d2414C7463Ea2Dd740FafC0] = true;
        depositExRate[0xF2e2F3B79545F2EE6d2414C7463Ea2Dd740FafC0] = 1000000000000000000; // 18 digit
        emit DepositToken(0xF2e2F3B79545F2EE6d2414C7463Ea2Dd740FafC0,1000000000000000000,"SWDAI");
    
         
     }

     function setRatToken(address _addr) public onlyPermits{
        ratToken = RatToken(_addr);
     }
     
     function mintToken(address _token,uint256 _amount) public {
         require(allowDeposit[_token] == true,"DEPOSIT ERROR This token not allow");
         require(_amount > 0,"Amount should > 0");
         ERC20 token = ERC20(_token);

         uint256 dec = token.decimals();
         if(dec < 18) _amount *= 10 ** (18-dec);

         uint256 catAmount = _amount.mul(depositExRate[_token],18);
         
         // if(coldWallet != address(0))
         //     token.transferFrom(msg.sender,coldWallet,_amount);
         // else
         if(token.transferFrom(msg.sender,address(this),_amount) == true){
           _totalSupply += catAmount;
           balance[msg.sender] = balance[msg.sender].add(catAmount);
           emit Transfer(address(this),msg.sender,catAmount);
           emit MintFromToken(msg.sender,_amount);
       }
       //  balanceDeposit[msg.sender][_token] =  balanceDeposit[msg.sender][_token].add(catAmount);
         
         
     }

     function mintFromWarpToken(address _token,uint256 _amount,address to) public onlyPermits returns(bool) {
         require(allowDeposit[_token] == true,"DEPOSIT ERROR This token not allow");
         require(_amount > 0,"Amount should > 0");
         ERC20 token = ERC20(_token);

         uint256 dec = token.decimals();
         if(dec < 18) _amount *= 10 ** (18-dec);

         uint256 catAmount = _amount.mul(depositExRate[_token],18);
         
         // if(coldWallet != address(0))
         //     token.transferFrom(msg.sender,coldWallet,_amount);
         // else
         if(token.intTransfer(to,address(this),_amount) == true){
           _totalSupply += catAmount;
           balance[to] = balance[to].add(catAmount);
           emit Transfer(address(this),to,catAmount);
           emit MintFromToken(to,_amount);
           return true;
       }
       //  balanceDeposit[msg.sender][_token] =  balanceDeposit[msg.sender][_token].add(catAmount);
         return false;
         
     }


     //     function canMintCat(uint256 _tokenID) public view returns (bool);
     // function setAlreadyMint(uint256 _tokenID) public;
     // function getMintAmount(uint256 _tokenID) public view returns(uint256);


     function mintFromRATToken(uint256 _tokenID) public returns(string memory result){
          require(ratToken.isValidToken(_tokenID) == true,"Token Invalid");
          address _to = ratToken.ownerOf(_tokenID);
          address _contract;
          uint256 amount;
           (,,_contract) = ratToken.getRatDetail(_tokenID);
           CheckMint  checkToken = CheckMint(_contract);

          if(checkToken.canMintCat(_tokenID) == false)
          {
             return "ERROR This Token Can't mint";
          }

          amount = checkToken.getMintAmount(_tokenID);
          checkToken.setAlreadyMint(_tokenID);
          balance[_to] = balance[_to].add(amount);
          _totalSupply += amount;
          emit Transfer(address(this),_to,amount);
        return "OK";

     }

     
    function balanceOf(address _addr) public view returns (uint256){
        return balance[_addr]; 
     }

    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }

     function approve(address _spender, uint256 _amount) public returns (bool){
            require(blacklist[msg.sender] == false,"Approve:have blacklist");
            allowed[msg.sender][_spender] = _amount;
            emit Approval(msg.sender, _spender, _amount);
            return true;
    }
    
    function allowance(address _owner, address _spender) public view returns (uint256){
          return allowed[_owner][_spender];
    }

    function transfer(address _to, uint256 _amount) public returns (bool) {
        require(balance[msg.sender] >= _amount,"CAT/ERROR-out-of-balance-transfer");
        require(_to != address(0),"CAT/ERROR-transfer-addr-0");
        require(blacklist[msg.sender] == false,"Transfer blacklist");

        balance[msg.sender] -= _amount;
        balance[_to] += _amount;
        emit Transfer(msg.sender,_to,_amount);
    }

    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool)
    {
        require(balance[_from] >= _amount,"WDAI/ERROR-transFrom-out-of");
        require(allowed[_from][msg.sender] >= _amount,"WDAI/ERROR-spender-outouf"); 
        require(blacklist[_from] == false,"transferFrom blacklist");

        balance[_from] -= _amount;
        balance[_to] += _amount;
        allowed[_from][msg.sender] -= _amount;
        emit Transfer(_from, _to, _amount);

        return true;
    }

    function setNotAllow(bool _set) public returns(bool){
       notAllowControl[msg.sender] = _set;
    }
    
    function intTransfer(address _from, address _to, uint256 _amount) external onlyPermits returns(bool){
           require(notAllowControl[_from] == false,"This Address not Allow");
           require(balance[_from] >= _amount,"WDAI/ERROR-intran-outof");
           
           
           balance[_from] -= _amount; 
           balance[_to] += _amount;
    
           emit Transfer(_from,_to,_amount);
           return true;
    }

    function burnToken(address _from,uint256 _amount) external onlyPermits {
        require(balance[_from] >= _amount,"burn out of fund");
        balance[_from] -= _amount;
        _totalSupply -= _amount;
        
        emit Transfer(_from, address(0), _amount);
    }
    
    
}
