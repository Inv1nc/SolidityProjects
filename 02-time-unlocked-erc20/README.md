# Time unlocked ERC20 / vesting contract

A time-locked ERC20 or vesting contract allows a payer to deposit a certain amount of tokens for a receiver, but the receiver can only withdraw a fraction (1/n) of the tokens daily over a fixed number of days. This type of contract ensures controlled, periodic token releases instead of providing the entire amount at once. It's useful for salary payments, equity vesting, or gradual token distribution in decentralized systems.



Key Features:
1. Payer: The person depositing tokens into the contract.
2. Receiver: The person entitled to withdraw tokens, but only 1/n per day over n days.
3. Tokens: The ERC20 tokens locked in the contract.
4. Vesting Period: The number of days over which the tokens are gradually released.



Events:

TokensDeposited: Emitted when the payer deposits tokens.
TokensWithdrawn: Emitted when the receiver withdraws tokens.

depositTokens(uint256 amount, address receiver, uint256 days): Allows the payer to deposit tokens.
withdrawTokens(): Allows the receiver to withdraw tokens based on the time passed.
getWithdrawableAmount(): Helper function to calculate how many tokens the receiver can withdraw.


When the deposit is made, the depositTime is recorded.
The receiver can withdraw tokens, but only the allowed portion each day.
The smart contract tracks how many tokens have been withdrawn and ensures the withdrawal happens gradually.

Security Considerations:

Ensure that the contract checks for re-entrancy vulnerabilities.
Properly handle the case where tokens are withdrawn only once per day.
Use OpenZeppelin's ERC20 standard for token interactions.

```
Ran 6 tests for test/Vesting.t.sol:TestVesting
[PASS] testDepositTokens(uint256,uint256) (runs: 258, μ: 184113, ~: 184113)
[PASS] testInvalidDesposits() (gas: 244622)
[PASS] testInvalidWithdraw() (gas: 202407)
[PASS] testWithdrawTokens(uint256,uint256) (runs: 258, μ: 54504970, ~: 30119682)
[PASS] testisDepositReset(uint256) (runs: 260, μ: 264140, ~: 264140)
[PASS] testwithdrawableAmount(uint256,uint256) (runs: 258, μ: 21620209, ~: 11978271)
Suite result: ok. 6 passed; 0 failed; 0 skipped; finished in 264.72s (420.63s CPU time)
```

```
| File               | % Lines        | % Statements   | % Branches    | % Funcs       |
|--------------------|----------------|----------------|---------------|---------------|
| src/ERC20Token.sol | 100.00% (1/1)  | 100.00% (1/1)  | 100.00% (0/0) | 100.00% (1/1) |
| src/Vesting.sol    | 96.43% (27/28) | 97.22% (35/36) | 71.43% (5/7)  | 83.33% (5/6)  |
| Total              | 96.55% (28/29) | 97.30% (36/37) | 71.43% (5/7)  | 85.71% (6/7)  |
```


```
Uncovered for src/Vesting.sol:
- Function "" (location: source ID 30, line 19, chars 494-573, hits: 0)
- Line (location: source ID 30, line 20, chars 538-566, hits: 0)
- Statement (location: source ID 30, line 20, chars 538-566, hits: 0)
- Branch (branch: 0, path: 0) (location: source ID 30, line 40, chars 1516-1565, hits: 0)
- Line (location: source ID 30, line 41, chars 1530-1554, hits: 0)
- Statement (location: source ID 30, line 41, chars 1530-1554, hits: 0)
- Branch (branch: 5, path: 0) (location: source ID 30, line 53, chars 2114-2201, hits: 0)
- Branch (branch: 8, path: 0) (location: source ID 30, line 76, chars 2997-3071, hits: 0)
```


