// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {StakeTogether} from "../src/StakeTogether.sol";
import {Script} from "forge-std/Script.sol";
import {CloudCoin} from "../src/CloudCoin.sol";

contract DeployStakeTogether is Script {
    CloudCoin coin;
    StakeTogether stakeTogether;

    function run() external {
        coin = new CloudCoin("Cloud Token", "CLOUD");
        stakeTogether = new StakeTogether(address(coin), block.timestamp);
        coin.mint(address(stakeTogether), stakeTogether.totalReward());
    }
}
