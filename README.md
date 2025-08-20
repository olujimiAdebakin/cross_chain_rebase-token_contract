# **OrionToken: Cross-Chain Rebase Token**

## Overview
This project implements the OrionToken, an innovative cross-chain rebase (elastic) token developed with **Solidity** and managed using **Foundry**. It dynamically adjusts user balances based on a decreasing interest rate, incentivizing deposits into associated vaults and offering a unique mechanism for value accrual.

## Features
*   ✨ **Elastic Supply Mechanism**: The token supply rebases (expands or contracts) based on a defined interest rate, allowing balances to change over time.
*   🔒 **Decreasing Interest Rate**: The global interest rate can only be decreased, ensuring predictable and potentially deflationary mechanics for accrued interest.
*   💸 **User-Specific Interest Rates**: Each user's accrued interest is calculated based on the global rate at their last interaction (deposit, transfer, burn).
*   🔄 **Accrued Interest Minting**: Interest is automatically minted to a user's balance upon interactions like minting, burning, or transferring tokens.
*   🛡️ **Role-Based Access Control**: Utilizes OpenZeppelin's `AccessControl` to manage permissions for sensitive operations like minting, burning, and setting interest rates.
*   🔗 **Cross-Chain Compatibility**: Designed with cross-chain applications in mind, facilitating transfers and value synchronization across different blockchain environments.

## Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

Ensure you have Foundry installed. If not, follow the official guide:
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
    The project uses Git submodules for OpenZeppelin contracts and Forge Standard Library.
    ```bash
    git submodule update --init --recursive
    ```

3.  **Compile the Smart Contracts**:
    Navigate to the project root and compile the contracts using Foundry:
    ```bash
    forge build
    ```

### Environment Variables

For local testing and deployment, you might need to set up the following environment variables. Create a `.env` file in the project root:

```
# RPC URL for the network you want to deploy to (e.g., Sepolia, Goerli)
RPC_URL="https://sepolia.infura.io/v3/YOUR_INFURA_PROJECT_ID"

# Private key of the deployer account (e.g., from your MetaMask or wallet)
PRIVATE_KEY="YOUR_PRIVATE_KEY_HERE"
```

## API Documentation

The OrionToken smart contract exposes several external and public functions for interacting with its rebase and token mechanics.

### Contract Address
The contract address will be determined upon deployment to a specific blockchain network.

### Functions

#### `constructor()`
Initializes the ERC20 token with "Orion Token" as its name and "ORT" as its symbol. Sets the deployer as the contract owner.

**Parameters**:
None.

**Events**:
None explicitly defined for constructor, but ERC20 events may be implicitly emitted for initial supply if applicable.

#### `function grantMintAndBurnRole(address _account) external onlyOwner`
Grants the `MINT_AND_BURN_ROLE` to a specified account, allowing them to call `mint` and `burn` functions. Only the contract owner can call this function.

**Parameters**:
- `_account` (address): The address to grant the role to.

**Errors**:
- `Ownable: caller is not the owner`: If the caller is not the contract owner.

#### `function setInterestRate(uint256 _newInterestRate) external onlyOwner`
Sets the global interest rate for the contract. The new interest rate can only be less than or equal to the current interest rate.

**Parameters**:
- `_newInterestRate` (uint256): The new interest rate to set (e.g., `5e16` for 5%).

**Events**:
- `InterestRateSet(uint256 newInterestRate)`: Emitted when the interest rate is successfully updated.

**Errors**:
- `OrionToken_InterestRateCanOnlyDecrease(uint256 oldInterestRate, uint256 newInterestRate, string message)`: If `_newInterestRate` is greater than the current `s_interestRate`.
- `Ownable: caller is not the owner`: If the caller is not the contract owner.

#### `function principleBalanceOf(address _user) external view returns (uint256)`
Retrieves the principal balance of a user (tokens actually minted to them), excluding any accrued interest. This is the raw ERC20 balance.

**Parameters**:
- `_user` (address): The address of the user.

**Response**:
- `uint256`: The principal balance of the user.

#### `function mint(address _to, uint256 _amount) external onlyRole(MINT_AND_BURN_ROLE)`
Mints new tokens to a specified address. Before minting, it calculates and mints any accrued interest for the `_to` address and locks in the current global interest rate for them.

**Parameters**:
- `_to` (address): The address to mint tokens to.
- `_amount` (uint256): The principal amount of tokens to mint. Must be greater than zero.

