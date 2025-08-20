# OrionToken Smart Contract: An Elastic Rebase Token

<p align="center">
  <a href="https://github.com/olujimiAdebakin/cross_chain_rebase-token_contract">
    <img src="https://img.shields.io/badge/Solidity-0.8.26-blueviolet" alt="Solidity Version">
  </a>
  <a href="https://github.com/olujimiAdebakin/cross_chain_rebase-token_contract">
    <img src="https://img.shields.io/badge/Foundry-Framework-lightgray" alt="Foundry Framework">
  </a>
  <a href="https://github.com/olujimiAdebakin/cross_chain_rebase-token_contract">
    <img src="https://img.shields.io/badge/License-MIT-green" alt="License: MIT">
  </a>
</p>

## Overview ✨
The **OrionToken** project implements an innovative cross-chain rebase (elastic) token using **Solidity** and the **Foundry** development framework. This smart contract is designed to dynamically adjust user balances through an interest rate mechanism, incentivizing participation and rewarding long-term holders. It integrates with **OpenZeppelin Contracts** for robust and secure ERC20 functionalities.

## Features 🚀
*   **Elastic Supply**: Token supply rebases based on a globally set interest rate.
*   **Dynamic Interest Rate**: Allows the contract owner to set a global interest rate that can only decrease, ensuring predictable value accrual.
*   **User-Specific Interest Rates**: Users' accrued interest is calculated based on the global rate at their last interaction (deposit, transfer, burn).
*   **Accrued Interest Minting**: Automatically mints accrued interest to users upon significant interactions (mint, burn, transfer), reflecting their updated balance.
*   **Standard ERC20 Compliance**: Extends OpenZeppelin's `ERC20` contract, ensuring full compatibility with ERC20 standards.
*   **Cross-Chain Capability**: Designed with cross-chain transfers in mind, allowing for burning on one chain and minting on another to maintain supply consistency.

## Getting Started ⚙️

### Installation
To get a local copy up and running, follow these simple steps.

1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/olujimiAdebakin/cross_chain_rebase-token_contract.git
    cd cross_chain_rebase-token_contract
    ```

2.  **Install Foundry**:
    If you don't have Foundry installed, run:
    ```bash
    curl -L https://foundry.paradigm.xyz | bash
    foundryup
    ```

3.  **Install Dependencies**:
    The project uses Git submodules for OpenZeppelin contracts and Forge Standard Library.
    ```bash
    forge install
    ```
    This command initializes and updates the submodules specified in `.gitmodules`.

4.  **Build the Project**:
    Compile the smart contracts:
    ```bash
    forge build
    ```

### Environment Variables
This specific smart contract currently does not require any environment variables for local development or testing. However, for deployment to a blockchain network, you would typically need:

*   `PRIVATE_KEY`: The private key of the deployer wallet. (e.g., `0x...`)
*   `RPC_URL`: The RPC endpoint URL for the blockchain network. (e.g., `https://rpc.sepolia.org`)

## Contract Functions 📖

### `constructor()`
Initializes the ERC20 token with "Orion Token" as its name and "ORT" as its symbol.

### `setInterestRate(uint256 _newInterestRate)`
**Description**: Sets the global interest rate for the token. This function can only decrease the current interest rate. Access control mechanisms (e.g., `onlyOwner` or a governance module) should be added for production environments to restrict who can call this function.

**Parameters**:
*   `_newInterestRate` (uint256): The new interest rate to set (e.g., `5e16` for 5%).

**Errors**:
*   `OrionToken_InterestRateCanOnlyDecrease`: If `_newInterestRate` is greater than the current `s_interestRate`.

### `principleBalanceOf(address _user)`
**Description**: Returns the principle balance of a user, which represents the tokens actually minted to them, excluding any accrued interest.

**Parameters**:
*   `_user` (address): The address of the user.

**Returns**:
*   `uint256`: The principle balance of the user.

### `mint(address _to, uint256 _amount)`
**Description**: Mints new tokens to a specified address. This function also triggers the minting of any accrued interest for the recipient and locks in the current global interest rate for them.

**Parameters**:
*   `_to` (address): The address to mint tokens to.
*   `_amount` (uint256): The principal amount of tokens to mint.

**Errors**:
*   `Amount must be greater than zero`: If `_amount` is 0.
*   `Cannot mint to the zero address`: If `_to` is `address(0)`.

