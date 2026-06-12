// 测试命令: FOUNDRY_PROFILE=advanced forge test --match-path "test/advanced/22.修饰器modifier.t.sol" -vv
pragma solidity ^0.8.26;

import {Test as ForgeTest} from "forge-std/Test.sol";
import "../../advanced/22.modifier.sol";

contract Adv22ModifierTest is ForgeTest {
    // onlyOwner modifier 放行修改
    function testChangeValue() public {
        Test t = new Test();
        t.changeValue(99);
        assertEq(t.value(), 99);
    }
}
