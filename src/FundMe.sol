// get fuds from users
// Withdraw funds
// Set a a minimum funding value in USD

// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;
import { PriceConverter } from "./PriceConverter.sol";
error NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    
    uint256 public constant MINIMUM_USD = 5;
    // 2446 gas non-constant
    // 347 gas constant
    address[] public funders;
    mapping (address funder => uint256 funderAmount) public addressToAmountFunded;
    address public immutable i_owner;
    // 2574 gas non-immutable
    // 439 gas immutable

    constructor () {
        i_owner = address(msg.sender);
    }

    // payable (red color) recibe un pago se puede leer desde msg.value
    function fund() public payable {
        // allow users ti send $
        // have a minimum $ sent $5
        // 1. how do we send ETH to this contract
        // uint256 valueConverter = getConversionRate(msg.value);
        require(msg.value.getConversionRate() >= (MINIMUM_USD * 1e18), "didn't send enough ETH"); // 1e18 = 1 ETH = 1000000000000000000 = 1 * 10 ** 18
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = addressToAmountFunded[msg.sender] + msg.value;
    }

    function witdraw () public onlyOwner {

        for (uint256 funderIndex; funderIndex < funders.length; funderIndex++) { 
            // find funder  
            address funder = funders[funderIndex];
            // update mapping 
            addressToAmountFunded[funder] = 0;
        }
        // reset funders with new array
        funders = new address[](0);

        // ===== Transfers Types ===== 
        // transfer witdraw.   (this is refer to all contract)
        // msg.sender = address
        // payable(msg.sender) = payable address
        // payable (msg.sender).transfer(address(this).balance);
        
        // send witdraw
        // bool sendSuccess = payable (msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");


        // call witdraw
        (bool calleSuccess, /*bytes memory dataRturned*/ ) = payable (msg.sender).call{ 
            value: address(this).balance
        }("");
        require(calleSuccess, "Call failed");
    }


    // modifiers (declare functionality)
    modifier onlyOwner() {
        // _; // Esto quiere decir que puede ejecutar lo que sigue
        // require(msg.sender == i_owner, "Sender is not Owner");
        if (msg.sender != i_owner) { revert NotOwner();}
        _; // Esto quiere decir que puede ejecutar lo que sigue
    }

    // what happens if someone sends this contract ETH  without calling the fund Fuction

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

}