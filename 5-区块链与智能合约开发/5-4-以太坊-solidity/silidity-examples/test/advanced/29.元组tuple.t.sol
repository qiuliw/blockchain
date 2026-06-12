// 测试命令: FOUNDRY_PROFILE=advanced forge test --match-path "test/advanced/29.元组tuple.t.sol" -vv
pragma solidity ^0.8.26;

import {Test as ForgeTest} from "forge-std/Test.sol";
import "../../advanced/29.tuple.sol";

contract Adv29TupleTest is ForgeTest {
    // 元组赋值更新 struct 字段
    function testAssignUpdatesStudent() public {
        Test t = new Test();
        t.assign();
        string memory n;
        uint age;
        uint score;
        string memory sex;
        (n, age, score, sex) = t.stu1();
        assertEq(keccak256(bytes(n)), keccak256("Lily"));
        assertEq(age, 18);
    }
}
