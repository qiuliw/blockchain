// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {Lottery} from "../src/Lottery.sol";

contract LotteryTest is Test {
    Lottery lottery;
    address manager = makeAddr("manager");
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        vm.prank(manager);
        lottery = new Lottery();
    }

    function testPlayAddsPlayer() public {
        vm.deal(alice, 1 ether);
        vm.prank(alice);
        lottery.play{value: 1 ether}();
        assertEq(lottery.getPlayersCount(), 1);
        assertEq(lottery.getBalance(), 1 ether);
    }

    function testKaiJiangPicksWinnerAndDistributesFunds() public {
        vm.deal(alice, 1 ether);
        vm.deal(bob, 1 ether);

        vm.prank(alice);
        lottery.play{value: 1 ether}();
        vm.prank(bob);
        lottery.play{value: 1 ether}();

        uint256 aliceBefore = alice.balance;
        uint256 bobBefore = bob.balance;

        vm.prank(manager);
        lottery.kaiJiang();

        address picked = lottery.winner();
        assertTrue(picked == alice || picked == bob);
        assertEq(lottery.round(), 1);
        assertEq(lottery.getPlayersCount(), 0);
        assertEq(lottery.getBalance(), 0);

        if (picked == alice) {
            assertEq(alice.balance, aliceBefore + 1.8 ether);
            assertEq(bob.balance, bobBefore);
        } else {
            assertEq(bob.balance, bobBefore + 1.8 ether);
            assertEq(alice.balance, aliceBefore);
        }
    }

    function testTuiJiangRefundsPlayers() public {
        vm.deal(alice, 1 ether);
        vm.deal(bob, 1 ether);

        vm.prank(alice);
        lottery.play{value: 1 ether}();
        vm.prank(bob);
        lottery.play{value: 1 ether}();

        vm.prank(manager);
        lottery.tuiJiang();

        assertEq(lottery.round(), 1);
        assertEq(lottery.getPlayersCount(), 0);
        assertEq(lottery.getBalance(), 0);
    }

    function testOnlyManagerCanDraw() public {
        vm.deal(alice, 1 ether);
        vm.prank(alice);
        lottery.play{value: 1 ether}();

        vm.prank(alice);
        vm.expectRevert();
        lottery.kaiJiang();
    }
}
