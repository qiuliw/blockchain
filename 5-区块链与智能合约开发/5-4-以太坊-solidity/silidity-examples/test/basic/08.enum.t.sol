// 测试命令: forge test --match-path "test/basic/08.enum.t.sol" -vv
pragma solidity ^0.8.26;

import {Test as ForgeTest} from "forge-std/Test.sol";
import "../../basic/08.enum.sol";

contract EnumTest is ForgeTest {
    // WeekDays.Sunday 枚举值为 6
    function testDefaultDay() public {
        Enum t = new Enum();
        assertEq(t.getDefaultDay(), 6);
    }
}
