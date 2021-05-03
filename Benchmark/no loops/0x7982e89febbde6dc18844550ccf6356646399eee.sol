/**

 *Submitted for verification at Etherscan.io on 2020-12-19

*/



//pragma solidity ^0.5.0;
pragma solidity >=0.5 <0.7.17;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a * b;

        assert(a == 0 || c / a == b);

        return c;

    }



    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        // assert(b > 0); // Solidity automatically throws when dividing by 0

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;

    }



    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);

        return a - b;

    }



    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        assert(c >= a);

        return c;

    }

}



contract ERC20 {

    uint256 public totalSupply;



    function balanceOf(address who) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);

    function allowance(address owner, address spender) public view returns (uint256);

    function transferFrom(address _from, address to, uint256 value) public returns (bool);



    event Approval(address indexed owner, address indexed spender, uint256 value);

    event Transfer(address indexed _from, address indexed to, uint256 value);

}



contract Ownable {

  address private _owner;



  event OwnershipTransferred(

    address indexed previousOwner,

    address indexed newOwner

  );



  constructor() internal {

    _owner = msg.sender;

    emit OwnershipTransferred(address(0), _owner);

  }



  function owner() public view returns(address) {

    return _owner;

  }



  modifier onlyOwner() {

    require(isOwner());

    _;

  }



  function isOwner() public view returns(bool) {

    return msg.sender == _owner;

  }



  function renounceOwnership() public onlyOwner {

    emit OwnershipTransferred(_owner, address(0));

    _owner = address(0);

  }



  function transferOwnership(address newOwner) public onlyOwner {

    _transferOwnership(newOwner);

  }



  function _transferOwnership(address newOwner) internal {

    require(newOwner != address(0));

    emit OwnershipTransferred(_owner, newOwner);

    _owner = newOwner;

  }

}

    

    

