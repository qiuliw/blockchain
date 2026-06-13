// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {EcommerceStore, Escrow} from "../src/EcommerceStore.sol";

contract EcommerceStoreTest is Test {
    EcommerceStore store;
    address seller = makeAddr("seller");
    address buyer = makeAddr("buyer");
    address bidderB = makeAddr("bidderB");
    address arbiter = makeAddr("arbiter");

    function setUp() public {
        store = new EcommerceStore();
    }

    function testAddProduct() public {
        vm.prank(seller);
        store.addProductToStore("shirt", "clothes", "img", "desc", 1, 2, 1 ether, 0);

        assertEq(store.productIndex(), 1);
        EcommerceStore.ProductInfo memory info = store.getProductById(1);
        assertEq(info.id, 1);
        assertEq(info.name, "shirt");
    }

    function testBidRevealAndFinalize() public {
        vm.prank(seller);
        store.addProductToStore("shirt", "clothes", "img", "desc", 1, 2, 1 ether, 0);

        vm.deal(buyer, 5 ether);
        vm.deal(bidderB, 5 ether);

        bytes32 commitA = store.computeCommitHash(1, buyer, 3 ether, "secret-a");
        bytes32 commitB = store.computeCommitHash(1, bidderB, 2 ether, "secret-b");

        vm.prank(buyer);
        store.bid{value: 3 ether}(1, commitA);

        vm.prank(bidderB);
        store.bid{value: 2 ether}(1, commitB);

        vm.prank(buyer);
        store.revealBid(1, 3 ether, "secret-a");

        vm.prank(bidderB);
        store.revealBid(1, 2 ether, "secret-b");

        (address highestBidder, uint256 highestBid, uint256 secondHighestBid,) =
            store.getHighestBidInfo(1);
        assertEq(highestBidder, buyer);
        assertEq(highestBid, 3 ether);
        assertEq(secondHighestBid, 2 ether);

        vm.prank(arbiter);
        store.finalaizeAuction(1);

        (address escrowBuyer, address escrowSeller, address escrowArbiter,,) =
            store.getEscrowInfo(1);
        assertEq(escrowBuyer, buyer);
        assertEq(escrowSeller, seller);
        assertEq(escrowArbiter, arbiter);

        Escrow escrow = Escrow(payable(store.productToEscrow(1)));
        assertEq(escrow.getBalance(), 2 ether);
    }

    function testRevealFailsWithWrongSecret() public {
        vm.prank(seller);
        store.addProductToStore("shirt", "clothes", "img", "desc", 1, 2, 1 ether, 0);

        vm.deal(buyer, 5 ether);
        bytes32 commit = store.computeCommitHash(1, buyer, 3 ether, "secret-a");

        vm.prank(buyer);
        store.bid{value: 3 ether}(1, commit);

        vm.prank(buyer);
        vm.expectRevert();
        store.revealBid(1, 3 ether, "wrong-secret");
    }

    function testCommitCannotReplayOnAnotherProduct() public {
        vm.startPrank(seller);
        store.addProductToStore("shirt", "clothes", "img", "desc", 1, 2, 1 ether, 0);
        store.addProductToStore("shoes", "clothes", "img2", "desc2", 1, 2, 1 ether, 0);
        vm.stopPrank();

        vm.deal(buyer, 5 ether);
        bytes32 commitForProduct1 = store.computeCommitHash(1, buyer, 3 ether, "secret-a");

        vm.prank(buyer);
        store.bid{value: 3 ether}(1, commitForProduct1);

        vm.prank(buyer);
        vm.expectRevert();
        store.revealBid(2, 3 ether, "secret-a");
    }
}
