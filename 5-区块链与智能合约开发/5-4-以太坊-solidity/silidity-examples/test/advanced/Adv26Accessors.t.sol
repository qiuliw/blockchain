// 测试命令: FOUNDRY_PROFILE=advanced forge test --match-path "test/advanced/Adv26Accessors.t.sol" -vv
pragma solidity ^0.8.26;

import {Test as ForgeTest} from "forge-std/Test.sol";
import "../../eth-basic/26.accessors.sol";

contract Adv26AccessorsTest is ForgeTest {
    // public 变量自动生成 getter
    function testPublicGetter() public {
        Test1 t = new Test1();
        assertEq(t.getValue(), 200);
    }
}
