// 测试命令: forge test --match-path "test/basic/Basic15Struct.t.sol" -vv
pragma solidity ^0.8.26;

import {Test as ForgeTest} from "forge-std/Test.sol";
import "../../basic/15.struct.sol";

contract Basic15StructTest is ForgeTest {
    // struct 多返回值解构
    function testReturnStudent() public {
        Test t = new Test();
        string memory n;
        uint age;
        uint score;
        string memory sex;
        (n, age, score, sex) = t.returnStudent();
        assertEq(keccak256(bytes(n)), keccak256("lily"));
        assertEq(age, 18);
        assertEq(score, 90);
    }
}
