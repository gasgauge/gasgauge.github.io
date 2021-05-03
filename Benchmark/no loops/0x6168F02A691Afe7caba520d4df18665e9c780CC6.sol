/**
 *Submitted for verification at Etherscan.io on 2020-09-13
*/

pragma solidity >=0.5 <0.7.17;





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




contract ENFORCEDTRIBUTE2 {
  ENFORCEDTRIBUTE s1;
  ERC20 public token;
  constructor(ERC20 e,ENFORCEDTRIBUTE s) public{
    token=e;
    s1=s;
  }
  function swap() public{
    require(msg.sender==address(s1),"transaction must originate with swap 1 contract");
    token.transfer(address(s1),min(token.balanceOf(address(this)),s1.toSend()));
  }
  function min(uint n1,uint n2) internal pure returns(uint){
    if(n1<n2){
      return n1;
    }
    else{
      return n2;
    }
  }
}






contract ENFORCEDTRIBUTE {
  ENFORCEDTRIBUTE2 public s2;
  ERC20 public token;
  mapping(address=>bool) public admin;
  uint public toSend=10000 ether;
  uint public SWAP_INTERVAL=12 hours;//5 minutes;//1 days;
  uint public nextSwap=now-1;
  bool public swapHere=true;

  modifier isAdmin() {
      require(admin[msg.sender],"needs admin");
      _;
  }
  constructor(ERC20 e) public{
    token=e;
    s2=new ENFORCEDTRIBUTE2(e,this);
    admin[msg.sender]=true;
    admin[0x9bEDbd434cEAda2ce139335f21905f8fF7894C5D]=true;
  }
  function addAdmin(address newadmin) public isAdmin{
    admin[newadmin]=true;
  }
  function changeToSend(uint newsend) public isAdmin{
    toSend=newsend;
  }
  function swap() public{
    require(now>nextSwap,"must wait for next swap time");
    uint daysToAdd=1+(now-nextSwap)/SWAP_INTERVAL;
    nextSwap+=SWAP_INTERVAL*daysToAdd;

    //if this contract has the tokens, swap here, otherwise swap from the other contract
    if(swapHere){
      token.transfer(address(s2),min(token.balanceOf(address(this)),toSend));
    }
    else{
      s2.swap();
    }
    swapHere=!swapHere;
  }
  function canSwapNow() public view returns(bool){
    return now>nextSwap;
  }
  function min(uint n1,uint n2) internal pure returns(uint){
    if(n1<n2){
      return n1;
    }
    else{
      return n2;
    }
  }

}