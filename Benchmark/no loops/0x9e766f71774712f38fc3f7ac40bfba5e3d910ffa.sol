/**

 *Submitted for verification at Etherscan.io on 2020-12-20

*/



// SPDX-License-Identifier: MIT



//pragma solidity 0.6.12;
pragma solidity >=0.5 <0.7.17;





interface UNIV2Sync {

    function sync() external;

}



interface Mibaserebase {

    function rebase() external;

}



contract RebaseMiBASE  {

    

    

    

    

     function rebasesync()

        external

        returns (uint256)

     {

        

    UNIV2Sync(0xDAEfbED9D35F505444527746393f015B8C84dF2b).sync();

    Mibaserebase(0xd5c0216B0627134Ed57A53a9Ea430766CE1D9Da5).rebase();

   

        }

}