**Events**:
- `Transfer(address indexed from, address indexed to, uint256 value)`: Emitted for the principal amount minted and any accrued interest minted.

**Errors**:
- `Amount must be greater than zero`: If `_amount` is 0.
- `Cannot mint to the zero address`: If `_to` is `address(0)`.
- `AccessControl: sender missing role`: If the caller does not have `MINT_AND_BURN_ROLE`.

#### `function burn(address _from, uint256 _amount) external onlyRole(MINT_AND_BURN_ROLE)`
Burns tokens from a specified address. Before burning, it calculates and mints any accrued interest for the `_from` address. If `_amount` is `type(uint256).max`, the entire balance of `_from` (including accrued interest) is burned.

**Parameters**:
- `_from` (address): The user address from which to burn tokens.
- `_amount` (uint256): The amount of tokens to burn. Use `type(uint256).max` to burn all tokens.

**Events**:
- `Transfer(address indexed from, address indexed to, uint256 value)`: Emitted for any accrued interest minted, and then for the burned amount (from `_from` to `address(0)`).

**Errors**:
- `ERC20: burn amount exceeds balance`: If `_amount` is greater than `balanceOf(_from)`.
- `AccessControl: sender missing role`: If the caller does not have `MINT_AND_BURN_ROLE`.

#### `function balanceOf(address _user) public view override returns (uint256)`
Returns the current total balance of an account, including any accrued interest. This function overrides the standard ERC20 `balanceOf` to provide the elastic balance.

**Parameters**:
- `_user` (address): The address of the account.

**Response**:
- `uint256`: The total balance including accrued interest.

#### `function transfer(address _recipient, uint256 _amount) public override returns (bool)`
Transfers tokens from the caller (`msg.sender`) to a recipient. Accrued interest for both the sender and recipient is minted *before* the transfer. If the recipient is new (no prior interest rate set), they inherit the sender's interest rate. If `_amount` is `type(uint256).max`, the full balance of `msg.sender` (including accrued interest) is transferred.

**Parameters**:
- `_recipient` (address): The address to transfer tokens to.
- `_amount` (uint256): The amount of tokens to transfer. Use `type(uint256).max` to transfer the full balance.

**Response**:
- `bool`: `true` if the operation succeeded.

**Events**:
- `Transfer(address indexed from, address indexed to, uint256 value)`: Emitted for any accrued interest minted to sender/recipient, and then for the actual transfer.

**Errors**:
- `ERC20: transfer amount exceeds balance`: If `_amount` is greater than `balanceOf(msg.sender)`.
- `ERC20: transfer to the zero address`: If `_recipient` is `address(0)`.

#### `function transferFrom(address _sender, address _recipient, uint256 _amount) public override returns (bool)`
Transfers tokens from one address (`_sender`) to another (`_recipient`) on behalf of the caller, provided an allowance is in place. Accrued interest for both sender and recipient is minted *before* the transfer. If the recipient is new (no prior interest rate set), they inherit the sender's interest rate. If `_amount` is `type(uint256).max`, the full balance of `_sender` (including accrued interest) is transferred.

**Parameters**:
- `_sender` (address): The address to transfer tokens from.
- `_recipient` (address): The address to transfer tokens to.
- `_amount` (uint256): The amount of tokens to transfer. Use `type(uint256).max` to transfer the full balance.

**Response**:
- `bool`: `true` if the operation succeeded.

**Events**:
- `Transfer(address indexed from, address indexed to, uint256 value)`: Emitted for any accrued interest minted to sender/recipient, and then for the actual transfer.
- `Approval(address indexed owner, address indexed spender, uint256 value)`: Emitted if allowance is changed.

**Errors**:
- `ERC20: insufficient allowance`: If the caller does not have enough allowance from `_sender`.
- `ERC20: transfer amount exceeds balance`: If `_amount` is greater than `balanceOf(_sender)`.
- `ERC20: transfer to the zero address`: If `_recipient` is `address(0)`.

#### `function getInterestRate() external view returns (uint256)`
Retrieves the current global interest rate for the token.

**Parameters**:
None.

**Response**:
- `uint256`: The current global interest rate.

#### `function getUserInterestRate(address _user) external view returns (uint256)`
Retrieves the specific interest rate locked in for a given user. This is the rate at which their balance accrues interest.

**Parameters**:
- `_user` (address): The address of the user.

**Response**:
- `uint256`: The user's specific interest rate.

## Usage

