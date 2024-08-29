//SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ERC20Token} from "../src/ERC20Token.sol";
import {TimeUnlockedERC20} from "../src/Vesting.sol";
import {Test} from "forge-std/Test.sol";

contract TestVesting is Test {
    ERC20Token token;
    TimeUnlockedERC20 vesting;
    uint256 constant TOTAL_ERC20_SUPPLY = 1000000;

    address immutable owner = makeAddr("owner");
    address immutable payer = makeAddr("payer");
    address immutable receiver = makeAddr("receiver");

    function setUp() external {
        vm.startPrank(owner);
        token = new ERC20Token("100", "100", TOTAL_ERC20_SUPPLY);
        token.transfer(payer, TOTAL_ERC20_SUPPLY);
        vesting = new TimeUnlockedERC20(address(token));
        vm.stopPrank();
    }

    function testInvalidDesposits() external {
        vm.startPrank(payer);

        vm.expectRevert(TimeUnlockedERC20.TimeUnlockedERC20_VestingDays_Not_Equal_To_Zero.selector);
        vesting.depositTokens(1, receiver, 0);

		vm.expectRevert(TimeUnlockedERC20.TimeUnlockedERC20_Vesting_Amount_Not_Equal_To_Zero.selector);
		vesting.depositTokens(0, receiver, 1);

		vm.expectRevert(TimeUnlockedERC20.TimeUnlockedERC20_Invalid_Receiver.selector);
		vesting.depositTokens(1, address(0), 1);

		vm.expectRevert();
		vesting.depositTokens(1, receiver, 1);

		// deposit
		token.approve(address(vesting), 10);
		vesting.depositTokens(5, receiver, 1);
		vm.expectRevert(TimeUnlockedERC20.TimeUnlockedERC20_Already_Deposited_For_Receiver.selector);
		vesting.depositTokens(5, receiver, 1);
    }

	function testDepositTokens(uint256 amount, uint256 _days) public {
		vm.assume(amount > 0 && amount <= TOTAL_ERC20_SUPPLY);
		vm.assume(_days > 0 && _days < amount);

		vm.startPrank(payer);
		token.approve(address(vesting),amount);
		vesting.depositTokens(amount, receiver, _days);
		vm.stopPrank();

        (address _receiver,
        uint256 totalAmount,
        uint256 depositTime,
        uint256 vestingDays,
        uint256 withdrawnAmount,
        bool isDeposited
    	) = vesting.getVestingInfo(payer, receiver);

		assertEq(_receiver, receiver);
		assertEq(totalAmount, amount);
		assertEq(depositTime, block.timestamp);
		assertEq(vestingDays, _days);
		assertEq(withdrawnAmount, 0);
		assertTrue(isDeposited);
	}

	function testwithdrawableAmount(uint256 amount, uint256  _days) external {
		testDepositTokens(amount, _days);

		vm.startPrank(receiver);
		assertEq(vesting.withdrawableAmount(payer, receiver), 0);

		for(uint256 i = 1; i < _days; i++) {
			vm.warp(block.timestamp + 1 days);

			uint256 withdrawableAmount = vesting.withdrawableAmount(payer, receiver);

			uint256 expectedWithdrawAmount = (i * amount) / _days;
			assertEq(withdrawableAmount, expectedWithdrawAmount);
		}

		vm.warp(block.timestamp + 1 days);
		assertEq(vesting.withdrawableAmount(payer, receiver), amount);

		vm.stopPrank();
	}

	function testWithdrawTokens(uint256 amount, uint256 _days) external {
		testDepositTokens(amount, _days);

		vm.startPrank(receiver);
		assertEq(token.balanceOf(receiver), 0);

		for(uint256 i = 1; i < _days; i++) {
			vm.warp(block.timestamp + 1 days);
			uint256 expectedTokens = (i * amount) / _days;

			vesting.withdrawTokens(payer);

			uint256 actualTokens = token.balanceOf(receiver);
			assertEq(actualTokens, expectedTokens);
		}

		vm.warp(block.timestamp + 1 days);
		vesting.withdrawTokens(payer);
		assertEq(token.balanceOf(receiver), amount);
	}

	function testInvalidWithdraw() external {
		vm.startPrank(payer);
		token.approve(address(vesting), 10);
		vesting.depositTokens(5, receiver, 1);
		vm.stopPrank();

		vm.prank(receiver);
		vm.expectRevert(TimeUnlockedERC20.TimeUnlockedERC20_No_Tokens_Available.selector);
		vesting.withdrawTokens(payer);
	}

	function testisDepositReset(uint256 amount) external {
		vm.assume(amount > 0 && amount < TOTAL_ERC20_SUPPLY / 2);
		vm.startPrank(payer);
		token.approve(address(vesting), amount);
		vesting.depositTokens(amount, receiver, 1);
		vm.stopPrank();

		vm.prank(receiver);
		vm.warp(block.timestamp + 1 days);
		vesting.withdrawTokens(payer);

		vm.startPrank(payer);
		token.approve(address(vesting), amount);
		vesting.depositTokens(amount, receiver, 1);
	}
}
