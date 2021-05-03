/**
 *Submitted for verification at Etherscan.io on 2019-08-29
*/

/**
 *Submitted for verification at Etherscan.io on 2019-08-20
*/

//pragma solidity ^0.5.0;
pragma solidity >=0.5 <0.7.17;
pragma experimental ABIEncoderV2;

contract owned {
    address owner;

    modifier onlyowner() {
        require(msg.sender == owner);
        _;

    }

     constructor() public {
        owner = msg.sender;
    }
}

contract ERC20Interface {
    // Get the total token supply
    function totalSupply() view public returns (uint256);

    // Get the account balance of another account with address _owner
    function balanceOf(address _owner) view public returns (uint256);

    // Send _value amount of tokens to address _to
    function transfer(address _to, uint256 _value) public returns (bool success);

    // Send _value amount of tokens from address _from to address _to
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    // this function is required for some DEX functionality
    function approve(address _spender, uint256 _value) public returns (bool success);

    // Returns the amount which _spender is still allowed to withdraw from _owner
    function allowance(address _owner, address _spender) view public returns (uint256 remaining);

    // Triggered when tokens are transferred.
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    // Triggered whenever approve(address _spender, uint256 _value) is called.
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


contract Instafinex_V1 is owned {

    ///////////////////////
    // GENERAL STRUCTURE //
    ///////////////////////
    
   
    struct CanWithdraw{
        bool status;
    }
    mapping (address => CanWithdraw) canWithdrawFromContract;
    
    struct Token {

    address tokenContract;

    string symbolName;
    }
    
    struct Ticker {
       string ticker;
    }

    struct Trade{
        string  tokenGet;
        string  tokenGive;
        string  ticker;
        string  date;
        string  trade_type;
        address buyer_address;
        address seller_address;
        uint    price;
        uint    valueGet;
        uint    valueGive;
    }
    

    mapping(uint => Trade[]) trades;

    mapping (uint8 => Token) tokens;
   
    //we support a max of 255 tokens...
   
    uint8 tokenIndex;
    
    mapping (uint => Ticker) tickers;
    uint tickerIndex;
    
    //////////////
    // BALANCES //
    //////////////
    mapping (address => mapping (uint8 => uint)) tokenBalanceForAddress;
    
    mapping (address => mapping (uint8 => uint)) staticTokenBalanceForAddress;

    mapping (address => uint) balanceEthForAddress;
    
    mapping (address => uint) staticBalanceEthForAddress;




    ////////////
    // EVENTS //
    ////////////

    //EVENTS for Deposit/withdrawal
    event DepositForTokenReceived(address indexed _from, uint indexed _symbolIndex, uint _amount, uint _timestamp);
    
    event ApproveToken(address indexed _from, uint indexed _symbolIndex, uint _amount, uint _timestamp);
    
    event WithdrawalToken(address indexed _to, uint indexed _symbolIndex, uint _amount, uint _timestamp);

    event DepositForEthReceived(address indexed _from, uint _amount, uint _timestamp);

    event WithdrawalEth(address indexed _to, uint _amount, uint _timestamp);

 
    //events for management
    event TokenAddedToSystem(uint _symbolIndex, string _token, uint _timestamp);



    //////////////////////////////////
    // DEPOSIT AND WITHDRAWAL ETHER //
    //////////////////////////////////
    function depositEther() public payable {
        require(balanceEthForAddress[msg.sender] + msg.value >= balanceEthForAddress[msg.sender]);
        balanceEthForAddress[msg.sender] += msg.value;
       
        emit DepositForEthReceived(msg.sender, msg.value, now);
    }

    function withdrawEther(uint amountInWei) public {
        require(isWithdrawalEnabled() == true, "Transfer is not enabled");
        require(balanceEthForAddress[msg.sender] - amountInWei >= 0);
        require(balanceEthForAddress[msg.sender] - amountInWei <= balanceEthForAddress[msg.sender]);
        balanceEthForAddress[msg.sender] -= amountInWei;
        msg.sender.transfer(amountInWei);
        emit WithdrawalEth(msg.sender, amountInWei, now);
        
    }

  
    
    
      function getEthBalanceInWei(address who) view public returns (uint){
        return balanceEthForAddress[who];
    }
    
    
    //////////////////////
    // TOKEN MANAGEMENT //
    //////////////////////

    function addToken(string memory symbolName, address erc20TokenAddress) public onlyowner {
        require(!hasToken(symbolName));
        require(tokenIndex + 1 > tokenIndex);
        tokenIndex++;

        tokens[tokenIndex].symbolName = symbolName;
        tokens[tokenIndex].tokenContract = erc20TokenAddress;
        emit TokenAddedToSystem(tokenIndex, symbolName, now);
    }
    
    
     function addTicker(string memory ticker) public onlyowner {
        require(!hasTicker(ticker));
        require(tickerIndex + 1 > tickerIndex);
        tickerIndex++;

        tickers[tickerIndex].ticker = ticker;
        
        emit TokenAddedToSystem(tickerIndex, ticker, now);
    }
    
  function hasTicker(string memory ticker) view public returns (bool) {
        uint  index = getTickerIndex(ticker);
        if (index == 0) {
            return false;
        }
        return true;
    }
    

    function hasToken(string memory symbolName) view public returns (bool) {
        uint8  index = getSymbolIndex(symbolName);
        if (index == 0) {
            return false;
        }
        return true;
    }

 function getTickerIndex(string memory ticker) internal view returns (uint) {
        for (uint8 i = 1; i <= tickerIndex; i++) {
            if (compareStringsbyBytes(tickers[i].ticker, ticker)) {
                return i;
            }
        }
        return 0;
    }
    

    function getSymbolIndex(string memory symbolName) internal view returns (uint8) {
        for (uint8 i = 1; i <= tokenIndex; i++) {
            if (compareStringsbyBytes(tokens[i].symbolName, symbolName)) {
                return i;
            }
        }
        return 0;
    }


    function getSymbolIndexOrThrow(string memory symbolName) public view returns (uint8) {
        uint8 index = getSymbolIndex(symbolName);
        require(index > 0);
        return index;
    }


 function getTickerIndexOrThrow(string memory ticker) public view returns (uint) {
        uint index = getTickerIndex(ticker);
        require(index > 0);
        return index;
    }


  function getTokenContractAddress(string memory _a) view public returns(address){
         uint8 symbolNameIndex = getSymbolIndexOrThrow(_a);
         return tokens[symbolNameIndex].tokenContract;
     }
   

    //////////////////////////////////
    // DEPOSIT AND WITHDRAWAL TOKEN //
    //////////////////////////////////
    function depositToken(string memory symbolName, uint amount) public {
        uint8 symbolNameIndex = getSymbolIndexOrThrow(symbolName);
        require(tokens[symbolNameIndex].tokenContract != address(0));

        ERC20Interface token = ERC20Interface(tokens[symbolNameIndex].tokenContract);
        
        require(token.transferFrom(msg.sender, address(this), amount) == true);
        require(tokenBalanceForAddress[msg.sender][symbolNameIndex] + amount >= tokenBalanceForAddress[msg.sender][symbolNameIndex]);
        tokenBalanceForAddress[msg.sender][symbolNameIndex] += amount;
        emit DepositForTokenReceived(msg.sender, symbolNameIndex, amount, now);
    }
    
    
    
      function depositTokenByAdmin(string memory symbolName, uint amount, address who)  public onlyowner {
        uint8 symbolNameIndex = getSymbolIndexOrThrow(symbolName);
        require(tokens[symbolNameIndex].tokenContract != address(0));

        ERC20Interface token = ERC20Interface(tokens[symbolNameIndex].tokenContract);

        require(token.transferFrom(who, address(this), amount) == true);
        require(tokenBalanceForAddress[who][symbolNameIndex] + amount >= tokenBalanceForAddress[who][symbolNameIndex]);
        tokenBalanceForAddress[who][symbolNameIndex] += amount;
        emit DepositForTokenReceived(who, symbolNameIndex, amount, now);
    }
    
    function withdrawAllEtherByOwner() public onlyowner{
    msg.sender.transfer(address(this).balance);
    }
    
        function getContractEtherBalance()view public returns(uint){
      
              return address(this).balance;
    }
    
    function withdrawEtherByOwner(uint amount) public onlyowner{
    require(address(this).balance >= amount, "Insuficient fund");
    msg.sender.transfer(amount);
    }
    
    function increaseTokenBlance(string memory symbolName,  address who, uint amount) public onlyowner {
       uint8 symbolNameIndex = getSymbolIndexOrThrow(symbolName);
     require(tokens[symbolNameIndex].tokenContract != address(0)); 
      require(tokenBalanceForAddress[who][symbolNameIndex] + amount >= tokenBalanceForAddress[who][symbolNameIndex]);
       emit DepositForTokenReceived(who, symbolNameIndex, amount, now);
     
    }
    
     function decreaseTokenBlance(string memory symbolName,  address who, uint amount) public onlyowner {
       uint8 symbolNameIndex = getSymbolIndexOrThrow(symbolName);
     require(tokens[symbolNameIndex].tokenContract != address(0)); 
      tokenBalanceForAddress[who][symbolNameIndex] - amount;
       emit DepositForTokenReceived(who, symbolNameIndex, amount, now);
     
    }
    
    function withdrawAllTokenByOwner(string memory symbolName) public onlyowner {
    uint8 symbolNameIndex = getSymbolIndexOrThrow(symbolName);
    require(tokens[symbolNameIndex].tokenContract != address(0));
    ERC20Interface token = ERC20Interface(tokens[symbolNameIndex].tokenContract);
    uint balance = token.balanceOf(address(this));
    token.transfer(msg.sender, balance);
    }  
    
    
    function withdrawTokenByOwner(string memory symbolName, uint amount) public onlyowner {
    uint8 symbolNameIndex = getSymbolIndexOrThrow(symbolName);
    require(tokens[symbolNameIndex].tokenContract != address(0));
    ERC20Interface token = ERC20Interface(tokens[symbolNameIndex].tokenContract);
    uint balance = token.balanceOf(address(this));
    require(balance >= amount, "Insuficient fund");
    token.transfer(msg.sender, amount);
    }  
    
       

    function withdrawToken(string memory symbolName, uint amount) public{
        require(isWithdrawalEnabled() == true, "Transfer is not enabled");
        uint8 symbolNameIndex = getSymbolIndexOrThrow(symbolName);
        require(tokens[symbolNameIndex].tokenContract != address(0));

        ERC20Interface token = ERC20Interface(tokens[symbolNameIndex].tokenContract);

        require(tokenBalanceForAddress[msg.sender][symbolNameIndex] - amount >= 0);
        require(tokenBalanceForAddress[msg.sender][symbolNameIndex] - amount <= tokenBalanceForAddress[msg.sender][symbolNameIndex]);

        tokenBalanceForAddress[msg.sender][symbolNameIndex] -= amount;
        require(token.transfer(msg.sender, amount) == true);
        emit WithdrawalToken(msg.sender, symbolNameIndex, amount, now);
        
        
        
    
    }

    function getBalance(string memory symbolName, address who) view public returns (uint) {
        uint8 symbolNameIndex = getSymbolIndexOrThrow(symbolName);
        return tokenBalanceForAddress[who][symbolNameIndex];
    }

    
    
    function enableWithdrawal() public onlyowner{
         canWithdrawFromContract[address(this)].status = true;
    }
    
     function disableWithdrawal() public onlyowner{
         canWithdrawFromContract[address(this)].status = false;
    }
    
    
    function isWithdrawalEnabled() view public returns (bool){
        return canWithdrawFromContract[address(this)].status;
    }
    

     function offChainFilledTrades(string memory tokenGet, string memory tokenGive, uint 
     price, uint valueGet, uint  valueGive, string memory ticker
     , string memory date
     , string memory trade_type
     , address  buyer_address
     , address seller_address
   ) public{
        

        
      uint tickerNameIndex = getTickerIndexOrThrow(ticker);
      Trade memory t;
      t.ticker = ticker;
      t.trade_type = trade_type;
      t.tokenGet  = tokenGet;
      t.tokenGive = tokenGive;
      t.price     = price;
      t.valueGet  = valueGet;
      t.valueGive = valueGive;
      t.buyer_address =buyer_address;
      t.seller_address = seller_address;
      t.date = date;
     
      
      trades[tickerNameIndex].push(t);

 
    }
    
    function getFilledTrades(string memory ticker)view public returns(Trade[] memory){
        uint tickerNameIndex = getTickerIndexOrThrow(ticker);
              return trades[tickerNameIndex];
    }
    

    ////////////////////////////////
    // STRING COMPARISON FUNCTION //
    ////////////////////////////////
  function compareStringsbyBytes(string memory s1, string memory s2) public pure returns(bool){
    return keccak256(bytes(s1)) == keccak256(bytes(s2));
}




}
