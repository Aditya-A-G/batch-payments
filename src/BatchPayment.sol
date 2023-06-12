// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract BatchPayment is ReentrancyGuard, Ownable {
    IERC20 public immutable token;

    event BatchPaymentCompleted(address operator, uint256 totalAmount);

    constructor(address _tokenAddress) {
        require(address(_tokenAddress) != address(0), "Invalid Token");

        token = IERC20(_tokenAddress);
    }

    function batchTransfer(
        uint256 totalAmount,
        address[] memory recipients,
        uint256[] memory amounts
    ) public nonReentrant {
        require(recipients.length == amounts.length, "Array Lengths Mismatch");
        require(recipients.length > 0, "Empty Array");

        uint256 sumOfAmounts;
        for (uint256 i = 0; i < amounts.length; i++) {
            sumOfAmounts += amounts[i];
        }

        require(sumOfAmounts == totalAmount, "Amount Mismatch");

        require(
            token.balanceOf(msg.sender) >= totalAmount,
            "Insufficient balance"
        );

        require(
            token.allowance(msg.sender, address(this)) >= totalAmount,
            "Insufficient allowance"
        );

        // Transfer the total amount from sender to this contract
        require(
            token.transferFrom(msg.sender, address(this), totalAmount),
            "Transfer failed"
        );

        // Execute batch payments
        for (uint256 i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "Invalid Recipient");
            require(
                token.transfer(recipients[i], amounts[i]),
                "Token transfer failed"
            );
        }

        emit BatchPaymentCompleted(msg.sender, totalAmount);
    }
}
