// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20Token is ERC20 {
    address owner;

    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        owner = msg.sender;
    }

    function mint(address mintAddress, uint256 amount) external {
        require(owner == msg.sender, "Only Owner Can Mint Tokens");
        _mint(mintAddress, amount);
    }
}
