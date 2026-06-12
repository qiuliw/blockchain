// 测试命令: forge test --match-path "test/basic/16-mapping.t.sol" -vv
pragma solidity ^0.8.26;

import {Test as ForgeTest} from "forge-std/Test.sol";
import "../../basic/16-mapping.sol";

contract MappingTest is ForgeTest {
    // mapping 按 id 读取
    function testGetNameById() public {
        Mapping t = new Mapping();
        assert(keccak256(bytes(t.getNameById(1))) == keccak256("lily"));
    }

    // mapping 按 id 写入
    function testSetNameById() public {
        Mapping t = new Mapping();
        t.setNameById(1);
        assert(keccak256(bytes(t.getNameById(1))) == keccak256("Hello"));
    }
}
