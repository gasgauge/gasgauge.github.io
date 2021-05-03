/**
 *Submitted for verification at Etherscan.io on 2020-09-14
*/

//pragma solidity 0.5.11;
pragma solidity >=0.5 <0.7.17;

contract erc20 {
    function transfer(address _to, uint256 _value) public returns (bool success);
}

contract MultiWallet {
    struct ThresholdJob {
        Role roleType;
        uint newThreshold;
        bool executed;
    }

    struct ManageJob {
        Role roleType;
        ManageAction action;
        address member;
        bool executed;
    }

    struct TransferJob {
        address payable to;
        uint value;
        bool executed;
    }
    
    struct TransferErc20Job {
        address asset;
        address to;
        uint value;
        bool executed;
    }

    enum ManageAction{
        Add,
        Remove
    }

    enum Role {
        Admin,
        Signer,
        Specialist
    }

    enum Job {
        ManageMember,
        Transfer,
        TransferErc20,
        ChangeThreshold
    }

    event EthTransfer(address indexed to,uint256 indexed value,bytes32 indexed jobId, string proof);
    event Erc20Transfer(address indexed asset, address indexed to,uint256 indexed value, bytes32 jobId, string proof);

    event ChangeMember(Role role, ManageAction action, address member);
    event ChangeThreshold(Role role, uint newThreshold);

    event Deposit(address from, uint256 value);

    event Pause(bool pauseStatus);

    event JobLog(bytes32 jobId);

    mapping(uint => mapping(address => bool)) members;
    mapping(uint => address[]) memberList;

    mapping(uint => uint) memberThresholds;
    mapping(uint => mapping(bytes32 => mapping(address => bool))) confirmations;

    mapping(bytes32 => ThresholdJob) thJobs;
    mapping(bytes32 => ManageJob) mJobs;
    mapping(bytes32 => TransferJob) txJobs;
    mapping(bytes32 => TransferErc20Job) erc20Jobs;

    bool public isPaused;

    constructor(address[] memory admins, address[] memory speicalists, address[] memory txsigners ) public {
        require(admins.length >= 2);
        require(speicalists.length >= 1);
        require(txsigners.length >= 2);

        uint temp = uint(Role.Admin);
        memberThresholds[temp] = 2;
        for(uint i = 0; i < admins.length; i++){
            members[temp][admins[i]] = true;
        }
        memberList[temp] = admins;

        temp = uint(Role.Specialist);
        memberThresholds[temp] = 1;
        for(uint i = 0; i < speicalists.length; i++){
            members[temp][speicalists[i]] = true;
        }
        memberList[temp] = speicalists;

        temp = uint(Role.Signer);
        memberThresholds[temp] = 2;
        for(uint i = 0; i < txsigners.length; i++){
            members[temp][txsigners[i]] = true;
        }
        memberList[temp] = txsigners;
    }

    modifier onlyMember(Role roleType) {
        require(members[uint(roleType)][msg.sender], "invalid role");
        _;
    }

    modifier onlyUnpaused(){
        require(!isPaused, "wallet is paused now");
        _;
    }

    function getMembers(Role roleType)
    public
    view
    returns (address[] memory result)
    {
        result = memberList[uint(roleType)];
    }

    function getThreshold(Role roleType)
    public
    view
    returns (uint result)
    {
        result = memberThresholds[uint(roleType)];
    }

    function addConfirmation(Job job, bytes32 jobId,  address addr)
        internal
    {
        confirmations[uint(job)][jobId][addr] = true;
    }

    function checkConfirmation(Role roleType, Job job, bytes32 jobId)
        public
        view
        returns (bool passed)
    {
        uint accumlate = 0;
        address[] memory mList = memberList[uint(roleType)];
        uint threshold = memberThresholds[uint(roleType)];
        for(uint i = 0; i < mList.length; i++) {
            if(confirmations[uint(job)][jobId][mList[i]]){
                accumlate += 1;
 
                if(accumlate >= threshold) {
                    passed = true;
                    break;
                }
            }

        }
    }


    function()
        external
        payable
    {
        if (msg.value > 0) {
            emit Deposit(msg.sender, msg.value);
        }
    }

    function ethTransfer(address payable to,uint256 value, bytes32 jobId, string memory proof)
        public
        onlyMember(Role.Signer)
        onlyUnpaused
    {
        TransferJob memory oldJob = txJobs[jobId];
        if(oldJob.to == address(0) && oldJob.value == 0) {
            txJobs[jobId] = TransferJob ({
                to: to,
                value: value,
                executed: false
            });
        }else {
            require(keccak256(abi.encodePacked(
                            to,
                            value))==
                    keccak256(abi.encodePacked(
                            oldJob.to,
                            oldJob.value)), "not consistence");

            require(!oldJob.executed, "executed already");
        }

        addConfirmation(Job.Transfer, jobId, msg.sender);

        emit EthTransfer(to, value, jobId, proof);

        if (checkConfirmation(Role.Signer, Job.Transfer, jobId)){
            txJobs[jobId].executed = true;

            to.transfer(value);
            emit JobLog(jobId);
        }
    }

    function erc20Transfer(address asset,address to,uint256 value, bytes32 jobId, string memory proof)
        public
        onlyMember(Role.Signer)
        onlyUnpaused
    {
        TransferErc20Job memory oldJob = erc20Jobs[jobId];
        if (oldJob.asset == address(0)) {
            erc20Jobs[jobId] = TransferErc20Job ({
                asset: asset,
                to: to,
                value: value,
                executed: false
            });
        } else {
            require(keccak256(abi.encodePacked(
                                asset,
                                to,
                                value))==
                    keccak256(abi.encodePacked(
                                oldJob.asset,
                                oldJob.to,
                                oldJob.value)), "not consistence");
            require(!oldJob.executed, "executed already");
        }

        addConfirmation(Job.TransferErc20, jobId, msg.sender);

        emit Erc20Transfer(asset, to, value, jobId, proof);

        if (checkConfirmation(Role.Signer, Job.TransferErc20, jobId)){
            erc20Jobs[jobId].executed = true;

            erc20 erc20Asset = erc20(asset);
            erc20Asset.transfer(to, value);
            emit JobLog(jobId);
        }
    }

    function changeMember(Role roleType, ManageAction action, address member, bytes32 jobId)
        public
        onlyMember(Role.Admin)
    {
        if (action == ManageAction.Add) {
            require(!members[uint(roleType)][member], "member already exists");
        }else if (action == ManageAction.Remove) {
            require(members[uint(roleType)][member], "member not exists");
            require(memberList[uint(roleType)].length > memberThresholds[uint(roleType)], "member count will below threshold");
        }else {
            require(false, "unexpected action");
        }

        ManageJob memory oldJob = mJobs[jobId];
        if (oldJob.member == address(0)) {
            mJobs[jobId] = ManageJob ({
                roleType: roleType,
                action: action,
                member: member,
                executed: false
            });
        } else {
            require(keccak256(abi.encodePacked(
                                roleType,
                                action,
                                member))==
                    keccak256(abi.encodePacked(
                                oldJob.roleType,
                                oldJob.action,
                                oldJob.member)), "not consistence");
            require(!oldJob.executed, "executed already");
        }

        addConfirmation(Job.ManageMember, jobId, msg.sender);

        emit ChangeMember(roleType, action, member);

        if (checkConfirmation(Role.Admin, Job.ManageMember, jobId)){
            mJobs[jobId].executed = true;

            if (action == ManageAction.Add) {
                members[uint(roleType)][member] = true;
                memberList[uint(roleType)].push(member);
            } else if (action == ManageAction.Remove) {
                delete members[uint(roleType)][member];

                uint len = memberList[uint(roleType)].length;
                for(uint i = 0; i < len; i++ ) {
                    if(memberList[uint(roleType)][i] == member) {
                        memberList[uint(roleType)][i] = memberList[uint(roleType)][len - 1];
                        memberList[uint(roleType)].length -= 1;
                        break;
                    }
                }
            } else {
                require(false, "unexpected action");
            }

            emit JobLog(jobId);
        }
    }

    function changeThreshold(Role roleType, uint threshold, bytes32 jobId)
        public
        onlyMember(Role.Admin)
    {
        require(threshold <= memberList[uint(roleType)].length, "threshold too low");

        ThresholdJob memory  oldJob = thJobs[jobId];
        if (oldJob.newThreshold == 0) {
            thJobs[jobId] = ThresholdJob({
                roleType: roleType,
                newThreshold: threshold,
                executed: false
            });
        } else {
            require(threshold == oldJob.newThreshold && roleType == oldJob.roleType, "not consistence");
            require(!oldJob.executed, "executed already");
        }

        addConfirmation(Job.ChangeThreshold, jobId, msg.sender);
        emit ChangeThreshold(roleType, threshold);

        if (checkConfirmation(Role.Admin, Job.ChangeThreshold, jobId)){
            thJobs[jobId].executed = true;
            memberThresholds[uint(roleType)] = threshold;

            emit JobLog(jobId);
        }
    }

    function pause(bool bPause)
        public
        onlyMember(Role.Specialist)
    {
        isPaused = bPause;
        emit Pause(bPause);
    }
}
