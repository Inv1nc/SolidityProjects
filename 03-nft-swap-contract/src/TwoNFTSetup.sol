// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTA is ERC721("NFT A", "A") {
	uint256 counter;
	address owner;
    constructor() {
		owner = msg.sender;
	}

	function mint() external {
		if (msg.sender != owner) revert();
		counter += 1;
		_mint(msg.sender, counter);
	}
}

contract NFTB is ERC721("NFT B", "B") {
	uint256 counter;
	address owner;
    constructor() {
		owner = msg.sender;
	}

	function mint() external {
		if (msg.sender != owner) revert();
		counter += 1;
		_mint(msg.sender, counter);
	}
}
