/**
 *Submitted for verification at Etherscan.io on 2020-08-28
*/

//pragma solidity 0.7.0;
pragma solidity >=0.5 <0.7.17;
// SPDX-License-Identifier: MIT

interface Vault {
    function earn() external;
}

contract VaultKeeper {
    function earn(address[] calldata vaults) external {
        for (uint i=0; i<vaults.length; i++) {
            Vault(vaults[i]).earn();
        }
    }
}
