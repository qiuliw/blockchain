// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {FundingFactory, Funding} from "../src/FundingFactory.sol";

contract FundingFactoryTest is Test {
    FundingFactory factory;
    address creator = makeAddr("creator");
    address investorA = makeAddr("investorA");
    address investorB = makeAddr("investorB");
    address seller = makeAddr("seller");

    uint256 constant SUPPORT = 1 ether;

    function setUp() public {
        factory = new FundingFactory();
    }

    function testCreateFundingAndInvest() public {
        vm.prank(creator);
        factory.createFunding("Book", 10 ether, SUPPORT, 7 days);

        address fundingAddr;
        vm.prank(creator);
        fundingAddr = factory.getCreatorFundings()[0];
        Funding funding = Funding(payable(fundingAddr));

        vm.deal(investorA, SUPPORT);
        vm.prank(investorA);
        funding.invest{value: SUPPORT}();

        assertEq(funding.getInvestorsCount(), 1);
        assertEq(funding.getBalance(), SUPPORT);
        assertEq(factory.getSupportorFunding().length, 0);

        vm.prank(investorA);
        assertEq(factory.getSupportorFunding().length, 1);
    }

    function testApproveAndFinalizeRequest() public {
        vm.prank(creator);
        factory.createFunding("Book", 10 ether, SUPPORT, 7 days);
        address fundingAddr;
        vm.prank(creator);
        fundingAddr = factory.getCreatorFundings()[0];
        Funding funding = Funding(payable(fundingAddr));

        vm.deal(investorA, SUPPORT);
        vm.deal(investorB, SUPPORT);
        vm.prank(investorA);
        funding.invest{value: SUPPORT}();
        vm.prank(investorB);
        funding.invest{value: SUPPORT}();

        vm.prank(creator);
        funding.createRequest("Print", SUPPORT, seller);

        vm.prank(investorA);
        funding.approveRequest(0);
        vm.prank(investorB);
        funding.approveRequest(0);

        uint256 sellerBefore = seller.balance;
        vm.prank(creator);
        funding.finalizeRequest(0);

        assertEq(seller.balance, sellerBefore + SUPPORT);
    }
}
