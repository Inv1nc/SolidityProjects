// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract EnglishAuction is ReentrancyGuard {
    struct Auction {
        bool ended;
        address seller;
        address highestBidder;
        uint256 highestBid;
        uint256 reservePrice;
        uint256 deadline;
    }

    mapping(uint256 => Auction) public auctions;
    mapping(uint256 => mapping(address => uint256)) bids;

    IERC721 public nftContract;

    constructor(address nftContractAddress) {
        nftContract = IERC721(nftContractAddress);
    }

    // events
    event AuctionCreated(uint256 tokenId, uint256 reservePrice, uint256 deadline);
    event BidPlaced(uint256 tokenId, address bidder, uint256 amount);
    event AuctionEnded(uint256 tokenId, address Winner, uint256 highestBid);

    // error
    error EnglishAuction_Not_NFT_Owner();
    error EnglishAuction_Not_Zero();
    error EnglishAuction_Expired();
    error EnglishAuction_Bid_Is_Low();
    error EnglishAuction_Nothing_To_Withdraw();
    error EnglishAuction_Not_Seller();
    error EnglishAuction_Not_Ended();
    error EnglishAuction_Already_Ended();
    error EnglishAuction_Reserve_Price_Not_Meet();
    error EnglishAuction_Reserve_Price_Meet();

    function deposit(uint256 tokenId, uint256 reservePrice, uint256 duration) external {
        if (nftContract.ownerOf(tokenId) != msg.sender) revert EnglishAuction_Not_NFT_Owner();
        if (duration == 0) revert EnglishAuction_Not_Zero();
        if (reservePrice == 0) revert EnglishAuction_Not_Zero();

        nftContract.transferFrom(msg.sender, address(this), tokenId);
        auctions[tokenId] = Auction({
            ended: false,
            seller: msg.sender,
            highestBidder: address(0),
            highestBid: 0,
            reservePrice: reservePrice,
            deadline: block.timestamp + duration
        });

        emit AuctionCreated(tokenId, reservePrice, block.timestamp + duration);
    }

    function placeBid(uint256 tokenId) external payable {
        Auction memory auction = auctions[tokenId];
        if (block.timestamp > auction.deadline) revert EnglishAuction_Expired();
        if (msg.value <= auction.highestBid) revert EnglishAuction_Bid_Is_Low();

        // refund previous highest bidder
        if (auction.highestBidder != address(0)) {
            bids[tokenId][auction.highestBidder] += auction.highestBid;
        }

        // update new highest bidder
        auctions[tokenId].highestBidder = msg.sender;
        auctions[tokenId].highestBid = msg.value;

        emit BidPlaced(tokenId, msg.sender, msg.value);
    }

    function withdrawBid(uint256 tokenId) external nonReentrant {
        uint256 bid = bids[tokenId][msg.sender];
        if (bid <= 0) revert EnglishAuction_Nothing_To_Withdraw();

        bids[tokenId][msg.sender] = 0;
        payable(msg.sender).transfer(bid);
    }

    function sellerEndAuction(uint256 tokenId) external nonReentrant {
        Auction memory auction = auctions[tokenId];
        if (msg.sender != auction.seller) revert EnglishAuction_Not_Seller();
        if (block.timestamp < auction.deadline) revert EnglishAuction_Not_Ended();
        if (auction.ended) revert EnglishAuction_Already_Ended();
        if (auction.highestBid < auction.reservePrice) revert EnglishAuction_Reserve_Price_Not_Meet();

        auctions[tokenId].ended = true;
        nftContract.transferFrom(address(this), auction.highestBidder, tokenId);
        payable(msg.sender).transfer(auction.highestBid);

        emit AuctionEnded(tokenId, auction.highestBidder, auction.highestBid);
    }

    function reclaimNFT(uint256 tokenId) external nonReentrant {
        Auction memory auction = auctions[tokenId];
        if (msg.sender != auction.seller) revert EnglishAuction_Not_Seller();
        if (block.timestamp < auction.deadline) revert EnglishAuction_Not_Ended();
        if (auction.ended) revert EnglishAuction_Already_Ended();
        if (auction.highestBid >= auction.reservePrice) revert EnglishAuction_Reserve_Price_Meet();

        auctions[tokenId].ended = true;
        nftContract.transferFrom(address(this), msg.sender, tokenId);
    }

    function getAuctionDetails(uint256 tokenId)
        external
        view
        returns (
            bool ended,
            address seller,
            address highestBidder,
            uint256 highestBid,
            uint256 reservePrice,
            uint256 deadline
        )
    {
        Auction memory auction = auctions[tokenId];
        return (
            auction.ended,
            auction.seller,
            auction.highestBidder,
            auction.highestBid,
            auction.reservePrice,
            auction.deadline
        );
    }
}
