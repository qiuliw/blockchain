// 测试命令: FOUNDRY_PROFILE=advanced forge test --match-path "test/advanced/33.HTCoinERC20.t.sol" -vv
pragma solidity ^0.8.26;

import {Test as ForgeTest} from "forge-std/Test.sol";
import "../../advanced/33.HTCoinERC20.sol";

contract Adv33HTCoinTest is ForgeTest {
    uint256 constant INITIAL_SUPPLY = 1_000_000;

    HangTouCoin token;
    address owner;
    address bob;
    address alice;

    // 部署 HTC，owner 持有全部代币
    function setUp() public {
        owner = makeAddr("owner");
        bob = makeAddr("bob");
        alice = makeAddr("alice");
        vm.prank(owner);
        token = new HangTouCoin(INITIAL_SUPPLY, "HangTouCoin", "HTC");
    }

    // 名称/符号/精度/总量/owner
    function testConstructor() public view {
        assertEq(token.name(), "HangTouCoin");
        assertEq(token.symbol(), "HTC");
        assertEq(token.decimals(), 18);
        assertEq(token.totalSupply(), INITIAL_SUPPLY * 10 ** 18);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY * 10 ** 18);
        assertEq(token.owner(), owner);
    }

    // transfer 转账扣减余额
    function testTransfer() public {
        uint256 amount = 100 ether;
        vm.prank(owner);
        token.transfer(bob, amount);
        assertEq(token.balanceOf(bob), amount);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY * 10 ** 18 - amount);
    }

    // approve + transferFrom 授权代扣
    function testApproveAndTransferFrom() public {
        uint256 amount = 200 ether;
        vm.prank(owner);
        token.approve(alice, amount);
        assertEq(token.allowance(owner, alice), amount);

        vm.prank(alice);
        token.transferFrom(owner, bob, amount);

        assertEq(token.balanceOf(bob), amount);
        assertEq(token.allowance(owner, alice), 0);
    }

    // burn 销毁减少 totalSupply
    function testBurn() public {
        uint256 amount = 50 ether;
        uint256 supplyBefore = token.totalSupply();
        vm.prank(owner);
        token.burn(amount);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY * 10 ** 18 - amount);
        assertEq(token.totalSupply(), supplyBefore - amount);
    }

    // freeze/unfreeze 冻结解冻
    function testFreezeAndUnfreeze() public {
        uint256 amount = 30 ether;
        vm.startPrank(owner);
        token.freeze(amount);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY * 10 ** 18 - amount);
        assertEq(token.freezeOf(owner), amount);

        token.unfreeze(amount);
        vm.stopPrank();
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY * 10 ** 18);
        assertEq(token.freezeOf(owner), 0);
    }

    // owner 提取合约内 ETH
    function testWithdrawEther() public {
        (bool ok,) = address(token).call{value: 1 ether}("");
        require(ok, "fund token");
        assertEq(address(token).balance, 1 ether);

        vm.prank(owner);
        token.withdrawEther(1 ether);
        assertEq(address(token).balance, 0);
        assertEq(owner.balance, 1 ether);
    }

    // 非 owner 提取 revert
    function testWithdrawEtherRevertsForNonOwner() public {
        vm.deal(bob, 1 ether);
        vm.prank(bob);
        vm.expectRevert();
        token.withdrawEther(1 ether);
    }
}
