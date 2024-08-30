//SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NFTSwap {
    struct Swap {
        address nft1Address;
        uint256 nft1Id;
        address nft1Owner;
        address nft2Address;
        uint256 nft2Id;
        address nft2Owner;
        bool swapExecuted;
        uint256 createdAt;
    }

    uint256 public immutable CANCEL_TIME_LIMIT;

    constructor(uint256 cancelTime) {
        CANCEL_TIME_LIMIT = cancelTime;
    }

    mapping(uint256 => Swap) public swaps;
    uint256 public swapCounter;

    // Events
    event swapCreated(uint256 swapId);
    event swapDone(uint256 swapId);
    event swapCancelled(uint256 swapId);

    // Errors
    error NFTSwap_Invalid_Contract_Addresses();
    error NFTSwap_Invalid_Token_ID();
    error NFTSwap_Cannot_Swap_Same_NFT();
    error NFTSwap_You_Not_Own_First_NFT();
    error NFTSwap_NFT1_Not_Deposited();
    error NFTSwap_You_Not_Own_Second_NFT();
    error NFTSwap_Not_Authorized_To_Cancel();
    error NFTSwap_Swap_Already_Executed();
    error NFTSwap_Cannot_Cancel_Yet();
    error NFTSwap_NFT2_Already_Deposited();

    function createSwap(address nft1Address, uint256 nft1Id, address nft2Address, uint256 nft2Id)
        external
        returns (uint256)
    {
        if (nft1Address == address(0) || nft2Address == address(0)) revert NFTSwap_Invalid_Contract_Addresses();
        if (nft1Id == 0 || nft2Id == 0) revert NFTSwap_Invalid_Token_ID();
        if (nft1Address == nft2Address && nft1Id == nft2Id) revert NFTSwap_Cannot_Swap_Same_NFT();
        if (IERC721(nft1Address).ownerOf(nft1Id) != msg.sender) revert NFTSwap_You_Not_Own_First_NFT();

        IERC721(nft1Address).transferFrom(msg.sender, address(this), nft1Id);

        swapCounter++;
        swaps[swapCounter] = Swap({
            nft1Address: nft1Address,
            nft1Id: nft1Id,
            nft1Owner: msg.sender,
            nft2Address: nft2Address,
            nft2Id: nft2Id,
            nft2Owner: address(0),
            swapExecuted: false,
            createdAt: block.timestamp
        });

        emit swapCreated(swapCounter);
        return swapCounter;
    }

    function depositAndExecuteSwap(uint256 swapId) external {
        Swap memory swap = swaps[swapId];

        if (swap.swapExecuted) revert NFTSwap_Swap_Already_Executed();
        if (IERC721(swap.nft1Address).ownerOf(swap.nft1Id) != address(this)) revert NFTSwap_NFT1_Not_Deposited();
        if (IERC721(swap.nft2Address).ownerOf(swap.nft2Id) != msg.sender) revert NFTSwap_You_Not_Own_Second_NFT();
        if (swap.nft2Owner != address(0)) revert NFTSwap_NFT2_Already_Deposited();

        IERC721(swap.nft2Address).transferFrom(msg.sender, address(this), swap.nft2Id);
        swaps[swapId].nft2Owner = msg.sender;

        _executeSwap(swapId);
    }

    function _executeSwap(uint256 swapId) internal {
        Swap memory swap = swaps[swapId];

        swaps[swapId].swapExecuted = true;

        IERC721(swap.nft1Address).transferFrom(address(this), swap.nft2Owner, swap.nft1Id);
        IERC721(swap.nft2Address).transferFrom(address(this), swap.nft1Owner, swap.nft2Id);

        emit swapDone(swapId);
    }

    function cancelSwap(uint256 swapId) external {
        Swap memory swap = swaps[swapId];

        if (swap.swapExecuted) revert NFTSwap_Swap_Already_Executed();
        if (msg.sender != swap.nft1Owner) revert NFTSwap_Not_Authorized_To_Cancel();
        if (block.timestamp < swap.createdAt + CANCEL_TIME_LIMIT) revert NFTSwap_Cannot_Cancel_Yet();

        IERC721(swap.nft1Address).transferFrom(address(this), swap.nft1Owner, swap.nft1Id);

        delete swaps[swapId];

        emit swapCancelled(swapId);
    }

    function getSwapDetails(uint256 swapId)
        public
        view
        returns (
            address nft1Address,
            uint256 nft1Id,
            address nft1Owner,
            address nft2Address,
            uint256 nft2Id,
            address nft2Owner,
            bool swapExecuted,
            uint256 createdAt
        )
    {
        Swap memory swap = swaps[swapId];
        return (
            swap.nft1Address,
            swap.nft1Id,
            swap.nft1Owner,
            swap.nft2Address,
            swap.nft2Id,
            swap.nft2Owner,
            swap.swapExecuted,
            swap.createdAt
        );
    }
}
