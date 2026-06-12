// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {SimpleStorage} from "../src/SimpleStorage.sol";

contract SimpleStorageTest is Test {
    SimpleStorage store;

    function setUp() public {
        store = new SimpleStorage("HelloWorld");
    }

    function testConstructorSetsValue() public view {
        assertEq(store.getValue(), "HelloWorld");
    }

    function testSetAndGet() public {
        store.setValue("Hello HangTou");
        assertEq(store.getValue(), "Hello HangTou");
    }
}
