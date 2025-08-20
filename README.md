🌌 Orion Token: Cross-Chain Rebase Protocol

This project introduces a sophisticated decentralized finance (DeFi) solution featuring an elastic supply token, `OrionToken`, designed to incentivize user engagement and deposits. It integrates with a secure `Vault` contract, facilitating seamless ETH deposits and token redemptions, alongside a unique rebase mechanism that adjusts token supply based on a dynamic interest rate system.

## ✨ Features

*   **Elastic Supply Token (`OrionToken`)**: An ERC-20 compatible token with a dynamic supply that adjusts based on accrued interest, maintaining an elastic nature.
*   **Dynamic Interest Rates**: A globally adjustable interest rate for `OrionToken` that can only decrease, ensuring predictable economic behavior.
*   **User-Specific Locked Rates**: Each user's accrued interest is calculated based on the global interest rate active at the time of their last interaction (deposit, burn, or transfer), providing personalized yield.
*   **Secure Vault Integration**: A dedicated `Vault` contract enables users to deposit Ether (ETH) and receive `OrionToken` in return, maintaining a 1:1 peg for principal amounts.
*   **Effortless Redemption**: Users can burn their `OrionToken` to redeem an equivalent amount of ETH from the `Vault`, including any accrued interest.
*   **Role-Based Access Control**: Utilizes OpenZeppelin's `AccessControl` to manage sensitive operations like minting and burning, ensuring only authorized entities (e.g., the Vault) can perform these actions.

## 🛠️ Technologies Used

| Technology    | Description                                       |
| :------------ | :------------------------------------------------ |
| **Solidity**  | Smart contract programming language               |
| **Foundry**   | Blazing fast, portable, and modular toolkit for Ethereum application development |
| **OpenZeppelin Contracts** | Secure and audited smart contract libraries       |

## 🚀 Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

Ensure you have Foundry installed. If not, follow the official Foundry installation guide:
```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### Installation

1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/olujimiAdebakin/cross_chain_rebase-token_contract.git
    cd cross_chain_rebase-token_contract
    ```

2.  **Install Dependencies**:
    This project uses Git submodules for its dependencies (OpenZeppelin Contracts, Forge Standard Library).
    ```bash
    forge install
    ```

3.  **Build the Contracts**:
    Compile the smart contracts to generate their ABI and bytecode.
    ```bash
    forge build
    ```

4.  **Run Tests (Optional but Recommended)**:
    Ensure all contracts are functioning as expected by running the test suite.
    ```bash
    forge test
    ```

### Environment Variables

For deployment and interaction on a live network, you will need to set up environment variables. Create a `.env` file in the root of your project:

```
# .env example
RPC_URL="YOUR_ETHEREUM_RPC_URL"
PRIVATE_KEY="YOUR_PRIVATE_KEY_FOR_DEPLOYMENT"
ETHERSCAN_API_KEY="YOUR_ETHERSCAN_API_KEY" # Optional, for contract verification
```

## 💡 Usage

This project primarily consists of smart contracts designed to be deployed and interacted with on an Ethereum-compatible blockchain.

### Deploying the Contracts

You can deploy the `OrionToken` and `Vault` contracts using Foundry's `forge script`.

1.  **Deploy `OrionToken`**:
    First, deploy the `OrionToken`. Note that its constructor takes no arguments.
    ```bash
    # Example deployment command (adjust chain-id, RPC URL, and private key as needed)
    forge script script/Deploy.s.sol:OrionTokenScript --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv
    ```
    *   *Note*: The actual deployment script (`script/Deploy.s.sol`) would need to be created by the developer to manage the deployment order and pass the `OrionToken` address to the `Vault` constructor.

2.  **Deploy `Vault`**:
    Once `OrionToken` is deployed, deploy the `Vault` contract, passing the `OrionToken`'s address to its constructor.
    ```bash
    # Example deployment command (replace ORION_TOKEN_ADDRESS with the actual deployed address)
    forge script script/Deploy.s.sol:VaultScript --constructor-args "ORION_TOKEN_ADDRESS" --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv
    ```

### Interacting with the Contracts

After deployment, you can interact with the contracts using `cast` (Foundry's CLI tool), a web3 library, or a dApp interface.

**Example Interactions (Conceptual):**

*   **Deposit ETH into Vault**:
    Call the `deposit()` function on the `Vault` contract, sending ETH along with the transaction.
*   **Redeem Tokens from Vault**:
    Call the `redeem(uint256 _amount)` function on the `Vault` contract, specifying the amount of `OrionToken` to burn in exchange for ETH.
*   **Check `OrionToken` Balance (with interest)**:
    Call `balanceOf(address _user)` on `OrionToken` to see the total balance, including accrued interest.
*   **Check `OrionToken` Principle Balance**:
    Call `principleBalanceOf(address _user)` on `OrionToken` to see the base amount minted, excluding interest.
*   **Set Global Interest Rate (Owner Only)**:
    The contract owner can call `setInterestRate(uint256 _newInterestRate)` on `OrionToken`. Remember, the interest rate can only decrease.
*   **Grant Mint/Burn Role (Owner Only)**:
    The contract owner can grant the `MINT_AND_BURN_ROLE` to the deployed `Vault` contract using `grantMintAndBurnRole(address _account)`. This is crucial for the Vault to be able to mint and burn `OrionToken`.

## ⚠️ Custom Errors

The contracts include custom error types for improved debugging and clarity:

*   `OrionToken_InterestRateCanOnlyDecrease(uint256 oldInterestRate, uint256 newInterestRate, string message)`: Reverts if an attempt is made to increase the global interest rate on the `OrionToken`.
*   `Redeem_FailedToSendETH(address recipient, uint256 amount)`: Reverts if the `Vault` fails to send ETH to a user during a redemption.

## 🤝 Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

To contribute:

1.  **Fork the Project**.
2.  **Create your Feature Branch**: `git checkout -b feature/AmazingFeature`
3.  **Commit your Changes**: `git commit -m 'feat: Add some AmazingFeature'`
4.  **Push to the Branch**: `git push origin feature/AmazingFeature`
5.  **Open a Pull Request**.

## 📄 License

Distributed under the MIT License. See the contract files for the SPDX License Identifier.

## 👤 Author

**Adebakin Olujimi**

*   LinkedIn: [Your LinkedIn Profile](https://linkedin.com/in/yourusername)
*   Twitter: [Your Twitter Handle](https://twitter.com/yourusername)

[![Readme was generated by Dokugen](https://img.shields.io/badge/Readme%20was%20generated%20by-Dokugen-brightgreen)](https://www.npmjs.com/package/dokugen)