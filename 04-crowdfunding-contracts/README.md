# Crowdfunding Contracts for ETH and ERC20 Tokens

This project contains two smart contracts designed to facilitate crowdfunding for both Ether and ERC20 tokens. These contracts allow users to create fundraising campaigns with specific goals and deadlines, and they handle donations, withdrawals, and refunds based on the success of the campaign.

## Overview

### Contracts
1. **EthCrowdFunding.sol**: A crowdfunding contract that operates with Ether.
2. **ERC20CrowdFunding.sol**: A similar contract that operates with an ERC20 token.

Both contracts allow users to:
- Create a fundraiser with a specific goal and deadline.
- Donate to a specific campaign.
- Withdraw funds if the goal is met before the deadline.
- Request refunds if the goal is not met and the deadline has passed.

### Features
- **Multiple Donations**: Donators can contribute multiple times to the same campaign.
- **Multiple Campaigns**: The same address can donate to multiple different campaigns.
- **Dynamic Contributions**: Contributions can be made in either Ether or an ERC20 token, depending on the contract.

## Contracts Overview

### EthCrowdFunding.sol

This contract allows users to create fundraisers that accept Ether donations. Key functionalities include:
- `createFundraiser(uint256 goal, uint256 deadline)`: Allows users to create a fundraiser with a goal and deadline.
- `donate(uint256 fundraiserId)`: Accepts Ether donations to a specific fundraiser.
- `withdrawFunds(uint256 fundraiserId)`: Enables the fundraiser creator to withdraw funds if the goal is reached before the deadline.
- `refundDonation(uint256 fundraiserId)`: Allows donators to refund their donations if the goal is not met after the deadline.

### ERC20CrowdFunding.sol

This contract functions similarly to the Ether-based crowdfunding contract, but it operates with an ERC20 token. Key functionalities include:
- `createFundraiser(uint256 goal, uint256 deadline)`: Allows users to create a fundraiser with a goal and deadline.
- `donate(uint256 fundraiserId, uint256 amount)`: Allows users to donate ERC20 tokens to a specific fundraiser.
- `withdrawFunds(uint256 fundraiserId)`: Allows the fundraiser creator to withdraw funds if the goal is reached before the deadline.
- `refundDonation(uint256 fundraiserId)`: Allows donators to claim refunds if the goal is not met after the deadline.

## Testing

The project contains extensive tests written in Solidity, covering the critical functionalities of both contracts. The tests validate edge cases and the general behavior of the contracts.

### Test Results

#### EthCrowdFunding Tests:
- **testETHCreateFundraiser()**: Tests successful fundraiser creation (Gas: 106984)
- **testETHCreateFundraiserInvalidDeadline()**: Ensures an error is thrown for invalid deadlines (Gas: 9195)
- **testETHDonate(uint256)**: Validates donation functionality with multiple random runs (μ: 168788)
- **testETHInvalidDonate()**: Tests invalid donation scenarios (Gas: 127083)
- **testETHRefundDonation(uint256)**: Tests refunding donations when the goal is not met (μ: 190213)
- **testEthWithdraw(uint256)**: Validates the withdraw functionality when the goal is met (μ: 232375)

#### ERC20CrowdFunding Tests:
- **testERC20CreateFundraiser()**: Tests successful fundraiser creation (Gas: 107030)
- **testERC20Donate(uint256)**: Validates ERC20 token donations with multiple random runs (μ: 233990)
- **testERC20InvalidDonate()**: Tests invalid donation scenarios (Gas: 112384)
- **testERC20RefundDonation(uint256)**: Ensures refunds for failed campaigns (μ: 245550)
- **testERC20Withdraw(uint256)**: Validates the withdraw functionality for ERC20 tokens (μ: 271698)
- **testFailMintNotOwner(address,uint256)**: Ensures only the owner can mint new tokens (Gas: 9065)
- **testERC20CreateFundraiserInvalidDeadline()**: Ensures an error is thrown for invalid deadlines (Gas: 9151)

### Coverage

```
| File                           | % Lines         | % Statements    | % Branches    | % Funcs        |
|--------------------------------|-----------------|-----------------|---------------|----------------|
| script/ERC20CrowdFunding.s.sol | 100.00% (1/1)   | 100.00% (1/1)   | 100.00% (0/0) | 100.00% (1/1)  |
| script/EthCrowdFunding.s.sol   | 100.00% (1/1)   | 100.00% (1/1)   | 100.00% (0/0) | 100.00% (1/1)  |
| src/ERC20CrowdFunding.sol      | 96.88% (31/32)  | 97.14% (34/35)  | 100.00% (0/0) | 83.33% (5/6)   |
| src/ERC20Token.sol             | 100.00% (3/3)   | 100.00% (3/3)   | 100.00% (2/2) | 100.00% (2/2)  |
| src/EthCrowdFunding.sol        | 100.00% (28/28) | 100.00% (28/28) | 100.00% (0/0) | 100.00% (5/5)  |
| Total                          | 98.46% (64/65)  | 98.53% (67/68)  | 100.00% (2/2) | 93.33% (14/15) |
```

### How to Run the Tests

1. Clone the repository.
2. Install the necessary dependencies using:
   ```bash
   forge install
   ```
3. Run the tests using:
   ```bash
   forge test
   ```
