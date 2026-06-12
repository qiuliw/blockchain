// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {Lottery} from "../src/Lottery.sol";

contract DeployLottery is Script {
    function run() external returns (Lottery lottery) {
        vm.startBroadcast();
        lottery = new Lottery();
        vm.stopBroadcast();
    }
}
