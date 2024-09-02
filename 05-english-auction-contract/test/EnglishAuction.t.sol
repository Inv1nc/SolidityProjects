// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {EnglishAuction} from "../src/EnglishAuction.sol";
import {NFTToken} from "../src/NFTToken.sol";
import {Test} from "forge-std/Test.sol";
import {DeployEnglishAuction} from "../script/EnglishAuction.s.sol";

contract TestEnglishAuction is Test {
    NFTToken token;
    EnglishAuction auction;

    address immutable OWNER = makeAddr("Owner");
    address immutable BIDDER1 = makeAddr("Inv1nc");
    address immutable BIDDER2 = makeAddr("Ajay");
    address immutable SELLER = makeAddr("Seller");

    string constant NAME = "Token";
    string constant SYMBOL = "TKN";

    uint256 tokenId;
    uint256 constant RESERVE_PRICE = 10 ether;
    uint256 constant DURATION = 1 days;
    uint256 constant STARTING_BALANCE = 20 ether;
    uint256 constant ETH = 1 ether;

    function setUp() external {
        vm.startPrank(OWNER);

        token = new NFTToken(NAME, SYMBOL);
        tokenId = token.mint(SELLER);
        auction = new EnglishAuction(address(token));

        vm.stopPrank();

        vm.deal(BIDDER1, STARTING_BALANCE);
        vm.deal(BIDDER2, STARTING_BALANCE);
    }

    function testdepositNFTNotOwner() external {
        uint256 zero = 0;

        vm.expectRevert(EnglishAuction.EnglishAuction_Not_NFT_Owner.selector);
        auction.deposit(tokenId, zero, zero);

        vm.expectRevert(EnglishAuction.EnglishAuction_Not_Zero.selector);
        vm.prank(SELLER);
        auction.deposit(tokenId, zero, zero);

        vm.expectRevert(EnglishAuction.EnglishAuction_Not_Zero.selector);
        vm.prank(SELLER);
        auction.deposit(tokenId, tokenId, zero);
    }

    function testDepositNFTToken() public {
        vm.startPrank(SELLER);

        token.approve(address(auction), tokenId);
        auction.deposit(tokenId, RESERVE_PRICE, DURATION);

        (bool ended, address seller, address highestBidder, uint256 highestBid, uint256 reservePrice, uint256 deadline)
        = auction.getAuctionDetails(tokenId);

        assertEq(ended, false);
        assertEq(seller, SELLER);
        assertEq(highestBidder, address(0));
        assertEq(highestBid, 0);
        assertEq(reservePrice, RESERVE_PRICE);
        assertEq(deadline, block.timestamp + DURATION);
        vm.stopPrank();
    }

    function testInvalidPlaceBid() external {
        testDepositNFTToken();

        vm.startPrank(BIDDER1);

        vm.expectRevert(EnglishAuction.EnglishAuction_Bid_Is_Low.selector);
        auction.placeBid(tokenId);

        vm.expectRevert(EnglishAuction.EnglishAuction_Expired.selector);
        vm.warp(block.timestamp + DURATION + 1);
        auction.placeBid{value: 1 ether}(tokenId);

        vm.stopPrank();
    }

    function testPlaceBid() public {
        testDepositNFTToken();

        vm.prank(BIDDER1);
        auction.placeBid{value: 10 * ETH}(tokenId);
        assertEq(BIDDER1.balance, 10 ether);
        assertEq(address(auction).balance, 10 ether);

        vm.prank(BIDDER2);
        auction.placeBid{value: 20 * ETH}(tokenId);
        assertEq(BIDDER2.balance, 0);
        assertEq(address(auction).balance, 30 ether);
    }

    function testWithdraw() external {
        testPlaceBid();
        vm.prank(BIDDER1);
        assertEq(BIDDER1.balance, 10 * ETH);
        auction.withdrawBid(tokenId);
        assertEq(BIDDER1.balance, STARTING_BALANCE);
    }

    function testSellerEndAuction() external {
        testPlaceBid();
        vm.prank(SELLER);
        vm.warp(block.timestamp + DURATION + 1);
        auction.sellerEndAuction(tokenId);
        assertEq(token.ownerOf(tokenId), BIDDER2);
    }

    function testReclaimNFT() external {
        testDepositNFTToken();

        assertEq(token.ownerOf(tokenId), address(auction));

        vm.prank(SELLER);
        vm.warp(block.timestamp + DURATION + 1);

        auction.reclaimNFT(tokenId);
        assertEq(token.ownerOf(tokenId), SELLER);
    }

    function testDeployScript() external {
        DeployEnglishAuction deploy = new DeployEnglishAuction();
        deploy.run(NAME, SYMBOL);
        assertTrue(address(deploy) != address(0));
    }

    function testFailMintNotOwner() external {
        token.mint(address(this));
    }
}
