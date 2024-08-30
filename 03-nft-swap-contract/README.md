## NFT Swap Contract

Two people want to trade their NFTs in a trustless way. A user creates a swap on the contract, which is a pair of address, ids where the address is the smart contract address of the NFT and the id is the tokenId of the NFT. One person can deposit an NFT only if the id matches the address and id. The counterparty can deposit only if their NFT matches the address and id of the swap.

## Features

- **Trustless NFT Trading:** Two users can create a swap where both NFTs are held by the contract until both are deposited.
- **Secure Deposits:** A user can only deposit their NFT if the contract and token ID match the swap's predefined criteria.
- **Swap Execution:** Once both NFTs are deposited, swap will done automatically, transferring ownership of the NFTs between them.
- **Cancellation Option:** The original creator of the swap can cancel it after a specified time limit (set in the contract) if the swap has not been executed yet.

## Contract Details

### `Swap` Structure

The core logic revolves around the `Swap` struct:

```solidity
struct Swap {
    address nft1Address;
    uint256 nft1Id;
    address nft1Owner;
    address nft2Address;
    uint256 nft2Id;
    address nft2Owner;
    bool swapExecuted;
    uint256 createdAt;
}
```

### Core Functions

1. **`createSwap`**:
    - A user can create a swap by providing the contract address and token ID of both NFTs. The creator must be the owner of the first NFT.
    - The first NFT is deposited into the contract during swap creation.

2. **`depositAndExecuteSwap`**:
    - The second user deposits their NFT, provided it matches the conditions of the swap.
    - Once both NFTs are deposited, the swap is executed, and ownership is transferred.

3. **`cancelSwap`**:
    - The swap creator can cancel the swap if it hasn't been executed after the defined time limit. The first NFT is returned to its owner.

4. **`getSwapDetails`**:
    - Provides details of a specific swap, including the addresses, token IDs, and ownership status.


## Setup

1. Install dependencies:

    ```bash
    forge install
    ```

2. Compile the contract:

    ```bash
    forge build
    ```

3. Run tests:

    ```bash
    forge test
    ```

## Tests

The contract is fully tested using Foundry for multiple scenarios:

- Swap creation and successful execution.
- Handling invalid token addresses and IDs.
- Failed deposits after swap cancellation.
- Invalid cancel attempts after execution.

Test Suite Results:

```
Ran 7 tests for test/NFTSwap.t.sol:TestNFTSwap
[PASS] testCancelFailAfterExecuted(uint256,uint256) (runs: 256, μ: 357609, ~: 357609)
[PASS] testCreateSwap(uint256,uint256) (runs: 256, μ: 238127, ~: 238127)
[PASS] testDeploy() (gas: 515387850)
[PASS] testDepositAndExecuteSwap(uint256,uint256) (runs: 256, μ: 349919, ~: 349919)
[PASS] testDepositFailAfterCancel(uint256,uint256) (runs: 256, μ: 217885, ~: 217884)
[PASS] testInvalidCancelSwap(uint256,uint256) (runs: 256, μ: 246014, ~: 246014)
[PASS] testInvalidCreateSwap() (gas: 67684)
Suite result: ok. 7 passed; 0 failed; 0 skipped; finished in 4.85s (12.81s CPU time)
```

## Test Coverage

```
| File                | % Lines        | % Statements   | % Branches    | % Funcs       |
|---------------------|----------------|----------------|---------------|---------------|
| script/Deploy.s.sol | 100.00% (3/3)  | 100.00% (3/3)  | 100.00% (0/0) | 100.00% (1/1) |
| src/NFTSwap.sol     | 96.67% (29/30) | 97.50% (39/40) | 100.00% (0/0) | 83.33% (5/6)  |
| src/TwoNFTSetup.sol | 87.50% (7/8)   | 87.50% (7/8)   | 100.00% (0/0) | 75.00% (3/4)  |
| Total               | 95.12% (39/41) | 96.08% (49/51) | 100.00% (0/0) | 81.82% (9/11) |
```

- **Deploy.s.sol**: 100% Line Coverage
- **NFTSwap.sol**: 96.67% Line Coverage
- **TwoNFTSetup.sol**: 87.50% Line Coverage (Uncovered areas pertain to constructor functions)

---

## Considerations

- **Cancel Time Limit**: The swap creator can cancel the swap only after the specified `CANCEL_TIME_LIMIT`. This ensures both parties have enough time to deposit their NFTs.
- **Ownership Check**: The contract ensures the depositors are the rightful owners of the NFTs before allowing any deposit or swap execution.
- **Uncovered Areas**: Constructors are uncovered in tests but don't affect the core functionality.


