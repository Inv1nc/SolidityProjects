// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract EthCrowdFunding is ReentrancyGuard {
    struct Fundraiser {
        address creator;
        uint256 goal;
        uint256 deadline;
        uint256 totalFunds;
        bool withdrawn;
    }

    mapping(uint256 => Fundraiser) public fundraisers;
    mapping(uint256 => mapping(address => uint256)) donations;
    uint256 public fundraiserIdCounter;

    // events
    event FundraiserCreated(uint256 fundraiserId, address creator, uint256 goal, uint256 deadline);
    event DonationReceived(uint256 fundraiserId, address donator, uint256 amount);
    event FundsWithdrawn(uint256 fundraiserId, address creator, uint256 totalFunds);
    event DonationRefunded(uint256 fundraiserId, address donator, uint256 donationAmount);

    // errors
    error EthCrowdFunding_Invalid_Deadline();
    error EthCrowdFunding_Must_Send_Ether();
    error EthCrowdFunding_Only_Creator_Can_Withdraw();
    error EthCrowdFunding_Fundraiser_Ended();
    error EthCrowdFunding_Deadline_Not_Reached();
    error EthCrowFunding_Not_Donated();
    error EthCrowdFunding_Goal_Reached();
    error EthCrowdFunding_Invalid_Fundraiser();
    error EthCrowdFunding_Goal_Not_Reached();
    error EthCrowdFunding_Already_Withdrawn();

    function createFundraiser(uint256 goal, uint256 deadline) external {
        if (block.timestamp >= deadline) revert EthCrowdFunding_Invalid_Deadline();
        fundraisers[fundraiserIdCounter] =
            Fundraiser({creator: msg.sender, goal: goal, deadline: deadline, totalFunds: 0, withdrawn: false});

        emit FundraiserCreated(fundraiserIdCounter, msg.sender, goal, deadline);
        fundraiserIdCounter++;
    }

    function donate(uint256 fundraiserId) external payable {
        Fundraiser storage fundraiser = fundraisers[fundraiserId];

        if (msg.value <= 0) revert EthCrowdFunding_Must_Send_Ether();
        if (fundraiserId >= fundraiserIdCounter) revert EthCrowdFunding_Invalid_Fundraiser();
        if (fundraiser.deadline < block.timestamp) revert EthCrowdFunding_Fundraiser_Ended();

        fundraiser.totalFunds += msg.value;
        donations[fundraiserId][msg.sender] += msg.value;

        emit DonationReceived(fundraiserId, msg.sender, msg.value);
    }

    function withdrawFunds(uint256 fundraiserId) external nonReentrant {
        Fundraiser memory fundraiser = fundraisers[fundraiserId]; // load to memory - gas optimisation

        if (msg.sender != fundraiser.creator) revert EthCrowdFunding_Only_Creator_Can_Withdraw();
        if (block.timestamp < fundraiser.deadline) revert EthCrowdFunding_Deadline_Not_Reached();
        if (fundraiser.totalFunds < fundraiser.goal) revert EthCrowdFunding_Goal_Not_Reached();
        if (fundraiser.withdrawn) revert EthCrowdFunding_Already_Withdrawn();

        fundraisers[fundraiserId].withdrawn = true; // write to storage
        payable(fundraiser.creator).transfer(fundraiser.totalFunds);
        emit FundsWithdrawn(fundraiserId, fundraiser.creator, fundraiser.totalFunds);
    }

    function refundDonations(uint256 fundraiserId) external nonReentrant {
        Fundraiser memory fundraiser = fundraisers[fundraiserId];
        if (block.timestamp < fundraiser.deadline) revert EthCrowdFunding_Deadline_Not_Reached();
        if (fundraiser.totalFunds >= fundraiser.goal) revert EthCrowdFunding_Goal_Reached();

        uint256 donationAmount = donations[fundraiserId][msg.sender];
        if (donationAmount <= 0) revert EthCrowFunding_Not_Donated();

        donations[fundraiserId][msg.sender] = 0;
        payable(msg.sender).transfer(donationAmount);

        emit DonationRefunded(fundraiserId, msg.sender, donationAmount);
    }

    function getFundraiserDetails(uint256 fundraiserId)
        external
        view
        returns (address creator, uint256 goal, uint256 deadline, uint256 totalFunds, bool withdrawn)
    {
        Fundraiser memory fundraiser = fundraisers[fundraiserId];
        return (fundraiser.creator, fundraiser.goal, fundraiser.deadline, fundraiser.totalFunds, fundraiser.withdrawn);
    }
}
