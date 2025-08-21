# Orion Rebase Token & Vault Contracts 🚀

## Overview
This project implements a sophisticated rebase (elastic supply) ERC-20 token, `OrionToken`, designed to incentivize user deposits into an associated `Vault` contract. The system allows for dynamic adjustments to the token supply based on a unique interest rate mechanism, enhancing token economics within a decentralized finance (DeFi) context.

## Features
-   **Elastic Supply (Rebase) Mechanism**: The `OrionToken` dynamically adjusts its supply by minting accrued interest to user balances based on time elapsed and individual interest rates.
-   **User-Specific Interest Rates**: Each user locks in the global interest rate at the time of their last interaction (mint, burn, transfer), ensuring predictable growth for their holdings.
-   **Controlled Interest Rate Decrement**: The global interest rate for the `OrionToken` can only be decreased by the contract owner, providing a controlled deflationary or stabilization mechanism.
-   **Role-Based Access Control**: `OrionToken` employs OpenZeppelin's `AccessControl` to manage `MINT_AND_BURN_ROLE` permissions, ensuring only authorized entities (like the `Vault`) can modify token supply.
-   **Decentralized Vault**: The `Vault` contract facilitates seamless deposits of ETH in exchange for `OrionToken` and redemption of `OrionToken` back into ETH, maintaining a 1:1 peg.
-   **Owner & Access Control**: Utilizes OpenZeppelin's `Ownable` and `AccessControl` for secure management of critical functions, such as setting interest rates and granting mint/burn roles.

## Getting Started

To get a copy of this project up and running on your local machine, follow these steps.

### Prerequisites
Ensure you have [Foundry](https://getfoundry.sh/) installed. Foundry is a blazing-fast, portable, and modular toolkit for Ethereum application development written in Rust.

```bash
curl -L https://foundry.sh | bash
foundryup
```

### Installation

1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/olujimiAdebakin/cross_chain_rebase-token_contract.git
    cd cross_chain_rebase-token_contract
    ```

2.  **Install Dependencies**:
    This project uses Git submodules for its dependencies, primarily OpenZeppelin Contracts and Forge Standard Library.
    ```bash
    forge update
    ```

3.  **Build the Contracts**:
    Compile the smart contracts using Foundry.
    ```bash
    forge build
    ```

### Environment Variables
For deployment and interaction, you might need to set up environment variables.
Create a `.env` file in the root directory of the project with the following (example values):

```env
PRIVATE_KEY=0x... # Your private key for deployment
RPC_URL=https://eth-sepolia.g.alchemy.com/v2/... # Your RPC URL for a network (e.g., Sepolia)
```

## Usage

This project consists of Solidity smart contracts. To use them, you typically deploy them to an Ethereum-compatible blockchain and interact with their functions.

1.  **Deploying Contracts**:
    You can deploy the `OrionToken` and `Vault` contracts using Foundry's `forge create` command or by writing a deployment script.

    *Example Deployment (Simplified, requires `PRIVATE_KEY` and `RPC_URL` in `.env`):*

    First, deploy `OrionToken`:
    ```bash
    # Example for deploying OrionToken (replace <Your_Private_Key> and <Your_RPC_URL>)
    # forge create src/OrionToken.sol:OrionToken --private-key <Your_Private_Key> --rpc-url <Your_RPC_URL>
    # Note: Use a deployment script for production deployments for better management
    ```
    Once `OrionToken` is deployed, note its address.

    Then, deploy `Vault`, passing the deployed `OrionToken` address to its constructor:
    ```bash
    # Example for deploying Vault (replace <OrionToken_Address>, <Your_Private_Key>, <Your_RPC_URL>)
    # forge create src/Vault.sol:Vault --constructor-args <OrionToken_Address> --private-key <Your_Private_Key> --rpc-url <Your_RPC_URL>
    ```

2.  **Granting Mint/Burn Role**:
    After deploying both contracts, the `Vault` contract needs the `MINT_AND_BURN_ROLE` on the `OrionToken` contract to be able to mint tokens upon deposit and burn them upon redemption. This must be done by the `OrionToken`'s owner.

    ```bash
    # Interacting with OrionToken (replace <OrionToken_Address>, <Vault_Address>, <Your_Private_Key>, <Your_RPC_URL>)
    # forge script --rpc-url <Your_RPC_URL> --private-key <Your_Private_Key> --broadcast YourDeploymentScript.s.sol --sig "grantMintAndBurnRole(address)" <Vault_Address>
    # Or, using cast for direct interaction if you know the ABI and deployed addresses:
    # cast send <OrionToken_Address> "grantMintAndBurnRole(address)" <Vault_Address> --private-key <Your_Private_Key> --rpc-url <Your_RPC_URL>
    ```

3.  **Interacting with the Vault**:

    *   **Deposit ETH**: Send ETH to the `deposit` function of the `Vault` contract. This will mint `OrionToken`s to your address.
        ```solidity
        // Example Solidity interaction
        Vault vault = Vault(<Vault_Address>);
        vault.deposit{value: 1 ether}(); // Deposits 1 ETH, gets 1 ORT
        ```

    *   **Redeem OrionToken**: Burn your `OrionToken`s via the `redeem` function of the `Vault` contract to receive ETH back.
        ```solidity
        // Example Solidity interaction
        IOrionToken orionToken = IOrionToken(<OrionToken_Address>);
        orionToken.approve(<Vault_Address>, 100); // Approve Vault to spend your ORT
        Vault vault = Vault(<Vault_Address>);
        vault.redeem(100); // Redeems 100 ORT for 100 ETH
        ```

    *   **Check Balances**:
        `balanceOf(address)` on `OrionToken` will show your effective balance including accrued interest.
        `principleBalanceOf(address)` will show the base amount of tokens minted to you, excluding interest.

4.  **Running Tests**:
    The project includes unit tests written with Foundry.
    ```bash
    forge test
    ```

## Technologies Used

| Technology         | Category           | Description                                        |
| :----------------- | :----------------- | :------------------------------------------------- |
| **Solidity**       | Smart Contract Language | The primary language for writing smart contracts. |
| **Foundry**        | Development Toolkit | A fast, powerful, and flexible toolkit for Ethereum development, testing, and deployment. |
| **OpenZeppelin Contracts** | Smart Contract Library | Industry-standard, secure, and audited smart contract implementations (ERC20, Ownable, AccessControl). |

## Contributing

We welcome contributions to the Orion Rebase Token & Vault project! To contribute:

-   ⭐ Fork this repository.
-   💡 Create a new branch for your feature or bug fix: `git checkout -b feature/your-feature-name` or `bugfix/fix-description`.
-   🛠️ Make your changes and ensure your code adheres to existing style guidelines.
-   🧪 Write and run tests to ensure your changes work as expected and don't introduce regressions.
-   ⬆️ Commit your changes with a clear and concise message.
-   🚀 Push your branch to your forked repository.
-   ➡️ Open a pull request against the `main` branch of this repository.

## License

This project is licensed under the MIT License. The SPDX license identifier used is `MIT`.

## Author Info

Connect with the author of this project:

**Adebakin Olujimi**
- LinkedIn: [Your_LinkedIn_Profile]
- Twitter: [Your_Twitter_Handle]

---

[![Readme was generated by Dokugen](https://img.shields.io/badge/Readme%20was%20generated%20by-Dokugen-brightgreen)](https://www.npmjs.com/package/dokugen)