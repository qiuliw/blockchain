// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract SimpleStorage {
    string private str;

    constructor(string memory _str) {
        str = _str;
    }

    function setValue(string memory _str) external {
        str = _str;
    }

    function getValue() external view returns (string memory) {
        return str;
    }
}
