// 测试命令: FOUNDRY_PROFILE=advanced forge test --match-path "test/advanced/31.inheritance.t.sol" -vv
pragma solidity ^0.8.26;

import {Test as ForgeTest} from "forge-std/Test.sol";
import "../../advanced/31.inheritance.sol";

contract Adv31InheritanceTest is ForgeTest {
    // 单继承 override，mydata=1
    function testSon3() public {
        son3 s = new son3();
        assertEq(s.mydata(), 1);
    }

    // 多重继承 override，mydata=2
    function testSon4() public {
        son4 s = new son4();
        assertEq(s.mydata(), 2);
    }
}
