// SPDX-License-Indentifier: MIT
pragma solidity 0.8.25;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CloudCoin is ERC20 {
    address owner;

    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        owner = msg.sender;
    }

    function mint(address mintAddress, uint256 amount) external {
        require(msg.sender == owner, "only owner can meet");
        _mint(mintAddress, amount);
    }
}
