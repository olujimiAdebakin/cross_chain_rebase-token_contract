# Orion Protocol: Cross-Chain Rebase Token & Vault

## Overview
Unleash the power of elastic finance with the Orion Protocol. 💫 This innovative project features a cross-chain compatible rebase token (OrionToken) that dynamically adjusts its supply to reward users with accrued interest. Coupled with a secure Vault contract, it incentivizes deposits and provides a robust framework for managing digital assets with built-in access control and a decreasing interest rate mechanism, fueling the next generation of DeFi liquidity across chains!

## Features
- **Elastic Token Supply**: The OrionToken implements a rebase mechanism where its supply dynamically adjusts to reflect accrued interest.
- **Accrued Interest**: Users' balances grow over time based on a set interest rate, which is minted to them upon any interaction (mint, burn, transfer).
- **User-Specific Interest Rates**: Each user's interest rate is locked in at the time of their deposit or interaction, allowing for personalized and consistent growth.
- **Controlled Interest Rate Adjustment**: The global interest rate can only be decreased by the contract owner, ensuring a controlled and potentially deflationary incentive structure.
- **Role-Based Access Control**: Leverages OpenZeppelin's `AccessControl` for secure management of critical functions, such as minting and burning.
- **Secure ETH Vault**: A dedicated `Vault` contract seamlessly handles ETH deposits and withdrawals, maintaining a 1:1 peg with the OrionToken.
- **Cross-Chain Design**: Architectural considerations for future cross-chain compatibility and liquidity solutions.

## Getting Started

### Installation
To get started with the Orion Protocol locally, follow these steps:

1.  👯‍♀️ **Clone the Repository**:
    ```bash
    git clone https://github.com/olujimiAdebakin/cross_chain_rebase-token_contract.git
    cd cross_chain_rebase-token_contract
    ```

2.  🛠️ **Install Foundry**:
    If you don't have Foundry installed, use the following commands:
    ```bash
    curl -L https://foundry.paradigm.xyz | bash
    foundryup
    ```

3.  📦 **Install Dependencies**:
    Navigate to the project directory and install the required smart contract libraries:
    ```bash
    forge install
    ```

4.  ⚙️ **Build Contracts**:
    Compile the smart contracts:
    ```bash
    forge build
    ```

5.  ✅ **Run Tests**:
    Verify the functionality by running the test suite:
    ```bash
    forge test
    ```

### Environment Variables
For deployment and interaction, you will typically need the following environment variables. Create a `.env` file in the root directory and populate it with your values:

```dotenv
RPC_URL="https://eth-sepolia.g.alchemy.com/v2/YOUR_ALCHEMY_API_KEY" # Your Ethereum RPC URL
PRIVATE_KEY="YOUR_DEPLOYER_PRIVATE_KEY"                          # Private key of the deployer account
ETHERSCAN_API_KEY="YOUR_ETHERSCAN_API_KEY"                       # (Optional) For contract verification on Etherscan
```

## API Documentation

The Orion Protocol consists of two primary smart contracts: `OrionToken` and `Vault`. Interaction with the protocol involves calling functions on these deployed contracts.

### Contract Addresses
After deployment, you will obtain the addresses for the `OrionToken` and `Vault` contracts. These addresses serve as the entry points for all protocol interactions.

### Endpoints (Contract Functions)

---

### **OrionToken Contract**

#### `constructor()`
**Description**: Initializes the `OrionToken` with the name "Orion Token" and symbol "ORT", setting the deployer as the `Ownable` owner.

**Parameters**: None
**Returns**: `OrionToken` contract instance
**Errors**: None

#### `grantMintAndBurnRole(address _account)`
**Description**: Grants the `MINT_AND_BURN_ROLE` to a specified address, enabling it to call `mint` and `burn` functions. This function is only callable by the contract owner.
**Access Control**: `onlyOwner`

**Request**:
```solidity
orionToken.grantMintAndBurnRole(0xYourVaultAddress);
```
`_account`: `address` - The address to grant the role to (e.g., the Vault contract address).

**Response**:
Transaction successful.

**Errors**:
- `OwnableUnauthorizedAccount(msg.sender)`: If the caller is not the contract owner.

#### `setInterestRate(uint256 _newInterestRate)`
**Description**: Sets the global interest rate for the token. The new interest rate must be less than or equal to the current rate. Only callable by the contract owner.
**Access Control**: `onlyOwner`

**Request**:
```solidity
orionToken.setInterestRate(4 * 1e16); // Sets the global interest rate to 4% (assuming PRECISION_FACTOR = 1e18)
```
`_newInterestRate`: `uint256` - The new interest rate to set, scaled by `PRECISION_FACTOR` (1e18).

**Response**:
Transaction successful, an `InterestRateSet` event is emitted.

