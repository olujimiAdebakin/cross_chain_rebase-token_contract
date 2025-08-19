# **OrionToken: Cross-Chain Rebase Token** 🚀

## Overview
OrionToken is an innovative Solidity smart contract implementing a cross-chain rebase (elastic) token. This project is engineered to incentivize user deposits into a vault by dynamically adjusting token balances based on an accruing interest rate, ensuring a unique elastic supply mechanism.

## Features
-   **Elastic Supply**: Implements a rebase mechanism where token balances adjust over time based on an interest rate.
-   **Decreasing Interest Rate**: The global interest rate can only decrease, providing a predictable deflationary control mechanism for the rate.
-   **User-Specific Interest Rates**: Each user's interest rate is locked in at the global rate at their time of deposit, ensuring transparency and fairness for individual accruals.
-   **Accrued Interest Minting**: Automatically calculates and mints accrued interest upon new deposits, reflecting the token's elastic nature.
-   **OpenZeppelin Standard**: Inherits from `ERC20` for standard token functionalities, ensuring compatibility and security.

## Getting Started

### Installation
To set up and interact with the OrionToken project locally, you will need [Foundry](https://getfoundry.sh/) installed.

#### Prerequisites
-   [Foundry](https://getfoundry.sh/) (comprising `forge` and `cast`)

#### Clone the Repository
```bash
git clone https://github.com/your-username/cross_chain_rebase-token.git
cd cross_chain_rebase-token
```

#### Install Dependencies
The project uses Git submodules for its dependencies (e.g., OpenZeppelin contracts). Initialize and update them:

```bash
forge install
git submodule update --init --recursive
```

#### Build the Project
Compile the smart contracts:

```bash
forge build
```

## Usage

This project is a smart contract designed to be deployed and interacted with on a blockchain. Here's how you can typically use and interact with the `OrionToken` contract:

### Deploying the Contract
You can deploy the `OrionToken` contract to a local development network (like Anvil, part of Foundry) or a public testnet/mainnet.

1.  **Start a Local Anvil Instance (Optional, for local development):**
    ```bash
    anvil
    ```
    This will start a local blockchain and display a list of accounts and their private keys.

2.  **Deploy using Forge:**
    Replace `PRIVATE_KEY` with your deployer's private key and `RPC_URL` with your network's RPC endpoint (e.g., `http://127.0.0.1:8545` for Anvil).

    ```bash
    forge script script/DeployOrionToken.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
    ```
    *(Note: A `DeployOrionToken.s.sol` script would need to be created in the `script` directory for this command to work, defining the deployment logic.)*

### Interacting with the Contract

Once deployed, you can interact with the contract's functions using `cast` (Foundry's CLI tool) or through a web3 library in your application.

Assume the contract is deployed at `CONTRACT_ADDRESS`.

#### 1. Get the Global Interest Rate
```bash
cast call $CONTRACT_ADDRESS "s_interestRate()" --rpc-url $RPC_URL
```

#### 2. Set the Global Interest Rate (Owner/Admin Only)
Only the contract owner or an authorized address can call `setInterestRate`. The new rate must be less than or equal to the current rate.
```bash
cast send $CONTRACT_ADDRESS "setInterestRate(uint256)" 4e10 --rpc-url $RPC_URL --private-key $PRIVATE_KEY
```
*(Example: setting new rate to 4%, where 5e10 is 5% represented as 5 * 10^10 given 1e18 scaling)*

#### 3. Mint Tokens
This function is typically called by a vault or another authorized entity to mint new tokens to a user, which also calculates and mints accrued interest.
```bash
cast send $CONTRACT_ADDRESS "mint(address,uint256)" 0xYourUserAddress 1000000000000000000 --rpc-url $RPC_URL --private-key $PRIVATE_KEY
```
*(Example: minting 1 ORT to `0xYourUserAddress`)*

#### 4. Get User Balance
This `balanceOf` function is overridden to include accrued interest in the returned balance.
```bash
cast call $CONTRACT_ADDRESS "balanceOf(address)" 0xYourUserAddress --rpc-url $RPC_URL
```

#### 5. Get User's Locked-in Interest Rate
```bash
cast call $CONTRACT_ADDRESS "getUserInterestRate(address)" 0xYourUserAddress --rpc-url $RPC_URL
```

*(Note: The examples above assume `cast` is configured with the correct RPC URL and private key for transactions. Replace placeholders like `$CONTRACT_ADDRESS`, `$RPC_URL`, `$PRIVATE_KEY`, and `0xYourUserAddress` with actual values.)*

## Technologies Used

| Technology         | Description                                        | Link                                          |
| :----------------- | :------------------------------------------------- | :-------------------------------------------- |
| **Solidity**       | Smart contract programming language                | [Solidity](https://soliditylang.org/)         |
| **Foundry**        | Fast, portable, and modular toolkit for Ethereum   | [Foundry](https://getfoundry.sh/)             |
| **OpenZeppelin**   | Secure smart contract libraries                    | [OpenZeppelin](https://openzeppelin.com/)     |

## Contributing

We welcome contributions to the OrionToken project! To contribute, please follow these guidelines:

-   ⭐ **Fork the Repository**: Start by forking the `cross_chain_rebase-token` repository to your GitHub account.
-   🌿 **Create a Branch**: Create a new branch for your feature or bug fix (e.g., `feat/add-rebase-logic` or `fix/interest-rate-bug`).
-   ✍️ **Make Your Changes**: Implement your changes, ensuring code quality and adherence to existing patterns.
-   🧪 **Write Tests**: Add or update tests to cover your changes. Ensure all existing tests pass.
-   🚀 **Submit a Pull Request**: Once your changes are complete and tested, submit a pull request to the `main` branch of this repository. Provide a clear description of your changes.

## License

This project is licensed under the MIT License. See the SPDX license identifier in `src/OrionToken.sol` for more details.

## Author Info

Connect with the author of this project:

**Adebakin Olujimi**
-   LinkedIn: [Your LinkedIn Profile](https://www.linkedin.com/in/your-linkedin-username)
-   Twitter: [Your Twitter Handle](https://twitter.com/your-twitter-handle)
-   Portfolio: [Your Portfolio Link](https://www.yourportfolio.com)

---

[![Solidity](https://img.shields.io/badge/Solidity-0.8.26-363636?style=flat&logo=solidity)](https://soliditylang.org/)
[![Foundry](https://img.shields.io/badge/Foundry-darkgrey?style=flat&logo=foundry&logoColor=white)](https://getfoundry.sh/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Readme was generated by Dokugen](https://img.shields.io/badge/Readme%20was%20generated%20by-Dokugen-brightgreen)](https://www.npmjs.com/package/dokugen)