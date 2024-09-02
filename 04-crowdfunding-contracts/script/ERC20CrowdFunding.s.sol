// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ERC20CrowdFunding} from "../src/ERC20CrowdFunding.sol";
import {Script} from "forge-std/Script.sol";
import {ERC20Token} from "../src/ERC20Token.sol";

contract DeployERC20CrowdFunding is Script {
    ERC20CrowdFunding funding;

    function run(address erc20Token) external {
        funding = new ERC20CrowdFunding(erc20Token);
    }
}
