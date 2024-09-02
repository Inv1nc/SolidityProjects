// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {EthCrowdFunding} from "../src/EthCrowdFunding.sol";
import {Test} from "forge-std/Test.sol";
import {DeployEthCrowdFunding} from "../script/EthCrowdFunding.s.sol";

contract TestEthCrowdFunding is Test {
    EthCrowdFunding funding;

    address immutable OWNER = makeAddr("Owner");
    address immutable CREATOR = makeAddr("Creator");
    address immutable DONATOR1 = makeAddr("Inv1nc");

    uint256 constant GOAL = 10 ether;
    uint256 constant TIME = 1 days;

    uint256 constant fundraiserId = 0;

    function setUp() external {
        funding = new EthCrowdFunding();
    }

    function testETHCreateFundraiserInvalidDeadline() external {
        vm.expectRevert(EthCrowdFunding.EthCrowdFunding_Invalid_Deadline.selector);
        funding.createFundraiser(GOAL, block.timestamp);
    }

    function testETHCreateFundraiser() public {
        vm.prank(CREATOR);
        funding.createFundraiser(GOAL, block.timestamp + TIME);
        assertEq(funding.fundraiserIdCounter(), 1);
    }

    function testETHInvalidDonate() external {
        testETHCreateFundraiser();

        vm.expectRevert(EthCrowdFunding.EthCrowdFunding_Must_Send_Ether.selector);
        funding.donate(fundraiserId);

        vm.expectRevert(EthCrowdFunding.EthCrowdFunding_Invalid_Fundraiser.selector);
        funding.donate{value: 1 wei}(fundraiserId + 1);

        vm.warp(block.timestamp + TIME + 1);
        vm.expectRevert(EthCrowdFunding.EthCrowdFunding_Fundraiser_Ended.selector);
        funding.donate{value: 1 wei}(fundraiserId);
    }

    function testETHDonate(uint256 amount) public {
        vm.assume(amount > 0);
        testETHCreateFundraiser();
        vm.deal(DONATOR1, amount);

        vm.prank(DONATOR1);
        funding.donate{value: amount}(fundraiserId);

        (address creator, uint256 goal, uint256 deadline, uint256 totalFunds, bool withdrawn) =
            funding.getFundraiserDetails(fundraiserId);
        assertEq(creator, CREATOR);
        assertEq(goal, GOAL);
        assertLt(block.timestamp, deadline);
        assertEq(totalFunds, amount);
        assertEq(withdrawn, false);
    }

    function testEthWithdraw(uint256 amount) external {
        vm.assume(amount >= GOAL);
        testETHDonate(amount);

        vm.warp(block.timestamp + TIME);
        vm.prank(CREATOR);
        funding.withdrawFunds(fundraiserId);
        assertEq(CREATOR.balance, amount);
    }

    function testETHRefundDonation(uint256 amount) external {
        vm.assume(amount < GOAL);
        testETHDonate(amount);

        vm.warp(block.timestamp + TIME);
        vm.prank(DONATOR1);
        funding.refundDonations(fundraiserId);
        assertEq(DONATOR1.balance, amount);
    }

    function testETH20DeployScript() external {
        DeployEthCrowdFunding deploy = new DeployEthCrowdFunding();
        deploy.run();
        assertTrue(address(deploy) != address(0));
    }
}
