/// ====================================================================
// TODAS LAS FORMAS EN LA QUE PODEMOS INTERACTUAR CON NUESTRO CONTRATO   
// Vamos a crear un script para fund 
// vamos a crear un script para Withdraw
/// ====================================================================

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;

import { Script, console } from "forge-std/Script.sol";
import { DevOpsTools } from "lib/foundry-devops/src/DevOpsTools.sol";
import { FundMe } from "../src/FundMe.sol";

contract FundFundMeInteraction is Script { // SCRIPT PARA FINANCIARME

    uint256 constant SEND_VALUE = 0.01 ether;

    // financiar nuestro contrato implementado el mas reciente
    function run() external {
        // obtiene la implementación de el ultimo contrato deployado mas reciente que podamos usar
        address contractAddresRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        console.log("contractAddresRecentlyDeployed", contractAddresRecentlyDeployed);
        
        vm.startBroadcast();
        fundFundMe(contractAddresRecentlyDeployed); // Ahora llamamos a nuestro fondo
        vm.stopBroadcast();
    }

    function fundFundMe(address contractAddresRecentlyDeployed) public {
        // vm.startBroadcast();
        FundMe( payable(contractAddresRecentlyDeployed) ).fund{value: SEND_VALUE}();
        console.log("### FundFundMeInteraction - fundFundMe - Funded with %s", SEND_VALUE);
    }
    
}
contract WithdrawFundMeInteraction is Script { // SCRIPT PARA RETIRAR FONDOS

    // financiar nuestro contrato mas reciente
    function run() external {
        // obtiene la implementación mas reciente que podamos usar
        // obtiene el ultimo contrato deploy 
        address mostReceltlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        vm.startBroadcast();
        withdrawFundMe(mostReceltlyDeployed); // esta ejecucion llama a nuestro fondo
        vm.stopBroadcast();
    }

    function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe( payable(mostRecentlyDeployed) ).withdraw();
        vm.stopBroadcast();
    }
}