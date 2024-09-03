// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTToken is ERC721 {
    address owner;
    uint256 tokenCounter;

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {
        owner = msg.sender;
    }

    function mint(address mintAddress) external returns (uint256 tokenId) {
        tokenCounter++;
        _mint(mintAddress, tokenCounter);
        return tokenCounter;
    }
}
