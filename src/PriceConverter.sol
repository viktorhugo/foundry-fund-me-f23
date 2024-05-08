// Price converter library

// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;
import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {

    function getPrice() internal view returns(uint256) {
        AggregatorV3Interface dataFeed = AggregatorV3Interface( 0x694AA1769357215DE4FAC081bf1f309aDC325306 );
        // prettier-ignore
        (
            /* uint80 roundID */,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        // price of eth in terms of USD
        // 2000.00000000
        return uint256(price * 1e10);
    }

    function getConversionRate(uint256 ethAmount) internal view returns (uint256){
        uint256 ethPrice = getPrice();
        uint256 ethAmountIntUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountIntUsd;
    }

}