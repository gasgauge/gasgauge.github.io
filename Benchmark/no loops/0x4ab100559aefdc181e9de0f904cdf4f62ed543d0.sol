/**

 *Submitted for verification at Etherscan.io on 2020-12-19

*/



//pragma solidity 0.6.12;
pragma solidity >=0.5 <0.7.17;



// ----------------------------------------------------------------------------

// Safe maths

// ----------------------------------------------------------------------------

contract SafeMath {

    function safeAdd(uint a, uint b) internal pure returns (uint c) {

        c = a + b;

        require(c >= a);

    }

    function safeSub(uint a, uint b) internal pure returns (uint c) {

        require(b <= a);

        c = a - b;

    }

    function safeMul(uint a, uint b) internal pure returns (uint c) {

        c = a * b;

        require(a == 0 || c / a == b);

    }

    function safeDiv(uint a, uint b) internal pure returns (uint c) {

        require(b > 0);

        c = a / b;

    }

}







// ----------------------------------------------------------------------------

// Owned contract

// ----------------------------------------------------------------------------

contract Owned {

    address public owner;

    address public newOwner;



    event OwnershipTransferred(address indexed _from, address indexed _to);



    constructor() public {

        owner = msg.sender;

    }



    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }



    function transferOwnership(address _newOwner) public onlyOwner {

        address oldOwner = owner;

        owner = _newOwner;

        emit OwnershipTransferred(oldOwner, owner);

    }

}





// ----------------------------------------------------------------------------

// ERC20 Token, with the addition of symbol, name and decimals and assisted

// token transfers

// ----------------------------------------------------------------------------

contract Momento is  Owned, SafeMath {

    string public name = "Momento";

    string public symbol = "MOMENT";

    uint8 public decimals = 18;

    uint public _totalSupply;

    bool public isLocked;



    mapping(address => uint) balances;

    mapping(address => mapping(address => uint)) allowed;



    event Transfer(address indexed from, address indexed to, uint tokens);

    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

    // ------------------------------------------------------------------------

    // Constructor

    // ------------------------------------------------------------------------

    

     constructor (uint tokens) public {

        _totalSupply = tokens;

        balances[owner] = safeAdd(balances[owner], tokens);

        isLocked = true;

    }



    modifier isNotLocked {

        require(!isLocked);

        _;

    }



    function setIsLocked(bool _isLocked) public onlyOwner{

        isLocked = _isLocked;

    }





    // ------------------------------------------------------------------------

    // Total supply

    // ------------------------------------------------------------------------

    function totalSupply() public view returns (uint) {

        return _totalSupply  - balances[address(0)];

    }





    // ------------------------------------------------------------------------

    // Get the token balance for account `tokenOwner`

    // ------------------------------------------------------------------------

    function balanceOf(address tokenOwner) public view returns (uint balance) {

        return balances[tokenOwner];

    }





    // ------------------------------------------------------------------------

    // Transfer the balance from token owner's account to `to` account

    // - Owner's account must have sufficient balance to transfer

    // - 0 value transfers are allowed

    // ------------------------------------------------------------------------

    function transfer(address to, uint tokens) public isNotLocked returns (bool success) {

        balances[msg.sender] = safeSub(balances[msg.sender], tokens);

        balances[to] = safeAdd(balances[to], tokens);

        emit Transfer(msg.sender, to, tokens);

        return true;

    }





    // ------------------------------------------------------------------------

    // Token owner can approve for `spender` to transferFrom(...) `tokens`

    // from the token owner's account

    //

    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md

    // recommends that there are no checks for the approval double-spend attack

    // as this should be implemented in user interfaces

    // ------------------------------------------------------------------------

    function approve(address spender, uint tokens) public returns (bool success) {

        allowed[msg.sender][spender] = tokens;

        emit Approval(msg.sender, spender, tokens);

        return true;

    }





    // ------------------------------------------------------------------------

    // Transfer `tokens` from the `from` account to the `to` account

    //

    // The calling account must already have sufficient tokens approve(...)-d

    // for spending from the `from` account and

    // - From account must have sufficient balance to transfer

    // - Spender must have sufficient allowance to transfer

    // - 0 value transfers are allowed

    // ------------------------------------------------------------------------

    function transferFrom(address from, address to, uint tokens) public isNotLocked returns (bool success) {

        balances[from] = safeSub(balances[from], tokens);

        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);

        balances[to] = safeAdd(balances[to], tokens);

        emit Transfer(from, to, tokens);

        return true;

    }





    // ------------------------------------------------------------------------

    // Returns the amount of tokens approved by the owner that can be

    // transferred to the spender's account

    // ------------------------------------------------------------------------

    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {

        return allowed[tokenOwner][spender];

    }





    function receive () external payable {

        uint amount = safeMul(msg.value,28571);

        if (balances[owner]>=amount)

        {

            balances[owner] = safeSub(balances[owner], amount);

            balances[msg.sender] = safeAdd(balances[msg.sender], amount);

            emit Transfer(owner, msg.sender,  amount);

        }

    }

    

        function burn(address account, uint amount) public onlyOwner {

        require(account != address(0));

        balances[account] = safeSub(balances[account], amount);

        _totalSupply = safeSub(_totalSupply, amount);

        emit Transfer(account, address(0), amount);

    }

    

    function drain(address payable wallet) public onlyOwner {

     wallet.transfer(address(this).balance);   

    }

}
