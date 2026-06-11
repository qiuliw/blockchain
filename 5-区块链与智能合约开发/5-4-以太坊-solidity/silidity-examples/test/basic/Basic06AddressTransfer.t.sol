// 测试命令: forge test --match-path "test/basic/Basic06AddressTransfer.t.sol" -vv
pragma solidity ^0.8.26;

import {Test as ForgeTest} from "forge-std/Test.sol";
import "../../basic/06.addressTransfer.sol";

contract Basic06AddressTransferTest is ForgeTest {
    // 新部署合约余额为 0
    function testInitialBalance() public {
        Test t = new Test();
        assertEq(t.getContractBalance(), 0);
    }
}
