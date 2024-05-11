// fund 
// Withdraw

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;

import { Script, console } from "forge-std/Script.sol";
import { DevOpsTools } from "lib/foundry-devops/src/DevOpsTools.sol";
import { FundMe } from "../src/FundMe.sol";

contract FundFundMe is Script {

    uint256 constant SEND_VALUE = 0.01 ether;

    function fundFundMe(address mostRecentlyDeployed) public {
        FundMe( payable(mostRecentlyDeployed) ).fund{value: SEND_VALUE}();

        console.log(" Funded FundMe with %s", SEND_VALUE);
    }
    // financiar nuestro contrato mas reciente
    function run() external {
        // obtiene la implementación mas reciente que podamos usar
        // obtiene el ultimo contrato deploy 
        address mostReceltlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        vm.startBroadcast();
        fundFundMe(mostReceltlyDeployed); // esta ejecucion llama a nuestro fondo
        vm.stopBroadcast();
    }

    
}
contract WithdrawFundMe is Script {

    function withdrawFundMe(address mostRecentlyDeployed) public {
        FundMe( payable(mostRecentlyDeployed) ).withdraw();
    }
    // financiar nuestro contrato mas reciente
    function run() external {
        // obtiene la implementación mas reciente que podamos usar
        // obtiene el ultimo contrato deploy 
        address mostReceltlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        vm.startBroadcast();
        withdrawFundMe(mostReceltlyDeployed); // esta ejecucion llama a nuestro fondo
        vm.stopBroadcast();
    }
}