After deploying the `OrionToken` contract to a blockchain network (e.g., using `forge script` for deployment), you can interact with it using a web3 library (like Ethers.js or Web3.js) or directly via a block explorer (e.g., Etherscan).

### Example Workflow:

1.  **Deploy the Contract**:
    ```bash
    # Example deployment command (replace with your actual script)
    forge script script/DeployOrionToken.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY
    ```
    (Note: A `DeployOrionToken.s.sol` script would need to be created in the `script` directory for this command to work).

2.  **Grant Mint/Burn Role**:
    The contract owner (`msg.sender` during deployment) can grant the `MINT_AND_BURN_ROLE` to a specific address, e.g., a vault contract or an authorized backend service.
    ```solidity
    // Example interaction from another contract or a wallet
    OrionToken(tokenAddress).grantMintAndBurnRole(vaultAddress);
    ```

3.  **Minting Tokens (e.g., upon user deposit into a vault)**:
    A wallet or a role-granted contract can mint tokens. This will also update the user's interest rate and mint any prior accrued interest.
    ```solidity
    // Example call
    OrionToken(tokenAddress).mint(userAddress, 100e18); // Mints 100 ORT tokens
    ```

4.  **Checking Balance (including accrued interest)**:
    Users can check their total balance, which dynamically reflects accrued interest.
    ```solidity
    uint256 userTotalBalance = OrionToken(tokenAddress).balanceOf(userAddress);
    ```

5.  **Burning Tokens (e.g., upon user withdrawal or cross-chain transfer)**:
    Role-granted entities can burn tokens from a user.
    ```solidity
    // Burn a specific amount
    OrionToken(tokenAddress).burn(userAddress, 50e18);
    // Burn all tokens
    OrionToken(tokenAddress).burn(userAddress, type(uint256).max);
    ```

6.  **Transferring Tokens**:
    Standard ERC20 transfers are supported, with the added logic of updating sender's and recipient's accrued interest.
    ```solidity
    OrionToken(tokenAddress).transfer(anotherUserAddress, 25e18);
    ```

## Technologies Used

| Technology         | Description                                        | Link                                                                        |
| :----------------- | :------------------------------------------------- | :-------------------------------------------------------------------------- |
| 𝗦𝗼𝗹𝗶𝗱𝗶𝘁𝘆          | Smart contract programming language                | [Solidity Lang](https://soliditylang.org/)                                  |
| 𝗙𝗼𝘂𝗻𝗱𝗿𝘆            | blazing-fast, portable, and modular toolkit for Ethereum application development | [Foundry](https://getfoundry.sh/)                                           |
| 𝗢𝗽𝗲𝗻𝗭𝗲𝗽𝗽𝗲𝗹𝗶𝗻 𝗖𝗼𝗻𝘁𝗿𝗮𝗰𝘁𝘀 | Secure, community-vetted smart contract libraries | [OpenZeppelin](https://openzeppelin.com/contracts/)                         |

## Contributing

Contributions are welcome! If you'd like to contribute, please follow these steps:

1.  🍴 Fork the repository.
2.  🌿 Create a new branch (`git checkout -b feature/AmazingFeature`).
3.  ⚙️ Make your changes and ensure tests pass (`forge test`).
4.  ➕ Commit your changes (`git commit -m 'Add some AmazingFeature'`).
5.  ⬆️ Push to the branch (`git push origin feature/AmazingFeature`).
6.  🗣️ Open a pull request.

Please ensure your code adheres to the existing style and includes appropriate tests.

## License

This project is licensed under the MIT License. See the `LICENSE` file for more details.

## Author Info

Adebakin Olujimi
*   LinkedIn: [Your LinkedIn Profile](https://www.linkedin.com/in/your-profile)
*   Twitter: [Your Twitter Handle](https://twitter.com/your-handle)

---

### Built With

[![Solidity](https://img.shields.io/badge/Solidity-%23363636.svg?style=for-the-badge&logo=solidity&logoColor=white)](https://soliditylang.org/)
[![Foundry](https://img.shields.io/badge/Foundry-black?style=for-the-badge&logo=foundry&logoColor=white)](https://getfoundry.sh/)
[![OpenZeppelin](https://img.shields.io/badge/OpenZeppelin-4E5057?style=for-the-badge&logo=openzeppelin&logoColor=white)](https://openzeppelin.com/contracts/)

[![Readme was generated by Dokugen](https://img.shields.io/badge/Readme%20was%20generated%20by-Dokugen-brightgreen)](https://www.npmjs.com/package/dokugen)