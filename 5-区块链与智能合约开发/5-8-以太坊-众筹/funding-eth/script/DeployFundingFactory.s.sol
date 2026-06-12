// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {FundingFactory} from "../src/FundingFactory.sol";

contract DeployFundingFactory is Script {
    function run() external returns (FundingFactory factory) {
        vm.startBroadcast();
        factory = new FundingFactory();
        vm.stopBroadcast();
    }
}
