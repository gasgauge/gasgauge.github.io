# Gas Gauge

Gas Gauge is designed to focus on gas-related vulnerabilities of Solidity Smart Contracts. This tool contains three major algorithms. The first part is a static analysis method that efficiently and accurately detects all the loops in a smart contract with the aid of Slither. We refer to this part as the Detection Phase of the tool. The second part is a static/runtime analysis whitebox fuzzer that identifies public functions containing at least one input variable that affects a loop inside the function. The reason is that unbounded loops are the leading cause of DoS with Block Gas Limit. Next, it finds a set of inputs to the function that causes the contract to go out of gas by running and fuzzing it. This part is referred to as the Identification Phase of the tool. The last algorithm uses static analysis and runtime verification to predict the maximum allowed loop bounds in a contract. It uses a binary search approach and an independent parallel processing design to speed up the process. This part automatically infers the maximum number of allowed iterations of loops in a contract before it runs out of gas. To run the contracts, Truffle Suite is used.

## Source Code

You can view our source code, benchmark, and experimental results as well as our case study on our [Github repository.](https://github.com/gasgauge/gasgauge.github.io)


## Installation and Setup for Ubuntu

### Prerequisite

```bash
$ sudo apt-get update
$ sudo apt-get install -y software-properties-common
$ sudo add-apt-repository -y ppa:ethereum/ethereum
$ sudo apt-get update
$ sudo apt-get install -y solc
$ sudo apt-get install libssl-dev
$ sudo apt-get install -y python3-pip=9.0.1-2 python3-dev
$ sudo ln -s /usr/bin/python3 /usr/local/bin/python
$ sudo apt-get install -y pandoc
$ sudo apt-get install -y git
$ sudo apt-get install nodejs
$ sudo apt-get install npm
$ sudo apt install python-pip
$ sudo apt install python3-pip
$ pip install numpy
$ pip3 install numpy

```

### Helper Tools:

### 1. [Slither](https://github.com/crytic/slither) : 
(Recommneded Method) Clone our repository and navigate to the folder "Slither"
```bash
$ sudo python3 setup.py install
```
Method 2:
```bash
$ pip3 install slither-analyzer
```
### 2. [Truffle](https://www.trufflesuite.com/) : 

```bash
$ npm install -g truffle
$ npm install -g ganache-cli
```
If the installation fails, it is most likely because Node.js is using an older version. Please update it to the newest version and try installing Truffle and Ganache again. 

### 3. [solc-select](https://github.com/crytic/solc-select) : 
```bash
$ pip3 install solc-select
```
Then install all the solc versions you need for your contracts (refer to the solc-select website)
For exaplme to install version 0.8.1:

```bash
$ solc-select install 0.8.1
```

### To run the tool:

1. Clone our repository
2. Modify run.py as needed
3. run run.py :

```bash
$ python3 run.py
```

4. The tool will generate a report in the file specified as "REPORT_PATH" in run.py




