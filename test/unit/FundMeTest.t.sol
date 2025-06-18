// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { Test, console }  from "forge-std/Test.sol";
import { FundMe } from "../../src/FundMe.sol";
import { DeployFundMe } from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    
    FundMe fundMe;
    address USER = makeAddr("user"); // fake USER
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;
    
    // siempre se va ejecutar primeramente la function setUp
    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe  = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE); // add balance to  fake USER
        console.log("STARTING_BALANCE", STARTING_BALANCE);
        console.log("STARTING_USER", USER);
    }

    // = Modifier =
    modifier funded() {
        vm.prank(USER); // fake user
        console.log('FUNDED_PRANK_USER', USER, fundMe.getOwner(), address(this));
        fundMe.fund{ value: SEND_VALUE }();// financiar con algo de "ether"(envio a la fund account)
        _;
    }


    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5 * 1e18);
        console.log("Finished TestMinimumDollarIsFive");
    }

    function testOwnerIsMsgSender() public view {
        console.log("getOwner", fundMe.getOwner());
        console.log("msg.sender", msg.sender);
        console.log("address(this)", address(this));
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testVersionIsAccurate() public view {
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundFailWithouthEnoughETH() public payable {
        vm.expectRevert("You need to send more ETH"); // en la siguiente linea se deberia revertir
        // assert(this tx fails/reverts)
        fundMe.fund(); // send 0 ETH
    }

    function testFundUpdateFundedDataStructure() public {
        vm.prank(USER); // The netx TX will be sent by USER
        fundMe.fund{ value: SEND_VALUE }();
        vm.stopPrank();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public {
        // nos vamos a asegurar que el funder que acabamos de crear funcione
        vm.prank(USER); // The netx TX will be sent by USER
        fundMe.fund{ value: SEND_VALUE }(); //financiar con algo de "ether"
        vm.stopPrank();
        // solo tenemos un funder
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    // ahora podemos implementar con el modifier
    function testOnlyOwnerCanWithdraw() public funded{
        vm.prank(USER); // otro fake user que no esta 
        vm.expectRevert(); // en la siguiente linea se deberia revertir
        fundMe.withdraw();
    }

    // testing withdraw( siempre  que haga una prueba trate de pensar en esta metodologia)
    function testWithdrawWithASingleFunder() public funded {
        
        // Arrange (Organizar la prueba)
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        console.log('saldo inicial de owner', startingOwnerBalance);
        uint256 startingFundMeBalance = address(fundMe).balance;
        console.log('saldo del fondo inicial', startingFundMeBalance);

        // Act (Accion para probar la prueba)
        uint256 gasStart = gasleft(); // cuanto gas queda en su ultima llamada
        console.log('gasStart', gasStart);
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner()); // solo el owner puede hacer un withdraw, entonces solo queremos hacer una broma, asegurarnos de que realmente somos el owner
        // console.log('fundMe.getOwner()', fundMe.getOwner());
        fundMe.withdraw(); // haciendo el withdraw
        console.log('fundMe', startingFundMeBalance);

        uint256 gasEnd = gasleft();
        console.log('gasEnd', gasEnd);
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice; // current gas price 
        console.log('gasUsed', gasUsed);

        // Assert (afrimar la prueba)
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        console.log('endingOwnerBalance', endingOwnerBalance);
        uint256 endingFundMeBalance = address(fundMe).balance;
        console.log('endingFundMeBalance', endingFundMeBalance);
        assertEq(endingFundMeBalance, 0); // entonces deberiamos haber retirado todo el dinero del fundMe
        assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);

    }

    // testing con una lista de funders (10 funders) que 
    function testWithdrawWithMultipleFunders() public funded {
        
         // Arrange (Organizar la prueba)
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank new Address
            // vm.deal new Address
            // address()
            hoax(address(i), SEND_VALUE); // hoax => Configura un prank desde una dirección que tiene algo de éter.
            fundMe.fund{ value: SEND_VALUE }();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        console.log('saldo inicial de owner', startingOwnerBalance);
        uint256 startingFundMeBalance = address(fundMe).balance;
        console.log('saldo del fondo inicial', startingFundMeBalance);

        // Act (Accion para probar la prueba)
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // Assert (afrimar la prueba)
        assert(address(fundMe).balance == 0);
        assert(startingOwnerBalance + startingFundMeBalance == fundMe.getOwner().balance);

    }   

    // testing con una lista de funders (10 funders) que 
    function testWithdrawWithMultipleFundersCheaper() public funded {
        
         // Arrange (Organizar la prueba)
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank new Address
            // vm.deal new Address
            // address()
            hoax(address(i), SEND_VALUE); // hoax => Configura un prank desde una dirección que tiene algo de éter.
            fundMe.fund{ value: SEND_VALUE }();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        console.log('saldo inicial de owner', startingOwnerBalance);
        uint256 startingFundMeBalance = address(fundMe).balance;
        console.log('saldo del fondo inicial', startingFundMeBalance);

        // Act (Accion para probar la prueba)
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        // Assert (afrimar la prueba)
        assert(address(fundMe).balance == 0);
        assert(startingOwnerBalance + startingFundMeBalance == fundMe.getOwner().balance);

    }   


}