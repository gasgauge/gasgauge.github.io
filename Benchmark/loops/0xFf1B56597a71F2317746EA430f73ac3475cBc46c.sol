/**

 *Submitted for verification at Etherscan.io on 2020-12-24

*/



//pragma solidity ^0.6.3;
pragma solidity >=0.5 <0.7.17;





interface AggregatorV3Interface {



  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);



  // getRoundData and latestRoundData should both raise "No data present"

  // if they do not have data to report, instead of returning unset values

  // which could be misinterpreted as actual reported values.

  function getRoundData(uint80 _roundId)

    external

    view

    returns (

      uint80 roundId,

      int256 answer,

      uint256 startedAt,

      uint256 updatedAt,

      uint80 answeredInRound

    );

  function latestRoundData()

    external

    view

    returns (

      uint80 roundId,

      int256 answer,

      uint256 startedAt,

      uint256 updatedAt,

      uint80 answeredInRound

    );

}



/** This example code is designed to quickly deploy an example contract using Remix.

 *  If you have never used Remix, try our example walkthrough: https://docs.chain.link/docs/example-walkthrough

 *  You will need testnet ETH and LINK.

 *     - Kovan ETH faucet: https://faucet.kovan.network/

 *     - Kovan LINK faucet: https://kovan.chain.link/

 */

contract PriceConsumerV3 {

    /**

     * Network: Kovan

     * Aggregator: ETH/USD

     * Address: 0x9326BFA02ADD2366b30bacB125260Af641031331

     */

    constructor() public {}



    /**

     * Returns the latest market price

     */

    function getLatestMarketPrice(address aggregatorAddr) public view returns (int) {

        require(aggregatorAddr != address(0), "Incorrect address");

        AggregatorV3Interface priceFeed = AggregatorV3Interface(aggregatorAddr);

        (

            uint80 roundID, 

            int price,

            uint startedAt,

            uint timeStamp,

            uint80 answeredInRound

        ) = priceFeed.latestRoundData();

        return price;

    }



    function priceOfBatch(address[] memory _aggregators) public view returns (int[] memory) {

        require(_aggregators.length > 0, "Should contain more than one aggregator address");

        // Variables

        int[] memory batchPrices = new int[](_aggregators.length);

        // Iterate over each owner and token ID

        for (uint256 i = 0; i < _aggregators.length; i++) {

            AggregatorV3Interface priceFeed = AggregatorV3Interface(_aggregators[i]);

            (

                uint80 roundID, 

                int price,

                uint startedAt,

                uint timeStamp,

                uint80 answeredInRound

            ) = priceFeed.latestRoundData();

            batchPrices[i] = price;

        }

        return batchPrices;

    }

}
