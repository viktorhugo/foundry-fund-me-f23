// get fuds from users
// Withdraw funds
// Set a a minimum funding value in USD

// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { PriceConverter } from "./PriceConverter.sol";
import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

error FundMe__NotOwner();
import { console } from "forge-std/Script.sol";

contract FundMe {
    
    // Type Declarations
    using PriceConverter for uint256;

    // State variables
    uint256 public constant MINIMUM_USD = 5 * 1 ether;
    // 2446 gas non-constant
    // 347 gas constant
    address private immutable i_owner;
    // 2574 gas non-immutable
    // 439 gas immutable
    mapping (address funder => uint256 funderAmount) private s_addressToAmountFunded;
    address[] private s_funders;
    AggregatorV3Interface private s_priceFeed;

    constructor (address priceFeed) {
        i_owner = address(msg.sender);
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    // Functions Order:
    // constructor
    // receive
    // fallback
    // external
    // public
    // internal
    // private
    // view / pure

    // payable (red color) recibe un pago se puede leer desde msg.value
    function fund() public payable {
        // allow users ti send $
        // have a minimum $ sent $5
        // 1. how do we send ETH to this contract
        // uint256 valueConverter = getConversionRate(msg.value);
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "didn't send enough ETH"); // 1e18 = 1 ETH = 1000000000000000000 = 1 * 10 ** 18
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] = s_addressToAmountFunded[msg.sender] + msg.value;
        console.log('New fund', msg.sender, msg.value);
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

        // call witdraw
        (bool calleSuccess, /*bytes memory dataRturned*/ ) = payable (i_owner).call{ 
            value: address(this).balance
        }("");
        require(calleSuccess, "Call failed");
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }


    // modifiers (declare functionality)
    modifier onlyOwner() {
        // _; // Esto quiere decir que puede ejecutar lo que sigue
        // require(msg.sender == i_owner, "Sender is not Owner");
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _; // Esto quiere decir que puede ejecutar lo que sigue
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
     * View / Pure Functions (Getters)
    */

    function getAddresToAmountFunded(address fundingAddress) public view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    } 

    function  getOwner() external view returns (address) {
        return i_owner;        
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