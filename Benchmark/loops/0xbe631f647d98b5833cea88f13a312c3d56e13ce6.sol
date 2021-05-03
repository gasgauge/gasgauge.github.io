/**

 *Submitted for verification at Etherscan.io on 2020-12-24

*/



//pragma solidity ^0.5.4;
pragma solidity >=0.5 <0.7.17;



interface Upgrader {

    function upgrade(address payable _wallet, address[] calldata _toDisable, address[] calldata _toEnable) external;

    function toDisable() external view returns (address[] memory);

    function toEnable() external view returns (address[] memory);

}



contract BaseWallet {

    function authoriseModule(address _module, bool _value) external  {}

}



contract LegacySimpleUpgrader is Upgrader {



    address[] private disable;

    address[] private enable;



    constructor(address[] memory _disable, address[] memory _enable) public {

        disable = _disable;

        enable = _enable;

    }



    function upgrade(address payable _wallet, address[] calldata _toDisable, address[] calldata _toEnable) external {

        uint256 i = 0;

        //remove old modules

        for(i = 0; i < _toDisable.length; i++) {

            BaseWallet(_wallet).authoriseModule(_toDisable[i], false);

        }

        //add new modules

        for(i = 0; i < _toEnable.length; i++) {

            BaseWallet(_wallet).authoriseModule(_toEnable[i], true);

        }

    }



    function toDisable() external view returns (address[] memory) {

        return disable;

    }



    function toEnable() external view returns (address[] memory) {

        return enable;

    }

}
