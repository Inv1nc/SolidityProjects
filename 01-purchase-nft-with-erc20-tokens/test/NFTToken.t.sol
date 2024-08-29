// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {NFTToken} from "../src/NFTToken.sol";
import {Test, console} from "forge-std/Test.sol";
import {ERC20Token} from "../src/ERC20Token.sol";
import {DeployNFTToken} from "../script/NFTToken.s.sol";

contract TestNFT is Test {
    NFTToken nft;
    ERC20Token erc20;

    uint256 constant mintPrice = 1;
    uint256 constant STARTING_BALANCE = 10 ether;
    address immutable OWNER = makeAddr("Owner");
    address immutable USER1 = makeAddr("Inv1nc");

    function setUp() external {
        vm.startPrank(OWNER);
        erc20 = new ERC20Token("Hai", "hai", mintPrice);
        nft = new NFTToken("Hello", "hlo", address(erc20), mintPrice);
        vm.stopPrank();
        vm.deal(USER1, STARTING_BALANCE);
    }

    function testMintPrice() external view {
        assertEq(nft.mintPrice(), mintPrice);
    }

    function testPaymentToken() external view {
        address paymentToken = address(nft.paymentToken());
        assertEq(paymentToken, address(erc20));
    }

    function testBuyERC20(uint256 BUY_ITEM) public {
        vm.assume(BUY_ITEM <= (STARTING_BALANCE / 1 ether));
        uint256 BALANCE_BEFORE = erc20.balanceOf(USER1);
        vm.prank(USER1);
        erc20.mint{value: BUY_ITEM * 1 ether}(BUY_ITEM);
        uint256 BALANCE_AFTER = erc20.balanceOf(USER1);
        assertEq(BALANCE_BEFORE + BUY_ITEM, BALANCE_AFTER);
    }

    function testMintERC20FailOnIncorrectValue(uint256 BUY_ITEM) public {
        vm.assume(BUY_ITEM <= (STARTING_BALANCE / 1 ether));
        vm.assume(BUY_ITEM != 0);
        vm.startPrank(USER1);
        vm.expectRevert();
        erc20.mint(BUY_ITEM);
        vm.expectRevert();
        erc20.mint{value: BUY_ITEM * 2 ether}(BUY_ITEM);
        vm.expectRevert();
        erc20.mint{value: BUY_ITEM * 1e17}(BUY_ITEM);
    }

    function testERC20Burn(uint256 BUY_ITEM) external {
        vm.assume(BUY_ITEM <= (STARTING_BALANCE / 1 ether));
        uint256 BALANCE_BEFORE = erc20.balanceOf(USER1);
        vm.prank(USER1);
        erc20.burn(BALANCE_BEFORE);
        assertEq(USER1.balance, STARTING_BALANCE);
        uint256 BALANCE_AFTER = erc20.balanceOf(USER1);
        assertEq(BALANCE_AFTER, 0);
    }

    function testNFTMint(uint256 BUY_ITEM) public {
        vm.assume(BUY_ITEM <= (STARTING_BALANCE / 1 ether));
        testBuyERC20(BUY_ITEM);
        vm.startPrank(USER1);
        erc20.approve(address(nft), BUY_ITEM);
        for (uint256 i = 0; i < BUY_ITEM; i++) {
            uint256 newItem = nft.tokenCounter();
            nft.mintNFT();
            assertEq(USER1, nft.ownerOf(newItem));
        }
        vm.stopPrank();
        assertEq(BUY_ITEM, nft.balanceOf(USER1));
    }

    function testNFTMintFailOnNoApprove(uint256 BUY_ITEM) public {
        vm.assume(BUY_ITEM <= (STARTING_BALANCE / 1 ether));
        vm.assume(BUY_ITEM != 0);
        testBuyERC20(BUY_ITEM);
        vm.startPrank(USER1);
        for (uint256 i = 0; i < BUY_ITEM; i++) {
            vm.expectRevert();
            nft.mintNFT();
        }
        vm.stopPrank();
        assertEq(BUY_ITEM, erc20.balanceOf(USER1));
        assertEq(nft.balanceOf(USER1), 0);
    }

    function testNFTFailInsufficientERC20() external {
        vm.prank(USER1);
        vm.expectRevert();
        nft.mintNFT();
    }

    function testWithdrawOwner(uint256 BUY_ITEM) external {
        vm.assume(BUY_ITEM <= (STARTING_BALANCE / 1 ether));
        vm.assume(BUY_ITEM != 0);
        testNFTMint(BUY_ITEM);
        vm.startPrank(OWNER);
        nft.withdrawTokens();
        uint256 BALANCE_BEFORE = erc20.balanceOf(OWNER);
        assertEq(BUY_ITEM, BALANCE_BEFORE);
        erc20.burn(BALANCE_BEFORE);
        uint256 BALANCE_AFTER = erc20.balanceOf(OWNER);
        assertEq(BALANCE_AFTER, 0);
        assertEq(OWNER.balance, BUY_ITEM * 1 ether);
    }

    function testWithdrawFailOnNotOwner(uint256 BUY_ITEM) external {
        vm.assume(BUY_ITEM <= (STARTING_BALANCE / 1 ether));
        testNFTMint(BUY_ITEM);
        vm.expectRevert();
        vm.prank(USER1);
        nft.withdrawTokens();
    }

    function testWithdrawFailOnNoBalance() external {
        vm.expectRevert();
        vm.prank(OWNER);
        nft.withdrawTokens();
    }

    function testfuzzNFTDeployment(string memory _name, string memory _symbol, uint256 _mintPrice) external {
        vm.assume((_mintPrice <= (type(uint256).max / 1 ether)));
        ERC20Token _erc20 = new ERC20Token(_name, _symbol, _mintPrice);
        NFTToken _nft = new NFTToken(_name, _symbol, address(_erc20), _mintPrice);
        assertEq(_nft.owner(), address(this));
        assertEq(_nft.mintPrice(), _mintPrice);
        assertEq(address(_nft.paymentToken()), address(_erc20));
        assertEq(_nft.tokenCounter(), 1);
    }

    function testSetupDeployment() external {
        DeployNFTToken deployment = new DeployNFTToken();
        deployment.run();
        assertTrue(address(0) != address(deployment));
    }

    function onERC721Received(address, address, uint256, bytes calldata) public pure returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
