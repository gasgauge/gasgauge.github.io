/**

 *Submitted for verification at Etherscan.io on 2020-12-18

*/



// Verified using https://dapp.tools

// hevm: flattened sources of src/spell.sol
//pragma solidity >=0.5.15 <0.6.0;
pragma solidity >=0.5 <0.7.17;

////// src/spell.sol
// Copyright (C) 2020 Centrifuge
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
/* pragma solidity >=0.5.15 <0.6.0; */

interface TinlakeRootLike {
    function relyContract(address, address) external;
    function denyContract(address, address) external;
}

interface NAVFeedLike {
    function file(bytes32 name, uint value) external;
    function file(bytes32 name, uint risk_, uint thresholdRatio_, uint ceilingRatio_, uint rate_, uint recoveryRatePD_) external;
    function discountRate() external returns(uint);
}

// This spell changes permissions for the junior & senior memberlists & assessor wrapper
// & changes the discount rate on the NS2 deployment
contract TinlakeSpell {

    bool public done;
    string constant public description = "Tinlake Mainnet Spell";

    // MAINNET ADDRESSES
    // The contracts in this list should correspond to a tinlake deployment
    // https://github.com/centrifuge/tinlake-pool-config/blob/master/mainnet-production.json

    // REVPOOL 1 root contracts
    address constant public ROOT = 0x53b2d22d07E069a3b132BfeaaD275b10273d381E;
    address constant public SENIOR_MEMBERLIST = 0x5B5CFD6E45F1407ABCb4BFD9947aBea1EA6649dA;
    address constant public JUNIOR_MEMBERLIST = 0x42C2483EEE8c1Fe46C398Ac296C59674F9eb88CD;
    address constant public ASSESSOR_ADMIN = 0x46470030e1c732A9C2b541189471E47661311375;
    address constant public NAV_FEED = 0x41fAD1Eb242De19dA0206B0468763333BB6C2B3D;

    // permissions to be set senior memberlist
    address constant public SENIOR_MEMBERLIST_ADMIN1 = 0xa7Aa917b502d86CD5A23FFbD9Ee32E013015e069;                                             
    address constant public SENIOR_MEMBERLIST_ADMIN2 = 0x440B547fa81f8b34c7558722fa79cF1b56c1bDcf;
    address constant public SENIOR_MEMBERLIST_ADMIN_REMOVE = 0xCE30bc6d0c9e489Ab06EC6E7F703E7DB69c5fa01;

    // permissions to be set junior memberlist
    address constant public JUNIOR_MEMBERLIST_ADMIN1 = 0xa7Aa917b502d86CD5A23FFbD9Ee32E013015e069;                                             
    address constant public JUNIOR_MEMBERLIST_ADMIN2 = 0xfEADaD6b75e6C899132587b7Cb3FEd60c8554821;
    address constant public JUNIOR_MEMBERLIST_ADMIN3 = 0x440B547fa81f8b34c7558722fa79cF1b56c1bDcf;

    // permissions assessor wrapper
    address constant public ASSESSOR_ADMIN_ADMIN1 = 0xa7Aa917b502d86CD5A23FFbD9Ee32E013015e069;                                             
    address constant public ASSESSOR_ADMIN_ADMIN2 = 0x440B547fa81f8b34c7558722fa79cF1b56c1bDcf;
           
    // new discount rate 7,5%                  
    uint constant public discountRate = uint(1000000002378234398782343987);
    function cast() public {
        require(!done, "spell-already-cast");
        done = true;
        execute();
    }

    function execute() internal {
        TinlakeRootLike root = TinlakeRootLike(address(ROOT));
        NAVFeedLike navFeed = NAVFeedLike(address(NAV_FEED));
   
        // add permissions  
        // Assessor Admin
        root.relyContract(ASSESSOR_ADMIN, ASSESSOR_ADMIN_ADMIN1);
        root.relyContract(ASSESSOR_ADMIN, ASSESSOR_ADMIN_ADMIN2);
        
        // Junior Memeberlist
        root.relyContract(JUNIOR_MEMBERLIST, JUNIOR_MEMBERLIST_ADMIN1);
        root.relyContract(JUNIOR_MEMBERLIST, JUNIOR_MEMBERLIST_ADMIN2);
        root.relyContract(JUNIOR_MEMBERLIST, JUNIOR_MEMBERLIST_ADMIN3);

        // Senior Memeberlist
        root.relyContract(SENIOR_MEMBERLIST, SENIOR_MEMBERLIST_ADMIN1);
        root.relyContract(SENIOR_MEMBERLIST, SENIOR_MEMBERLIST_ADMIN2);
        root.denyContract(SENIOR_MEMBERLIST, SENIOR_MEMBERLIST_ADMIN_REMOVE);

        // NavFeed 
        root.relyContract(NAV_FEED, address(this)); // required to file riskGroups & change discountRate
        // change discountRate
        navFeed.file("discountRate", discountRate);
    }   
}
