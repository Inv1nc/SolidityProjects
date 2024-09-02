// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {EthCrowdFunding} from "../src/EthCrowdFunding.sol";
import {Script} from "forge-std/Script.sol";

contract DeployEthCrowdFunding is Script {
    EthCrowdFunding funding;

    function run() external {
        funding = new EthCrowdFunding();
    }
}
