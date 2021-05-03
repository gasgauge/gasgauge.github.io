/**
 *Submitted for verification at Etherscan.io on 2020-09-23
*/

//pragma solidity >=0.4.0 <0.5.17;
pragma solidity >=0.5 <0.7.17;

contract ERCInterface {
    function transferFrom(address _from, address _to, uint256 _value) public;
    function balanceOf(address who) view public  returns (uint256);
    function allowance(address owner, address spender) view public returns (uint256);
    function transfer(address to, uint256 value) public returns(bool);
}

contract CryptochromeFirstPresale {
    
    uint256 public PRESALE_CAP = 30000000000000000000000000;
    uint256 public EXCHANGE_RATE = 57828429100000;
    address public owner;   
    address public etherreceiver;   
    uint256 public totalraised=0;
    uint256 public totalvaluedeposited=0;

    uint256 public decimalplaces= 1000000000000000000;
    uint256 public lastentryid=0;
    address public tokenaddress;
    uint256 public startTime=1600852344;
    uint256 public endTime=1601114400;
    

    modifier onlyWhileSale() {
    require(isActive());
     _;
    }

    modifier onlyOwner () {
    require(msg.sender == owner);
    _;
    }
 
    struct Transaction
   {
       address buyer;
       uint256 deposit;
       uint256 tokens;
       uint256 bonus;
       uint256 datetime;
       uint8 status;//status of deposit 0 if value deposited, 1 if token released
       uint256 tokentransferred;          
   }
    event Tokenallocated(address indexed to, uint256 tokens, uint256 bonus, uint256 date,uint256 valuedeposited);
        event Tokentransfered(address indexed to, uint256 tokens, uint256 bonus, uint256 release, uint256 date);

    
    mapping (uint256 => Transaction) public buyerentries;
    mapping (address => uint256) public depositedvalue;
    mapping (address => uint256) public totaltokens;
    mapping (address => uint256) public totalbonus;
    mapping (address => uint256) public totaltokenstransferred;
    mapping (address => uint256) public totalbonustransferred;
    mapping (uint256 => uint8) public uniswapeventrelease;
    mapping (uint256 => uint8) public secondrelease;
    mapping (uint256 => uint8) public thirdrelease;
    mapping (uint256 => uint8) public forthrelease;
 
   constructor(address ownerAddress, address etherreceiveraddr) public {
      owner = ownerAddress;
      lastentryid = 0;
     etherreceiver=etherreceiveraddr;
    
   }
 

   function getBonusValue(uint256 tokens) public view returns (uint256) {
       if (now < (startTime + 24 hours)) {
           return (tokens*10/100);
          
       }
       if (now < (startTime + 2 days)) {
           return (tokens*5/100);
           
       }
       if (now < (startTime + 3 days)) {
           return ((tokens * 250)/10000);
           
       }
   }
   
 
    function isActive() public view returns (bool) {
      return now >= startTime && now < endTime;
    }
 
  
   function getTokenAllowance(address ercowner, address _addressOfToken) public view returns(uint256) {
       ERCInterface token = ERCInterface(_addressOfToken);
       return token.allowance(ercowner,msg.sender);
    }
 
    function allocatetokens() external payable returns(bool,uint256,uint256){
        require(msg.value >= 0.05 ether, "0.05 ether is  min deposite");
                require(msg.value <= 50 ether, "50 ether is  max deposite");

                require(PRESALE_CAP > totalraised, "Presale limit reached");

        require(isActive());
        uint256 tokenscheck=((msg.value/EXCHANGE_RATE)*decimalplaces);
        uint256 bonuscheck=(getBonusValue(tokenscheck));
        if((tokenscheck+bonuscheck)<=(PRESALE_CAP-totalraised))
        {
        lastentryid++;
        buyerentries[lastentryid].buyer=msg.sender;
        buyerentries[lastentryid].deposit=msg.value;
        buyerentries[lastentryid].tokens=tokenscheck;
        buyerentries[lastentryid].bonus=bonuscheck;
        buyerentries[lastentryid].datetime=now;
        buyerentries[lastentryid].status=0;
        depositedvalue[msg.sender]=(depositedvalue[msg.sender] + msg.value);
        totaltokens[msg.sender]=(totaltokens[msg.sender]+ tokenscheck); //Need to verify this logic
        totalbonus[msg.sender]=(totalbonus[msg.sender] + bonuscheck); //Need to verify this logic
        totalraised=(totalraised+ bonuscheck + tokenscheck); //Need to verify this logic
        uniswapeventrelease[lastentryid]=0;
   secondrelease[lastentryid]=0;
   thirdrelease[lastentryid]=0;
    forthrelease[lastentryid]=0;
     buyerentries[lastentryid].tokentransferred=0;
     totalvaluedeposited=(totalvaluedeposited+msg.value);
    emit Tokenallocated(msg.sender, tokenscheck, bonuscheck, now,msg.value);
    
     address(uint160(etherreceiver)).transfer(msg.value);
    return(true,tokenscheck,bonuscheck);
        }
        return(false,0,0);
        
    }
 
 //this transfers 25% tokens and all bonus tokens
    function transfertokensuniswapevent(address ercowner) public onlyOwner{
       ERCInterface token = ERCInterface(tokenaddress);
       for(uint256 i = 1; i <= lastentryid; i++) {
           if(uniswapeventrelease[i]!=1)
           {
           if(buyerentries[i].buyer != address(0) && buyerentries[i].tokens > 0) {
               uint256 uniswapreleasetokens=(buyerentries[i].tokens/4);
               
               uint256 uniswapbonus= buyerentries[i].bonus;
                 if((uniswapreleasetokens+uniswapbonus)<=((buyerentries[i].tokens+buyerentries[i].bonus)-(buyerentries[i].tokentransferred)))
          {
               token.transferFrom(ercowner, buyerentries[i].buyer,(uniswapreleasetokens+uniswapbonus));
                
                              uniswapeventrelease[i]=1;
                           buyerentries[i].status=1;

               totaltokenstransferred[buyerentries[i].buyer]= (totaltokenstransferred[buyerentries[i].buyer]+uniswapreleasetokens);
               totalbonustransferred[buyerentries[i].buyer]=(totalbonustransferred[buyerentries[i].buyer]+uniswapbonus);
                buyerentries[i].tokentransferred=(buyerentries[i].tokentransferred+uniswapreleasetokens+uniswapbonus);
                emit Tokentransfered(buyerentries[i].buyer, uniswapreleasetokens, uniswapbonus, 1, now);
           }
           }
       }
    }
    }
    
    
     //this transfers next 25% tokens

    function transfertokenssecondrelease(address ercowner) public onlyOwner{
       ERCInterface token = ERCInterface(tokenaddress);
       
       for(uint256 i = 1; i <= lastentryid; i++) {
            if(secondrelease[i]!=1)
           {
      if(buyerentries[i].buyer != address(0) && buyerentries[i].tokens > 0) {
          uint256 secondreleasetokens=(buyerentries[i].tokens/4);
            if(secondreleasetokens<=((buyerentries[i].tokens+buyerentries[i].bonus)-(buyerentries[i].tokentransferred)))
          {
          token.transferFrom(ercowner, buyerentries[i].buyer,secondreleasetokens);
                         secondrelease[i]=1;
                           buyerentries[i].status=2;

                         totaltokenstransferred[buyerentries[i].buyer]= (totaltokenstransferred[buyerentries[i].buyer]+secondreleasetokens);
                                   buyerentries[i].tokentransferred=(buyerentries[i].tokentransferred+secondreleasetokens);

                               emit Tokentransfered(buyerentries[i].buyer, secondreleasetokens, 0, 2, now);

           }
      }
       }
           }
    }
    
         //this transfers next 25% tokens

    function transfertokensthirdrelease(address ercowner) public onlyOwner{
       ERCInterface token = ERCInterface(tokenaddress);
       for(uint i = 1; i <= lastentryid; i++) {
            if(thirdrelease[i]!=1)
           {
           
      if(buyerentries[i].buyer != address(0) && buyerentries[i].tokens > 0) {
        uint256 thirdreleasetokens= (buyerentries[i].tokens/4);
         if(thirdreleasetokens<=((buyerentries[i].tokens+buyerentries[i].bonus)-(buyerentries[i].tokentransferred)))
          {
          token.transferFrom(ercowner, buyerentries[i].buyer,thirdreleasetokens);
                      thirdrelease[i]=1;
                           buyerentries[i].status=3;

       totaltokenstransferred[buyerentries[i].buyer]= (totaltokenstransferred[buyerentries[i].buyer]+thirdreleasetokens);
                                          buyerentries[i].tokentransferred=(buyerentries[i].tokentransferred+thirdreleasetokens);

                  emit Tokentransfered(buyerentries[i].buyer,thirdreleasetokens , 0, 3, now);

           }
      }
       }
    }
    }
    
    
    function transfertokensfinalrelease(address ercowner) public onlyOwner{
       ERCInterface token = ERCInterface(tokenaddress);
       for(uint i = 1; i <= lastentryid; i++) {
               if(forthrelease[i]!=1)
           {
           
      if(buyerentries[i].buyer != address(0) && buyerentries[i].tokens > 0) {
          uint256 finaltokens=((buyerentries[i].tokens+buyerentries[i].bonus)-(buyerentries[i].tokentransferred));
          if(finaltokens<=((buyerentries[i].tokens+buyerentries[i].bonus)-(buyerentries[i].tokentransferred)))
          {
          token.transferFrom(ercowner, buyerentries[i].buyer,finaltokens);
               forthrelease[i]=1;
                                          buyerentries[i].status=4;

               totaltokenstransferred[buyerentries[i].buyer]= (totaltokenstransferred[buyerentries[i].buyer]+finaltokens);
               buyerentries[i].tokentransferred=(buyerentries[i].tokentransferred+finaltokens);

                           emit Tokentransfered(buyerentries[i].buyer, finaltokens, 0, 4, now);

           }
      }
           }
       }
    }
    
    
function transferbalance(uint256 amount,address to) public onlyOwner {
        address(uint160(to)).transfer(amount);
    }
    function setExchangeRate(uint256 _rate) public onlyOwner {
        EXCHANGE_RATE=_rate;
    
    }
    
    function setTimeSpan(uint256 _sTime,uint256 _eTime) public onlyOwner {
        startTime=_sTime;
        endTime=_eTime;
    
    }
 
    function setTokenaddress(address _taddress) public onlyOwner {
        tokenaddress=_taddress;
    
    }
    
    function setEthReceriverAddr(address _taddress) public onlyOwner {
        etherreceiver=_taddress;
    
    }
   
    function setPresaleCap(uint256 cap) public onlyOwner {
        PRESALE_CAP=cap;
    }
   
}
