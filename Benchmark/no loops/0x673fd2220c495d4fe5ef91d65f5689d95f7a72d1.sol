/**
 *Submitted for verification at Etherscan.io on 2020-12-16
*/

// SPDX-License-Identifier: MIT
//pragma solidity 0.6.10;
pragma solidity >=0.5 <0.7.17;

contract BombDisposal {
    address owner;
    address public theRealJohnMcClane;
    uint16 public purpleWiresCut;
    uint16 public brownWiresCut;
    uint16 public greenWiresCut;
    uint16 public orangeWiresCut;
    uint16 public redOrBlueWiresCut;
    bool public bombArmed = true;
    bool public bombDetonated = false;
    uint256 constant INITIAL_COMMIT_PERIOD_END = 11498000;
    uint256 constant BLOCKS_TO_WAIT = 15;
    uint256 constant DETONATION_TIME = 11525000;
    mapping(address => bool) public purpleWireCutters;
    mapping(address => bool) public brownWireCutters;
    mapping(address => bool) public greenWireCutters;
    mapping(address => bool) public orangeWireCutters;
    mapping(address => bool) public blueWireCutters;
    mapping(address => bool) public redWireCutters;
    mapping(address => bool) public redBlueAttempted;
    mapping(address => bytes32) public purpleCommits;
    mapping(address => bytes32) public brownCommits;
    mapping(address => bytes32) public greenCommits;
    mapping(address => bytes32) public disarmCommits;
    mapping(address => uint256) public disarmCommitBlock;
    string public disarmCode;

    
    constructor() public {
        owner = msg.sender;
    }
    
    function commitToCutPurpleWire(bytes32 _hash) external {
        require(block.number < INITIAL_COMMIT_PERIOD_END, "You're too late");
        purpleCommits[msg.sender] = _hash;
    }
    
    function commitToCutBrownWire(bytes32 _hash) external {
        require(block.number < INITIAL_COMMIT_PERIOD_END, "You're too late");
        brownCommits[msg.sender] = _hash;
    }
    
    function commitToCutGreenWire(bytes32 _hash) external {
        require(block.number < INITIAL_COMMIT_PERIOD_END, "You're too late");
        greenCommits[msg.sender] = _hash;
    }

    // Make sure to appreciate the last bit of 2020
    function cutPurpleWire(string calldata answer) external {
        require(block.number > INITIAL_COMMIT_PERIOD_END, "Easy does it");
        require(!purpleWireCutters[msg.sender], "Already cut");
        bytes32 answerHash = keccak256(abi.encodePacked(answer));
        bytes32 commitHash = keccak256(abi.encodePacked(msg.sender, answerHash));
        require(commitHash == purpleCommits[msg.sender], "Poor commitment");
        bytes32 answerDoubleHash = keccak256(abi.encodePacked(answerHash));
        require(answerDoubleHash == 0xb9bf1f33618e06cf16c58b07f82b01bbe4a9320b54b18ae4ba299f4eead3969f, "Wrong answer");
        purpleWireCutters[msg.sender] = true;
        purpleWiresCut += 1;
    }
    
    // The original Coinbase
    function cutBrownWire(bytes calldata answer) external {
        require(block.number > INITIAL_COMMIT_PERIOD_END, "Easy does it");
        require(!brownWireCutters[msg.sender], "Already cut");
        bytes32 answerHash = keccak256(abi.encodePacked(answer));
        bytes32 commitHash = keccak256(abi.encodePacked(msg.sender, answerHash));
        require(commitHash == brownCommits[msg.sender], "Poor commitment");
        bytes32 answerDoubleHash = keccak256(abi.encodePacked(answerHash));
        require(answerDoubleHash == 0x32b0b16339e2428094126b67945dbe24136adea413b84958e65d48f0007a7d6b, "Wrong answer");
        brownWireCutters[msg.sender] = true;
        brownWiresCut += 1;
    }
  
    // Mark my words, if we are not careful we will lose sight of why we started - To create a more decentralized future.
    // For 18-20 included many distractions. 
    // What were they?
    function cutGreenWire(string calldata tcotw, string calldata tdor, string calldata tloot) external {
        require(block.number > INITIAL_COMMIT_PERIOD_END, "Easy does it");
        require(!greenWireCutters[msg.sender], "Already cut");
        bytes32 answerHash = keccak256(abi.encodePacked(tcotw, tdor, tloot));
        bytes32 commitHash = keccak256(abi.encodePacked(msg.sender, answerHash));
        require(commitHash == greenCommits[msg.sender], "Poor commitment");
        bytes32 answerDoubleHash = keccak256(abi.encodePacked(answerHash));
        require(answerDoubleHash == 0x3b7f80ff78a45475c3a1236c54a82625fbf41aa567b5e230a05e1b1066194748, "Wrong answers");
        greenWireCutters[msg.sender] = true;
        greenWiresCut += 1;
    }
    
    // A miner problem
    function cutOrangeWire(bytes2 nonce) external {
        require(block.number > INITIAL_COMMIT_PERIOD_END, "Easy does it");
        require(!orangeWireCutters[msg.sender], "Already cut");
        bytes32 hashedValue = keccak256(abi.encodePacked(msg.sender, nonce));
        byte firstByte = hashedValue[0];
        require(firstByte == 0x00, "Try a new nonce");
        orangeWireCutters[msg.sender] = true;
        orangeWiresCut += 1;
    }
    
    // This is your last chance. After this, there is no turning back.
    function cutRedOrBlueWire() external {
        require(block.number > INITIAL_COMMIT_PERIOD_END, "Easy does it");
        require(!redBlueAttempted[tx.origin], "No turning back");
        blueWireCutters[tx.origin] = !blueWireCutters[tx.origin];
        redWireCutters[tx.origin] = !blueWireCutters[tx.origin];
        msg.sender.call("You stay in Wonderland and I show you how deep the rabbit-hole goes");
        if (!redBlueAttempted[tx.origin]) {
            redOrBlueWiresCut += 1;
        }
        redBlueAttempted[tx.origin] = true;
    }
    
    // An additional disarm code will be provided by the SCPD after block 11511500
    function provideDisarmCode(string calldata code) external {
        require(msg.sender == owner);
        disarmCode = code;
    }
    
    function commitToDisarm(bytes32 _hash) external {
        disarmCommits[msg.sender] = _hash;
        disarmCommitBlock[msg.sender] = block.number;
    }
    	
	// Await additional disarm code
    function disarmBomb(string calldata missingChars) external {
        require(!bombDetonated, "Already exploded");
        require(bombArmed, "Already disarmed");
        require(purpleWireCutters[msg.sender], "Cut purple wire");
        require(brownWireCutters[msg.sender], "Cut brown wire");
        require(greenWireCutters[msg.sender], "Cut green wire");
        require(orangeWireCutters[msg.sender], "Cut orange wire");
		require(block.number > disarmCommitBlock[msg.sender] + BLOCKS_TO_WAIT, "No front-running");
		bytes32 missingCharsHash = keccak256(abi.encodePacked(missingChars));
		bytes32 commitHash = keccak256(abi.encodePacked(msg.sender, missingCharsHash));
		require(commitHash == disarmCommits[msg.sender], "Poor commitment");
		bytes32 finalResultHash = keccak256(abi.encodePacked(
		    missingCharsHash, 
		    disarmCode, 
		    blueWireCutters[msg.sender], 
		    redWireCutters[msg.sender]
		    ));
		require(finalResultHash == 0x820b25046cc144c5c0cff21af15e3387f538c5278cb097a77599041182b8ca17, "Disarm failed");
        bombArmed = false;
        theRealJohnMcClane = msg.sender;
    }

    function claimDisarmReward() external {
        require(msg.sender == theRealJohnMcClane, "Get outta here");
        msg.sender.transfer(address(this).balance);
    }
    
    function detonateBomb() external {
        require(block.number > DETONATION_TIME, "Not until Xmas");
        require(!bombDetonated, "Already exploded");
        require(bombArmed, "Already disarmed");
        bombDetonated = true;
        bombArmed = false;
    }
    
    function receive() external payable {}
}
