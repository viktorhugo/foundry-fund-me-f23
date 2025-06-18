// get fuds from users
// Withdraw funds
// Set a a minimum funding value in USD

// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/// s_name => quiere decir que es una variable que se esta leyendo desde el storage

import { PriceConverter } from "./PriceConverter.sol";
import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

error FundMe__NotOwner();
import { console } from "forge-std/Script.sol";

contract FundMe {

    // Functions Order:
    // constructor
    // receive
    // fallback
    // external
    // public
    // internal
    // private
    // view / pure
    
    // Type Declarations
    using PriceConverter for uint256;

    // State variables
    uint256 public constant MINIMUM_USD = 5 * 10 ** 18;
    // 2446 gas non-constant
    // 347 gas constant
    address private immutable i_owner;
    // 2574 gas non-immutable
    // 439 gas immutable
    mapping (address founder => uint256 founderAmount) private s_addressToAmountFunded;

    address[] private s_funders;
    AggregatorV3Interface private s_priceFeed;

    // modifiers (declare functionality)
    modifier onlyOwner() {
        console.log('Only Owner', msg.sender, i_owner);
        //  _;  => Esto quiere decir que puede ejecutar lo que sigue
        // require(msg.sender == i_owner, "Sender is not Owner");
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    // Constructor
    constructor (address priceFeed) {
        i_owner = address(msg.sender);
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    // payable (red color) recibe un pago se puede leer desde msg.value,  Funds our contract on the ETH/USD price 
    function fund() public payable {
        // have a minimum $ sent $5
        // 1. how do we send ETH to this contract
        // uint256 valueConverter = getConversionRate(msg.value);
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "You need to send more ETH"); // 1e18 = 1 ETH = 1000000000000000000 = 1 * 10 ** 18
        s_addressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);
        console.log('### FundMe - fund - new fund', msg.sender, msg.value);
    }

    function withdraw() public onlyOwner {
        // recorre todos el array s_funders
        for (uint256 funderIndex; funderIndex < s_funders.length; funderIndex++) { 
            // find funder  
            address funder = s_funders[funderIndex];
            // update mapping 
            s_addressToAmountFunded[funder] = 0;
        }
        // reset s_funders with new array
        s_funders = new address[](0);

        // call withdraw
        (bool calledSuccess,  /*bytes memory data returned*/ ) = payable (i_owner).call{ value: address(this).balance }("");
        require(calledSuccess, "Call failed");
    }

    // GAS Optimization
    function cheaperWithdraw() public onlyOwner {
        // ahorramos gas el leer s_funders.length de la memoria (memory) en lugar del almacenamiento (stotage)
        address[] memory funders = s_funders;

        // recorre todos el array s_funders
        for (uint256 funderIndex; funderIndex < funders.length; funderIndex++) { 
            // find funder 
            address funder = s_funders[funderIndex];
            // update mapping 
            s_addressToAmountFunded[funder] = 0;
        }
        // reset s_funders with new array
        s_funders = new address[](0);
        // call withdraw
        (bool calledSuccess, /*bytes memory dataRturned*/ ) = payable (i_owner).call{ value: address(this).balance }("");
        require(calledSuccess, "Call failed");
    }

    // what happens if someone sends this contract ETH  without calling the fund Fuction

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    
    /**
     * 
     * Getters Functions
    */

    function getAddressToAmountFunded(address fundingAddress) public view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }

    // ===== Transfers Types ===== 
    // transfer witdraw.   (this is refer to all contract)
    // msg.sender = address
    // payable(msg.sender) = payable address
    // payable (msg.sender).transfer(address(this).balance);
    
    // send witdraw
    // bool sendSuccess = payable (msg.sender).send(address(this).balance);
    // require(sendSuccess, "Send failed");
}