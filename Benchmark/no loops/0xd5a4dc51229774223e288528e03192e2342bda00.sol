/**
 *Submitted for verification at Etherscan.io on 2020-09-11
*/

pragma solidity >=0.5 <0.7.17;

contract Secondary {
    address private _primary;
    address private _primaryCandidate;

    constructor () internal {
        _primary = msg.sender;
        _primaryCandidate = address(0);
    }

    modifier onlyPrimary() {
        require(msg.sender == _primary, "Secondary: caller is not the primary account");
        _;
    }

    function primary() public view returns (address) {
        return _primary;
    }
    
    function acceptBeingPrimary() public {
        require(msg.sender == _primaryCandidate, "Secondary: caller is not the primary candidate account");
        require(msg.sender != address(0));
        
        _primary = _primaryCandidate;
        _primaryCandidate = address(0);
    }

    function setPrimaryCandidate(address recipient) public onlyPrimary {
        require(recipient != _primary, "You can't make yourself Primary Candidate");
        _primaryCandidate = recipient;
    }
    
}

contract Kye is Secondary {
    
    address private _routerAddress;
    
    function routerAddress() public view returns (address){
        return _routerAddress;
    }
    
    function updateRouterAddress(address input) public onlyPrimary {
        require(input != _routerAddress, "Input is already routerAddress");
        require(input != address(this), "Input is Kye address");
        _routerAddress = input;
    }


}