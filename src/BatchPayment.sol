// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract BatchPayment is ReentrancyGuard, Ownable {
    IERC20 public immutable token;

    event BatchPaymentCompleted(address operator, uint256 totalAmount);

    constructor(address _tokenAddress) {
        require(address(_tokenAddress) != address(0), "Invalid Token Address");
        
        token = IERC20(_tokenAddress);
    }

 function depositAndBatchPayments(uint256 totalAmount, address[] memory recipients, uint256[] memory amounts) public nonReentrant onlyOwner {
    require(recipients.length == amounts.length, "Recipients and amounts array lengths must match");
    require(recipients.length > 0, "Recipients and amounts array must not be empty");

    uint256 sumOfAmounts;
    for (uint256 i = 0; i < amounts.length; i++) {
        sumOfAmounts += amounts[i];
    }
    require(sumOfAmounts == totalAmount, "Total amount does not match sum of individual amounts");

    // Transfer the total amount from sender to this contract
    require(token.transferFrom(msg.sender, address(this), totalAmount), "Transfer failed");

    // Execute batch payments
    for (uint256 i = 0; i < recipients.length; i++) {
        // If the transfer fails, revert the transaction
        require(token.transfer(recipients[i], amounts[i]), "Token transfer failed");
    }

    emit BatchPaymentCompleted(msg.sender, totalAmount);
}

}
