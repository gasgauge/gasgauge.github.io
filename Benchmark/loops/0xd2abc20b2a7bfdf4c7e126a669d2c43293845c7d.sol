/**
 *Submitted for verification at Etherscan.io on 2020-09-06
*/

//pragma solidity 0.6.12;
pragma solidity >=0.5 <0.7.17;

contract GuardiansMigrationV1V2 {
    event GuardianAddressMigrationRecorded(address indexed oldGuardianAddress, address indexed newGuardianAddress);
    mapping (address => address) newGuardianAddress;
    function setNewGuardianAddress(address newAddress) external {
        newGuardianAddress[msg.sender] = newAddress;
        emit GuardianAddressMigrationRecorded(msg.sender, newAddress);
    }
    function getGuardianV2Address(address oldAddress) public view returns(address newAddress) {
        newAddress = newGuardianAddress[oldAddress];
        if (newAddress == address(0)) {
            newAddress = oldAddress;
        }
    }
    function getGuardiansV2AddressBatch(address[] calldata oldAddresses) external view returns(address[] memory newAddresses) {
        newAddresses = new address[](oldAddresses.length);
        for (uint i = 0; i < oldAddresses.length; i++) {
            newAddresses[i] = getGuardianV2Address(oldAddresses[i]);
        }
        return newAddresses;
    }
}
