// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {EnglishAuction} from "../src/EnglishAuction.sol";
import {NFTToken} from "../src/NFTToken.sol";

contract DeployEnglishAuction {
    NFTToken public nftToken;
    EnglishAuction public auction;

    function run(string memory _name, string memory _symbol) external {
        nftToken = new NFTToken(_name, _symbol);
        auction = new EnglishAuction(address(nftToken));
    }
}
