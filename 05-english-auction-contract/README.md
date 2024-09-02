## English Auction Smart Contract

### Overview

This project implements an **English Auction** smart contract where NFTs can be auctioned. A seller deposits an NFT into the auction with a reserve price and deadline. Buyers place bids until the auction expires, and the highest bid wins if it meets or exceeds the reserve price. If the reserve price is not met, the NFT is returned to the seller. 

Multiple auctions can happen simultaneously, and non-winning bidders can withdraw their bids. The contract ensures secure and fair auctions using Solidity, OpenZeppelin’s `IERC721` for NFT interaction, and Foundry for testing.

---

### Features

1. **Deposit NFT for Auction**
   - Sellers deposit an NFT into the contract along with a reserve price and a duration (auction deadline).
   
2. **Place Bids**
   - Buyers place bids on the NFT. Bids must be higher than the current highest bid, and bidding is only allowed before the auction deadline.

3. **Seller Ends Auction**
   - After the auction has ended (i.e., the deadline has passed), the seller can end the auction if the highest bid meets or exceeds the reserve price.
   - The highest bidder wins the auction and receives the NFT, while the seller is paid the winning bid in Ether.

4. **Withdraw Bid**
   - Non-winning bidders can withdraw their bids after the auction has ended.

5. **Reclaim NFT**
   - If the auction ends and the reserve price is not met, the seller can reclaim the NFT without transferring it to the highest bidder.

---

### Smart Contract Structure

#### 1. **`EnglishAuction` Contract**

The `EnglishAuction` contract handles the core auction functionalities:

- **Auction struct**: Defines the auction parameters including the seller, highest bidder, highest bid, reserve price, and deadline.
  
- **Mapping**:
  - `auctions`: Stores auction data for each NFT (identified by its `tokenId`).
  - `bids`: Tracks the amount bid by each address for each auction.
  
- **Constructor**:
  - Initializes the contract with the NFT contract address to ensure compatibility with the ERC-721 standard.

#### 2. **Key Functions**

- **`deposit(uint256 tokenId, uint256 reservePrice, uint256 duration)`**:
  - Allows the NFT owner to deposit an NFT into the auction, setting the reserve price and auction deadline.
  - Transfers the NFT from the seller to the contract and creates the auction.

- **`placeBid(uint256 tokenId)`**:
  - Allows buyers to place bids on the NFT. The bid must be higher than the current highest bid.
  - If there was a previous highest bidder, their bid is refunded.

- **`withdrawBid(uint256 tokenId)`**:
  - Enables non-winning bidders to withdraw their bids after the auction ends.

- **`sellerEndAuction(uint256 tokenId)`**:
  - Allows the seller to end the auction after the deadline, transferring the NFT to the highest bidder and Ether to the seller if the reserve price is met.

- **`reclaimNFT(uint256 tokenId)`**:
  - If the auction expires without meeting the reserve price, the seller can reclaim their NFT.

- **`getAuctionDetails(uint256 tokenId)`**:
  - Retrieves the details of a particular auction such as the seller, highest bidder, highest bid, reserve price, and deadline.

---

### Error Handling

The contract includes custom error messages to handle various edge cases:

- **`EnglishAuction_Not_NFT_Owner()`**: Thrown when someone other than the NFT owner tries to deposit an NFT into the auction.
- **`EnglishAuction_Expired()`**: Thrown when someone tries to place a bid after the auction deadline has passed.
- **`EnglishAuction_Bid_Is_Low()`**: Thrown when a bid is lower than or equal to the current highest bid.
- **`EnglishAuction_Nothing_To_Withdraw()`**: Thrown when a user tries to withdraw a non-existent bid.
- **`EnglishAuction_Already_Ended()`**: Thrown when trying to end an auction that has already ended.
- **`EnglishAuction_Reserve_Price_Not_Meet()`**: Thrown when trying to end an auction where the highest bid is below the reserve price.

---

### Events

- **`AuctionCreated(uint256 tokenId, uint256 reservePrice, uint256 deadline)`**: Emitted when an auction is created.
- **`BidPlaced(uint256 tokenId, address bidder, uint256 amount)`**: Emitted when a new bid is placed.
- **`AuctionEnded(uint256 tokenId, address winner, uint256 highestBid)`**: Emitted when the auction ends successfully.

---

### How the Contract Works

1. **Seller Deposits an NFT**:
   - The seller calls `deposit()` to lock their NFT in the contract. The auction starts with a reserve price and deadline.

2. **Buyers Place Bids**:
   - Buyers send Ether along with their bid using `placeBid()`. The highest bid is recorded, and previous bids are refunded.

3. **Ending the Auction**:
   - The auction can be ended by the seller via `sellerEndAuction()` once the auction deadline has passed and the reserve price is met. The NFT is transferred to the highest bidder, and the seller receives the highest bid in Ether.

4. **Withdraw Bids**:
   - After the auction, non-winning bidders can call `withdrawBid()` to reclaim their Ether.

5. **Reclaiming NFT**:
   - If the auction fails (i.e., the highest bid is below the reserve price), the seller can reclaim the NFT using `reclaimNFT()`.

---

### Gas Optimization

The contract ensures efficient gas usage by:
- Minimizing state changes when not necessary.
- Using mappings for easy and fast lookup of bids and auctions.

---

### Testing

A comprehensive test suite has been developed using Foundry. It verifies various aspects of the contract, including:

- Successful and failed NFT deposits.
- Placing valid and invalid bids.
- Correct auction termination by the seller.
- Bid withdrawal and NFT reclamation.

The test results indicate all core functionalities pass successfully, ensuring a well-tested and secure auction process.

```
Ran 9 tests for test/EnglishAuction.t.sol:TestEnglishAuction
[PASS] testDeployScript() (gas: 6450389)
[PASS] testDepositNFTToken() (gas: 144409)
[PASS] testFailMintNotOwner() (gas: 8304)
[PASS] testInvalidPlaceBid() (gas: 158542)
[PASS] testPlaceBid() (gas: 234650)
[PASS] testReclaimNFT() (gas: 147864)
[PASS] testSellerEndAuction() (gas: 288235)
[PASS] testWithdraw() (gas: 228013)
[PASS] testdepositNFTNotOwner() (gas: 42402)
```

```
| File                        | % Lines        | % Statements   | % Branches    | % Funcs       |
|-----------------------------|----------------|----------------|---------------|---------------|
| script/EnglishAuction.s.sol | 100.00% (2/2)  | 100.00% (2/2)  | 100.00% (0/0) | 100.00% (1/1) |
| src/EnglishAuction.sol      | 97.14% (34/35) | 97.22% (35/36) | 100.00% (1/1) | 85.71% (6/7)  |
| src/NFTToken.sol            | 100.00% (5/5)  | 100.00% (5/5)  | 100.00% (2/2) | 100.00% (2/2) |
| Total                       | 97.62% (41/42) | 97.67% (42/43) | 100.00% (3/3) | 90.00% (9/10) |
```

---

### Installation and Usage

1. Install dependencies: 
   ```
   forge install
   ```
2. Compile the contract: 
   ```
   forge build
   ```
3. Run tests:
   ```
   forge test
   ```
