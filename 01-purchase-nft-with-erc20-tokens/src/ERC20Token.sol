// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20Token is ERC20 {
    uint256 mintPrice;

    constructor(string memory _name, string memory _symbol, uint256 _mintPrice) ERC20(_name, _symbol) {
        mintPrice = _mintPrice * 1 ether;
    }

    function mint(uint256 value) external payable {
        require(msg.value == value * mintPrice);
        _mint(msg.sender, value);
    }

    function burn(uint256 value) external payable {
        _burn(msg.sender, value);
        payable(msg.sender).transfer(value * mintPrice);
    }
}