### `burn(address _from, uint256 _amount)`
**Description**: Burns tokens from a user's balance. This function automatically handles burning the entire balance if `_amount` is `type(uint256).max`. It also mints any accrued interest for the user before burning.

**Parameters**:
*   `_from` (address): The address from which to burn tokens.
*   `_amount` (uint256): The amount of tokens to burn. Use `type(uint256).max` to burn the entire balance.

### `balanceOf(address _user)`
**Description**: Returns the current balance of an account, *including* any accrued interest since the last update. This overrides the standard ERC20 `balanceOf` to provide the elastic token's total balance.

**Parameters**:
*   `_user` (address): The address of the account.

**Returns**:
*   `uint256`: The total balance of the user, including accrued interest.

### `transfer(address _recipient, uint256 _amount)`
**Description**: Transfers tokens from the caller to a recipient. Before the transfer, accrued interest for both the sender and recipient is minted. If the recipient is new (has no prior interest rate set), they inherit the sender's interest rate.

**Parameters**:
*   `_recipient` (address): The address to transfer tokens to.
*   `_amount` (uint256): The amount of tokens to transfer. Can be `type(uint256).max` to transfer the full balance.

**Returns**:
*   `bool`: `true` if the transfer was successful.

### `transferFrom(address _sender, address _recipient, uint256 _amount)`
**Description**: Transfers tokens from one address to another on behalf of the `msg.sender`, provided an allowance has been approved. Similar to `transfer`, accrued interest for both sender and recipient is minted before the transfer, and new recipients inherit the sender's interest rate.

**Parameters**:
*   `_sender` (address): The address to transfer tokens from.
*   `_recipient` (address): The address to transfer tokens to.
*   `_amount` (uint256): The amount of tokens to transfer. Can be `type(uint256).max` to transfer the full balance.

**Returns**:
*   `bool`: `true` if the transfer was successful.

### `getInterestRate()`
**Description**: Retrieves the current global interest rate set for the token.

**Returns**:
*   `uint256`: The current global interest rate.

### `getUserInterestRate(address _user)`
**Description**: Retrieves the specific interest rate that was locked in for a given user at their last interaction.

**Parameters**:
*   `_user` (address): The address of the user.

**Returns**:
*   `uint256`: The user's specific locked-in interest rate.

## Technologies Used 🛠️

| Technology      | Description                               | Link                                                                        |
| :-------------- | :---------------------------------------- | :-------------------------------------------------------------------------- |
| **Solidity**    | Smart Contract Language                   | [soliditylang.org](https://soliditylang.org/)                               |
| **Foundry**     | Smart Contract Development Framework      | [book.getfoundry.sh](https://book.getfoundry.sh/)                           |
| **OpenZeppelin**| Secure Smart Contract Libraries           | [openzeppelin.com/contracts](https://docs.openzeppelin.com/contracts/5.x/)  |

## Contributing 🤝
We welcome contributions to the OrionToken project! To contribute:

*   **Fork the repository** on GitHub.
*   **Clone your forked repository** locally.
*   **Create a new branch** for your feature or bug fix: `git checkout -b feature/your-feature-name`.
*   **Implement your changes**, ensuring they adhere to the existing code style.
*   **Write comprehensive tests** for your new code to maintain high code quality.
*   **Run existing tests** to ensure no regressions: `forge test`.
*   **Commit your changes** with a clear and concise message.
*   **Push your branch** to your forked repository.
*   **Open a Pull Request** against the `main` branch of the original repository, describing your changes in detail.

## License 📄
This project is licensed under the MIT License - see the [LICENSE](https://github.com/olujimiAdebakin/cross_chain_rebase-token_contract/blob/main/LICENSE) file for details.

## Author Info 👤
**Adebakin Olujimi**
A passionate Blockchain Developer with a focus on creating secure and efficient decentralized applications.

*   **LinkedIn**: [Your LinkedIn Profile](https://linkedin.com/in/your_username)
*   **Twitter**: [Your Twitter Profile](https://twitter.com/your_username)

---

[![Solidity](https://img.shields.io/badge/Language-Solidity-purple)](https://soliditylang.org/)
[![Foundry](https://img.shields.io/badge/Framework-Foundry-lightgray)](https://book.getfoundry.sh/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![Readme was generated by Dokugen](https://img.shields.io/badge/Readme%20was%20generated%20by-Dokugen-brightgreen)](https://www.npmjs.com/package/dokugen)