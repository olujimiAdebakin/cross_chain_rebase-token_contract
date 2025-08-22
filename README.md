# 🌌 Cross-Chain Orion Rebase Token & Vault Protocol

## Overview
This project presents a sophisticated decentralized finance (DeFi) solution featuring an elastic supply (rebase) token, `OrionToken`, and a companion `Vault` contract. It is designed to incentivize user deposits into the vault by applying a unique interest rate mechanism, making it ideal for cross-chain applications requiring dynamic token supply.

## Features
*   **Elastic Token Supply:** `OrionToken` implements a rebase mechanism, dynamically adjusting user balances to reflect accrued interest based on a global rate.
*   **Decreasing Interest Rate:** The global interest rate can only be decreased, providing predictable economic behavior and preventing sudden, undesirable increases in supply expansion.
*   **User-Specific Interest Rates:** Each user's interest rate is locked in at the time of their last significant interaction (mint, burn, transfer), ensuring a fair and consistent experience.
*   **Role-Based Access Control:** `OrionToken` integrates OpenZeppelin's `AccessControl` to manage `MINT_AND_BURN_ROLE`, enhancing security and governance.
*   **ETH Vault Integration:** The `Vault` contract allows users to deposit ETH and receive an equivalent amount of `OrionToken`, and subsequently redeem tokens for ETH.
*   **Gas-Efficient Calculations:** Interest calculations (`_caculatedUserAccumulatedInterestSinceLastUpdate`) are designed for linear growth based on time elapsed and user-specific rates.

## Getting Started

### Installation
To set up the project locally, follow these steps:

1.  ⬇️ **Clone the Repository:**
    ```bash
    git clone https://github.com/olujimiAdebakin/cross_chain_rebase-token_contract.git
    cd cross_chain_rebase-token_contract
    ```

2.  🛠️ **Install Foundry:**
    If you don't have Foundry installed, follow the instructions on the [Foundry GitHub page](https://github.com/foundry-rs/foundry). A common installation method is:
    ```bash
    curl -L https://foundry.paradigm.xyz | bash
    foundryup
    ```

3.  📦 **Install Dependencies:**
    Navigate to the project directory and install the necessary OpenZeppelin contracts and Forge Standard Library via Git submodules:
    ```bash
    forge install
    ```

4.  🏗️ **Build the Project:**
    Compile the smart contracts:
    ```bash
    forge build
    ```

### Environment Variables
No specific environment variables are required for basic local compilation and testing. For deployment or advanced testing, you might need:

*   `PRIVATE_KEY`: Private key for the deployer account (e.g., `0x...`)
*   `RPC_URL`: RPC URL for the desired network (e.g., `https://eth-sepolia.g.alchemy.com/v2/...`)

## Usage
This section details how to interact with the `OrionToken` and `Vault` contracts.

### Deploying the Contracts
Contracts are typically deployed using Foundry scripts or a deployment framework.
First, deploy the `OrionToken` contract. Then, deploy the `Vault` contract, passing the address of the deployed `OrionToken` as a constructor argument. After deploying the `Vault`, remember to grant it the `MINT_AND_BURN_ROLE` on the `OrionToken` contract so it can mint and burn tokens.

Example deployment commands (assuming `forge script` is used):
```bash
# Deploy OrionToken
# forge script script/DeployOrionToken.s.sol:DeployOrionToken --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --verify

# Deploy Vault (after getting OrionToken address)
# forge script script/DeployVault.s.sol:DeployVault --constructor-args <ORION_TOKEN_ADDRESS> --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --verify
```

### Granting Mint/Burn Role to the Vault
After deploying both contracts, the `OrionToken` owner must grant the `Vault` contract the `MINT_AND_BURN_ROLE`.
```solidity
// Example in a testing/script context
OrionToken orionToken = OrionToken(<ORION_TOKEN_ADDRESS>);
Vault vault = Vault(<VAULT_ADDRESS>);
orionToken.grantMintAndBurnRole(address(vault));
```

### Interacting with the Vault
Once roles are set, users can interact with the `Vault`.

#### Deposit ETH
To deposit ETH into the vault and receive `OrionToken`:
```solidity
// Example transaction from a user account
vault.deposit{value: 1 ether}();
```
This will mint 1 `OrionToken` to `msg.sender` (the depositor).

#### Redeem Tokens
To burn `OrionToken` and receive an equivalent amount of ETH from the vault:
```solidity
// First, ensure the Vault has allowance to spend the user's tokens if using transferFrom implicitly
// However, the current redeem function expects the user to have tokens and directly burns them.
// Ensure the user has enough OrionToken balance.
vault.redeem(1 ether); // Burns 1 OrionToken, sends 1 ETH
```
Users can specify `type(uint256).max` to redeem their entire `OrionToken` balance.

### OrionToken Specific Interactions

#### Setting Interest Rate
Only the contract owner can set the global interest rate for `OrionToken`. The rate can only decrease.
```solidity
orionToken.setInterestRate(4 * 1e18 / 1e8); // Sets interest rate to 4% (scaled by PRECISION_FACTOR)
```

#### Checking Balances
*   **`balanceOf(address _user)`**: Returns the total balance of a user, including any accrued interest.
*   **`principleBalanceOf(address _user)`**: Returns the base amount of tokens minted to a user, excluding accrued interest.
*   **`getInterestRate()`**: Returns the current global interest rate.
*   **`getUserInterestRate(address _user)`**: Returns the specific interest rate locked for a given user.

### Running Tests
To ensure the contracts function as expected, run the provided tests using Foundry:
```bash
forge test
```

## Technologies Used
| Technology         | Description                                                          |
| :----------------- | :------------------------------------------------------------------- |
| **Solidity**       | Primary language for smart contract development.                     |
| **Foundry**        | Blazing fast EVM toolkit for smart contract development and testing. |
| **OpenZeppelin**   | Libraries for secure smart contract development (ERC20, Ownable, AccessControl). |

## Contributing
We welcome contributions to enhance the Orion Rebase Token & Vault Protocol!

*   ✨ **Fork the repository** and clone it to your local machine.
*   🌿 **Create a new branch** for your feature or bug fix: `git checkout -b feature/your-feature-name`.
*   💻 **Implement your changes**, ensuring you adhere to the existing code style.
*   🧪 **Write or update tests** to cover your changes.
*   ✅ **Run all tests** (`forge test`) to ensure everything is working correctly.
*   📝 **Commit your changes** with a clear and concise message.
*   ⬆️ **Push your branch** to your forked repository.
*   🗣️ **Open a pull request** describing your changes in detail.

## License
This project is licensed under the MIT License.

## Author Info
Developed by Adebakin Olujimi.

Connect with me:
*   LinkedIn: [linkedin.com/in/AdebakinOlujimi](https://linkedin.com/in/your-linkedin-profile)
*   Twitter: [@AdebakinOlujimi](https://twitter.com/your-twitter-handle)

---

[![Readme was generated by Dokugen](https://img.shields.io/badge/Readme%20was%20generated%20by-Dokugen-brightgreen)](https://www.npmjs.com/package/dokugen)