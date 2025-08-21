# OrionToken: Cross-Chain Rebase Token & Vault 🚀

This project introduces `OrionToken`, an innovative elastic (rebase) token designed to incentivize user engagement and deposits into an accompanying `Vault` contract. It dynamically adjusts user balances based on accrued interest, ensuring a unique and rewarding experience for participants in the decentralized ecosystem.

## Installation

To get this project up and running locally, follow these steps:

### Prerequisites
Before you begin, ensure you have [Foundry](https://getfoundry.sh/) installed. If not, you can install it using `foundryup`:

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### Clone the Repository
Start by cloning the project repository to your local machine:

```bash
git clone https://github.com/olujimiAdebakin/cross_chain_rebase-token_contract.git
cd cross_chain_rebase-token_contract
```

### Install Dependencies
This project uses Git submodules for its dependencies (Forge Standard Library and OpenZeppelin Contracts). Initialize and update them:

```bash
forge install
```

### Build the Project
Compile the smart contracts to ensure everything is set up correctly:

```bash
forge build
```

## Usage

This project consists of two core smart contracts: `OrionToken.sol` (the rebase token) and `Vault.sol` (the ETH deposit/redemption vault). Interaction typically involves deploying these contracts and then calling their public functions.

### Deployment
To deploy the contracts, you would generally use a Foundry script or a deployment framework. The `OrionToken` must be deployed first, and its address then passed to the `Vault` constructor.

1.  **Deploy `OrionToken`**:
    ```solidity
    // Example pseudocode for deployment
    OrionToken orionToken = new OrionToken();
    ```
2.  **Deploy `Vault`**:
    ```solidity
    // Pass the deployed OrionToken address
    Vault vault = new Vault(orionToken);
    ```
3.  **Grant Role**: The `Vault` contract needs the `MINT_AND_BURN_ROLE` on the `OrionToken` to be able to mint and burn tokens. This step is crucial for the `deposit` and `redeem` functionalities of the Vault.
    ```solidity
    // Call this from the OrionToken owner account
    orionToken.grantMintAndBurnRole(address(vault));
    ```

### Interacting with Contracts

Here are the key interactions with the deployed contracts:

#### `Vault` Contract Interactions

*   **Deposit ETH**: Users can deposit ETH into the Vault, which mints an equivalent amount of `OrionToken` to their address.
    *   **Function**: `deposit()`
    *   **Request**: Send ETH directly to the `deposit()` function.
        ```solidity
        // Example: Sending 1 ETH to the vault
        vault.deposit{value: 1 ether}();
        ```
    *   **Response**: Emits a `Deposit` event with the user's address and the amount deposited.

*   **Redeem Tokens for ETH**: Users can burn their `OrionToken` to receive ETH back from the Vault.
    *   **Function**: `redeem(uint256 _amount)`
    *   **Request**: Call `redeem` with the amount of `OrionToken` to burn. Ensure the Vault has enough ETH.
        ```solidity
        // Example: Redeeming 100 OrionTokens
        vault.redeem(100 * 1e18); // Assuming 18 decimals for OrionToken
        ```
    *   **Response**: Transfers ETH back to the user. Emits a `Redeem` event.
    *   **Errors**: `Vault__Redeem__FailedToSendETH` if the ETH transfer fails.

#### `OrionToken` Contract Interactions

*   **Get User Balance**: Retrieve a user's balance, which includes accrued interest.
    *   **Function**: `balanceOf(address _user)`
    *   **Request**: Pass the user's address.
        ```solidity
        uint256 balance = orionToken.balanceOf(msg.sender);
        ```
    *   **Response**: Returns `uint256` representing the total token balance including interest.

*   **Get Principal Balance**: Retrieve the base balance of tokens minted, excluding accrued interest.
    *   **Function**: `principleBalanceOf(address _user)`
    *   **Request**: Pass the user's address.
        ```solidity
        uint256 principal = orionToken.principleBalanceOf(msg.sender);
        ```
    *   **Response**: Returns `uint256` representing the base token balance.

*   **Set Global Interest Rate**: The contract owner can adjust the global interest rate.
    *   **Function**: `setInterestRate(uint256 _newInterestRate)`
    *   **Request**: Call with a new interest rate (e.g., `5 * 1e16` for 5% when `PRECISION_FACTOR` is `1e18`).
        ```solidity
        orionToken.setInterestRate(0.03 * 1e18); // Sets interest rate to 3%
        ```
    *   **Response**: Emits an `InterestRateSet` event.
    *   **Errors**: `OrionToken_InterestRateCanOnlyDecrease` if `_newInterestRate` is greater than the current rate.

*   **Get Global Interest Rate**:
    *   **Function**: `getInterestRate()`
    *   **Response**: Returns `uint256` representing the current global interest rate.

*   **Get User-Specific Interest Rate**: Each user's interest rate is locked in at the time of their first interaction (deposit/mint).
    *   **Function**: `getUserInterestRate(address _user)`
    *   **Request**: Pass the user's address.
    *   **Response**: Returns `uint256` representing the user's specific interest rate.

## Features

This project incorporates several key features designed for a robust and dynamic token economy:

*   **Elastic/Rebase Token (OrionToken)**: Implements an elastic supply mechanism where token balances can increase or decrease based on an interest rate, without requiring users to actively claim rewards.
*   **Dynamic Interest Accrual**: Balances automatically accrue interest over time, calculated linearly based on a user's locked-in interest rate and the time elapsed since their last interaction.
*   **User-Specific Interest Rates**: Each user's interest rate is fixed at the global rate prevalent at their first deposit or token acquisition, providing predictability.
*   **Controlled Interest Rate Decrement**: The global interest rate can only be decreased by the contract owner, ensuring a deflationary or stable environment over time.
*   **Access Control**: Utilizes OpenZeppelin's `Ownable` and `AccessControl` for managing critical functions like setting interest rates (`onlyOwner`) and controlling mint/burn operations (`MINT_AND_BURN_ROLE`).
*   **ETH Vault Integration**: A dedicated `Vault` contract allows users to seamlessly deposit ETH to mint `OrionToken` and burn `OrionToken` to redeem ETH, establishing a direct peg.
*   **Secure ETH Redemption**: The `redeem` function uses a low-level `.call` for ETH transfer, adhering to the Checks-Effects-Interactions pattern for enhanced security.

## Technologies Used

| Technology         | Description                                                      |
| :----------------- | :--------------------------------------------------------------- |
| **Solidity**       | Primary language for smart contract development.                 |
| **Foundry**        | Blazing fast, portable, and modular toolkit for Ethereum application development. |
| **OpenZeppelin Contracts** | Secure and community-audited smart contracts for common functionalities (ERC20, Ownable, AccessControl). |

## Contributing

We welcome contributions! If you have suggestions or want to improve the project, please follow these steps:

✨ **Fork the Repository**: Start by forking this repository to your GitHub account.

💻 **Clone Your Fork**: Clone the forked repository to your local machine:
```bash
git clone https://github.com/YOUR_USERNAME/cross_chain_rebase-token_contract.git
```

🌿 **Create a Branch**: Create a new branch for your feature or bug fix:
```bash
git checkout -b feature/your-feature-name
```

🚀 **Make Your Changes**: Implement your changes and ensure tests pass.

➕ **Add & Commit**: Stage your changes and commit them with a descriptive message:
```bash
git add .
git commit -m "feat: Add new feature"
```

⬆️ **Push to Your Fork**: Push your changes to your fork on GitHub:
```bash
git push origin feature/your-feature-name
```

🔄 **Open a Pull Request**: Create a pull request from your branch to the `main` branch of the original repository. Describe your changes clearly.

## License

Distributed under the MIT License. See the project for details.

## Author Info

👋 **Adebakin Olujimi**
*   **LinkedIn**: [Your LinkedIn Username] (e.g., `linkedin.com/in/adebakin-olujimi`)
*   **Twitter**: [Your Twitter Handle] (e.g., `@adebakin_olujimi`)

---
[![Solidity](https://img.shields.io/badge/Solidity-0.8.26-363636?logo=solidity)](https://soliditylang.org/)
[![Foundry](https://img.shields.io/badge/Powered%20By-Foundry-F94A2D?logo=foundry)](https://getfoundry.sh/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

[![Readme was generated by Dokugen](https://img.shields.io/badge/Readme%20was%20generated%20by-Dokugen-brightgreen)](https://www.npmjs.com/package/dokugen)