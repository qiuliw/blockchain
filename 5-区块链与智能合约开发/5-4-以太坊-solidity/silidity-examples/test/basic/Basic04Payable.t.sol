// 测试命令: forge test --match-path "test/basic/Basic04Payable.t.sol" -vv
pragma solidity ^0.8.26;

import {Test as ForgeTest} from "forge-std/Test.sol";
import "../../basic/04.payable.sol";

contract Basic04PayableTest is ForgeTest {
    // payable 函数可接收 1 ether
    function testPayableReceivesEther() public {
        Test t = new Test();
        t.test1{value: 1 ether}("paid");
        assertEq(t.getbalance(), 1 ether);
    }
}