**Errors**:
- `OwnableUnauthorizedAccount(msg.sender)`: If the caller is not the contract owner.
- `OrionToken_InterestRateCanOnlyDecrease(oldInterestRate, newInterestRate, "Interest rate can only decrease")`: If `_newInterestRate` is greater than the current global interest rate.

#### `principleBalanceOf(address _user)`
**Description**: Retrieves the principal balance of a user, excluding any accrued interest. This represents the raw ERC20 balance.

**Request**:
```solidity
orionToken.principleBalanceOf(0xUserAddress);
```
`_user`: `address` - The address of the user.

**Response**:
`uint256` - The principal balance of the user.

**Errors**: None

#### `mint(address _to, uint256 _amount)`
**Description**: Mints new `OrionToken` to a specified address. Before minting, any accrued interest for `_to` is minted, and `_to`'s interest rate is locked to the current global rate.
**Access Control**: `onlyRole(MINT_AND_BURN_ROLE)`

**Request**:
```solidity
orionToken.mint(0xRecipientAddress, 100 * 1e18); // Mint 100 tokens (scaled by 1e18)
```
`_to`: `address` - The address to mint tokens to.
`_amount`: `uint256` - The principal amount of tokens to mint.

**Response**:
Transaction successful, tokens minted to `_to`.

**Errors**:
- `AccessControlUnauthorizedAccount(msg.sender, MINT_AND_BURN_ROLE)`: If the caller does not have the `MINT_AND_BURN_ROLE`.
- `Transaction reverted: Amount must be greater than zero`: If `_amount` is 0.
- `Transaction reverted: Cannot mint to the zero address`: If `_to` is `address(0)`.

#### `burn(address _from, uint256 _amount)`
**Description**: Burns `OrionToken` from a specified address. If `_amount` is `type(uint256).max`, the entire balance (including accrued interest) is burned. Accrued interest for `_from` is minted before burning.
**Access Control**: `onlyRole(MINT_AND_BURN_ROLE)`

**Request**:
```solidity
orionToken.burn(0xSenderAddress, 50 * 1e18); // Burn 50 tokens
orionToken.burn(0xSenderAddress, type(uint256).max); // Burn all tokens from sender
```
`_from`: `address` - The address to burn tokens from.
`_amount`: `uint256` - The amount of tokens to burn. Use `type(uint256).max` to burn all tokens.

**Response**:
Transaction successful, tokens burned from `_from`.

**Errors**:
- `AccessControlUnauthorizedAccount(msg.sender, MINT_AND_BURN_ROLE)`: If the caller does not have the `MINT_AND_BURN_ROLE`.
- `ERC20InsufficientBalance(owner, currentBalance, burnAmount)`: If `_from` does not have sufficient balance.

#### `balanceOf(address _user)`
**Description**: Returns the total balance of an account, including any accrued interest since the last update.

**Request**:
```solidity
orionToken.balanceOf(0xUserAddress);
```
`_user`: `address` - The address of the account.

**Response**:
`uint256` - The total balance including accrued interest (scaled by `PRECISION_FACTOR`).

**Errors**: None

#### `transfer(address _recipient, uint256 _amount)`
**Description**: Transfers `OrionToken` from the caller to a recipient. Accrued interest for both sender and recipient is minted prior to transfer. If `_amount` is `type(uint256).max`, the full balance (including interest) is transferred. New recipients inherit the sender's interest rate.

**Request**:
```solidity
orionToken.transfer(0xRecipientAddress, 25 * 1e18); // Transfer 25 tokens
```
`_recipient`: `address` - The address to transfer tokens to.
`_amount`: `uint256` - The amount of tokens to transfer. Use `type(uint256).max` to transfer the full balance.

**Response**:
`bool` - `true` if the transfer was successful.

**Errors**:
- `ERC20InsufficientBalance(msg.sender, currentBalance, transferAmount)`: If the caller does not have sufficient balance.
- `ERC20InvalidReceiver(address(0))`: If `_recipient` is `address(0)`.

#### `transferFrom(address _sender, address _recipient, uint256 _amount)`
**Description**: Transfers `OrionToken` from `_sender` to `_recipient` on behalf of the caller, provided the caller has sufficient allowance. Accrued interest for both `_sender` and `_recipient` is minted prior to transfer. If `_amount` is `type(uint256).max`, the full balance (including interest) is transferred. New recipients inherit the sender's interest rate.

**Request**:
```solidity
// Example call (assuming caller has allowance from _sender)
orionToken.transferFrom(0xSenderAddress, 0xRecipientAddress, 25 * 1e18);
```
`_sender`: `address` - The address to transfer tokens from.
`_recipient`: `address` - The address to transfer tokens to.
`_amount`: `uint256` - The amount of tokens to transfer. Use `type(uint256).max` to transfer the full balance.

