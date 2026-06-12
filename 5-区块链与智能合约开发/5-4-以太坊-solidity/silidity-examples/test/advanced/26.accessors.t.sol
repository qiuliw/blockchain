// 测试命令: FOUNDRY_PROFILE=advanced forge test --match-path "test/advanced/26.accessors.t.sol" -vv
pragma solidity ^0.8.26;

import {Test as ForgeTest} from "forge-std/Test.sol";
import "../../advanced/26.accessors.sol";

contract AccessorsTest is ForgeTest {
    // public 变量自动生成 getter
    function testPublicGetter() public {
        Accessors1 t = new Accessors1();
        assertEq(t.getValue(), 200);
    }
}
