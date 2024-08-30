// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {NFTSwap} from "../src/NFTSwap.sol";
import {NFTA, NFTB} from "../src/TwoNFTSetup.sol";
import {Script} from "forge-std/Script.sol";

contract DeployNFTSwap is Script {

    NFTSwap public nftSwap;
    NFTA public nfta;
    NFTB public nftb;

    function run(uint256 CANCEL_TIME) external {
        nfta = new NFTA();
        nftb = new NFTB();
        nftSwap = new NFTSwap(CANCEL_TIME);
    }
}
