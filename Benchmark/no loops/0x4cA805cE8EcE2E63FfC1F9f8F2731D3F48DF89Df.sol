/**
 *Submitted for verification at Etherscan.io on 2020-12-16
*/

// Verified using https://dapp.tools

// hevm: flattened sources of src/root.sol
//pragma solidity >=0.4.23 >=0.5.15 <0.6.0;
pragma solidity >=0.5 <0.7.17;

////// lib/tinlake-auth/lib/ds-note/src/note.sol
/// note.sol -- the `note' modifier, for logging calls as events

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

/* pragma solidity >=0.4.23; */

contract DSNote {
    event LogNote(
        bytes4   indexed  sig,
        address  indexed  guy,
        bytes32  indexed  foo,
        bytes32  indexed  bar,
        uint256           wad,
        bytes             fax
    ) anonymous;

    modifier note {
        bytes32 foo;
        bytes32 bar;
        uint256 wad;

        assembly {
            foo := calldataload(4)
            bar := calldataload(36)
            wad := callvalue()
        }

        _;

        emit LogNote(msg.sig, msg.sender, foo, bar, wad, msg.data);
    }
}

////// lib/tinlake-auth/src/auth.sol
// Copyright (C) Centrifuge 2020, based on MakerDAO dss https://github.com/makerdao/dss
//
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

/* import "ds-note/note.sol"; */

contract Auth is DSNote {
    mapping (address => uint) public wards;
    function rely(address usr) public auth note { wards[usr] = 1; }
    function deny(address usr) public auth note { wards[usr] = 0; }
    modifier auth { require(wards[msg.sender] == 1); _; }
}

////// src/root.sol
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

/* import "tinlake-auth/auth.sol"; */

interface AuthLike_3 {
    function rely(address) external;
    function deny(address) external;
}

interface DependLike_3 {
    function depend(bytes32, address) external;
}

interface BorrowerDeployerLike {
    function collector() external returns (address);
    function feed() external returns (address);
    function shelf() external returns (address);
    function title() external returns (address);
}

interface LenderDeployerLike {
    function assessor() external returns (address);
    function reserve() external returns (address);
    function assessorAdmin() external returns (address);
    function juniorMemberlist() external returns (address);
    function seniorMemberlist() external returns (address);
}


contract TinlakeRoot is Auth {
    BorrowerDeployerLike public borrowerDeployer;
    LenderDeployerLike public  lenderDeployer;

    bool public             deployed;
    address public          deployUsr;

    constructor (address deployUsr_) public {
        deployUsr = deployUsr_;
    }

    // --- Prepare ---
    // Sets the two deployer dependencies. This needs to be called by the deployUsr
    function prepare(address lender_, address borrower_, address ward_) public {
        require(deployUsr == msg.sender);
        borrowerDeployer = BorrowerDeployerLike(borrower_);
        lenderDeployer = LenderDeployerLike(lender_);
        wards[ward_] = 1;
        deployUsr = address(0); // disallow the deploy user to call this more than once.
    }

    // --- Deploy ---
    // After going through the deploy process on the lender and borrower method, this method is called to connect
    // lender and borrower contracts.
    function deploy() public {
        require(address(borrowerDeployer) != address(0) && address(lenderDeployer) != address(0) && deployed == false);
        deployed = true;

        address reserve_ = lenderDeployer.reserve();
        address shelf_ = borrowerDeployer.shelf();

        // Borrower depends
        DependLike_3(borrowerDeployer.collector()).depend("distributor", reserve_);
        DependLike_3(borrowerDeployer.shelf()).depend("lender", reserve_);
        DependLike_3(borrowerDeployer.shelf()).depend("distributor", reserve_);

        //AuthLike(reserve).rely(shelf_);


        //  Lender depends
        address navFeed = borrowerDeployer.feed();

        DependLike_3(reserve_).depend("shelf", shelf_);
        DependLike_3(lenderDeployer.assessor()).depend("navFeed", navFeed);

         // permissions
        address poolAdmin1 = 0x71d9f8CFdcCEF71B59DD81AB387e523E2834F2b8;
        address poolAdmin2 = 0xbAc249271918db4261fF60354cc97Bb4cE9A08A1;                                             
        address oracle = 0x29558325eB0d8E73c8DfE3DE94CEAe93048B7255;

        address juniorMemberlistAdmin1 = 0x71d9f8CFdcCEF71B59DD81AB387e523E2834F2b8;
        address juniorMemberlistAdmin2 = 0x97b2d32FE673af5bb322409afb6253DFD02C0567;

        address seniorMemberlistAdmin1 = 0x71d9f8CFdcCEF71B59DD81AB387e523E2834F2b8;
        address seniorMemberlistAdmin2 = 0x97b2d32FE673af5bb322409afb6253DFD02C0567;
        address seniorMemberlistAdmin3 = 0xa7Aa917b502d86CD5A23FFbD9Ee32E013015e069;
        address seniorMemberlistAdmin4 = 0xfEADaD6b75e6C899132587b7Cb3FEd60c8554821;

        AuthLike_3(lenderDeployer.assessorAdmin()).rely(poolAdmin1);
        AuthLike_3(lenderDeployer.assessorAdmin()).rely(poolAdmin2);
        AuthLike_3(lenderDeployer.juniorMemberlist()).rely(juniorMemberlistAdmin1);
        AuthLike_3(lenderDeployer.juniorMemberlist()).rely(juniorMemberlistAdmin2);
        AuthLike_3(lenderDeployer.seniorMemberlist()).rely(seniorMemberlistAdmin1);
        AuthLike_3(lenderDeployer.seniorMemberlist()).rely(seniorMemberlistAdmin2);
        AuthLike_3(lenderDeployer.seniorMemberlist()).rely(seniorMemberlistAdmin3);
        AuthLike_3(lenderDeployer.seniorMemberlist()).rely(seniorMemberlistAdmin4);
        AuthLike_3(navFeed).rely(oracle);
    }

    // --- Governance Functions ---
    // `relyContract` & `denyContract` can be called by any ward on the TinlakeRoot
    // contract to make an arbitrary address a ward on any contract the TinlakeRoot
    // is a ward on.
    function relyContract(address target, address usr) public auth {
        AuthLike_3(target).rely(usr);
    }

    function denyContract(address target, address usr) public auth {
        AuthLike_3(target).deny(usr);
    }

}
