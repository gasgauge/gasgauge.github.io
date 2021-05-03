/**
 *Submitted for verification at Etherscan.io on 2020-12-16
*/

// hevm: flattened sources of src/DssDeployPauseProxyActionsAddon.sol
//pragma solidity >0.4.13 >=0.4.23 >=0.5.12 >=0.5.0 <0.6.0 >=0.5.10 <0.6.0 >=0.5.12 <0.6.0;
pragma solidity >=0.5 <0.7.17;

////// src/DssDeployPauseProxyActionsAddon.sol
/* pragma solidity >=0.5.12; */

interface PauseLike {
    function plot(
        address,
        bytes32,
        bytes calldata,
        uint256
    ) external;

    function exec(
        address,
        bytes32,
        bytes calldata,
        uint256
    ) external;
}

contract DssDeployPauseProxyActionsAddon {
    function deny(
        address pause,
        address actions,
        address who,
        address to
    ) external {
        bytes32 tag;
        assembly {
            tag := extcodehash(actions)
        }
        PauseLike(pause).plot(
            address(actions),
            tag,
            abi.encodeWithSignature("deny(address,address)", who, to),
            now
        );
        PauseLike(pause).exec(
            address(actions),
            tag,
            abi.encodeWithSignature("deny(address,address)", who, to),
            now
        );
    }
}
