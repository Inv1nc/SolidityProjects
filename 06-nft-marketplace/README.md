# NFT Marketplace

This NFT Marketplace allows users to list, buy, and cancel sales of NFTs using a secure and decentralized approach. The key features include:

## Features

1. **Sell NFTs**:
   - Sellers can list their NFTs for sale by specifying a price and an expiration time.
   - Instead of locking the NFT in the contract, the seller grants approval to the marketplace contract to transfer the NFT upon a successful sale.
   - If a buyer purchases the NFT by paying the specified price before the expiration, the NFT is automatically transferred from the seller to the buyer, and the Ether is transferred to the seller.

2. **Buy NFTs**:
   - Buyers can purchase NFTs listed on the marketplace by paying the exact price set by the seller.
   - The transaction is only successful if the payment matches the listed price and the expiration time has not been reached.

3. **Cancel Listings**:
   - Sellers can cancel their listings at any time before the NFT is sold. This removes the listing from the marketplace, ensuring the NFT remains with the seller.

## Technical Overview

- **Smart Contract**: The contract uses `ReentrancyGuard` to prevent reentrancy attacks and `EnumerableSet` from OpenZeppelin to manage the list of token IDs for each contract.
- **Security**: The contract ensures only the owner can list an NFT, and proper checks are in place for approvals and ownership. Additionally, Ether can only be transferred via the `buy` function, preventing unauthorized transactions.

## Testing & Coverage

The contract has been fully tested with 100% coverage across all lines, statements, branches, and functions, ensuring robust and secure functionality.

### Test Results:

```
[PASS] testBuy() (gas: 294205)
[PASS] testCancel() (gas: 226114)
[PASS] testDeployScript() (gas: 2544419)
[PASS] testGetListedTokens() (gas: 468622)
[PASS] testInvalidBuy() (gas: 315363)
[PASS] testInvalidCancel() (gas: 284642)
[PASS] testInvalidSell() (gas: 166)
[PASS] testSell() (gas: 281151)
[PASS] testSellerRefuseEther() (gas: 413413)
[PASS] testSendDirectEth() (gas: 17325)
[PASS] testTokenDisprove() (gas: 118661)
```

```
| script/NFTMarketplace.s.sol | 100.00% (1/1)   | 100.00% (1/1)   | 100.00% (0/0) | 100.00% (1/1) |
| src/NFTMarketplace.sol      | 100.00% (32/32) | 100.00% (34/34) | 100.00% (3/3) | 100.00% (5/5) |
| src/NFTToken.sol            | 100.00% (4/4)   | 100.00% (4/4)   | 100.00% (0/0) | 100.00% (2/2) |
| test/NFTMarketplace.t.sol   | 100.00% (2/2)   | 100.00% (2/2)   | 100.00% (0/0) | 100.00% (1/1) |
| Total                       | 100.00% (39/39) | 100.00% (41/41) | 100.00% (3/3) | 100.00% (9/9) |
```

## How to Run

1. Install dependencies and compile:
   ```bash
   forge build
   ```

2. Run tests:
   ```bash
   forge test
   ```
