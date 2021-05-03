/**
 *Submitted for verification at Etherscan.io on 2020-12-16
*/

//pragma solidity 0.6.12;
pragma solidity >=0.5 <0.7.17;
contract ERC20  {
	mapping(address => uint256) balances;

	mapping(address => mapping(address => uint256)) allowed;

	event Transfer(address _from, address _to, uint256 amount);

	event Approval(address _from, address _to, uint256 amount);

	string public name = "BiFi";

	uint8 public decimals = 18;

	string public symbol = "BiFi";

	uint256 public totalSupply;

	constructor () public
	{
		totalSupply = (10 ** 9) * (10 ** uint256(decimals));
		balances[msg.sender] = totalSupply;
	}

	function transfer(address _to, uint256 _value) public returns (bool)
	{
		if ((balances[msg.sender] >= _value) && (_value > 0))
		{
			balances[msg.sender] = balances[msg.sender] - _value;
			balances[_to] = balances[_to] + _value;
			emit Transfer(msg.sender, _to, _value);
			return true;
		}
		else
		{
			return false;
		}
	}

	function transferFrom(address _from, address _to, uint256 _value) public returns (bool)
	{
		if (((balances[_from] >= _value) && (allowed[_from][msg.sender] >= _value)) && (_value > 0))
		{
			balances[_to] = balances[_to] + _value;
			balances[_from] = balances[_from] - _value;
			allowed[_from][msg.sender] = allowed[_from][msg.sender] - _value;
			emit Transfer(_from, _to, _value);
			return true;
		}
		else
		{
			return false;
		}
	}

	function balanceOf(address _owner) public view returns (uint256)
	{
		return balances[_owner];
	}

	function approve(address _spender, uint256 _value) public returns (bool)
	{
		allowed[msg.sender][_spender] = _value;
		emit Approval(msg.sender, _spender, _value);
		return true;
	}

	function allowance(address _owner, address _spender) public view returns (uint256)
	{
		return allowed[_owner][_spender];
	}
}
