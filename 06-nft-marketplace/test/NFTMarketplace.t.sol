// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {NFTMarketplace} from "../src/NFTMarketplace.sol";
import {Test} from "forge-std/Test.sol";
import {NFTToken} from "../src/NFTToken.sol";
import {DeployNFTMarketplace} from "../script/NFTMarketplace.s.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract TestNFTMarketplace is Test {
    string constant NAME = "NFTToken";
    string constant SYMBOL = "TKN";

    address immutable OWNER = makeAddr("Owner");
    address immutable SELLER = makeAddr("Seller");
    address immutable BUYER = makeAddr("Buyer");

    NFTMarketplace marketplace;
    NFTToken token;

    uint256 tokenCounter;
    uint256 constant PRICE = 10 ether;
    uint256 constant DURATION = 1 days;

    function setUp() external {
        vm.prank(OWNER);
        token = new NFTToken(NAME, SYMBOL);
        marketplace = new NFTMarketplace();
        vm.deal(BUYER, PRICE);
    }

    function testInvalidSell() external {}

    function testSell() public {
        vm.prank(OWNER);
        tokenCounter = token.mint(SELLER);

        vm.startPrank(SELLER);
        token.approve(address(marketplace), tokenCounter);
        marketplace.sell(address(token), tokenCounter, PRICE, DURATION);
        vm.stopPrank();

        (address seller, uint256 price, uint256 expiration) = marketplace.getListing(address(token), tokenCounter);
        assertEq(seller, SELLER);
        assertEq(price, PRICE);
        assertEq(expiration, block.timestamp + DURATION);
    }

    function testInvalidBuy() external {
        testSell();
        vm.startPrank(BUYER);
        vm.expectRevert(NFTMarketplace.NFTMarketplace_Not_Available.selector);
        marketplace.buy(address(token), tokenCounter + 1);

        vm.expectRevert(NFTMarketplace.NFTMarketplace_Invalid_Eth_Sent.selector);
        marketplace.buy(address(token), tokenCounter);

        vm.warp(block.timestamp + DURATION + 1);
        vm.expectRevert(NFTMarketplace.NFTMarketplace_Deadline_Reached.selector);
        marketplace.buy(address(token), tokenCounter);
    }

    function testTokenDisprove() external {
        vm.prank(OWNER);
        tokenCounter = token.mint(SELLER);

        vm.prank(SELLER);
        vm.expectRevert(NFTMarketplace.NFTMarketplace_Token_Not_Approved.selector);
        marketplace.sell(address(token), tokenCounter, PRICE, DURATION);
    }

    function testBuy() public {
        testSell();
        assertEq(BUYER.balance, PRICE);
        vm.prank(BUYER);

        marketplace.buy{value: PRICE}(address(token), tokenCounter);
        assertEq(BUYER.balance, 0);
        assertEq(BUYER, token.ownerOf(tokenCounter));
    }

    function testInvalidCancel() external {
        testSell();
        vm.prank(BUYER);
        vm.expectRevert(NFTMarketplace.NFTMarketplace_Not_Seller.selector);
        marketplace.cancel(address(token), tokenCounter);
    }

    function testCancel() external {
        testSell();
        vm.prank(SELLER);
        marketplace.cancel(address(token), tokenCounter);
    }

    function testGetListedTokens() external {
        testSell();
        uint256 token1 = tokenCounter;
        testSell();
        uint256[] memory tokens = marketplace.getListedTokens(address(token));
        assertEq(tokens[0], token1);
        assertEq(tokens[1], tokenCounter);
    }

    function testSendDirectEth() external {
        vm.expectRevert(NFTMarketplace.NFTMarketplace_Direct_Eth_Transfer_Not_Allowed.selector);
        vm.prank(BUYER);
        address(marketplace).call{value: PRICE}("");
    }

    function testDeployScript() external {
        DeployNFTMarketplace deploy = new DeployNFTMarketplace();
        deploy.run();
        assertTrue(address(deploy) != address(0));
    }

    function testSellerRefuseEther() external {
        RefuseEther refuse = new RefuseEther();
        vm.prank(OWNER);
        tokenCounter = token.mint(address(refuse));
        refuse.sell(address(marketplace), address(token), tokenCounter, PRICE, DURATION);

        vm.prank(BUYER);
        vm.expectRevert();
        marketplace.buy{value: PRICE}(address(token), tokenCounter);
    }
}

contract RefuseEther {
    function sell(address marketplace, address nftAddress, uint256 tokenId, uint256 price, uint256 duration) external {
        IERC721(nftAddress).approve(marketplace, tokenId);
        NFTMarketplace(payable(marketplace)).sell(nftAddress, tokenId, price, duration);
    }

    receive() external payable {
        revert();
    }
}
