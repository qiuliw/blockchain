// 测试命令: FOUNDRY_PROFILE=advanced forge test --match-path "test/advanced/22.modifier.t.sol" -vv
pragma solidity ^0.8.26;

import {Test as ForgeTest} from "forge-std/Test.sol";
import "../../advanced/22.modifier.sol";

contract ModifierTest is ForgeTest {
    // onlyOwner modifier 放行修改
    function testChangeValue() public {
        Modifier t = new Modifier();
        t.changeValue(99);
        assertEq(t.value(), 99);
    }
}
