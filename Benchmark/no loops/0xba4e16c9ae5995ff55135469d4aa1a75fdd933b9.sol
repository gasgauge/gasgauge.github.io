/**
 *Submitted for verification at Etherscan.io on 2020-09-16
*/

pragma solidity >=0.5 <0.7.17;

contract yyCRVInterface{
  function getPricePerFullShare() public view returns(uint256);
}

contract yCRVInterface{
  function get_virtual_price() public view returns (uint256);
}

contract yyCRVPrice{
  yyCRVInterface public yycrv_address;
  yCRVInterface public ycrv_address;

  constructor(address yycrv, address ycrv) public{
    yycrv_address = yyCRVInterface(yycrv);
    ycrv_address = yCRVInterface(ycrv);
  }
  function getyyCRVPrice() public view returns(uint256){
    return yycrv_address.getPricePerFullShare();
  }
  function getyCRVPrice() public view returns(uint256){
    return ycrv_address.get_virtual_price();
  }

  function getVirtulPrice() public view returns(uint256){
    return getyyCRVPrice() * getyCRVPrice() /1e18;
  }

}