// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {StakeTogether} from "../src/StakeTogether.sol";
import {Test} from "forge-std/Test.sol";
import {CloudCoin} from "../src/CloudCoin.sol";
import {DeployStakeTogether} from "../script/StakeTogether.s.sol";

contract TestStakeTogether is Test {
    CloudCoin coin;
    StakeTogether stakeTogether;

    address immutable OWNER = makeAddr("Owner");
    address immutable STAKER1 = makeAddr("Inv1nc");
    address immutable STAKER2 = makeAddr("Inv1nc");
    address immutable STAKER3 = makeAddr("Inv1nc");
    address immutable STAKER4 = makeAddr("Inv1nc");
    uint256 constant STARTING_BALANCE = 100;
    uint256 startTime;
    uint256 endTime;
    uint256 constant DURATION = 7 days;

    function setUp() external {
        vm.startPrank(OWNER);
        coin = new CloudCoin("CloudCoin", "CLOUD");

        startTime = block.timestamp;
        stakeTogether = new StakeTogether(address(coin), startTime);
        endTime = startTime + DURATION;

        coin.mint(address(stakeTogether), stakeTogether.totalReward());
        coin.mint(STAKER1, STARTING_BALANCE);
        coin.mint(STAKER2, STARTING_BALANCE);
        coin.mint(STAKER3, STARTING_BALANCE);
        coin.mint(STAKER4, STARTING_BALANCE);
        vm.stopPrank();
    }

    function testInvalidStake() external {
        vm.expectRevert(StakeTogether.StakeTogether_Amount_Not_Zero.selector);
        stakeTogether.stake(0);

        vm.warp(endTime);
        vm.expectRevert(StakeTogether.StakeTogether_Stake_Ended.selector);
        stakeTogether.stake(STARTING_BALANCE);
    }

    function testStake() public {
        vm.startPrank(STAKER1);

        coin.approve(address(stakeTogether), STARTING_BALANCE);
        stakeTogether.stake(STARTING_BALANCE);

        vm.stopPrank();

        assertEq(stakeTogether.stakes(STAKER1), STARTING_BALANCE);
        assertEq(stakeTogether.hasStaked(STAKER1), true);
    }

    function testInvalidDistributeReward() public {
        vm.expectRevert(StakeTogether.StakeTogether_No_Coins_Stacked.selector);
        vm.warp(endTime);
        stakeTogether.distributeReward();
    }

    function testStakeTogetherNotStarted() external {
        vm.expectRevert(StakeTogether.StakeTogether_Not_Started.selector);
        vm.warp(startTime - 1);
        stakeTogether.stake(STARTING_BALANCE);
    }

    function testStakeTogether_Not_Ended() external {
        vm.expectRevert(StakeTogether.StakeTogether_Not_Ended.selector);
        vm.warp(endTime - 1);
        stakeTogether.distributeReward();
    }

    function testInvalidWithdraw() external {
        testStake();

        vm.warp(endTime);
        vm.expectRevert(StakeTogether.StakeTogether_Reward_Not_Distributed.selector);
        stakeTogether.withdraw();

        stakeTogether.distributeReward();
        vm.expectRevert(StakeTogether.StakeTogether_No_Stake_To_Withdraw.selector);
        stakeTogether.withdraw();
    }

    function testWithdraw() external {
        testStake();
        vm.warp(endTime);
        stakeTogether.distributeReward();
        vm.prank(STAKER1);
        stakeTogether.withdraw();
        assertEq(coin.balanceOf(address(stakeTogether)), 0);
    }

    function testFailMintCloudCoin() external {
        coin.mint(address(this), STARTING_BALANCE);
    }

    function testDeployStakeTogether() external {
        DeployStakeTogether deploy = new DeployStakeTogether();
        deploy.run();
        assertTrue(address(deploy) != address(0));
    }
}