**Response**:
`bool` - `true` if the transfer was successful.

**Errors**:
- `ERC20InsufficientAllowance(owner, currentAllowance, transferAmount)`: If the caller does not have sufficient allowance from `_sender`.
- `ERC20InsufficientBalance(owner, currentBalance, transferAmount)`: If `_sender` does not have sufficient balance.
- `ERC20InvalidReceiver(address(0))`: If `_recipient` is `address(0)`.

#### `getInterestRate()`
**Description**: Returns the current global interest rate of the `OrionToken` contract.

**Request**:
```solidity
orionToken.getInterestRate();
```
**Parameters**: None

**Response**:
`uint256` - The current global interest rate (scaled by `PRECISION_FACTOR`).

**Errors**: None

#### `getUserInterestRate(address _user)`
**Description**: Returns the locked-in interest rate for a specific user. This is the rate recorded at their last interaction.

**Request**:
```solidity
orionToken.getUserInterestRate(0xUserAddress);
```
`_user`: `address` - The address of the user.

**Response**:
`uint256` - The user's specific interest rate (scaled by `PRECISION_FACTOR`).

**Errors**: None

---

### **Vault Contract**

#### `constructor(IOrionToken _orionToken)`
**Description**: Initializes the `Vault` contract by setting the address of the `OrionToken` it will interact with.

**Request**:
```solidity
new Vault(0xOrionTokenAddress); // Deploying the Vault with the OrionToken address
```
`_orionToken`: `IOrionToken` - The address of the deployed `OrionToken` contract.

**Response**:
`Vault` contract instance.

**Errors**: None

#### `receive()`
**Description**: A fallback function that allows the `Vault` to receive direct ETH transfers, typically used for adding rewards or increasing its liquidity.

**Request**:
```solidity
payable(vaultAddress).transfer(1 ether); // Sending 1 ETH directly to the vault
```
**Parameters**: None (implicit `msg.value` from transaction).

**Response**:
Transaction successful, ETH received by the `Vault`.

**Errors**: None

#### `deposit()`
**Description**: Allows a user to deposit ETH into the `Vault`. An equivalent amount of `OrionToken` is minted to the user, based on the `msg.value` sent.

**Request**:
```solidity
vault.deposit{value: 1 ether}(); // Deposit 1 ETH into the vault
```
**Parameters**: None (implicit `msg.value` from transaction).

**Response**:
Transaction successful, a `Deposit` event is emitted, and `OrionToken` is minted to `msg.sender`.

**Errors**:
- `Transaction reverted: Amount must be greater than zero`: If `msg.value` (the deposit amount) is 0.
- Other `OrionToken` errors if `mint` fails (e.g., `_to` is `address(0)`).

#### `redeem(uint256 _amount)`
**Description**: Allows a user to burn their `OrionToken` from the `Vault` and receive a corresponding amount of ETH. If `_amount` is `type(uint256).max`, the user's entire `OrionToken` balance (including accrued interest) is burned, and equivalent ETH is sent.

**Request**:
```solidity
vault.redeem(50 * 1e18); // Redeem 50 tokens from the vault
vault.redeem(type(uint256).max); // Redeem all tokens from the vault
```
`_amount`: `uint256` - The amount of `OrionToken` to redeem. Use `type(uint256).max` to redeem all tokens.

**Response**:
Transaction successful, a `Redeem` event is emitted, and ETH is sent to `msg.sender`.

**Errors**:
- `Vault__Redeem__FailedToSendETH(redeemer, amount)`: If sending ETH to the redeemer fails.
- `ERC20InsufficientBalance(owner, currentBalance, burnAmount)`: If the user does not have sufficient `OrionToken` balance to burn.

#### `getOrionTokenAddress()`
**Description**: Retrieves the address of the `OrionToken` contract associated with this `Vault`.

**Request**:
```solidity
vault.getOrionTokenAddress();
```
**Parameters**: None

**Response**:
`address` - The address of the `OrionToken` contract.

**Errors**: None

---

## Usage

After deploying the `OrionToken` and `Vault` contracts to an Ethereum-compatible network, you can interact with them programmatically or through tools like Foundry's `cast` or `forge script`.

1.  **Deployment (Example using Foundry)**:
    First, ensure your `.env` file is configured with `RPC_URL` and `PRIVATE_KEY`.
    Deploy `OrionToken`:
    ```bash
    forge create src/OrionToken.sol:OrionToken --rpc-url $RPC_URL --private-key $PRIVATE_KEY
    ```
    Note the deployed `OrionToken` address.
    
    Then, deploy `Vault`, passing the `OrionToken` address:
    ```bash
    forge create src/Vault.sol:Vault --rpc-url $RPC_URL --private-key $PRIVATE_KEY --constructor-args <ORION_TOKEN_ADDRESS>
    ```
    Note the deployed `Vault` address.

