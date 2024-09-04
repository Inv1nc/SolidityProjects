## StakeTogether - Cloud Coin Staking Contract

### Overview

**StakeTogether** is a decentralized staking contract where users can stake **Cloud Coin** (an ERC20 token) and receive rewards based on the amount of tokens they have staked. The contract owns 1,000,000 Cloud Coins, and participants who stake their coins for 7 days will earn rewards proportional to their portion of the total stake.

### Features

- **Cloud Coin Staking**: Users can stake Cloud Coins, an ERC20 token, into the contract.
- **Reward Distribution**: After 7 days, rewards are distributed to users based on their contribution to the total stake.
- **Withdraw Stake**: Once the staking period ends and rewards are distributed, users can withdraw their original stake.
- **Proportional Rewards**: Users receive rewards proportional to the percentage of the total stake they contributed.
  
### Smart Contract Details

The contract is built using Solidity 0.8.25 and leverages the **SafeERC20** library from OpenZeppelin to ensure secure token transfers. Key functions include staking, distributing rewards, and withdrawing the original staked amount.

### Contract Flow

1. **Staking**: Users call the `stake` function to transfer their Cloud Coins into the contract during the staking period.
2. **Reward Distribution**: After 7 days, rewards are distributed using the `distributeReward` function. Each staker receives their share of the 1,000,000 Cloud Coin reward, proportional to the amount they staked.
3. **Withdraw**: Once rewards have been distributed, users can withdraw their initial staked amount.

### Key Functions

1. **`stake(uint256 amount)`**:
   - Allows users to stake Cloud Coins during the staking period.
   - Users can only stake once, and the function checks that the staking period has started but not ended.

2. **`distributeReward()`**:
   - Called after the 7-day staking period ends.
   - Distributes the reward pool (1,000,000 Cloud Coins) proportionally based on the users' staked amounts.
   - Prevents double distribution by setting a flag after rewards have been distributed.

3. **`withdraw()`**:
   - Allows users to withdraw their staked Cloud Coins after rewards have been distributed.

### Installation

1. Install dependencies:
    ```bash
    forge install
    ```

2. Compile the contract:
    ```bash
    forge compile
    ```

3. Run tests:
    ```bash
    forge test
    ```

```bash
[PASS] testDeployStakeTogether() (gas: 4399593)
[PASS] testFailMintCloudCoin() (gas: 8614)
[PASS] testInvalidDistributeReward() (gas: 15210)
[PASS] testInvalidStake() (gas: 19616)
[PASS] testInvalidWithdraw() (gas: 203504)
[PASS] testStake() (gas: 161223)
[PASS] testStakeTogetherNotStarted() (gas: 13687)
[PASS] testStakeTogether_Not_Ended() (gas: 13296)
[PASS] testWithdraw() (gas: 182257)
```

```bash
| script/StakeTogether.s.sol | 100.00% (3/3)  | 100.00% (3/3)  | 100.00% (0/0) | 100.00% (1/1) |
| src/CloudCoin.sol          | 100.00% (3/3)  | 100.00% (3/3)  | 100.00% (2/2) | 100.00% (2/2) |
| src/StakeTogether.sol      | 88.46% (23/26) | 89.66% (26/29) | 100.00% (1/1) | 83.33% (5/6)  |
| Total                      | 90.62% (29/32) | 91.43% (32/35) | 100.00% (3/3) | 88.89% (8/9)  |
```