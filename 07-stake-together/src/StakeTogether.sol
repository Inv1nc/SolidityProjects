// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {CloudCoin} from "./CloudCoin.sol";

contract StakeTogether {
    using SafeERC20 for CloudCoin;

    CloudCoin public cloudCoin;
    uint256 public totalReward = 1_000_000;
    uint256 public totalStaked;
    uint256 public startTime;
    uint256 public endTime;
    uint256 constant DURATION = 7 days;

    mapping(address => uint256) public stakes;
    mapping(address => bool) public hasStaked;
    mapping(address => bool) rewardsClaimed;

    address[] public stakers;
    bool public rewardsDistributed;

    constructor(address cloudCoinAddress, uint256 _startTime) {
        cloudCoin = CloudCoin(cloudCoinAddress);
        startTime = _startTime;
        endTime = _startTime + DURATION;
    }

    // events
    event Staked(address indexed user, uint256 amount);
    event RewardDistributed(uint256 totalReward);
    event Withdrawn(address indexed user, uint256 amount);

    // errors
    error StakeTogether_Amount_Not_Zero();
    error StakeTogether_Stake_Ended();
    error StakeTogether_No_Coins_Stacked();
    error StakeTogether_Reward_Not_Distributed();
    error StakeTogether_No_Stake_To_Withdraw();
    error StakeTogether_Not_Started();
    error StakeTogether_Not_Ended();

    modifier onlyAfterStart() {
        if (block.timestamp < startTime) revert StakeTogether_Not_Started();
        _;
    }

    modifier onlyAfterEnded() {
        if (block.timestamp < endTime) revert StakeTogether_Not_Ended();
        _;
    }

    function stake(uint256 amount) external onlyAfterStart {
        if (amount <= 0) revert StakeTogether_Amount_Not_Zero();
        if (block.timestamp >= endTime) revert StakeTogether_Stake_Ended();

        cloudCoin.safeTransferFrom(msg.sender, address(this), amount);
        if (!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
            hasStaked[msg.sender] = true;
        }

        stakes[msg.sender] += amount;
        totalStaked += amount;
        emit Staked(msg.sender, amount);
    }

    function distributeReward() external onlyAfterEnded {
        if (totalStaked == 0) revert StakeTogether_No_Coins_Stacked();

        rewardsDistributed = true;

        for (uint256 i = 0; i < stakers.length; i++) {
            address staker = stakers[i];
            uint256 stakedAmount = stakes[staker];
            uint256 reward = (stakedAmount * totalReward) / totalStaked;
            cloudCoin.safeTransfer(staker, reward);
        }
    }

    function withdraw() external onlyAfterEnded {
        if (!rewardsDistributed) revert StakeTogether_Reward_Not_Distributed();
        if (stakes[msg.sender] == 0) revert StakeTogether_No_Stake_To_Withdraw();

        uint256 stakedAmount = stakes[msg.sender];
        stakes[msg.sender] = 0;
        cloudCoin.safeTransfer(msg.sender, stakedAmount);
    }
}
