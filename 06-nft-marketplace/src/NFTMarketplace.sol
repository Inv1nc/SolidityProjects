// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract NFTMarketplace is ReentrancyGuard {
    using EnumerableSet for EnumerableSet.UintSet;

    struct Listing {
        address seller;
        uint256 price;
        uint256 expiration;
    }

    mapping(address => EnumerableSet.UintSet) private tokenIdListing;
    mapping(address nftContract => mapping(uint256 tokenId => Listing)) listings;

    // events
    event Listed(
        address indexed seller, address indexed nftContract, uint256 tokenId, uint256 price, uint256 expiration
    );
    event Purchased(
        address indexed nftContract, uint256 indexed tokenId, address indexed seller, address buyer, uint256 price
    );
    event ListingRemoved(address indexed nftContract, uint256 tokenId);

    // error
    error NFTMarketplace_Invalid_TokenId();
    error NFTMarketplace_Invalid_Duration();
    error NFTMarketplace_Token_Not_Approved();
    error NFTMarketplace_Token_Already_Listed();
    error NFTMarketplace_You_Are_Not_Token_Owner();
    error NFTMarketplace_Not_Available();
    error NFTMarketplace_Deadline_Reached();
    error NFTMarketplace_Invalid_Eth_Sent();
    error NFTMarketplace_Not_Seller();
    error NFTMarketplace_Direct_Eth_Transfer_Not_Allowed();

    function sell(address nftContract, uint256 tokenId, uint256 price, uint256 duration) external {
        if (tokenId == 0) revert NFTMarketplace_Invalid_TokenId();
        if (duration == 0) revert NFTMarketplace_Invalid_Duration();
        if (IERC721(nftContract).ownerOf(tokenId) != msg.sender) revert NFTMarketplace_You_Are_Not_Token_Owner();

        if (
            !(
                IERC721(nftContract).getApproved(tokenId) == address(this)
                    || IERC721(nftContract).isApprovedForAll(msg.sender, address(this))
            )
        ) {
            revert NFTMarketplace_Token_Not_Approved();
        }

        Listing storage listing = listings[nftContract][tokenId];

        if (listing.seller != address(0)) revert NFTMarketplace_Token_Already_Listed();

        uint256 expirationTime = block.timestamp + duration;
        listing.seller = msg.sender;
        listing.price = price;
        listing.expiration = expirationTime;

        tokenIdListing[nftContract].add(tokenId);

        emit Listed(msg.sender, nftContract, tokenId, price, expirationTime);
    }

    function buy(address nftContract, uint256 tokenId) external payable nonReentrant returns (bool success) {
        Listing memory listing = listings[nftContract][tokenId];
        if (listing.seller == address(0)) revert NFTMarketplace_Not_Available();
        if (block.timestamp > listing.expiration) revert NFTMarketplace_Deadline_Reached();
        if (msg.value != listing.price) revert NFTMarketplace_Invalid_Eth_Sent();

        delete listings[nftContract][tokenId];
        tokenIdListing[nftContract].remove(tokenId);

        IERC721(nftContract).transferFrom(listing.seller, msg.sender, tokenId);

        (success,) = listing.seller.call{value: msg.value}("");
        require(success, "Transfer failed");

        emit Purchased(nftContract, tokenId, listing.seller, msg.sender, msg.value);
    }

    function cancel(address nftContract, uint256 tokenId) external {
        Listing memory listing = listings[nftContract][tokenId];
        if (listing.seller != msg.sender) revert NFTMarketplace_Not_Seller();

        delete listings[nftContract][tokenId];
        tokenIdListing[nftContract].remove(tokenId);

        emit ListingRemoved(nftContract, tokenId);
    }

    function getListedTokens(address nftContract) external view returns (uint256[] memory) {
        return tokenIdListing[nftContract].values();
    }

    function getListing(address nftContract, uint256 tokenId)
        external
        view
        returns (address seller, uint256 price, uint256 expiration)
    {
        Listing memory listing = listings[nftContract][tokenId];
        return (listing.seller, listing.price, listing.expiration);
    }

    receive() external payable {
        revert NFTMarketplace_Direct_Eth_Transfer_Not_Allowed();
    }
}
