/**

 *Submitted for verification at Etherscan.io on 2019-02-18

*/



//pragma solidity ^0.5.4;
pragma solidity >=0.5 <0.7.17;



contract CarInsurancePolicy {

    enum PolicyState { CREATED, APPROVED, CLAIMABLE, CLAIM_MADE}



    address manager_;

    address holder_;

    address validator_;

    address underwriter_;



    bytes32 carReg_;

    uint256 validAfterBlock_;

    PolicyState state_;



    event CLAIM_MADE(address policy, uint256 amount);

    event POLICY_APPROVAL(address policy, address approvedBy);



    modifier managerOnly() {

        require(msg.sender == manager_);

        _;

    }



    modifier validatorOnly() {

        require(msg.sender == validator_);

        _;

    }



    modifier holderOnly() {

        require(msg.sender == holder_);

        _;

    }



    modifier underwriterOnly() {

        require(msg.sender == underwriter_); 

        _;

    }

    

    constructor(bytes32 carReg, address holder, address underwriter, address validator) public {

        manager_ = msg.sender;

        holder_ = holder;

        carReg_ = carReg;

        underwriter_ = underwriter;

        validator_ = validator;

    }   

    

    function updateValidator(address validator) public managerOnly {

        validator_ = validator;

    }

    

    function certifyClaim() public validatorOnly {

        require(block.number >= validAfterBlock_, "Policy not active yet");

        require(state_ >= PolicyState.APPROVED, "cannot allow claim before approval");

        state_ = PolicyState.CLAIMABLE;

    }   

    

    function makeClaim(uint256 amount) public holderOnly {

        require(state_ >= PolicyState.APPROVED, "cannot claim before approval");

        state_ = PolicyState.CLAIM_MADE;

        emit CLAIM_MADE(msg.sender, amount);

    }   

        

    function approve(uint256 validAfter) public underwriterOnly {

        require(state_ == PolicyState.CREATED, "policy already approved");

        validAfterBlock_ = validAfter;

        state_ = PolicyState.APPROVED;

        emit POLICY_APPROVAL(address(this), msg.sender);

    }

}



contract CarInsurancePolicyManager {

    event NEW_POLICY(address policy);



    address owner_;

    address validator_;

    address underwriter_;



    address[] allPolicies_;



    constructor(address underwriter, address validator) public {

        owner_ = msg.sender;

        underwriter_ = underwriter;

        validator_ = validator;

    }



    function CreatePolicy(bytes32 carReg) public payable {

        CarInsurancePolicy newPolicy = new CarInsurancePolicy(carReg, msg.sender, underwriter_, validator_);

        allPolicies_.push(address(newPolicy));

        emit NEW_POLICY(address(newPolicy));

    }

    

    modifier ownderOnly() {

        require(msg.sender == owner_); 

        _;

    }



    function updateValidator(address validator) public ownderOnly {

        for (uint256 i; i < allPolicies_.length; i++) {

            CarInsurancePolicy policy = CarInsurancePolicy(allPolicies_[i]);

            policy.updateValidator(validator);

        }

    }

}
