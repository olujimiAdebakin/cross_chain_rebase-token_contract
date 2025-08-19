# OrionToken: Cross-Chain Rebase Token 🔗

## Overview
OrionToken is an innovative Solidity smart contract implementing a cross-chain rebase (elastic) token. Built with the robust [OpenZeppelin Contracts](https://openzeppelin.com/contracts/) library and developed using the [Foundry](https://getfoundry.sh/) development framework, this token incentivizes user deposits by dynamically adjusting balances based on an internal interest rate mechanism.

## Features
- **Elastic Supply (Rebase Token)**: Token supply adjusts to reflect accrued interest, providing an "elastic" balance for holders.
- **Accruing Interest**: Users' token balances grow over time based on a set interest rate.
- **Decreasing Interest Rate**: The global interest rate for the token can only be set to a lower value, aiming to stabilize or control growth.
- **User-Specific Interest Rates**: Each user locks in the global interest rate at the time of their last deposit or interaction, ensuring fair and predictable growth.
- **ERC20 Standard Compliance**: Inherits from OpenZeppelin's ERC20, ensuring compatibility with wallets, exchanges, and other DeFi protocols.

## Getting Started

### Installation
To get started with the OrionToken project, you'll need Foundry installed. Follow these steps to set up your local development environment:

*   **Prerequisites**:
    *   [Foundry](https://getfoundry.sh/) (includes `forge` and `cast`)
    *   Git

*   **Clone the Repository**:
    ```bash
    git clone https://github.com/olujimiAdebakin/cross_chain_rebase-token_contract.git
    cd cross_chain_rebase-token_contract
    ```

*   **Install Dependencies**:
    Foundry automatically handles dependencies specified in `.gitmodules`. Run `forge build` to ensure all submodules are fetched and compiled.
    ```bash
    forge build
    ```

### Environment Variables
While not explicitly used within the contract's direct execution, for deployment and interaction with a blockchain network, you would typically need the following environment variables. Create a `.env` file in the project root:

*   `RPC_URL`: The URL of your blockchain node (e.g., Infura, Alchemy endpoint for Sepolia or Mainnet).
    ```
    RPC_URL=https://sepolia.infura.io/v3/YOUR_INFURA_PROJECT_ID
    ```
*   `PRIVATE_KEY`: The private key of the wallet you'll use for deploying and transacting. **Handle with extreme care, never expose this!**
    ```
    PRIVATE_KEY=0x...your_private_key_here...
    ```

## Contract Documentation

### Contract Address
Upon deployment, the contract will reside at a specific address on the blockchain network.
**Example (Placeholder)**: `0xAbcD1234EfGh5678IJkL9012MnOp3456QrSt7890`

### Public Functions

#### `constructor()`
*   **Purpose**: Initializes the `OrionToken` contract, setting its name to "Orion Token" and symbol to "ORT", as per the ERC20 standard.
*   **Parameters**: None
*   **Return Value**: None
*   **Notes**: This function is executed only once when the contract is deployed to the blockchain.

#### `setInterestRate(uint256 _newInterestRate)`
*   **Purpose**: Allows the owner or an authorized entity to update the global interest rate applied to token balances.
*   **Parameters**:
    *   `_newInterestRate` (uint256): The new interest rate to set. Rates are typically expressed with a `PRECISION_FACTOR` (e.g., `5e16` for 5%).
*   **Return Value**: None
*   **Errors**:
    *   `OrionToken_InterestRateCanOnlyDecrease(uint256 oldInterestRate, uint256 newInterestRate, string message)`: Reverts if the `_newInterestRate` is higher than the current `s_interestRate`, enforcing a decrease-only policy.
*   **Events**:
    *   `InterestRateSet(uint256 newInterestRate)`: Emitted upon a successful interest rate update.
*   **Notes**: As of the current implementation, this function lacks explicit access control (e.g., `onlyOwner`). It's crucial to add such a modifier in a production environment.

#### `mint(address _to, uint256 _amount)`
*   **Purpose**: Mints new `OrionToken`s to a specified address, typically used when a user deposits funds. This function also calculates and mints any accrued interest for the user and locks in their current interest rate.
*   **Parameters**:
    *   `_to` (address): The address of the recipient who will receive the minted tokens.
    *   `_amount` (uint256): The principal amount of tokens to mint.
*   **Return Value**: None
*   **Errors**:
    *   `revert`: If `_amount` is zero ("Amount must be greater than zero").
    *   `revert`: If `_to` is the zero address ("Cannot mint to the zero address").
*   **Notes**: This function handles the "rebase" aspect by adjusting the user's balance based on accrued interest.

#### `balanceOf(address _user)`
*   **Purpose**: Retrieves the current balance of `OrionToken`s for a given account, including any accrued interest. This is an override of the standard ERC20 `balanceOf` function.
*   **Parameters**:
    *   `_user` (address): The address of the account whose balance is to be queried.
*   **Return Value**: `uint256`: The total `OrionToken` balance, encompassing the principal amount and calculated accrued interest.

#### `getUserInterestRate(address _user)`
*   **Purpose**: Returns the specific interest rate that was locked in for a given user at the time of their last interaction (e.g., minting).
*   **Parameters**:
    *   `_user` (address): The address of the user.
*   **Return Value**: `uint256`: The user's specific interest rate (e.g., `5e16` for 5%).

## Usage

After deploying the `OrionToken.sol` contract to a blockchain network (e.g., using `forge script` or a frontend DApp), you can interact with it using tools like `cast` (part of Foundry) or a web3.js/ethers.js library in your application.

Here are examples of how to interact with the deployed contract:

*   **Deploying the Contract (Example using `forge script`)**:
    First, compile your contract if you haven't:
    ```bash
    forge build
    ```
    Then, deploy using a script (you'd typically write a deployment script in `script/`):
    ```bash
    # Example (requires a deployment script, e.g., DeployOrionToken.s.sol)
    # forge script script/DeployOrionToken.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --verify
    ```
    *Replace `script/DeployOrionToken.s.sol` with your actual deployment script path.*

*   **Calling `setInterestRate`**:
    To set a new interest rate (e.g., to 4% from a previous 5%), assuming `CONTRACT_ADDRESS` is your deployed contract's address:
    ```bash
    cast send $CONTRACT_ADDRESS "setInterestRate(uint256)" 40000000000000000 --rpc-url $RPC_URL --private-key $PRIVATE_KEY
    ```
    *Note: `40000000000000000` is `4e16` for 4% given the `PRECISION_FACTOR` of `1e18`.*

*   **Calling `mint`**:
    To mint 100 tokens to `0xYourUserAddress`:
    ```bash
    cast send $CONTRACT_ADDRESS "mint(address,uint256)" 0xYourUserAddressHere 100000000000000000000 --rpc-url $RPC_URL --private-key $PRIVATE_KEY
    ```
    *Note: `100000000000000000000` is `100 * 1e18` for 100 tokens, considering 18 decimals by default for ERC20.*

*   **Querying `balanceOf`**:
    To check the balance of `0xYourUserAddress`:
    ```bash
    cast call $CONTRACT_ADDRESS "balanceOf(address)" 0xYourUserAddressHere --rpc-url $RPC_URL
    ```
    The output will be the user's total balance, including accrued interest.

*   **Querying `getUserInterestRate`**:
    To check the locked-in interest rate for `0xYourUserAddress`:
    ```bash
    cast call $CONTRACT_ADDRESS "getUserInterestRate(address)" 0xYourUserAddressHere --rpc-url $RPC_URL
    ```

## Technologies Used

| Technology                                                                     | Description                                                                                             |
| :----------------------------------------------------------------------------- | :------------------------------------------------------------------------------------------------------ |
| <img src="https://img.shields.io/badge/Solidity-363636?style=for-the-badge&logo=solidity&logoColor=white" height="25"/> | Primary language for smart contract development.                                                        |
| <img src="https://img.shields.io/badge/Foundry-151515?style=for-the-badge&logo=foundry&logoColor=white" height="25"/>   | Blazing fast, portable, and modular toolkit for Ethereum application development.                       |
| <img src="https://img.shields.io/badge/OpenZeppelin_Contracts-5F5F5F?style=for-the-badge&logo=openzeppelin&logoColor=white" height="25"/> | Secure and community-vetted smart contract libraries for building robust decentralized applications. |

## Contributing

We welcome contributions to the OrionToken project! If you're interested in improving this smart contract, please follow these guidelines:

*   ✨ **Fork the Repository**: Start by forking the `cross_chain_rebase-token_contract` repository to your GitHub account.
*   🌿 **Create a Branch**: Create a new branch for your feature or bug fix: `git checkout -b feature/your-feature-name` or `git checkout -b bugfix/fix-bug-name`.
*   💻 **Make Changes**: Implement your changes and ensure they adhere to the project's coding style.
*   ✅ **Run Tests**: Before committing, run all existing tests (`forge test`) and add new tests for your changes to maintain high code quality and prevent regressions.
*   📝 **Commit Changes**: Write clear, concise commit messages that explain your changes.
*   ⬆️ **Push to Your Fork**: Push your branch to your forked repository.
*   🚀 **Open a Pull Request**: Submit a pull request to the `main` branch of the original repository. Provide a detailed description of your changes.

## License

This project is licensed under the MIT License.

## Author Info

Connect with the author:

*   **Adebakin Olujimi**
*   LinkedIn: [Your LinkedIn Profile](https://linkedin.com/in/yourusername)
*   Twitter: [@yourtwitterhandle](https://twitter.com/yourtwitterhandle)

---

[![Solidity](https://img.shields.io/badge/Solidity-^0.8.0-blue?logo=solidity)](https://soliditylang.org/)
[![Foundry](https://img.shields.io/badge/Developed%20with-Foundry-grey?logo=foundry)](https://getfoundry.sh/)
[![OpenZeppelin](https://img.shields.io/badge/Uses-OpenZeppelin%20Contracts-green?logo=openzeppelin)](https://openzeppelin.com/contracts/)

[![Readme was generated by Dokugen](https://img.shields.io/badge/Readme%20was%20generated%20by-Dokugen-brightgreen)](https://www.npmjs.com/package/dokugen)