// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ERC20CrowdFunding} from "../src/ERC20CrowdFunding.sol";
import {Test} from "forge-std/Test.sol";
import {ERC20Token} from "../src/ERC20Token.sol";
import {DeployERC20CrowdFunding} from "../script/ERC20CrowdFunding.s.sol";

contract TestERC20CrowdFunding is Test {
    ERC20CrowdFunding funding;

    address immutable OWNER = makeAddr("Owner");
    address immutable CREATOR = makeAddr("Creator");
    address immutable DONATOR1 = makeAddr("Inv1nc");

    uint256 constant GOAL = 1000;
    uint256 constant TIME = 1 days;

    uint256 constant fundraiserId = 0;

    ERC20Token token;

    function setUp() external {
        vm.prank(CREATOR);
        token = new ERC20Token("Token", "tkn");
        funding = new ERC20CrowdFunding(address(token));
    }

    function testRC20CreateFundraiserInvalidDeadline() external {
        vm.expectRevert(ERC20CrowdFunding.ERC20CrowdFunding_Invalid_Deadline.selector);
        funding.createFundraiser(GOAL, block.timestamp);
    }

    function testERC20CreateFundraiser() public {
        vm.prank(CREATOR);
        funding.createFundraiser(GOAL, block.timestamp + TIME);
        assertEq(funding.fundraiserIdCounter(), 1);
    }

    function testERC20InvalidDonate() external {
        testERC20CreateFundraiser();

        vm.expectRevert(ERC20CrowdFunding.ERC20CrowdFunding_Must_Donate_Some_Tokens.selector);
        funding.donate(fundraiserId, 0);

        vm.warp(block.timestamp + TIME + 1);
        vm.expectRevert(ERC20CrowdFunding.ERC20CrowdFunding_Fundraiser_Ended.selector);
        funding.donate(fundraiserId, 1);
    }

    function testERC20Donate(uint256 amount) public {
        vm.assume(amount > 0);
        testERC20CreateFundraiser();
        vm.prank(CREATOR);
        token.mint(DONATOR1, amount);

        vm.startPrank(DONATOR1);
        token.approve(address(funding), amount);
        funding.donate(fundraiserId, amount);
        vm.stopPrank();

        (address creator, uint256 goal, uint256 deadline, uint256 totalFunds, bool withdrawn) =
            funding.getFundraiserDetails(fundraiserId);
        assertEq(creator, CREATOR);
        assertEq(goal, GOAL);
        assertLt(block.timestamp, deadline);
        assertEq(totalFunds, amount);
        assertEq(withdrawn, false);
    }

    function testERC20Withdraw(uint256 amount) external {
        vm.assume(amount >= GOAL);
        testERC20Donate(amount);

        vm.warp(block.timestamp + TIME);
        vm.prank(CREATOR);
        funding.withdrawFunds(fundraiserId);
        assertEq(token.balanceOf(CREATOR), amount);
    }

    function testERC20RefundDonation(uint256 amount) external {
        vm.assume(amount < GOAL);
        testERC20Donate(amount);

        vm.warp(block.timestamp + TIME);
        vm.prank(DONATOR1);
        funding.refundDonations(fundraiserId);
        assertEq(token.balanceOf(DONATOR1), amount);
    }

    function testFailMintNotOwner(address mintAddress, uint256 amount) external {
        token.mint(mintAddress, amount);
    }

    function testERC20DeployScript() external {
        DeployERC20CrowdFunding deploy = new DeployERC20CrowdFunding();
        deploy.run(address(token));
        assertTrue(address(deploy) != address(0));
    }
}
