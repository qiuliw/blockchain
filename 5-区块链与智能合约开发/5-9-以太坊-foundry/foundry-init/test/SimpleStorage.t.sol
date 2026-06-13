// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {SimpleStorage} from "../src/SimpleStorage.sol";

contract SimpleStorageTest is Test {
    SimpleStorage store;

    function setUp() public {
        store = new SimpleStorage();
    }

    function testSetAndGet() public {
        store.set(1000);
        assertEq(store.get(), 1000);
    }
}
