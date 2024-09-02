// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ERC20CrowdFunding is ReentrancyGuard {
    struct Fundraiser {
        address creator;
        uint256 goal;
        uint256 deadline;
        uint256 totalFunds;
        bool withdrawn;
    }

    IERC20 public token;

    mapping(uint256 => Fundraiser) public fundraisers;
    mapping(uint256 => mapping(address => uint256)) donations;
    uint256 public fundraiserIdCounter;

    constructor(address tokenAddress) {
        token = IERC20(tokenAddress);
    }

    // events
    event FundraiserCreated(uint256 fundraiserId, address creator, uint256 goal, uint256 deadline);
    event DonationReceived(uint256 fundraiserId, address donator, uint256 amount);
    event FundsWithdrawn(uint256 fundraiserId, address creator, uint256 totalFunds);
    event DonationRefunded(uint256 fundraiserId, address donator, uint256 donationAmount);

    // errors
    error ERC20CrowdFunding_Invalid_Deadline();
    error ERC20CrowdFunding_Fundraiser_Ended();
    error ERC20CrowdFunding_Must_Donate_Some_Tokens();
    error ERC20CrowdFunding_Token_Transfer_Failed();
    error ERC20CrowdFunding_Only_Creator_Can_Withdraw();
    error ERC20CrowdFunding_Deadline_Not_Reached();
    error ERC20CrowdFunding_Goal_Not_Reached();
    error ERC20CrowdFunding_Already_Withdrawn();
    error ERC20CrowdFunding_Goal_Reached();
    error ERC20CrowFunding_Not_Donated();

    function createFundraiser(uint256 goal, uint256 deadline) external {
        if (block.timestamp >= deadline) revert ERC20CrowdFunding_Invalid_Deadline();
        fundraisers[fundraiserIdCounter] =
            Fundraiser({creator: msg.sender, goal: goal, deadline: deadline, totalFunds: 0, withdrawn: false});

        emit FundraiserCreated(fundraiserIdCounter, msg.sender, goal, deadline);
        fundraiserIdCounter++;
    }

    function donate(uint256 fundraiserId, uint256 amount) external payable {
        Fundraiser storage fundraiser = fundraisers[fundraiserId];

        if (fundraiser.deadline < block.timestamp) revert ERC20CrowdFunding_Fundraiser_Ended();
        if (amount <= 0) revert ERC20CrowdFunding_Must_Donate_Some_Tokens();

        bool success = token.transferFrom(msg.sender, address(this), amount);
        if (!success) revert ERC20CrowdFunding_Token_Transfer_Failed();

        fundraiser.totalFunds += amount;
        donations[fundraiserId][msg.sender] += amount;

        emit DonationReceived(fundraiserId, msg.sender, amount);
    }

    function withdrawFunds(uint256 fundraiserId) external nonReentrant {
        Fundraiser memory fundraiser = fundraisers[fundraiserId]; // load to memory - gas optimisation

        if (msg.sender != fundraiser.creator) revert ERC20CrowdFunding_Only_Creator_Can_Withdraw();
        if (block.timestamp < fundraiser.deadline) revert ERC20CrowdFunding_Deadline_Not_Reached();
        if (fundraiser.totalFunds < fundraiser.goal) revert ERC20CrowdFunding_Goal_Not_Reached();
        if (fundraiser.withdrawn) revert ERC20CrowdFunding_Already_Withdrawn();

        fundraisers[fundraiserId].withdrawn = true; // write to storage
        bool success = token.transfer(fundraiser.creator, fundraiser.totalFunds);
        if (!success) revert ERC20CrowdFunding_Token_Transfer_Failed();

        emit FundsWithdrawn(fundraiserId, fundraiser.creator, fundraiser.totalFunds);
    }

    function refundDonations(uint256 fundraiserId) external nonReentrant {
        Fundraiser memory fundraiser = fundraisers[fundraiserId];
        if (block.timestamp < fundraiser.deadline) revert ERC20CrowdFunding_Deadline_Not_Reached();
        if (fundraiser.totalFunds >= fundraiser.goal) revert ERC20CrowdFunding_Goal_Reached();

        uint256 donationAmount = donations[fundraiserId][msg.sender];
        if (donationAmount <= 0) revert ERC20CrowFunding_Not_Donated();

        donations[fundraiserId][msg.sender] = 0;
        bool success = token.transfer(msg.sender, donationAmount);
        if (!success) revert ERC20CrowdFunding_Token_Transfer_Failed();

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