2.  **Granting Mint/Burn Role to Vault**:
    The `Vault` needs the `MINT_AND_BURN_ROLE` to mint and burn `OrionToken`. The `OrionToken` owner (the deployer) must grant this role:
    ```bash
    cast send <ORION_TOKEN_ADDRESS> "grantMintAndBurnRole(address)" <VAULT_ADDRESS> --rpc-url $RPC_URL --private-key $PRIVATE_KEY
    ```

3.  **Depositing ETH into the Vault**:
    Any user can deposit ETH into the `Vault` to receive `OrionToken`:
    ```bash
    cast send <VAULT_ADDRESS> "deposit()" --value 1ether --rpc-url $RPC_URL --private-key $PRIVATE_KEY
    ```
    This will mint 1 `OrionToken` (with its initial interest) to `msg.sender`.

4.  **Redeeming OrionToken from the Vault**:
    A user can burn their `OrionToken` to receive ETH back:
    ```bash
    cast send <VAULT_ADDRESS> "redeem(uint256)" <AMOUNT_TO_REDEEM_SCALED_BY_1e18> --rpc-url $RPC_URL --private-key $PRIVATE_KEY
    ```
    To redeem all tokens:
    ```bash
    cast send <VAULT_ADDRESS> "redeem(uint256)" $(cast call <ORION_TOKEN_ADDRESS> "balanceOf(address)" $(cast wallet address) --rpc-url $RPC_URL) --rpc-url $RPC_URL --private-key $PRIVATE_KEY
    ```

5.  **Checking Balances**:
    To check the total balance of a user (including accrued interest):
    ```bash
    cast call <ORION_TOKEN_ADDRESS> "balanceOf(address)" <USER_ADDRESS> --rpc-url $RPC_URL
    ```
    To check the principal balance (initial minted amount):
    ```bash
    cast call <ORION_TOKEN_ADDRESS> "principleBalanceOf(address)" <USER_ADDRESS> --rpc-url $RPC_URL
    ```

## Technologies Used

| Technology       | Description                                                                                             | Link                                                                  |
| :--------------- | :------------------------------------------------------------------------------------------------------ | :-------------------------------------------------------------------- |
| **Solidity**     | The primary language for writing secure smart contracts on Ethereum.                                    | [docs.soliditylang.org](https://docs.soliditylang.org/en/latest/)     |
| **Foundry**      | A blazing fast, portable, and modular toolkit for Ethereum application development.                    | [book.getfoundry.sh](https://book.getfoundry.sh/)                     |
| **OpenZeppelin** | A library of battle-tested smart contracts for building secure decentralized applications.              | [docs.openzeppelin.com](https://docs.openzeppelin.com/contracts/5.x/) |
| **Ethereum**     | The foundational decentralized blockchain platform enabling smart contracts and dApps.                  | [ethereum.org](https://ethereum.org/en/)                              |

## Contributing
We welcome contributions to the Orion Protocol! If you're interested in improving this project, please consider the following guidelines:

*   ✨ **Fork the repository**: Start by forking the project to your own GitHub account.
*   🌿 **Create a new branch**: Always work on a new branch for your features or bug fixes.
*   🐛 **Report issues**: If you find any bugs or have suggestions, please open an issue on the GitHub repository.
*   📝 **Submit pull requests**: Once you've implemented a feature or fix, submit a pull request with a clear description of your changes.
*   🧪 **Write tests**: Ensure your code is well-tested. New features should have comprehensive test coverage.
*   🤝 **Follow code style**: Adhere to the existing code style and best practices for Solidity and Foundry.

## License
This project is open-source and licensed under the MIT License.

## Author Info

**Adebakin Olujimi**
-   LinkedIn: [linkedin.com/in/your_profile](https://linkedin.com/in/your_profile)
-   Twitter: [@your_twitter_handle](https://twitter.com/your_twitter_handle)

---
[![Foundry](https://img.shields.io/badge/Made%20with-Foundry-black.svg?style=flat-square&logo=foundry)](https://getfoundry.sh/)
[![Solidity](https://img.shields.io/badge/Solidity-0.8.26-lightgrey.svg?style=flat-square&logo=solidity)](https://docs.soliditylang.org/en/latest/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](https://opensource.org/licenses/MIT)
[![Build Status](https://img.shields.io/badge/Build-Passing-brightgreen.svg?style=flat-square)](https://github.com/olujimiAdebakin/cross_chain_rebase-token_contract/actions)
[![Readme was generated by Dokugen](https://img.shields.io/badge/Readme%20was%20generated%20by-Dokugen-brightgreen)](https://www.npmjs.com/package/dokugen)