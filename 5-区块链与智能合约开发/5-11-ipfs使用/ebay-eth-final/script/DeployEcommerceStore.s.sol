// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {EcommerceStore} from "../src/EcommerceStore.sol";

contract DeployEcommerceStore is Script {
    function run() external returns (EcommerceStore store) {
        vm.startBroadcast();
        store = new EcommerceStore();
        vm.stopBroadcast();
    }
}
