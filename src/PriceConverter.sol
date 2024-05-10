// Price converter library

// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {

    function getPrice(AggregatorV3Interface priceFeed) internal view returns(uint256) {
        // prettier-ignore
        (
            /* uint80 roundID */,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        // price of eth in terms of USD
        // 2000.00000000
        return uint256(price * 1e10);
    }

    function getConversionRate(uint256 ethAmount, AggregatorV3Interface priceFeed) internal view returns (uint256){
        uint256 ethPrice = getPrice( priceFeed);
        uint256 ethAmountIntUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountIntUsd;
    }

}