

// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {Vault} from "../src/Vault.sol";
import {OrionToken} from "../src/OrionToken.sol";
import {IOrionToken} from "../src/interface/IOrionToken.sol";




contract OrionTokenTest is Test {

      OrionToken private orionToken;
      Vault private vault;

      address public owner = makeAddr("owner");
      address public user = makeAddr("user");

      function setUp() public{
            vm.startPrank(owner);
            orionToken = new OrionToken();
            vault = new Vault((IOrionToken(address(orionToken))));
            orionToken.grantMintAndBurnRole(address(vault));
           (bool success,) = payable(address(vault)).call{value: 1e18}("");
            vm.stopPrank();
      }

      function testDepositLinear() public {
            // fuzz the amount
            
            amount = bound(amount, 1e5, type(uint96).max);


            // 1. deposit amount ETH
            vm.startPrank(user);
            vm.deal(user, amount);
            vault.deposit(value: amount){};
            // 2. check our rebase Token balance for user
            uint256 startingBalance = orionToken.balanceOf(user);
            console.log("STARTING BALANCE", startingBalance);
            assertEq(startingBalance, amount);
            // 3. warp time forward and check balance again
            // 4. warp time forward by the same amount and check balance again
      }

}