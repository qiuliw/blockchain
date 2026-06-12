// 测试命令: forge test --match-path "test/basic/13.fixedArray.t.sol" -vv
pragma solidity ^0.8.26;

import {Test as ForgeTest} from "forge-std/Test.sol";
import "../../basic/13.fixedArray.sol";

contract FixedArrayTest is ForgeTest {
    // 定长数组元素求和 55
    function testTotal() public {
        FixedArray t = new FixedArray();
        assertEq(t.total(), 55);
    }
}
