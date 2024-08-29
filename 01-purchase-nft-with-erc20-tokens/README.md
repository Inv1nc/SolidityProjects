# NFT Purchase with ERC20 Tokens

This project demonstrates a basic NFT contract that can only be minted by paying with a specific ERC20 token.

## Overview

The project includes two main smart contracts:

1. **ERC20 Token Contract**:
   - This is a standard ERC20 token with a custom minting fee.
   - The minting fee is converted from Ether into tokens when new ERC20 tokens are minted.

2. **NFT Contract**:
   - This is a standard ERC721 (NFT) contract that only allows minting of NFTs by paying with a specific ERC20 token.
   - Users need to approve the NFT contract to spend their ERC20 tokens before they can mint an NFT.

## How to Mint the NFT

1. **Buy ERC20 Tokens**: First, you need to purchase ERC20 tokens from the token creator.
2. **Approve ERC20 Tokens**: After acquiring the tokens, you must approve the NFT contract to spend your ERC20 tokens.
3. **Mint the NFT**: Finally, you can call the `mintNFT()` function on the NFT contract to mint your NFT.

## Methodology

1. **ERC20 Token Creation**:
   - Built using the OpenZeppelin ERC20 contract.
   - A custom minting fee is set, which is calculated in Ether during the minting process.

2. **NFT Token Creation**:
   - Created using OpenZeppelin’s ERC721 contract.
   - The contract accepts payments in the form of the specific ERC20 token.

## Testing

The smart contracts have been tested extensively with various scenarios including:
- Successful ERC20 token purchase and minting.
- Failing mint attempts when incorrect amounts or approvals are provided.
- Testing withdrawal functions and contract owner restrictions.

### Test Suite Summary:

The test coverage and results are as follows:

- **ERC20 Token Contract**: 100% coverage (lines, statements, branches, and functions).
- **NFT Contract**: 85.71% coverage, with some uncovered parts related to the constructor.

```shell
forge coverage
```

```shell
| File                  | % Lines        | % Statements   | % Branches    | % Funcs       |
|-----------------------|----------------|----------------|---------------|---------------|
| script/NFTToken.s.sol | 100.00% (4/4)  | 100.00% (4/4)  | 100.00% (0/0) | 100.00% (1/1) |
| src/ERC20Token.sol    | 100.00% (5/5)  | 100.00% (5/5)  | 100.00% (2/2) | 100.00% (3/3) |
| src/NFTToken.sol      | 75.00% (9/12)  | 76.92% (10/13) | 100.00% (6/6) | 66.67% (2/3)  |
| Total                 | 85.71% (18/21) | 86.36% (19/22) | 100.00% (8/8) | 85.71% (6/7)  |
```

```shell
forge test
```

```shell
Ran 13 tests for test/NFTToken.t.sol:TestNFT
[PASS] testBuyERC20(uint256) (runs: 258, μ: 52912, ~: 66971)
[PASS] testERC20Burn(uint256) (runs: 258, μ: 23520, ~: 23520)
[PASS] testMintERC20FailOnIncorrectValue(uint256) (runs: 257, μ: 31988, ~: 32142)
[PASS] testMintPrice() (gas: 10577)
[PASS] testNFTFailInsufficientERC20() (gas: 18591)
[PASS] testNFTMint(uint256) (runs: 258, μ: 163663, ~: 185374)
[PASS] testNFTMintFailOnNoApprove(uint256) (runs: 257, μ: 104283, ~: 98043)
[PASS] testPaymentToken() (gas: 12820)
[PASS] testSetupDeployment() (gas: 3914932)
[PASS] testWithdrawFailOnNoBalance() (gas: 18496)
[PASS] testWithdrawFailOnNotOwner(uint256) (runs: 258, μ: 163182, ~: 153182)
[PASS] testWithdrawOwner(uint256) (runs: 257, μ: 233593, ~: 214009)
[PASS] testfuzzNFTDeployment(string,string,uint256) (runs: 258, μ: 1879277, ~: 1880519)
Suite result: ok. 13 passed; 0 failed; 0 skipped; finished in 823.84ms (2.77s CPU time)
```

## Deployment

```
forge script scipt/NFTToken.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY
```
