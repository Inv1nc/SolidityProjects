// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {NFTSwap} from "../src/NFTSwap.sol";
import {NFTA, NFTB} from "../src/TwoNFTSetup.sol";
import {Test} from "forge-std/Test.sol";
import {DeployNFTSwap} from "../script/Deploy.s.sol";

contract TestNFTSwap is Test {
    NFTSwap nftSwap;
    NFTA nfta;
    NFTB nftb;

    uint256 constant MINT_COUNT = 10000;
    uint256 constant CANCEL_TIME = 1 days;

    address immutable USER1 = makeAddr("Inv1nc");
    address immutable USER2 = makeAddr("Ajay");
    address immutable OWNER = makeAddr("Owner");

    function setUp() external {
        vm.startPrank(USER1);
        nfta = new NFTA();
		for(uint256 i = 1; i <= MINT_COUNT; i++) {
			nfta.mint();
		}
		vm.stopPrank();

        vm.startPrank(USER2);
        nftb = new NFTB();
		for(uint256 i = 1; i <= MINT_COUNT; i++) {
			nftb.mint();
		}
		vm.stopPrank();

        vm.prank(OWNER);
        nftSwap = new NFTSwap(CANCEL_TIME);
    }

    function testInvalidCreateSwap() external {
        vm.startPrank(USER1);

        vm.expectRevert(NFTSwap.NFTSwap_Invalid_Contract_Addresses.selector);
        nftSwap.createSwap(address(0), 1, address(nftb), 1);

        vm.expectRevert(NFTSwap.NFTSwap_Invalid_Contract_Addresses.selector);
        nftSwap.createSwap(address(nfta), 1, address(0), 1);

        vm.expectRevert(NFTSwap.NFTSwap_Invalid_Token_ID.selector);
        nftSwap.createSwap(address(nfta), 0, address(nftb), 1);

        vm.expectRevert(NFTSwap.NFTSwap_Invalid_Token_ID.selector);
        nftSwap.createSwap(address(nfta), 1, address(nftb), 0);

        vm.expectRevert(NFTSwap.NFTSwap_Cannot_Swap_Same_NFT.selector);
        nftSwap.createSwap(address(nfta), 1, address(nfta), 1);

        vm.expectRevert(NFTSwap.NFTSwap_You_Not_Own_First_NFT.selector);
        nftSwap.createSwap(address(nftb), 1, address(nfta), 1);

        vm.expectRevert();
        nftSwap.createSwap(address(nfta), 1, address(nftb), 1);

        vm.stopPrank();
    }

    function testCreateSwap(uint256 id1, uint256 id2) public returns(uint256 swapId){
		vm.assume(0 < id1 && id1 <= MINT_COUNT);
		vm.assume(0 < id2 && id2 <= MINT_COUNT);
        vm.startPrank(USER1);

        nfta.approve(address(nftSwap), id1);
        swapId = nftSwap.createSwap(address(nfta), id1, address(nftb), id2);

        (
            address nft1Address,
            uint256 nft1Id,
            address nft1Owner,
            address nft2Address,
            uint256 nft2Id,
            address nft2Owner,
            bool swapExecuted,
            uint256 createdAt
        ) = nftSwap.getSwapDetails(swapId);

        assertEq(nft1Address, address(nfta));
        assertEq(nft1Id, id1);
        assertEq(nft1Owner, USER1);
        assertEq(nft2Id, id2);
        assertEq(nft2Address, address(nftb));
		assertEq(nft2Owner, address(0));
		assertEq(swapExecuted, false);
		assertEq(createdAt, block.timestamp);
		vm.stopPrank();
    }

	function testInvalidCancelSwap(uint256 id1, uint256 id2) external {
		vm.assume(0 < id1 && id1 <= MINT_COUNT);
		vm.assume(0 < id2 && id2 <= MINT_COUNT);
		uint256 swapId = testCreateSwap(id1, id2);

		vm.expectRevert(NFTSwap.NFTSwap_Not_Authorized_To_Cancel.selector);
		nftSwap.cancelSwap(swapId);

		vm.expectRevert(NFTSwap.NFTSwap_Cannot_Cancel_Yet.selector);
		vm.prank(USER1);
		nftSwap.cancelSwap(swapId);
	}

	function testDepositFailAfterCancel(uint256 id1, uint256 id2) external {
		vm.assume(0 < id1 && id1 <= MINT_COUNT);
		vm.assume(0 < id2 && id2 <= MINT_COUNT);
		uint256 swapId= testCreateSwap(id1, id2);

		vm.prank(USER1);
		vm.warp(block.timestamp + 1 days);
		nftSwap.cancelSwap(swapId);
		vm.expectRevert();
		nftSwap.depositAndExecuteSwap(swapId);
	}

	function testDepositAndExecuteSwap(uint256 id1, uint256 id2) public returns(uint256 swapId){
		vm.assume(0 < id1 && id1 <= MINT_COUNT);
		vm.assume(0 < id2 && id2 <= MINT_COUNT);
		(swapId)= testCreateSwap(id1, id2);
		vm.startPrank(USER2);

		nftb.approve(address(nftSwap), id2);
		nftSwap.depositAndExecuteSwap(swapId);

		(
            address nft1Address,
            uint256 nft1Id,
            address nft1Owner,
            address nft2Address,
            uint256 nft2Id,
            address nft2Owner,
            bool swapExecuted,
        ) = nftSwap.getSwapDetails(swapId);

		assertEq(nft1Address, address(nfta));
        assertEq(nft1Id, id1);
        assertEq(nft1Owner, USER1);
        assertEq(nft2Id, id2);
        assertEq(nft2Address, address(nftb));
		assertEq(nft2Owner, USER2);
		assertEq(swapExecuted, true);

		address nftaOwnerAfter = nfta.ownerOf(id1);
		address nftbOwnerAfter = nftb.ownerOf(id2);

		assertEq(nftbOwnerAfter, USER1);
		assertEq(nftaOwnerAfter, USER2);
		vm.stopPrank();
	}

	function testCancelFailAfterExecuted(uint256 id1, uint256 id2) external {
		vm.assume(0 < id1 && id1 <= MINT_COUNT);
		vm.assume(0 < id2 && id2 <= MINT_COUNT);
		uint256 swapId = testDepositAndExecuteSwap(id1, id2);
		vm.expectRevert(NFTSwap.NFTSwap_Swap_Already_Executed.selector);
		vm.prank(USER1);
		nftSwap.cancelSwap(swapId);
		vm.expectRevert(NFTSwap.NFTSwap_Swap_Already_Executed.selector);
		nftSwap.depositAndExecuteSwap(swapId);
	}

	function testDeploy() external {
		DeployNFTSwap deploy = new DeployNFTSwap();
		deploy.run(CANCEL_TIME);
		assertTrue(address(deploy) != address(0));
	}
}
