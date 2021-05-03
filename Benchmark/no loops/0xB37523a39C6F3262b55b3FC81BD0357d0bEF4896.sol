// SPDX-License-Identifier: MIT
//pragma solidity 0.6.12;
pragma solidity >=0.5 <0.7.17;

/**
 * @notice Interface of Controller contract.
 * 
 * Controller maintains the list of vaults, manages vaults' shared
 * properties, e.g. governance and treasury address, and performs
 * reward allocation to vaults.
 */
interface IController {

    /**
     * @dev Returns the governance address of the Controller.
     * Governance has the greatest right and should be assumed by a Timelock.
     * Controller, all vaults and all strategies share the same governance.
     */
    function governance() external view returns (address);

    /**
     * @dev Returns the token served as additional rewards(i.e ACoconut) to vault users.
     */
    function rewardToken() external view returns (address);

    /**
     * @dev Returns the treasury address for vault fees.
     */
    function treasury() external view returns (address);

    /**
     * @dev Returns the total number of vaults managed by the Controller.
     */
    function numVaults() external view returns (uint256);

    /**
     * @dev Returns the vault address given the vault ID.
     */
    function vaults(uint256 _vaultId) external view returns (address);
}
