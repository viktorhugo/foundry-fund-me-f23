// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { Script } from "forge-std/Script.sol";
import { FundMe } from "../src/FundMe.sol";
import { HelperConfig } from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run () external returns(FundMe) {

        // Before start Broadcast >> Not a real transaction
        HelperConfig helperConfig = new HelperConfig();
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();

        // after start Broadcast >> Real transaction!
        vm.startBroadcast();
        // Mock
        FundMe fundMe = new FundMe(ethUsdPriceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}