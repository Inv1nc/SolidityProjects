// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract NFTToken is ERC721, Ownable {
    IERC20 public paymentToken;
    uint256 public mintPrice;
    uint256 public tokenCounter;

    constructor(string memory _name, string memory _symbol, address _paymentToken, uint256 _mintPrice)
        ERC721(_name, _symbol)
        Ownable(msg.sender)
    {
        paymentToken = IERC20(_paymentToken);
        mintPrice = _mintPrice;
        tokenCounter = 1;
    }

    function mintNFT() external {
        require(paymentToken.balanceOf(msg.sender) >= mintPrice, "Insufficient ERC20 token balance");
        require(
            paymentToken.allowance(msg.sender, address(this)) >= mintPrice, "Approve contract to spend ERC20 tokens"
        );
        paymentToken.transferFrom(msg.sender, address(this), mintPrice);
        uint256 newItemId = tokenCounter;
        _safeMint(msg.sender, newItemId);
        tokenCounter++;
    }

    function withdrawTokens() public onlyOwner {
        uint256 balance = paymentToken.balanceOf(address(this));
        require(balance > 0);
        paymentToken.transfer(msg.sender, balance);
    }
}
