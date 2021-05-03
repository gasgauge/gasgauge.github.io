//SPDX-License-Identifier: Unlicense
//pragma solidity ^0.7.0;
pragma solidity >=0.5 <0.7.17;


contract Greeter {
    string public greeting;

    event GreetingChanged(string from, string to);

    constructor(string memory _greeting) public {
        greeting = _greeting;

        emit GreetingChanged("", greeting);
    }

    function greet() public view returns (string memory) {
        return greeting;
    }

    function setGreeting(string memory _greeting) public {
        emit GreetingChanged(greeting, _greeting);

        greeting = _greeting;
    }
}
