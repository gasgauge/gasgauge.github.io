/**
 *Submitted for verification at Etherscan.io on 2020-08-28
*/

//pragma solidity ^0.5.17;
pragma solidity >=0.5 <0.7.17;


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

contract ERC20 {

     // function totalSupply() public view returns (uint256);
      function balanceOf(address tokenOwner) public view returns (uint256 balance);
      function allowance(address tokenOwner, address spender) public view returns (uint256 remaining);

      function transfer(address to, uint256 tokens) public returns (bool success);
       
      function approve(address spender, uint256 tokens) public returns (bool success);
      function transferFrom(address from, address to, uint256 tokens) public returns (bool success);
      function decimals() public view returns(uint256);
      function intTransfer(address _from, address _to, uint256 _amount) external returns(bool); // only for shuttleone token
 }

contract Permissions {

  mapping (address=>bool) public permits;
  bool allPermit;

// all events will be saved as log files
  event AddPermit(address _addr);
  event RemovePermit(address _addr);

  constructor() public {
    permits[msg.sender] = true;
    allPermit = false;
  }

  
  modifier onlyPermits(){
    require(permits[msg.sender] == true);
    _;
  }

  function isPermit(address _addr) public view returns(bool){
    return permits[_addr];
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

}



contract ShuttleOneDepositPools is Permissions{
  
  event Deposit(address indexed _from,uint256 amount);
    event Withdraw(address indexed _from,uint256 amount);
    event WithdrawInterest(address indexed _from,uint256 amount);
    event Borrow(address indexed _from,uint256 amount,uint256 interest);
    event Interest(uint256 _old,uint256 _new);
    event Repayment(address indexed,uint256 indexed contractID,uint256 amount);

    struct BorrowContract{
        uint256 amount;
        uint256 repayAmount;
        uint256 interestPay;
        uint256 interest;
        uint256 time;
        uint256 status;  // 1 active 0 close
        uint256 startTime;
    }

    struct DepositContract{
        uint256 amount;
        uint256 interest; //profit
        uint256 startTime;
    }

    mapping (address => uint256) public balance;
    mapping (address => uint256) depositIdx;

    BorrowContract[] borrows;
    DepositContract[]  deposits;

    mapping (address=>uint256[]) contracts;

    using SafeMath for uint256;
    uint256 public borrowInterest;
    uint256 public totalInterest;
    uint256 public totalClaimInterest;
    // uint256 public supplyInterest;
    uint256 public totalSupply;
    uint256 public totalBorrow;
    uint256 public decimal;
    string public TOKEN_POOLS;

    ERC20  public token;
    ERC20  public catToken;

    uint256 oneYear = 365 days;
    uint256 hundred;
    bool  public  wrapPools;

    uint256 public version = 5;

    constructor() public{
        
    wrapPools = true;
    token = ERC20(0xF2e2F3B79545F2EE6d2414C7463Ea2Dd740FafC0); // SWDAI
    catToken = ERC20(0x2D916e99E53b31Ae968991472b15b90e1355E7B9); // CAT
    decimal = token.decimals();
    hundred = 100 * (10 ** decimal);
    borrowInterest = 10 * (10 ** decimal);
    TOKEN_POOLS = "SWDAI";
    //catToken =
  }

  function loanBalance() public view returns(uint256){
    if(totalBorrow > totalSupply) return 0;
    else
      return totalSupply - totalBorrow;
  }

  function setCatToken(address _addr) public onlyPermits{
    catToken = ERC20(_addr);
  }

  function setBorrowInterest(uint256 _newInterst) public onlyPermits{
     emit Interest(borrowInterest,_newInterst);
     borrowInterest = _newInterst;
  }

  function getInterestProfit() public view returns(uint256){
//      require(depositIdx[msg.sender] > 0,"Not have deposit");
      if(depositIdx[msg.sender] == 0)
         return 0;
         
      uint256 idx = depositIdx[msg.sender] - 1;

      return deposits[idx].interest;
  }

  function deposit(address _from,uint256 amount) public returns (bool){
      // check amount should not have decimal
      uint256 havDecimal;
      havDecimal = amount % (10 ** decimal);
      if(havDecimal > 0){
            
          return false;
      }
      
      
       if(token.transferFrom(_from,address(this),amount) == true){
            balance[_from] += amount;
            emit Deposit(_from,amount);
            totalSupply += amount;

            uint256 idx = depositIdx[_from];
            if(idx == 0){
                DepositContract memory dep = DepositContract({
                  amount:amount,
                  interest:0,
                  startTime:now
                });
                idx = deposits.push(dep);
                depositIdx[_from] = idx;
            }
            else
            {
                idx = idx - 1;
                if(balance[_from] == amount){
                    deposits[idx].startTime = now;
                }   
                deposits[idx].amount += amount;
            }


        }
        
        return true;
  } 

// When witdraw interest will reset to 0
  function withdraw(uint256 amount) public returns(bool){
    require(balance[msg.sender] >= amount,"Not enought Token");
    require(loanBalance() >= amount,"Not enouth FUND to withdraw");
    require(amount <= totalSupply,"Not enouth token");

    if(token.transfer(msg.sender,amount) == true){
        balance[msg.sender] -= amount;
        uint256 idx = depositIdx[msg.sender] - 1;
        deposits[idx].amount -= amount;
        emit Withdraw(msg.sender,amount);
        totalSupply -= amount;
    }

    return true;
  }

  function withdrawInterest(uint256 amount) public returns(bool){
      require(depositIdx[msg.sender] > 0,"Not deposit");

      
      uint256 idx = depositIdx[msg.sender] - 1;
      if(deposits[idx].interest < amount){
          amount = deposits[idx].interest;
          deposits[idx].interest = 0;

      }
      else
      {
          deposits[idx].interest -= amount;
      }

      totalClaimInterest += amount;
      token.transfer(msg.sender,amount);
      return true;

  }
  
  function withdrawWithInterest(uint256 amount) public returns(bool){
      require(depositIdx[msg.sender] > 0,"Not deposit");
      require(amount > 0);
      
      uint256 idx = depositIdx[msg.sender] - 1;
      
      uint256 principle;
      uint256 interest;
      
      if(deposits[idx].interest >= amount){
          principle = 0;
          interest = amount;
      }
      else
      {
          principle = amount - deposits[idx].interest;
          interest = deposits[idx].interest;
      }
      if(principle > 0)
          withdraw(principle);
          
      withdrawInterest(interest);
      
      return true;
  }
  
  

//============ All About contract ==============
  function maxContractUser() public view returns(uint256){
    return contracts[msg.sender].length;
  }

  function getContractUser() public view returns(uint256[] memory cons){
    uint256 leng = contracts[msg.sender].length;
    cons = new uint256[](leng);
    cons = contracts[msg.sender];
    
  }
  
  function getMaxDeposit() public view returns(uint256){
      return deposits.length;
  }
  
  function getDepositDataIdx(uint256 idx) public view returns(uint256[] memory _data){
      require(idx >=0 && idx < deposits.length);
      
      _data = new uint256[](3);
      _data[0] = deposits[idx].amount;
      _data[1] = deposits[idx].interest;
      _data[2] = deposits[idx].startTime;
  }
  
   function getDepositData(address addr) public view returns(uint256[] memory _data){
      require(depositIdx[addr] > 0);
      uint256 idx = depositIdx[addr] - 1;
      return getDepositDataIdx(idx);
  }
  
  
  function getMaxBorrowContract() public view returns(uint256){
      return borrows.length;
  }

  function getBorrowData(uint256 condIdx) public view returns(uint256[] memory _data){
      require(condIdx <= borrows.length && condIdx > 0,"Error not have this idx");
      uint256 idx = condIdx - 1;
      _data = new uint256[](7);

      _data[0] = borrows[idx].amount;
      _data[1] = borrows[idx].interest;
      _data[2] = borrows[idx].repayAmount;
      _data[3] = borrows[idx].interestPay;
      _data[4] = borrows[idx].time;
      _data[5] = borrows[idx].status;
      _data[6] = borrows[idx].startTime;

  }

  uint256 public SECPYEAR = 31536000;

  
    function _interest(uint256 _amount,uint256 _intPY,uint256 _time) internal view returns(uint256 fullInt){
      

      fullInt = _intPY / SECPYEAR / 100;
      fullInt = (fullInt * _time); //fullInt.mul(_amount,decimal);
      fullInt = fullInt.mul(_amount,decimal);

  }
  


  function pricipleAndInterest(uint256 conIdx) public view returns(uint256 principle,uint256 _int){
      require(conIdx <= borrows.length && conIdx > 0,"Error not have this idx");
  
      uint256 idx = conIdx - 1;

      if(borrows[idx].status == 0)
      {
         return (0,0);
      }

      if(borrows[idx].repayAmount > borrows[idx].amount)
        principle = 0;
      else
        principle = borrows[idx].amount - borrows[idx].repayAmount; 

      uint256 fullInt = _interest(principle,borrows[idx].interest,now - borrows[idx].time); //_intPerSec(borrows[idx].interest) * (now - borrows[idx].time); 

//      fullInt = fullInt.mul(borrows[idx].amount,decimal);

      if(borrows[idx].interestPay > fullInt)
         _int = 0;
      else
         _int  = fullInt - borrows[idx].interestPay;

  }


  function supplyInterest() public view returns(uint256){
      uint256 supInt;
      uint256 totalSupplyNoDecimal = totalSupply / (10 ** decimal);
      
      if(totalSupplyNoDecimal == 0)
          return 0;
      else
      {
          supInt =  (totalInterest * 100) / totalSupplyNoDecimal;
      
        //supInt =  totalInterest.div(totalSupply,decimal);
        //supInt = supInt.mul(hundred,decimal);
         return supInt;
      }
  }


// amount in CATToken only
  function _borrow(uint256 amount,address _addr) internal returns(uint256 contractID){
      amount  = (amount / (10 ** 18)) * (10 ** 18);
      require(amount <= catToken.balanceOf(_addr),"not enought CAT Token");
      uint256 amountStable = (amount / (10 ** 18)) * (10 ** decimal);
      require(amountStable <= totalSupply - totalBorrow,"Not have fund to borrw");

      BorrowContract memory br = BorrowContract({
          amount : amountStable,
          interest: borrowInterest,
          repayAmount:0,
          interestPay:0,
          time:now,
          status:1,
          startTime:now
        });

      uint256 idx = borrows.push(br);
      contracts[_addr].push(idx);
      catToken.intTransfer(_addr,address(this),amount);
      token.transfer(_addr,amountStable);
      totalBorrow += amountStable;

      emit Borrow(_addr,amountStable,borrowInterest);
      
      return idx;
  }

  function borrow(uint256 amount) public returns(uint256 contractID){
    return _borrow(amount,msg.sender);

  }

  function borrowWithAddr(uint256 amount,address _addr)public onlyPermits returns(uint256 contractID){
    return _borrow(amount,_addr);
  }
  
  function _getSupplyPercent(uint256 amount) internal view returns(uint256){
      uint256 totalSupplyNoDecimal = totalSupply / (10 ** decimal);
      uint256 percent = amount / totalSupplyNoDecimal;
      
      return percent;
  }

  function _shareInterest(uint256 amount) internal returns(uint256){
    //  uint256 shareInt = amount.div(totalSupply,decimal); // it will be 0 
      uint256 percent;
      for(uint256 i=0;i<deposits.length;i++){
          if(deposits[i].amount > 0){
            percent = _getSupplyPercent(deposits[i].amount);
            
            deposits[i].interest +=   (amount * percent) / (10 ** decimal); 
          }
      }
  }
  
  //rePayment address want to approve first for DAI token
  // Then will got CAT back

  function _rePayment(uint256 amount,uint256 conIdx,address _addr,bool wrap) internal returns(bool){
        require(conIdx > 0 && conIdx <= borrows.length);
        uint256 idx = conIdx - 1;
        require(borrows[idx].status == 1);

        uint256 principle;
        uint256 interest;
        uint256 catReturn;
        (principle,interest) = pricipleAndInterest(conIdx);


        if(amount >= principle + interest){
            amount = principle + interest; 
            if(wrap == true)
              token.intTransfer(_addr,address(this),amount);
            else
              token.transferFrom(_addr,address(this),amount);

            emit Repayment(_addr,conIdx,amount);

            borrows[idx].interestPay += interest;
            borrows[idx].repayAmount += principle;
            totalInterest += interest;  
            totalBorrow -= principle;
            if(decimal < 18)
               catReturn = principle * (10 ** (18 - decimal));
            else
               catReturn = principle;


            catToken.transfer(_addr,catReturn);
            _shareInterest(interest);
            borrows[idx].time = now;
            return true;
        }
        else{
           if(wrap == true)
            token.intTransfer(_addr,address(this),amount);
           else
            token.transferFrom(_addr,address(this),amount);
           emit Repayment(_addr,conIdx,amount);

           if(amount > interest){
              principle = amount - interest;
              borrows[idx].interestPay += interest;
              borrows[idx].repayAmount += principle;
              totalInterest += interest;
              totalBorrow -= principle;
              if(decimal < 18)
                catReturn = principle * (10 ** (18 - decimal));
              else
                catReturn = principle;


              catToken.transfer(_addr,catReturn);
              _shareInterest(interest);
               borrows[idx].time = now;
              return true;
           }
           else
           {
              borrows[idx].interestPay += amount;
              totalInterest += amount;
              _shareInterest(amount);
               borrows[idx].time = now;
              return true;
           }
        }

  }
 
  function rePaymentWithWrap(uint256 amount,uint256 conIdx,address _addr) public onlyPermits returns(bool){
      return _rePayment(amount,conIdx,_addr,true);
  }

  function rePayment(uint256 amount,uint256 conIdx) public returns(bool){
      return _rePayment(amount,conIdx,msg.sender,false);
  }

}
