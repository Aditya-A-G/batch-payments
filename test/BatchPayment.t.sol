// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {BatchPayment} from "../src/BatchPayment.sol";
import {MyToken} from "./MyToken.sol";

contract BatchPaymentTest is Test {
    BatchPayment public batchPayment;
    MyToken public token;

    address[] recipients;
    uint256[] amounts;

    address alice;
    address bob;

    function setUp() public {
        token = new MyToken();

        alice = makeAddr("alice");
        bob = makeAddr("bob");

        recipients = [address(alice), address(bob)];
        amounts = [100, 200];

        batchPayment = new BatchPayment(address(token));
    }

    function testFailEmptyRecipients() public {
        token.approve(address(batchPayment), 300);

        recipients = new address[](0);
        amounts = new uint256[](0);

        batchPayment.batchTransfer(300, recipients, amounts);
    }

    function testFailZeroAddressRecipient() public {
        token.approve(address(batchPayment), 300);

        address zeroAddress = address(0);
        recipients = [address(alice), zeroAddress];

        batchPayment.batchTransfer(300, recipients, amounts);
    }

    function testFailMismatchedArrays() public {
        token.approve(address(batchPayment), 300);

        amounts.pop();

        batchPayment.batchTransfer(300, recipients, amounts);
    }

    function testFailIncorrectTotalAmount() public {
        token.approve(address(batchPayment), 300);

        batchPayment.batchTransfer(299, recipients, amounts);
    }

    function testFailInsufficientAllowance() public {
        token.approve(address(batchPayment), 299);

        batchPayment.batchTransfer(300, recipients, amounts);
    }

    function testSuccessfulBatchPayment() public {
        token.approve(address(batchPayment), 300);

        batchPayment.batchTransfer(300, recipients, amounts);

        assertEq(token.balanceOf(recipients[0]), 100);
        assertEq(token.balanceOf(recipients[1]), 200);

        assertEq(token.balanceOf(address(batchPayment)), 0);
    }
}