contract MonetaSales is Ownable {

    

    uint public startTime;

    uint public roundOneTime;

    uint public roundTwoTime;

    uint public roundThreeTime;

    

    // uint public roundOneSupply;

    // uint public roundTwoSupply;

    // uint public roundThreeSupply;

    

    

    

    struct Currency {

        uint currencyId;

        ERC20 currencyAddress;

        string currencyName;

        uint256 currencyPriceUSD;

        uint256 currencyPriceEUR;

        uint256 currencyPriceJPY;

        uint256 currencyPriceGBP;

        uint256 currencyPriceCNY;

        uint256 currencyPriceCHF;

        uint roundOneSupply;

        uint roundTwoSupply;

        uint roundThreeSupply;

        uint8 decimals;

    }

    

    mapping(uint => Currency) public currencies;



    event AddNewToken(uint currencyId, ERC20 tokenAddress, string tokenName);



    

    constructor (ERC20 _btc, ERC20 _eth, ERC20 _usdt, ERC20 _usdm, ERC20 _eurm, ERC20 _gbpm, ERC20 _jpy, ERC20 _cny, ERC20 _chf) public {

    

        addToken(_btc, "BTC", 8, 0, 0, 0, 0);

        addToken(_eth, "ETH", 18, 1, 0, 0, 0);

        addToken(_usdt, "USDT", 6, 2, 0, 0, 0);

        

        addToken(_usdm, "USDM", 6, 3, (400000 * 1e6), (800000 * 1e6), (1600000 * 1e6));

        addToken(_eurm, "EURM", 6, 4, (400000 * 1e6), (800000 * 1e6), (1600000 * 1e6));

        addToken(_gbpm, "GBPM", 6, 5, (400000 * 1e6), (800000 * 1e6), (1600000 * 1e6));

        

        addToken(_jpy, "JPYM", 6, 6, (40000000 * 1e6), (80000000 * 1e6), (160000000 * 1e6));

        addToken(_cny, "CNYM", 6, 7, (4000000 * 1e6), (8000000 * 1e6), (16000000 * 1e6));

        addToken(_chf, "CHFM", 6, 8, (400000 * 1e6), (800000 * 1e6), (1600000 * 1e6));

        

    

    

    }    

    

    function addToken(ERC20 _currencyAddress, string memory _currencyName, uint8 _decimals, uint _tokenCount, uint256 _roundOneSupply, uint256 _roundTwoSupply, uint256 _roundThreeSupply) internal returns(bool) {

        

        currencies[_tokenCount].currencyId = _tokenCount;

        currencies[_tokenCount].currencyAddress = _currencyAddress;

        currencies[_tokenCount].currencyName = _currencyName;

        currencies[_tokenCount].decimals = _decimals;

        currencies[_tokenCount].roundOneSupply = _roundOneSupply;

        currencies[_tokenCount].roundTwoSupply = _roundTwoSupply;

        currencies[_tokenCount].roundThreeSupply = _roundThreeSupply;

        

        emit AddNewToken(currencies[_tokenCount].currencyId, currencies[_tokenCount].currencyAddress, currencies[_tokenCount].currencyName);

        return true;

    }

    

    function setBtcPrice(uint256 _usd, uint256 _eur, uint256 _jpy, uint256 _gbp, uint256 _cny, uint256 _chf) public onlyOwner returns(bool) {

        

        currencies[0].currencyPriceUSD = _usd * 1e2;

        currencies[0].currencyPriceEUR = _eur * 1e2;

        currencies[0].currencyPriceJPY = _jpy * 1e2;

        currencies[0].currencyPriceGBP = _gbp * 1e2;

        currencies[0].currencyPriceCNY = _cny * 1e2;

        currencies[0].currencyPriceCHF = _chf * 1e2;

            

        return true;

    }

    

    function setEthPrice(uint256 _usd, uint256 _eur, uint256 _jpy, uint256 _gbp, uint256 _cny, uint256 _chf) public onlyOwner returns(bool) {

        

        currencies[1].currencyPriceUSD = _usd * 1e2;

        currencies[1].currencyPriceEUR = _eur * 1e2;

        currencies[1].currencyPriceJPY = _jpy * 1e2;

        currencies[1].currencyPriceGBP = _gbp * 1e2;

        currencies[1].currencyPriceCNY = _cny * 1e2;

        currencies[1].currencyPriceCHF = _chf * 1e2;

            

        return true;

    }

    

    function setUsdtPrice(uint256 _usd, uint256 _eur, uint256 _jpy, uint256 _gbp, uint256 _cny, uint256 _chf) public onlyOwner returns(bool) {

        

        currencies[2].currencyPriceUSD = _usd;

        currencies[2].currencyPriceEUR = _eur;

        currencies[2].currencyPriceJPY = _jpy;

        currencies[2].currencyPriceGBP = _gbp;

        currencies[2].currencyPriceCNY = _cny;

        currencies[2].currencyPriceCHF = _chf;

            

        return true;

    }

    

    function purchaseTokens(ERC20 _currencyIn, ERC20 _currencyOut, uint256 _amountIn) public {

        

        require(_currencyIn == currencies[0].currencyAddress || _currencyIn == currencies[1].currencyAddress ||_currencyIn == currencies[2].currencyAddress, "Invalid Currency to buy tokens with");

        require(_currencyOut == currencies[3].currencyAddress || _currencyOut == currencies[4].currencyAddress ||

        _currencyOut == currencies[5].currencyAddress ||_currencyOut == currencies[6].currencyAddress

        ||_currencyOut == currencies[7].currencyAddress ||_currencyOut == currencies[8].currencyAddress, "Invalid Currency to buy");

        

        uint256 _now = block.timestamp;

        uint256 bonusAmount;



       _currencyIn.transferFrom(msg.sender, address(this), _amountIn);

        

         // BTC CONFIGS WITH OTHER CURRENCIES

        if(_currencyIn == currencies[0].currencyAddress) {

             bonusAmount = _btcConfigs(_currencyOut, _amountIn, _now, bonusAmount);

        }

        

         // ETH CONFIGS WITH OTHER CURRENCIES

        else if (_currencyIn == currencies[1].currencyAddress) {

            bonusAmount = _ethConfigs(_currencyOut, _amountIn, _now, bonusAmount);



        }

        

        // // USDT CONFIGS WITH OTHER CURRENCIES

        else if (_currencyIn == currencies[2].currencyAddress) {

          bonusAmount = _usdtConfigs(_currencyOut, _amountIn, _now, bonusAmount);

        }

        _currencyOut.transfer(msg.sender, bonusAmount);

    }

    

    

    function _checkSaleTime(uint256 _now) internal view returns(uint56) {

        if(_now > startTime && _now < roundOneTime) {

            return 1;

        } else if(_now > roundOneTime && _now < roundTwoTime) {

            return 2;

        } else if(_now > roundTwoTime && _now <= roundThreeTime) {

            return 3;

        } else return 0;

        

    }

    

    function _usdtConfigs(ERC20 _currencyOut ,uint256 _amountIn , uint256 _now , uint256 bonusAmount) internal returns(uint256) {

          if (_currencyOut == currencies[3].currencyAddress) {

            

            if(_checkSaleTime(_now) == 1) {

                  bonusAmount = (((_amountIn * currencies[2].currencyPriceUSD) / 1e2) * 65) / 100;

                  currencies[3].roundOneSupply -= bonusAmount;

                  

            }  else if (_checkSaleTime(_now) == 2 ) {

               

                 currencies[3].roundTwoSupply += currencies[3].roundOneSupply;

                 currencies[3].roundOneSupply = 0;

                 

                 bonusAmount = (((_amountIn * currencies[2].currencyPriceUSD) / 1e2) * 45) / 100;

                 

                 currencies[3].roundTwoSupply -= bonusAmount;



             } else if (_checkSaleTime(_now) == 3) {



                 currencies[3].roundThreeSupply += currencies[3].roundTwoSupply;

                 currencies[3].roundTwoSupply = 0;



                 bonusAmount = (((_amountIn * currencies[2].currencyPriceUSD) / 1e2) * 25) / 100;

                 

                 currencies[3].roundThreeSupply -= bonusAmount;



             } else {

                    currencies[3].roundThreeSupply = currencies[3].roundThreeSupply+ currencies[3].roundTwoSupply + currencies[3].roundOneSupply;



                    bonusAmount = (((_amountIn * currencies[2].currencyPriceUSD) / 1e2));

                    

                    currencies[3].roundThreeSupply -= bonusAmount;

             } 

            

        } else if( _currencyOut == currencies[4].currencyAddress) {

            

              if(_checkSaleTime(_now) == 1) {

                  bonusAmount = (((_amountIn * currencies[2].currencyPriceEUR) / 1e2) * 65) / 100;

                  currencies[4].roundOneSupply -= bonusAmount;

                  

            }  else if (_checkSaleTime(_now) == 2 ) {

               

                 currencies[4].roundTwoSupply += currencies[4].roundOneSupply;

                 currencies[4].roundOneSupply = 0;

                 

                 bonusAmount = (((_amountIn * currencies[2].currencyPriceEUR) / 1e2) * 45) / 100;

                 

                 currencies[4].roundTwoSupply -= bonusAmount;



             } else if (_checkSaleTime(_now) == 3) {



                 currencies[4].roundThreeSupply += currencies[4].roundTwoSupply;

                 currencies[4].roundTwoSupply = 0;



                 bonusAmount = (((_amountIn * currencies[2].currencyPriceEUR) / 1e2) * 25) / 100;

                 

                 currencies[4].roundThreeSupply -= bonusAmount;



             } else {

                    currencies[4].roundThreeSupply = currencies[4].roundThreeSupply+ currencies[4].roundTwoSupply + currencies[4].roundOneSupply;



                    bonusAmount = (((_amountIn * currencies[2].currencyPriceEUR) / 1e2));

                    

                    currencies[4].roundThreeSupply -= bonusAmount;

             } 

            

        } else if(_currencyOut == currencies[5].currencyAddress) {

            



             if(_checkSaleTime(_now) == 1) {

                  bonusAmount = (((_amountIn * currencies[2].currencyPriceGBP) / 1e2) * 65) / 100;

                  currencies[5].roundOneSupply -= bonusAmount;

                  

            }  else if (_checkSaleTime(_now) == 2 ) {

               

                 currencies[5].roundTwoSupply += currencies[5].roundOneSupply;

                 currencies[5].roundOneSupply = 0;

                 

                 bonusAmount = (((_amountIn * currencies[2].currencyPriceGBP) / 1e2) * 45) / 100;

                 

                 currencies[5].roundTwoSupply -= bonusAmount;



             } else if (_checkSaleTime(_now) == 3) {



                 currencies[5].roundThreeSupply += currencies[5].roundTwoSupply;

                 currencies[5].roundTwoSupply = 0;



                 bonusAmount = (((_amountIn * currencies[2].currencyPriceGBP) / 1e2) * 25) / 100;

                 

                 currencies[5].roundThreeSupply -= bonusAmount;



             } else {

                    currencies[5].roundThreeSupply = currencies[5].roundThreeSupply+ currencies[5].roundTwoSupply + currencies[5].roundOneSupply;



                    bonusAmount = (((_amountIn * currencies[2].currencyPriceGBP) / 1e2));

                    

                    currencies[5].roundThreeSupply -= bonusAmount;

             } 

            

        } else if(_currencyOut == currencies[6].currencyAddress) {

            

             if(_checkSaleTime(_now) == 1) {

                  bonusAmount = (((_amountIn * currencies[2].currencyPriceJPY) / 1e2) * 65) / 100;

                  currencies[6].roundOneSupply -= bonusAmount;

                  

            }  else if (_checkSaleTime(_now) == 2 ) {

               

                 currencies[6].roundTwoSupply += currencies[6].roundOneSupply;

                 currencies[6].roundOneSupply = 0;

                 

                 bonusAmount = (((_amountIn * currencies[2].currencyPriceJPY) / 1e2) * 45) / 100;

                 

                 currencies[6].roundTwoSupply -= bonusAmount;



             } else if (_checkSaleTime(_now) == 3) {



                 currencies[6].roundThreeSupply += currencies[6].roundTwoSupply;

                 currencies[6].roundTwoSupply = 0;



                 bonusAmount = (((_amountIn * currencies[2].currencyPriceJPY) / 1e2) * 25) / 100;

                 

                 currencies[6].roundThreeSupply -= bonusAmount;



             } else {

                    currencies[6].roundThreeSupply = currencies[6].roundThreeSupply+ currencies[6].roundTwoSupply + currencies[6].roundOneSupply;



                    bonusAmount = (((_amountIn * currencies[2].currencyPriceJPY) / 1e2));

                    

                    currencies[6].roundThreeSupply -= bonusAmount;

             } 

            

        } else if( _currencyOut == currencies[7].currencyAddress) {

            

              if(_checkSaleTime(_now) == 1) {

                  bonusAmount = (((_amountIn * currencies[2].currencyPriceCNY) / 1e2) * 65) / 100;

                  currencies[7].roundOneSupply -= bonusAmount;

                  

            }  else if (_checkSaleTime(_now) == 2 ) {

               

                 currencies[7].roundTwoSupply += currencies[7].roundOneSupply;

                 currencies[6].roundOneSupply = 0;

                 

                 bonusAmount = (((_amountIn * currencies[2].currencyPriceCNY) / 1e2) * 45) / 100;

                 

                 currencies[7].roundTwoSupply -= bonusAmount;



             } else if (_checkSaleTime(_now) == 3) {



                 currencies[7].roundThreeSupply += currencies[7].roundTwoSupply;

                 currencies[7].roundTwoSupply = 0;



                 bonusAmount = (((_amountIn * currencies[2].currencyPriceCNY) / 1e2) * 25) / 100;

                 

                 currencies[7].roundThreeSupply -= bonusAmount;



             } else {

                    currencies[7].roundThreeSupply = currencies[7].roundThreeSupply+ currencies[7].roundTwoSupply + currencies[7].roundOneSupply;



                    bonusAmount = (((_amountIn * currencies[2].currencyPriceCNY) / 1e2));

                    

                    currencies[7].roundThreeSupply -= bonusAmount;

             } 

        } else if(_currencyOut == currencies[8].currencyAddress) {

            

             if(_checkSaleTime(_now) == 1) {

                  bonusAmount = (((_amountIn * currencies[2].currencyPriceCHF) / 1e2) * 65) / 100;

                  currencies[8].roundOneSupply -= bonusAmount;

                  

            }  else if (_checkSaleTime(_now) == 2 ) {

               

                 currencies[8].roundTwoSupply += currencies[8].roundOneSupply;

                 currencies[8].roundOneSupply = 0;

                 

                 bonusAmount = (((_amountIn * currencies[2].currencyPriceCHF) / 1e2) * 45) / 100;

                 

                 currencies[8].roundTwoSupply -= bonusAmount;



             } else if (_checkSaleTime(_now) == 3) {



                 currencies[8].roundThreeSupply += currencies[8].roundTwoSupply;

                 currencies[8].roundTwoSupply = 0;



                 bonusAmount = (((_amountIn * currencies[2].currencyPriceCHF) / 1e2) * 25) / 100;

                 

                 currencies[8].roundThreeSupply -= bonusAmount;



             } else {

                    currencies[8].roundThreeSupply = currencies[8].roundThreeSupply+ currencies[8].roundTwoSupply + currencies[8].roundOneSupply;



                    bonusAmount = (((_amountIn * currencies[2].currencyPriceCHF) / 1e2));

                    

                    currencies[8].roundThreeSupply -= bonusAmount;

             } 

        }

        

        return bonusAmount;

        

    }

    

    function _ethConfigs(ERC20 _currencyOut ,uint256 _amountIn , uint256 _now , uint256 bonusAmount) internal returns (uint256) {

        if (_currencyOut == currencies[3].currencyAddress) {

           if(_checkSaleTime(_now) == 1) {

                  bonusAmount = (((_amountIn * currencies[1].currencyPriceUSD) / 1e14) * 65) / 100;

                  currencies[3].roundOneSupply -= bonusAmount;

                  

            }  else if (_checkSaleTime(_now) == 2 ) {

               

                 currencies[3].roundTwoSupply += currencies[3].roundOneSupply;

                 currencies[3].roundOneSupply = 0;

                 

                 bonusAmount = (((_amountIn * currencies[1].currencyPriceUSD) / 1e14) * 45) / 100;

                 

                 currencies[3].roundTwoSupply -= bonusAmount;



             } else if (_checkSaleTime(_now) == 3) {



                 currencies[3].roundThreeSupply += currencies[3].roundTwoSupply;

                 currencies[3].roundTwoSupply = 0;



                 bonusAmount = (((_amountIn * currencies[1].currencyPriceUSD) / 1e14) * 25) / 100;

                 

                 currencies[3].roundThreeSupply -= bonusAmount;



             } else {

                    currencies[3].roundThreeSupply = currencies[3].roundThreeSupply+ currencies[3].roundTwoSupply + currencies[3].roundOneSupply;



                    bonusAmount = (((_amountIn * currencies[1].currencyPriceUSD) / 1e14));

                    

                    currencies[3].roundThreeSupply -= bonusAmount;

             } 

            

        } else if(_currencyOut == currencies[4].currencyAddress) {

            

             if(_checkSaleTime(_now) == 1) {

                  bonusAmount = (((_amountIn * currencies[1].currencyPriceEUR) / 1e14) * 65) / 100;

                  currencies[4].roundOneSupply -= bonusAmount;

                  

            }  else if (_checkSaleTime(_now) == 2 ) {

               

                 currencies[4].roundTwoSupply += currencies[4].roundOneSupply;

                 currencies[4].roundOneSupply = 0;

                 

                 bonusAmount = (((_amountIn * currencies[1].currencyPriceEUR) / 1e14) * 45) / 100;

                 

                 currencies[4].roundTwoSupply -= bonusAmount;



             } else if (_checkSaleTime(_now) == 3) {



                 currencies[4].roundThreeSupply += currencies[4].roundTwoSupply;

                 currencies[4].roundTwoSupply = 0;



                 bonusAmount = (((_amountIn * currencies[1].currencyPriceEUR) / 1e14) * 25) / 100;

                 

                 currencies[4].roundThreeSupply -= bonusAmount;



             } else {

                    currencies[4].roundThreeSupply = currencies[4].roundThreeSupply+ currencies[4].roundTwoSupply + currencies[4].roundOneSupply;



                    bonusAmount = (((_amountIn * currencies[1].currencyPriceEUR) / 1e14));

                    

                    currencies[4].roundThreeSupply -= bonusAmount;

             } 

            

        } else if(_currencyOut == currencies[5].currencyAddress) {

            



               if(_checkSaleTime(_now) == 1) {

                  bonusAmount = (((_amountIn * currencies[1].currencyPriceGBP) / 1e14) * 65) / 100;

                  currencies[5].roundOneSupply -= bonusAmount;

                  

            }  else if (_checkSaleTime(_now) == 2 ) {

               

                 currencies[5].roundTwoSupply += currencies[5].roundOneSupply;

                 currencies[5].roundOneSupply = 0;

                 

                 bonusAmount = (((_amountIn * currencies[1].currencyPriceGBP) / 1e14) * 45) / 100;

                 

                 currencies[5].roundTwoSupply -= bonusAmount;



             } else if (_checkSaleTime(_now) == 3) {



                 currencies[5].roundThreeSupply += currencies[5].roundTwoSupply;

                 currencies[5].roundTwoSupply = 0;



                 bonusAmount = (((_amountIn * currencies[1].currencyPriceGBP) / 1e14) * 25) / 100;

                 

                 currencies[5].roundThreeSupply -= bonusAmount;



             } else {

                    currencies[5].roundThreeSupply = currencies[5].roundThreeSupply+ currencies[5].roundTwoSupply + currencies[5].roundOneSupply;



                    bonusAmount = (((_amountIn * currencies[1].currencyPriceGBP) / 1e14));

                    

                    currencies[5].roundThreeSupply -= bonusAmount;

             }

            

        } else if(_currencyOut == currencies[6].currencyAddress) {

              if(_checkSaleTime(_now) == 1) {

                  bonusAmount = (((_amountIn * currencies[1].currencyPriceJPY) / 1e14) * 65) / 100;

                  currencies[6].roundOneSupply -= bonusAmount;

                  

            }  else if (_checkSaleTime(_now) == 2 ) {

               

                 currencies[6].roundTwoSupply += currencies[6].roundOneSupply;

                 currencies[6].roundOneSupply = 0;

                 

                 bonusAmount = (((_amountIn * currencies[1].currencyPriceJPY) / 1e14) * 45) / 100;

                 

                 currencies[6].roundTwoSupply -= bonusAmount;



             } else if (_checkSaleTime(_now) == 3) {



                 currencies[6].roundThreeSupply += currencies[6].roundTwoSupply;

                 currencies[6].roundTwoSupply = 0;



                 bonusAmount = (((_amountIn * currencies[1].currencyPriceJPY) / 1e14) * 25) / 100;

                 

                 currencies[6].roundThreeSupply -= bonusAmount;



             } else {

                    currencies[6].roundThreeSupply = currencies[6].roundThreeSupply+ currencies[6].roundTwoSupply + currencies[6].roundOneSupply;



                    bonusAmount = (((_amountIn * currencies[1].currencyPriceJPY) / 1e14));

                    

                    currencies[6].roundThreeSupply -= bonusAmount;

             } 

        } else if(_currencyOut == currencies[7].currencyAddress) {

            

              if(_checkSaleTime(_now) == 1) {

                  bonusAmount = (((_amountIn * currencies[1].currencyPriceCNY) / 1e14) * 65) / 100;

                  currencies[7].roundOneSupply -= bonusAmount;

                  

            }  else if (_checkSaleTime(_now) == 2 ) {

               

                 currencies[7].roundTwoSupply += currencies[7].roundOneSupply;

                 currencies[7].roundOneSupply = 0;

                 

                 bonusAmount = (((_amountIn * currencies[1].currencyPriceCNY) / 1e14) * 45) / 100;

                 

                 currencies[7].roundTwoSupply -= bonusAmount;



             } else if (_checkSaleTime(_now) == 3) {



                 currencies[7].roundThreeSupply += currencies[7].roundTwoSupply;

                 currencies[7].roundTwoSupply = 0;



                 bonusAmount = (((_amountIn * currencies[1].currencyPriceCNY) / 1e14) * 25) / 100;

                 

                 currencies[7].roundThreeSupply -= bonusAmount;



             } else {

                    currencies[7].roundThreeSupply = currencies[7].roundThreeSupply+ currencies[7].roundTwoSupply + currencies[7].roundOneSupply;



                    bonusAmount = (((_amountIn * currencies[1].currencyPriceCNY) / 1e14));

                    

                    currencies[7].roundThreeSupply -= bonusAmount;

             } 

            

        } else if(_currencyOut == currencies[8].currencyAddress) {

        

              if(_checkSaleTime(_now) == 1) {

                  bonusAmount = (((_amountIn * currencies[1].currencyPriceCHF) / 1e14) * 65) / 100;

                  currencies[8].roundOneSupply -= bonusAmount;

                  

            }  else if (_checkSaleTime(_now) == 2 ) {

               

                 currencies[8].roundTwoSupply += currencies[8].roundOneSupply;

                 currencies[8].roundOneSupply = 0;

                 

                 bonusAmount = (((_amountIn * currencies[1].currencyPriceCHF) / 1e14) * 45) / 100;

                 

                 currencies[8].roundTwoSupply -= bonusAmount;



             } else if (_checkSaleTime(_now) == 3) {



                 currencies[8].roundThreeSupply += currencies[8].roundTwoSupply;

                 currencies[8].roundTwoSupply = 0;



                 bonusAmount = (((_amountIn * currencies[1].currencyPriceCHF) / 1e14) * 25) / 100;

                 

                 currencies[8].roundThreeSupply -= bonusAmount;



             } else {

                    currencies[8].roundThreeSupply = currencies[8].roundThreeSupply+ currencies[8].roundTwoSupply + currencies[8].roundOneSupply;



                    bonusAmount = (((_amountIn * currencies[1].currencyPriceCHF) / 1e14));

                    

                    currencies[8].roundThreeSupply -= bonusAmount;

             } 

            

        }

        

        return bonusAmount;

    }

    

    function _btcConfigs(ERC20 _currencyOut ,uint256 _amountIn , uint256 _now , uint256 bonusAmount) internal returns (uint256) {

        if(_currencyOut == currencies[3].currencyAddress) {

           

            if(_checkSaleTime(_now) == 1) {

                  bonusAmount = (((_amountIn * currencies[0].currencyPriceUSD) / 1e4) * 65) / 100;

                  currencies[3].roundOneSupply -= bonusAmount;

                  

            }  else if (_checkSaleTime(_now) == 2 ) {

               

                 currencies[3].roundTwoSupply += currencies[3].roundOneSupply;

                 currencies[3].roundOneSupply = 0;

                 

                 bonusAmount = (((_amountIn * currencies[0].currencyPriceUSD) / 1e4) * 45) / 100;

                 

                 currencies[3].roundTwoSupply -= bonusAmount;



             } else if (_checkSaleTime(_now) == 3) {



                 currencies[3].roundThreeSupply += currencies[3].roundTwoSupply;

                 currencies[3].roundTwoSupply = 0;



                 bonusAmount = (((_amountIn * currencies[0].currencyPriceUSD) / 1e4) * 25) / 100;

                 

                 currencies[3].roundThreeSupply -= bonusAmount;



             } else {

                    currencies[3].roundThreeSupply = currencies[3].roundThreeSupply+ currencies[3].roundTwoSupply + currencies[3].roundOneSupply;



                    bonusAmount = (((_amountIn * currencies[0].currencyPriceUSD) / 1e4));

                    

                    currencies[3].roundThreeSupply -= bonusAmount;

             }

             

            

            

        } else if(_currencyOut == currencies[4].currencyAddress) {

        

            if(_checkSaleTime(_now) == 1) {

                  bonusAmount = (((_amountIn * currencies[0].currencyPriceEUR) / 1e4) * 65) / 100;

                  currencies[4].roundOneSupply -= bonusAmount;

                  

             }  else if (_checkSaleTime(_now) == 2 ) {

               

                 currencies[4].roundTwoSupply += currencies[4].roundOneSupply;

                 currencies[4].roundOneSupply = 0;

                 

                 bonusAmount = (((_amountIn * currencies[0].currencyPriceEUR) / 1e4) * 45) / 100;

                 

                 currencies[3].roundTwoSupply -= bonusAmount;



             } else if (_checkSaleTime(_now) == 3) {



                 currencies[4].roundThreeSupply += currencies[4].roundTwoSupply;

                 currencies[4].roundTwoSupply = 0;



                 bonusAmount = (((_amountIn * currencies[0].currencyPriceEUR) / 1e4) * 25) / 100;

                 

                 currencies[4].roundThreeSupply -= bonusAmount;



             } else {

                    currencies[4].roundThreeSupply = currencies[4].roundThreeSupply+ currencies[4].roundTwoSupply + currencies[4].roundOneSupply;



                    bonusAmount = (((_amountIn * currencies[0].currencyPriceEUR) / 1e4));

                    

                    currencies[4].roundThreeSupply -= bonusAmount;

             }

             

            

        } else if(_currencyOut == currencies[5].currencyAddress) {

          

             if(_checkSaleTime(_now) == 1) {

                  bonusAmount = (((_amountIn * currencies[0].currencyPriceGBP) / 1e4) * 65) / 100;

                  currencies[5].roundOneSupply -= bonusAmount;

                  

             }  else if (_checkSaleTime(_now) == 2 ) {

               

                 currencies[5].roundTwoSupply += currencies[5].roundOneSupply;

                 currencies[5].roundOneSupply = 0;

                 

                 bonusAmount = (((_amountIn * currencies[0].currencyPriceGBP) / 1e4) * 45) / 100;

                 

                 currencies[5].roundTwoSupply -= bonusAmount;



             } else if (_checkSaleTime(_now) == 3) {



                 currencies[5].roundThreeSupply += currencies[5].roundTwoSupply;

                 currencies[5].roundTwoSupply = 0;



                 bonusAmount = (((_amountIn * currencies[0].currencyPriceGBP) / 1e4) * 25) / 100;

                 

                 currencies[5].roundThreeSupply -= bonusAmount;



             } else {

                    currencies[5].roundThreeSupply = currencies[5].roundThreeSupply+ currencies[5].roundTwoSupply + currencies[5].roundOneSupply;



                    bonusAmount = (((_amountIn * currencies[0].currencyPriceGBP) / 1e4));

                    

                    currencies[5].roundThreeSupply -= bonusAmount;

             }

            

        } else if( _currencyOut == currencies[6].currencyAddress) {

            

             

             if(_checkSaleTime(_now) == 1) {

                  bonusAmount = (((_amountIn * currencies[0].currencyPriceJPY) / 1e4) * 65) / 100;

                  currencies[6].roundOneSupply -= bonusAmount;

                  

             }  else if (_checkSaleTime(_now) == 2 ) {

               

                 currencies[6].roundTwoSupply += currencies[6].roundOneSupply;

                 currencies[6].roundOneSupply = 0;

                 

                 bonusAmount = (((_amountIn * currencies[0].currencyPriceJPY) / 1e4) * 45) / 100;

                 

                 currencies[6].roundTwoSupply -= bonusAmount;



             } else if (_checkSaleTime(_now) == 3) {



                 currencies[6].roundThreeSupply += currencies[6].roundTwoSupply;

                 currencies[6].roundTwoSupply = 0;



                 bonusAmount = (((_amountIn * currencies[0].currencyPriceJPY) / 1e4) * 25) / 100;

                 

                 currencies[6].roundThreeSupply -= bonusAmount;



             } else {

                    currencies[6].roundThreeSupply = currencies[6].roundThreeSupply+ currencies[6].roundTwoSupply + currencies[6].roundOneSupply;



                    bonusAmount = (((_amountIn * currencies[0].currencyPriceJPY) / 1e4));

                    

                    currencies[6].roundThreeSupply -= bonusAmount;

             }

            

        } else if( _currencyOut == currencies[7].currencyAddress) {

            

              if(_checkSaleTime(_now) == 1) {

                  bonusAmount = (((_amountIn * currencies[0].currencyPriceCNY) / 1e4) * 65) / 100;

                  currencies[7].roundOneSupply -= bonusAmount;

                  

             }  else if (_checkSaleTime(_now) == 2 ) {

               

                 currencies[7].roundTwoSupply += currencies[7].roundOneSupply;

                 currencies[7].roundOneSupply = 0;

                 

                 bonusAmount = (((_amountIn * currencies[0].currencyPriceCNY) / 1e4) * 45) / 100;

                 

                 currencies[7].roundTwoSupply -= bonusAmount;



             } else if (_checkSaleTime(_now) == 3) {



                 currencies[7].roundThreeSupply += currencies[7].roundTwoSupply;

                 currencies[7].roundTwoSupply = 0;



                 bonusAmount = (((_amountIn * currencies[0].currencyPriceCNY) / 1e4) * 25) / 100;

                 

                 currencies[7].roundThreeSupply -= bonusAmount;



             } else {

                    currencies[7].roundThreeSupply = currencies[7].roundThreeSupply+ currencies[7].roundTwoSupply + currencies[7].roundOneSupply;



                    bonusAmount = (((_amountIn * currencies[0].currencyPriceCNY) / 1e4));

                    

                    currencies[7].roundThreeSupply -= bonusAmount;

             }

            

        } else if(_currencyOut == currencies[8].currencyAddress) {

            

              if(_checkSaleTime(_now) == 1) {

                  bonusAmount = (((_amountIn * currencies[0].currencyPriceCHF) / 1e4) * 65) / 100;

                  currencies[8].roundOneSupply -= bonusAmount;

                  

             }  else if (_checkSaleTime(_now) == 2 ) {

               

                 currencies[8].roundTwoSupply += currencies[8].roundOneSupply;

                 currencies[8].roundOneSupply = 0;

                 

                 bonusAmount = (((_amountIn * currencies[0].currencyPriceCHF) / 1e4) * 45) / 100;

                 

                 currencies[8].roundTwoSupply -= bonusAmount;



             } else if (_checkSaleTime(_now) == 3) {



                 currencies[8].roundThreeSupply += currencies[8].roundTwoSupply;

                 currencies[8].roundTwoSupply = 0;



                 bonusAmount = (((_amountIn * currencies[0].currencyPriceCHF) / 1e4) * 25) / 100;

                 

                 currencies[8].roundThreeSupply -= bonusAmount;



             } else {

                    currencies[8].roundThreeSupply = currencies[8].roundThreeSupply+ currencies[8].roundTwoSupply + currencies[8].roundOneSupply;



                    bonusAmount = (((_amountIn * currencies[0].currencyPriceCHF) / 1e4));

                    

                    currencies[8].roundThreeSupply -= bonusAmount;

             }

            

        }

        

        return bonusAmount;

    }

   

    function exitSwappedLiquidity(ERC20 _withdrawToken, uint256 _tokens) public onlyOwner returns (bool success) {

        

        _withdrawToken.transfer(msg.sender, _tokens);

        

        return true;

    }

    

    function setStartTime(uint256 _newStartTime) public onlyOwner {

        startTime = _newStartTime; 

        roundOneTime = startTime + 60 days;

        roundTwoTime = roundOneTime + 60 days;

        roundThreeTime = roundTwoTime + 60 days;

        

    }

}
