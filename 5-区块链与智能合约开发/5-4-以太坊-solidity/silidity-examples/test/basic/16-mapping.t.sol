// 测试命令: forge test --match-path "test/basic/16-mapping.t.sol" -vv
pragma solidity ^0.8.26;

import {Test as ForgeTest} from "forge-std/Test.sol";
import "../../basic/16-mapping.sol";

contract Basic16MappingTest is ForgeTest {
    // mapping 按 id 读取
    function testGetNameById() public {
        Test t = new Test();
        assert(keccak256(bytes(t.getNameById(1))) == keccak256("lily"));
    }

    // mapping 按 id 写入
    function testSetNameById() public {
        Test t = new Test();
        t.setNameById(1);
        assert(keccak256(bytes(t.getNameById(1))) == keccak256("Hello"));
    }
}
