// 1 deploy mocks when we are on local ganache chain
// 2 keep track of contract address across different chains 
// Sepolia ETH/USD
// Mainnet ETH/USD

// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { Script } from "forge-std/Script.sol";
import { MockV3Aggregator } from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {

    // if we are on a local ganache , we deploy mocks
    // otherwise, grab the existing addres from the live networrk
    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed;
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = getOrCreateGanacheEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x3E64Cd889482443324F91bFA9c84fE72A511f48A
        });
        return sepoliaConfig;
    }

    function getOrCreateGanacheEthConfig() public returns (NetworkConfig memory) {
        // price feed address
        if (activeNetworkConfig.priceFeed != address(0)) { // check if we already exits activeNetworkConfig
            return activeNetworkConfig;
        }
        // 1. Deploy mocks
        // 2. Return the Mock address
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();

        NetworkConfig memory ganacheConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return ganacheConfig;
    }

}