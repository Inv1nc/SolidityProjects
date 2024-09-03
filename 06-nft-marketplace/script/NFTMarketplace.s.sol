// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {NFTMarketplace} from "../src/NFTMarketplace.sol";
import {Script} from "forge-std/Script.sol";

contract DeployNFTMarketplace is Script {
    NFTMarketplace marketplace;

    function run() external {
        marketplace = new NFTMarketplace();
    }
}
