/**
 *Submitted for verification at Etherscan.io on 2020-09-23
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
      function deposit(address _from,uint256 amount) public returns (bool);
      function withdrawInternal(address _to,uint256 _amount) public returns(bool);
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

contract ProfitCal{
    function getInterest(address _contract,address _addr) public view returns(uint256);
    function getWithdrawInterest(address _contract,address _addr) public view returns(uint256);
}

// contract RewardPools{
//     function getReward(address _contract,address _wallet,uint256 _amount,uint256 _depositTime) public view returns(uint256);
//     function claimReward(address _contract,address _wallet,uint256 _amount,uint256 _depositTime) public  returns(uint256); // 0 not claim;
// }


contract SpacePodsUSDC is Permissions{
  
    event Deposit(address indexed _from,uint256 amount);
    event Withdraw(address indexed _from,uint256 amount);
    event WithdrawInterest(address indexed _from,uint256 amount);
    event Borrow(address indexed _from,uint256 amount,uint256 interest);
    event SetInterest(uint256 _interest);
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
        uint256 term;   // Add on V8
        uint256 lastDeposit;
        
    }
    
    struct InterestStruct{
        uint256 startTime;
        uint256 interest;
    }


    mapping (address => uint256) public balance;
   

    BorrowContract[] borrows;
    DepositContract[]  deposits;
    InterestStruct[] public interests;

    mapping (address=>uint256[]) contracts;
    mapping (address=>uint256[]) depositIdxs; // all index
    mapping (address=>bool) stopAdminControl; // default false;

    using SafeMath for uint256;
    uint256 public borrowInterest;
    uint256 public totalInterest;
    uint256 public totalClaimInterest;
    // uint256 public supplyInterest;
    uint256 public totalSupply;
    uint256 public totalBorrow;
    uint256 public decimal = 18;
    string public TOKEN_POOLS = "szUSDC";
    uint256 public startPools;
    uint256 public POOL_HARDCAP;

    ERC20  public token;
    ERC20  public catToken;
    ProfitCal public profitCal; // profit calculaate class;
    
  //  RewardPools public reward;


    uint256 oneYear = 365 days;
    uint256 hundred = 100 ether;

    uint256 public version = 9;
    uint256 public minimumTerm; // minimumDeposit Time;    

// support only wrap token and 18 decimal only
    constructor() public{
        
        token = ERC20(0x55b123B169400Da201Dd69814BAe2B8C2660c2Bf); // szUSDC
        catToken = ERC20(0x2D916e99E53b31Ae968991472b15b90e1355E7B9); // CAT MAIN NET

        startPools = now;
        profitCal = ProfitCal(0x1Ef037764BED4c1f8598e57e142FA166eE32d8ad);  

        minimumTerm = 30 days;
        POOL_HARDCAP = 1000000 ether;
        setBorrowInterest(10 ether);
    }
    
    function setPoolHardcap(uint256 amount) public onlyPermits{
      require(amount > totalSupply,"CAN'T SET BELOW TOTALSUPPLY");
      POOL_HARDCAP = amount;
    }
    function getMaxInterestData() public view returns(uint256){
         return interests.length;    
    }
    
    // incase of some one directy transfer dai to this contract
    // normmaly this contract not recieve dai
    function withdrawStupidUser(uint256 amount,address _contract,address _to) public onlyPermits{
      require(_contract != address(token),"Can't Withdraw SZUSDC"); 
      ERC20  stupid = ERC20(_contract);
      stupid.transfer(_to,amount);
    }
  
    function setMinimumDeposit(uint256 _min) public onlyPermits{
        minimumTerm = _min;
    }
  

    function setProfitCal(address _addr) public onlyPermits{
        profitCal = ProfitCal(_addr);
    }
  

    function loanBalance() public view returns(uint256){
        if(totalBorrow > totalSupply) 
            return 0;
        else
        return totalSupply - totalBorrow;
    }

    function setCatToken(address _addr) public onlyPermits{
        catToken = ERC20(_addr);
    }

    function setBorrowInterest(uint256 _newInterst) public onlyPermits{
     
        InterestStruct memory _interest = InterestStruct({
                        startTime:now,
                        interest: _newInterst
                        });
     
        interests.push(_interest);
      
        emit SetInterest(_newInterst);
        borrowInterest = _newInterst;
    }

    function getInterestProfit(address _addr) public view returns(uint256){
        return profitCal.getInterest(address(this),_addr);
    }
  
    function setAdminControl(bool _set) public{
        stopAdminControl[msg.sender] = _set;
    }
  
    function _depositContract(address _from,uint256 amount,uint256 _term) internal{
        require(amount <= POOL_HARDCAP - totalSupply,"THIS POOL NOT ALLOW TO DEPOSIT THIS TIME");
        balance[_from] += amount;
        emit Deposit(_from,amount);
        totalSupply += amount;

        uint256 idxSize = depositIdxs[_from].length;
        uint256 idx;
    
        if(idxSize == 0){
            DepositContract memory dep = DepositContract({
                amount:amount,
                lastDeposit:now,
                term:_term
            });
            idx = deposits.push(dep);
            depositIdxs[_from].push(idx);
        }
        else
        {
            for(uint256 i=0;i<idxSize;i++)
            {
                idx = depositIdxs[_from][i] - 1;
                if(deposits[idx].amount == 0){
                deposits[idx].amount = amount;
                deposits[idx].lastDeposit = now;
                return;
                
            }
        }
        
        // Not found add new again
         DepositContract memory dep = DepositContract({
            amount:amount,
            lastDeposit:now,
            term:_term
        });
        idx = deposits.push(dep);
        depositIdxs[_from].push(idx);
     
        }
     }


    function depositToken(address _from,uint256 amount) public returns (bool){
        return depositTokenTerm(_from,amount,minimumTerm);
    }

    // use can direct deposit USDC and it will auto swap to szUSDC
    function depositTokenTerm(address _from,uint256 amount,uint256 _term) public returns (bool){
        require(msg.sender == _from || 
        (permits[msg.sender] == true && stopAdminControl[_from] == false),"NO Permission to call this function");
        require(_term >= minimumTerm);
      
        // check amount should not have decimal
        uint256 havDecimal;
        havDecimal = amount % (10 ** 6);
        if(havDecimal > 0){
            return false;
        }
      
        if(token.deposit(_from,amount) == false)
            return false;
      
       if(token.intTransfer(_from,address(this),amount * (10 ** 12)) == true){
            _depositContract(_from,amount * (10 ** 12),_term);
            return true;
        }
        
        return false;
     } 
  
    function depositSZToken(address _from,uint256 amount) public returns (bool){
        return depositSZTokenTerm(_from,amount,minimumTerm);
    }
    // user can direct deposit szUSDC
    function depositSZTokenTerm(address _from,uint256 amount,uint256 _term) public returns (bool){
        require(msg.sender == _from || 
        (permits[msg.sender] == true && stopAdminControl[_from] == false),"NO Permission to call function");
        require(_term >= minimumTerm,"TERM ERRIR");
        // check amount should not have decimal
        uint256 havDecimal;
        havDecimal = amount % (10 ** decimal);
        if(havDecimal > 0){
          return false;
        }
            
       if(token.intTransfer(_from,address(this),amount) == true){
            _depositContract(_from,amount,_term);
            return true;
        }
        
            return false;
    } 

    // When witdraw interest will reset to 0
    function _withdraw(address _to,uint256 _amount) internal returns(uint256){
        if(_amount == 0) return 0;
      
        uint256 interest =  profitCal.getWithdrawInterest(address(this),_to);
        uint256 idxSize = depositIdxs[_to].length;
        uint256 idx;
        uint256 principle;
        uint256 tempPrinciple;
      
        for(uint256 i=0;i<idxSize;i++){
            idx = depositIdxs[_to][i] - 1;
            if(deposits[idx].amount > 0)
                deposits[idx].lastDeposit = now;
        }
    
        totalClaimInterest += interest;
 
        if(interest > _amount){
            require(interest <= loanBalance(),"ERROR01 Insuffician Fund to withdraw");
            token.transfer(_to,interest);
            token.transfer(_to,0);
            totalSupply -= interest;
            return interest;
        }
        else
        {
        
            principle = _amount - interest;
            if(principle > balance[_to])
                principle = balance[_to];
        
            require(principle + interest <=loanBalance(),"ERROR02 Insuffician Fund to withdraw");
            tempPrinciple = principle;
        
            for(uint256 i=0;i<idxSize;i++){
                idx = depositIdxs[_to][i] - 1;
            if(tempPrinciple >0)
            {
                if(tempPrinciple >= deposits[idx].amount){
                    tempPrinciple -=deposits[idx].amount;
                    deposits[idx].amount = 0;
                }
                else
                {
                    deposits[idx].amount -= tempPrinciple;
                    tempPrinciple = 0;
                }
            }
            }
                totalSupply -= principle + interest;
                balance[_to] -= principle;
                token.transfer(_to,interest);
                token.transfer(_to,principle);
                 return interest + principle;
        }
    }
  
    function withdrawPercent(address _to,uint256 percent) public returns(uint256){
       require(msg.sender == _to || 
       (permits[msg.sender] == true && stopAdminControl[_to] == false),"No Permission to call");
      
       require(percent >0 && percent <= 100,"Percent Error");
       
       uint256 amount = balance[_to];
       uint256 interest =  profitCal.getInterest(address(this),_to);
       
       amount += interest;
       amount = amount * percent / 100;
       require(loanBalance() >= amount,"Not enouth FUND to withdraw");
       
       return _withdraw(_to,amount);
       
    }

    function withdraw(address _to,uint256 amount) public returns(uint256){
       require(msg.sender == _to || 
       (permits[msg.sender] == true && stopAdminControl[_to] == false),"No Permission to call");
      
       require(loanBalance() >= amount,"Not enouth FUND to withdraw");

       return _withdraw(_to,amount);
    }


// this function will withdraw all interest only
  function withdrawInterest(address _to) public returns(uint256){
      require(msg.sender == _to || 
      (permits[msg.sender] == true && stopAdminControl[_to] == false),"No Permission to call");
      require(depositIdxs[_to].length > 0,"Not deposit");

      
      uint256 amount =  profitCal.getWithdrawInterest(address(this),_to);
      uint256 idxSize = depositIdxs[_to].length;
      uint256 idx;
      
      if(amount == 0) return 0;
      
      for(uint256 i=0;i<idxSize;i++){
          idx = depositIdxs[_to][i] - 1;
          if(deposits[idx].amount > 0)
              deposits[idx].lastDeposit = now;
      }
 
      totalClaimInterest += amount;
      token.transfer(_to,amount);
      return amount;
 
  }
  
  function withdrawAll(address _to) public returns(uint256){
      require(msg.sender == _to || 
      (permits[msg.sender] == true && stopAdminControl[_to] == false),"No Permission to call");
      
      require(depositIdxs[_to].length > 0,"Not deposit");

      uint256 interest =  profitCal.getWithdrawInterest(address(this),_to);
      require(balance[_to] + interest <= loanBalance());
    //  require(totalClaimInterest + interest >= totalInterest);

      return _withdraw(_to,balance[_to] + interest);
  }
  
  function withdrawStable(address _to,uint256 amount) public returns(bool){
       require(msg.sender == _to || 
       (permits[msg.sender] == true && stopAdminControl[_to] == false),"NO Permission to call");
      
       uint256 szGot = withdraw(_to,amount);
       if(szGot > 0){
         token.withdrawInternal(msg.sender,szGot);
         return true;
       }
       return false;
  }

  function withdrawIntStable(address _to) public returns(bool){
      require(msg.sender == _to || 
       (permits[msg.sender] == true && stopAdminControl[_to] == false));
      
      uint256 szGot = withdrawInterest(_to);
      if(szGot > 0){
        token.withdrawInternal(_to,szGot);
        return true;
      }
      return false;
      
  }

  function withdrawAllStable(address _to) public returns(bool){
      require(msg.sender == _to || 
      (permits[msg.sender] == true && stopAdminControl[_to] == false),"NO Permission to call");
      uint256 szGot =  withdrawAll(_to);
    
      if(szGot > 0){
         token.withdrawInternal(_to,szGot);
         return true;
      }
 
      return false;
    }
   function withdrawPercentStable(address _to,uint256 percent) public returns(bool){
       require(msg.sender == _to || 
       (permits[msg.sender] == true && stopAdminControl[_to] == false),"NO Permission to call");
      
       uint256 szGot = withdrawPercent(_to,percent);
      
        if(szGot > 0){
           token.withdrawInternal(_to,szGot);
           return true;
        }
 
        return false;
       
   }

//============ All About contract ==============
  function maxContracBorrow() public view returns(uint256){
    return contracts[msg.sender].length;
  }

  function getContractBorrow() public view returns(uint256[] memory cons){
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
      _data[1] = deposits[idx].lastDeposit;
      _data[2] = deposits[idx].term;
  }
  
  function getMaxDepositContract(address _addr) public view returns(uint256 _max){
      return depositIdxs[_addr].length;
  }
  
  function getAllDepositIdx(address _addr) public view returns(uint256[] memory _idx){

        return depositIdxs[_addr];      
      
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

//   function _shareInterest(uint256 amount) internal returns(uint256){
//     //  uint256 shareInt = amount.div(totalSupply,decimal); // it will be 0 
//       uint256 percent;
//       for(uint256 i=0;i<deposits.length;i++){
//           if(deposits[i].amount > 0){
//             percent = _getSupplyPercent(deposits[i].amount);
            
//             deposits[i].interest +=   (amount * percent) / (10 ** decimal); 
//           }
//       }
//   }
  
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
            // if(decimal < 18)
            //   catReturn = principle * (10 ** (18 - decimal));
            // else
               catReturn = principle;


            catToken.transfer(_addr,catReturn);
          //  _shareInterest(interest);
            borrows[idx].time = now;
            return true;
        }
        else{
       //    if(wrap == true)
            token.intTransfer(_addr,address(this),amount);
    //       else
     //       token.transferFrom(_addr,address(this),amount);
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
         //     _shareInterest(interest);
               borrows[idx].time = now;
              return true;
           }
           else
           {
              borrows[idx].interestPay += amount;
              totalInterest += amount;
          //    _shareInterest(amount);
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
