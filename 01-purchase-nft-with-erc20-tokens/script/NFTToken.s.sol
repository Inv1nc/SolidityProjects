//SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {NFTToken} from "../src/NFTToken.sol";
import {Script} from "forge-std/Script.sol";
import {ERC20Token} from "../src/ERC20Token.sol";

contract DeployNFTToken is Script {
    ERC20Token public erc20;
    NFTToken public nft;
    uint256 private mintPrice = 1; // converted into ether in ERC20Token contract

    function run() external {
        vm.startBroadcast();
        erc20 = new ERC20Token("Currency", "SINGLE", mintPrice);
        nft = new NFTToken("RARE", "rr", address(erc20), mintPrice);
        vm.stopBroadcast();
    }
}
