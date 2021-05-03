/**

 *Submitted for verification at Etherscan.io on 2020-01-17

*/



/**
Author: BlockRocket.tech.

*/

//pragma solidity ^0.5.12;
pragma solidity >=0.5 <0.7.17;


library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

contract PauserRole {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(msg.sender);
    }

    modifier onlyPauser() {
        require(isPauser(msg.sender), "PauserRole: caller does not have the Pauser role");
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(msg.sender);
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}

contract Pausable is PauserRole {
    
    event Paused(address account);

    
    event Unpaused(address account);

    bool private _paused;

    
    constructor () internal {
        _paused = false;
    }

    
    function paused() public view returns (bool) {
        return _paused;
    }

    
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

contract WhitelistAdminRole {
    using Roles for Roles.Role;

    event WhitelistAdminAdded(address indexed account);
    event WhitelistAdminRemoved(address indexed account);

    Roles.Role private _whitelistAdmins;

    constructor () internal {
        _addWhitelistAdmin(msg.sender);
    }

    modifier onlyWhitelistAdmin() {
        require(isWhitelistAdmin(msg.sender), "WhitelistAdminRole: caller does not have the WhitelistAdmin role");
        _;
    }

    function isWhitelistAdmin(address account) public view returns (bool) {
        return _whitelistAdmins.has(account);
    }

    function addWhitelistAdmin(address account) public onlyWhitelistAdmin {
        _addWhitelistAdmin(account);
    }

    function renounceWhitelistAdmin() public {
        _removeWhitelistAdmin(msg.sender);
    }

    function _addWhitelistAdmin(address account) internal {
        _whitelistAdmins.add(account);
        emit WhitelistAdminAdded(account);
    }

    function _removeWhitelistAdmin(address account) internal {
        _whitelistAdmins.remove(account);
        emit WhitelistAdminRemoved(account);
    }
}

contract WhitelistedRole is WhitelistAdminRole {
    using Roles for Roles.Role;

    event WhitelistedAdded(address indexed account);
    event WhitelistedRemoved(address indexed account);

    Roles.Role private _whitelisteds;

    modifier onlyWhitelisted() {
        require(isWhitelisted(msg.sender), "WhitelistedRole: caller does not have the Whitelisted role");
        _;
    }

    function isWhitelisted(address account) public view returns (bool) {
        return _whitelisteds.has(account);
    }

    function addWhitelisted(address account) public onlyWhitelistAdmin {
        _addWhitelisted(account);
    }

    function removeWhitelisted(address account) public onlyWhitelistAdmin {
        _removeWhitelisted(account);
    }

    function renounceWhitelisted() public {
        _removeWhitelisted(msg.sender);
    }

    function _addWhitelisted(address account) internal {
        _whitelisteds.add(account);
        emit WhitelistedAdded(account);
    }

    function _removeWhitelisted(address account) internal {
        _whitelisteds.remove(account);
        emit WhitelistedRemoved(account);
    }
}

contract TrickleDownSplitter is Pausable, WhitelistedRole {
    using SafeMath for uint256;

    address payable[] public participants;

    event FundsSplit(uint256 value, address payable[] participants);

    modifier onlyWhenContractHasABalance() {
        require(address(this).balance > 0, "There are no contract funds to send");
        _;
    }

    constructor() public {
        super.addWhitelisted(msg.sender);
    }

    function setParticipants(address payable[] calldata _participants) external onlyWhitelisted {
        require(_participants.length > 0, "No addresses have been supplied");
        participants = _participants;
    }

    function addParticipant(address payable participant) external onlyWhitelisted {
        require(participant != address(0), "Cannot add zero address as participant");
        participants.push(participant);
    }

    function removeParticipantAtIndex(uint256 index) external onlyWhitelisted {
        uint256 numOfParticipants = participants.length;
        require(participants.length > 0, "The participant addresses list is empty");

        uint256 lastParticipantIndex = numOfParticipants.sub(1);
        require(index <= lastParticipantIndex, "Array out of bounds reference");

        delete participants[index];

        
        if (index != lastParticipantIndex) {
            participants[index] = participants[lastParticipantIndex];
        }

        participants.length--;
    }

    function splitFunds(uint256 value)
    external payable
    whenNotPaused
    onlyWhenContractHasABalance
    onlyWhitelisted {
        require(value > 0, "No value has been specified");

        uint256 modulo = 10000;
        uint256 numOfParticipants = participants.length;
        uint256 individualSharePercentage = modulo.div(numOfParticipants);
        uint256 singleUnitOfValue = value.div(modulo);
        uint256 individualShare = singleUnitOfValue.mul(individualSharePercentage);

        for (uint i = 0; i < numOfParticipants; i++) {
            address payable participant = participants[i];
            
            (bool success,) = participant.call.value(individualShare)("");
            require(success, "Unable to send funds");
        }

        emit FundsSplit(value, participants);
    }

    function withdrawAllFunds() external onlyWhitelisted {
        
        (bool success,) = msg.sender.call.value(address(this).balance)("");
        require(success, "Failed to withdraw contract funds");
    }

    function() external payable {}
}
