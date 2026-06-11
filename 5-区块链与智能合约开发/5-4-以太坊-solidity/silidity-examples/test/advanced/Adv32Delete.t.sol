// 测试命令: FOUNDRY_PROFILE=advanced forge test --match-path "test/advanced/Adv32Delete.t.sol" -vv
pragma solidity ^0.8.26;

import {Test as ForgeTest} from "forge-std/Test.sol";
import "../../advanced/32.delete.sol";

contract Adv32DeleteTest is ForgeTest {
    // delete 清空 string 长度归零
    function testDeleteString() public {
        Test t = new Test();
        assertEq(keccak256(bytes(t.str1())), keccak256("hello"));
        t.deleteStr();
        assertEq(bytes(t.str1()).length, 0);
    }
}
