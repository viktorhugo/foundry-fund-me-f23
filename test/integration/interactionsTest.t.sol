// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { Test, console }  from "forge-std/Test.sol";
import { FundMe } from "../../src/FundMe.sol";
import { DeployFundMe } from "../../script/DeployFundMe.s.sol";
import { FundFundMeInteraction, WithdrawFundMeInteraction } from "../../script/Interactions.s.sol";

contract InteractionsTest is Test { 
    
    FundMe fundMe;
    address USER = makeAddr("user"); // fake USER
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe  = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE); // add balance to  fake USER
        console.log("STARTING_USER", USER);
    }

    function testUserCanFundInteractions() public {
        // financiar nuestro contrato implementado el mas reciente
        FundFundMeInteraction fundFundMeInteraction = new FundFundMeInteraction();
        vm.prank(USER);
        vm.deal(USER, 1e18);
        fundFundMeInteraction.fundFundMe(address( fundMe ));

        // retirar los fondos
        WithdrawFundMeInteraction withdrawFundMeInteraction = new WithdrawFundMeInteraction();
        withdrawFundMeInteraction.withdrawFundMe(address( fundMe ));

        address funder = fundMe.getFunder(0); // obtiene el primer funder
        assertEq(funder, USER);
    }
}