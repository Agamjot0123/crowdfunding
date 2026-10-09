// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {CrowdFund, ThankYouNFT} from "../src/CrowdFund.sol";

contract CrowdFundTest is Test {
    CrowdFund fund;
    ThankYouNFT nft;
    address owner = makeAddr("owner");
    address alice = makeAddr("alice");

    uint256 constant GOAL = 5 ether;
    uint256 constant DURATION = 30 days;

    function setUp() public {
        vm.startPrank(owner);
        nft = new ThankYouNFT();
        fund = new CrowdFund(GOAL, DURATION, address(nft));
        vm.stopPrank();
    }

    function testFundUpdatesMapping() public {
        vm.deal(alice, 1 ether);
        vm.prank(alice);
        fund.fund{value: 1 ether}();
        assertEq(fund.s_amountFunded(alice), 1 ether);
    }

    function testMintsNFT() public {
        vm.deal(alice, 1 ether);
        vm.prank(alice);
        fund.fund{value: 1 ether}();
        assertEq(nft.balanceOf(alice), 1);
    }

    function testCannotWithdrawBeforeDeadline() public {
        vm.deal(alice, 10 ether);
        vm.prank(alice);
        fund.fund{value: 10 ether}();
        vm.prank(owner);
        vm.expectRevert(CrowdFund.CrowdFund__GoalReachedOrDeadlineNotPassed.selector);
        fund.withdraw();
    }

    function testRefundAfterFailedCampaign() public {
        vm.deal(alice, 1 ether);
        vm.prank(alice);
        fund.fund{value: 1 ether}();
        vm.warp(block.timestamp + DURATION + 1);
        vm.prank(alice);
        fund.refund();
        assertEq(alice.balance, 1 ether);
        assertEq(fund.s_amountFunded(alice), 0);
    }
}