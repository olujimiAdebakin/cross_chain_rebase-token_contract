// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;



import {IOrionToken} from "./interface/IOrionToken.sol";


contract Vault{

    // Core Requirements:
    // 1. Store the address of the RebaseToken contract (passed in constructor).
    // 2. Implement a deposit function:
    //    - Accepts ETH from the user.
    //    - Mints RebaseTokens to the user, equivalent to the ETH sent (1:1 peg initially).
    // 3. Implement a redeem function:
    //    - Burns the user's RebaseTokens.
    //    - Sends the corresponding amount of ETH back to the user.
    // 4. Implement a mechanism to add ETH rewards to the vault.

     IOrionToken private immutable i_orionToken;
//      address private immutable i_rebaseToken;


    error Vault__Redeem__FailedToSendETH(address redeemer, uint256 amount);

   
    // IRebaseToken is the interface for the RebaseToken contract.


   
    event Deposit(address indexed user, uint256 amount);
    event Redeem(address indexed redeemer, uint256 amount);


    constructor (IOrionToken _orionToken) {
      i_orionToken = _orionToken;
    }


       /**
     * @notice Fallback function to accept ETH rewards sent directly to the contract.
     */
    receive () external payable {}

      /**
     * @notice Allows a user to deposit ETH and receive an equivalent amount of RebaseTokens.
     */
    function deposit() external payable {
      // 1. we need to use the amount of ETH the user has sent to mint tokens to the user
      i_orionToken.mint(msg.sender, msg.value);
      emit Deposit(msg.sender, msg.value);
    }

      /**
     * @notice Allows a user to burn their RebaseTokens and receive a corresponding amount of ETH.
     * @param _amount The amount of RebaseTokens to redeem.
     * @dev Follows Checks-Effects-Interactions pattern. Uses low-level .call for ETH transfer.
     */
    function redeem(uint256 _amount) external {
        // 1. we need to burn the user's tokens
        i_orionToken.burn(msg.sender, _amount);
        // 2. we need to send the user the amount of ETH equivalent to the amount of tokens burned
       (bool success,) = payable(msg.sender).call{value: _amount}("");
       if (success == false) {
           revert Vault__Redeem__FailedToSendETH(msg.sender, _amount);
       }

       emit Redeem(msg.sender, _amount);
    }

        /**
     * @notice Gets the address of the RebaseToken contract associated with this vault.
     * @return The address of the RebaseToken.
     */
    function getRebaseTokenAddress() external view returns (address) {
        return address (i_orionToken);
    }


}