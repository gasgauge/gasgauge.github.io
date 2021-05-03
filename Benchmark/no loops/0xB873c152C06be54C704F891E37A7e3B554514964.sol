/**
 *Submitted for verification at Etherscan.io on 2020-12-15
*/

// Verified using https://dapp.tools

// hevm: flattened sources of src/lender/reserve.sol
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

////// lib/tinlake-math/src/math.sol
// Copyright (C) 2018 Rain <[email protected]>
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

contract Math {
    uint256 constant ONE = 10 ** 27;

    function safeAdd(uint x, uint y) public pure returns (uint z) {
        require((z = x + y) >= x, "safe-add-failed");
    }

    function safeSub(uint x, uint y) public pure returns (uint z) {
        require((z = x - y) <= x, "safe-sub-failed");
    }

    function safeMul(uint x, uint y) public pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "safe-mul-failed");
    }

    function safeDiv(uint x, uint y) public pure returns (uint z) {
        z = x / y;
    }

    function rmul(uint x, uint y) public pure returns (uint z) {
        z = safeMul(x, y) / ONE;
    }

    function rdiv(uint x, uint y) public pure returns (uint z) {
        require(y > 0, "division by zero");
        z = safeAdd(safeMul(x, ONE), y / 2) / y;
    }

    function rdivup(uint x, uint y) internal pure returns (uint z) {
        require(y > 0, "division by zero");
        // always rounds up
        z = safeAdd(safeMul(x, ONE), safeSub(y, 1)) / y;
    }


}

////// src/lender/reserve.sol
/* pragma solidity >=0.5.15 <0.6.0; */

/* import "tinlake-math/math.sol"; */
/* import "tinlake-auth/auth.sol"; */

contract ERC20Like_2 {
    function balanceOf(address) public view returns (uint256);

    function transferFrom(
        address,
        address,
        uint256
    ) public returns (bool);

    function mint(address, uint256) public;

    function burn(address, uint256) public;

    function totalSupply() public view returns (uint256);
}

contract ShelfLike_3 {
    function balanceRequest() public returns (bool requestWant, uint256 amount);
}

contract AssessorLike_4 {
    function repaymentUpdate(uint amount) public;
    function borrowUpdate(uint amount) public;
}

// The reserve keeps track of the currency and the bookkeeping
// of the total balance
contract Reserve is Math, Auth {
    ERC20Like_2 public currency;
    ShelfLike_3 public shelf;
    AssessorLike_4 public assessor;

    // currency available for borrowing new loans
    uint256 public currencyAvailable;

    // address or contract which holds the currency
    // by default it is address(this)
    address pot;

    // total currency in the reserve
    uint public balance_;

    constructor(address currency_) public {
        wards[msg.sender] = 1;
        currency = ERC20Like_2(currency_);
        pot = address(this);
    }

    function file(bytes32 what, uint amount) public auth {
        if (what == "currencyAvailable") {
            currencyAvailable = amount;
        } else revert();
    }

    function depend(bytes32 contractName, address addr) public auth {
        if (contractName == "shelf") {
            shelf = ShelfLike_3(addr);
        } else if (contractName == "currency") {
            currency = ERC20Like_2(addr);
        } else if (contractName == "assessor") {
            assessor = AssessorLike_4(addr);
        } else if (contractName == "pot") {
            pot = addr;
        } else revert();
    }

    function totalBalance() public view returns (uint) {
        return balance_;
    }

    // deposits currency in the the reserve
    function deposit(uint currencyAmount) public auth {
        _deposit(msg.sender, currencyAmount);
    }

    function _deposit(address usr, uint currencyAmount) internal {
        require(currency.transferFrom(usr, pot, currencyAmount), "reserve-deposit-failed");
        balance_ = safeAdd(balance_, currencyAmount);
    }

    // remove currency from the reserve
    function payout(uint currencyAmount) public auth {
        _payout(msg.sender, currencyAmount);
    }

    function _payout(address usr, uint currencyAmount)  internal {
      require(currency.transferFrom(pot, usr, currencyAmount), "reserve-payout-failed");
      balance_ = safeSub(balance_, currencyAmount);
    }

    // balance handles currency requests from the borrower side
    // currency is moved between shelf and reserve if needed
    function balance() public {
        (bool requestWant, uint256 currencyAmount) = shelf.balanceRequest();
        if (requestWant) {
            require(
                currencyAvailable >= currencyAmount,
                "not-enough-currency-reserve"
            );

            currencyAvailable = safeSub(currencyAvailable, currencyAmount);
            _payout(address(shelf), currencyAmount);
            assessor.borrowUpdate(currencyAmount);
            return;
        }
        _deposit(address(shelf), currencyAmount);
        assessor.repaymentUpdate(currencyAmount);
    }
}
