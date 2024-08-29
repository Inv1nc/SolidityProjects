// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract TimeUnlockedERC20 is ReentrancyGuard {
    IERC20 public token;

    struct VestingInfo {
        address receiver;
        uint256 totalAmount;
        uint256 depositTime;
        uint256 vestingDays;
        uint256 withdrawnAmount;
        bool isDeposited;
    }

    constructor(address tokenAddress) {
        token = IERC20(tokenAddress);
    }

    mapping(address payer => mapping(address receiver => VestingInfo)) private vestingData;

    // Events
    event TokensDeposited(address indexed payer, address indexed receiver, uint256 amount, uint256 _days);
    event TokensWithdrawn(address indexed payer, address indexed receiver, uint256 amount);

    // Errors
    error TimeUnlockedERC20_Already_Deposited_For_Receiver();
    error TimeUnlockedERC20_VestingDays_Not_Equal_To_Zero();
    error TimeUnlockedERC20_Vesting_Amount_Not_Equal_To_Zero();
    error TimeUnlockedERC20_Invalid_Receiver();
    error TimeUnlockedERC20_No_Tokens_Available();
    error TimeUnlockedERC20_No_Tokens_Deposited_By_Payer();
    error TimeUnlockedERC20_Contracts_Cannot_Withdraw();

    function _despositReset(address payer, address receiver) internal {
        VestingInfo storage info = vestingData[payer][receiver];
        if (info.totalAmount != 0 && info.totalAmount == info.withdrawnAmount) {
            info.isDeposited = false;
        }
    }

    function depositTokens(uint256 amount, address _receiver, uint256 _vestingDays) external nonReentrant {
        if (_vestingDays == 0) revert TimeUnlockedERC20_VestingDays_Not_Equal_To_Zero();
        if (amount == 0) revert TimeUnlockedERC20_Vesting_Amount_Not_Equal_To_Zero();
        if (_receiver == address(0)) revert TimeUnlockedERC20_Invalid_Receiver();

        _despositReset(msg.sender, _receiver);
        if (vestingData[msg.sender][_receiver].isDeposited) revert TimeUnlockedERC20_Already_Deposited_For_Receiver();

        require(token.transferFrom(msg.sender, address(this), amount), "Token Transfer Failed");

        vestingData[msg.sender][_receiver] = VestingInfo({
            totalAmount: amount,
            receiver: _receiver,
            vestingDays: _vestingDays,
            depositTime: block.timestamp,
            withdrawnAmount: 0,
            isDeposited: true
        });

       emit TokensDeposited(msg.sender, _receiver, amount, _vestingDays);
    }

    function withdrawTokens(address payer) external nonReentrant {
        VestingInfo storage info = vestingData[payer][msg.sender];

        if (!info.isDeposited) revert TimeUnlockedERC20_No_Tokens_Deposited_By_Payer();

        uint256 withdrawable = withdrawableAmount(payer, msg.sender);
        if (withdrawable == 0) revert TimeUnlockedERC20_No_Tokens_Available();
        info.withdrawnAmount += withdrawable;

        require(token.transfer(msg.sender, withdrawable), "Token Transfer Failed");

        emit TokensWithdrawn(payer, msg.sender, withdrawable);
    }

    function withdrawableAmount(address payer, address receiver) public view returns (uint256) {
        VestingInfo memory info = vestingData[payer][receiver];

        if (block.timestamp < info.depositTime) return 0;

        uint256 timePassed = block.timestamp - info.depositTime;
        uint256 vestedDays = timePassed / 1 days;

        if (vestedDays >= info.vestingDays) {
            return info.totalAmount - info.withdrawnAmount;
        } else {
            uint256 totalVested = (info.totalAmount * vestedDays) / info.vestingDays;
            return totalVested - info.withdrawnAmount;
        }
    }

    function getVestingInfo(address payer, address receiver)
    external
    view
    returns (
        address _receiver,
        uint256 totalAmount,
        uint256 depositTime,
        uint256 vestingDays,
        uint256 withdrawnAmount,
        bool isDeposited
    ) {
	    VestingInfo memory vestingInfo = vestingData[payer][receiver];

	    (_receiver, totalAmount, depositTime, vestingDays, withdrawnAmount, isDeposited) = (
	        vestingInfo.receiver,
	        vestingInfo.totalAmount,
	        vestingInfo.depositTime,
	        vestingInfo.vestingDays,
	        vestingInfo.withdrawnAmount,
	        vestingInfo.isDeposited
	    );
	}
}
