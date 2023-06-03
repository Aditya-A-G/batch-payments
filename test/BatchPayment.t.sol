// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "foundry/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {BatchPayment} from "../src/BatchPayment.sol";
import {MyToken} from "./MyToken.sol";

contract BatchPaymentTest is Test {
    BatchPayment public batchPayment;
    MyToken public token;

    address public tokenOwner;
    address public contractOwner;
    address[] _recipients;
    uint256[] _amounts;

    function setUp() public {
        tokenOwner = makeAddr("TokenOwner");
        contractOwner = makeAddr("ContractOwner");

        vm.prank(tokenOwner);
        token = new MyToken();

        vm.prank(contractOwner);

        // Set up some _recipients and _amounts
        _recipients = [address(0x123), address(0x456)];
        _amounts = [100, 200];

        batchPayment = new BatchPayment(address(token));

        vm.label(address(this), "BatchPaymentTest");
    }

    function testSuccessfulBatchPayment() public {
        // Approve the BatchPayment contract to spend tokens
        token.approve(address(batchPayment), 300);

        // Make the batch payment
        batchPayment.depositAndBatchPayments(300, _recipients, _amounts);

        // Check that the _recipients received the correct _amounts
        assertEq(token.balanceOf(_recipients[0]), 100);
        assertEq(token.balanceOf(_recipients[1]), 200);

        // Check that the BatchPayment contract's balance is 0
        assertEq(token.balanceOf(address(batchPayment)), 0);
    }

    function testFailMismatchedArrays() public {
        // Approve the BatchPayment contract to spend tokens
        token.approve(address(batchPayment), 300);

        // Remove an element from the _amounts array
        _amounts.pop();

        // This should fail because the _recipients and _amounts arrays do not have the same length
        batchPayment.depositAndBatchPayments(300, _recipients, _amounts);
    }

    function testFailIncorrectTotalAmount() public {
        // Approve the BatchPayment contract to spend tokens
        token.approve(address(batchPayment), 300);

        // This should fail because the total amount does not match the sum of the _amounts
        batchPayment.depositAndBatchPayments(299, _recipients, _amounts);
    }

    function testFailInsufficientAllowance() public {
        // Approve the BatchPayment contract to spend fewer tokens than the total amount
        token.approve(address(batchPayment), 299);

        // This should fail because the BatchPayment contract is not approved to spend enough tokens
        batchPayment.depositAndBatchPayments(300, _recipients, _amounts);
    }
}
