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


    error Redeem_FailedToSendETH(msg.sender, _amount);

   
    // IRebaseToken is the interface for the RebaseToken contract.


   
    event Deposit(address indexed user, uint256 amount);


    constructor (IOrionToken _orionToken) {
      i_orionToken = _orionToken;
    }



    receive () external payable {}

    function deposit() external payable {
      // 1. we need to use the amount of ETH the user has sent to mint tokens to the user
      i_orionToken.mint(msg.sender, msg.value);
      emit Deposit(msg.sender, msg.value);
    }


    function redeem(uint256 _amount) external {
        // 1. we need to burn the user's tokens
        i_orionToken.burn(msg.sender, _amount);
        // 2. we need to send the user the amount of ETH equivalent to the amount of tokens burned
       (bool success,) = payable(msg.sender).call{value: _amount}("");
       if (success == false) {
           revert Redeem_FailedToSendETH(msg.sender, _amount);
       }
    }

    function getRebaseTokenAddress() external view returns (address) {
        return address (i_orionToken);
    }



}