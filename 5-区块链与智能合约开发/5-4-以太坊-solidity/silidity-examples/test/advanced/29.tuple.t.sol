// 测试命令: FOUNDRY_PROFILE=advanced forge test --match-path "test/advanced/29.tuple.t.sol" -vv
pragma solidity ^0.8.26;

import {Test as ForgeTest} from "forge-std/Test.sol";
import "../../advanced/29.tuple.sol";

contract TupleTest is ForgeTest {
    // assign 改 stu1.name，public getter 解构验证
    function testAssignUpdatesStudent() public {
        Tuple t = new Tuple();
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
