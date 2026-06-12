// 测试命令: forge test --match-path "test/basic/12.conversions.t.sol" -vv
pragma solidity ^0.8.26;

import {Test as ForgeTest} from "forge-std/Test.sol";
import "../../basic/12.conversions.sol";

contract ConversionsTest is ForgeTest {
    // bytes 拼接后转 string
    function testBytesToString() public {
        Conversions t = new Conversions();
        t.bytesToString();
        assert(keccak256(bytes(t.str1())) == keccak256("helloworld"));
    }
}
