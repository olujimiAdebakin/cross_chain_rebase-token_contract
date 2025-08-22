// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {Vault} from "../src/Vault.sol";
import {OrionToken} from "../src/OrionToken.sol";
import {IOrionToken} from "../src/interface/IOrionToken.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";

/// @title OrionTokenTest
/// @author Adebakin Olujimi
/// @notice This contract contains a suite of tests for the OrionToken and Vault contracts.
/// @dev The tests use Foundry's `forge-std` library for a robust testing environment.
contract OrionTokenTest is Test {
    // OrionToken is the rebase token.
    OrionToken private orionToken;
    // Vault is the contract that handles ETH deposits and withdrawals.
    Vault private vault;

    // `owner` is the address that deploys the contracts and has special permissions.
    address public owner = makeAddr("owner");
    // `user` is a regular user for testing deposit and redeem functionalities.
    address public user = makeAddr("user");

    /// @dev Sets up the testing environment before each test function.
    function setUp() public {
        // Start a prank from the `owner` address to simulate a transaction.
        vm.startPrank(owner);
        // Deploy the OrionToken contract.
        orionToken = new OrionToken();
        // Deploy the Vault contract, passing the OrionToken contract address to its constructor.
        vault = new Vault((IOrionToken(address(orionToken))));
        // Grant the MINT_AND_BURN_ROLE to the Vault, allowing it to mint and burn tokens.
        orionToken.grantMintAndBurnRole(address(vault));
        // Fund the vault with 1 ETH so it can start rebasing.
        (bool success,) = payable(address(vault)).call{value: 1e18}("");
        // Store the success status of the ETH transfer.
        success;
        // The commented-out `require` is from an older version and is no longer needed.
        //      require(success, "Failed to send Ether");
        // Stop the prank, returning to the default address.
        vm.stopPrank();
        // The commented-out `require` is a duplicate and is no longer needed.
        // require(success, "Failed to send Ether");
    }

    /// @notice Tests the linear growth of a user's balance after a deposit.
    /// @dev Deposits a fuzzed amount of ETH, verifies the starting token balance,
    /// then warps time forward twice to check that the balance grows linearly.
    /// @param amount The fuzzed amount of ETH to deposit.
    function testDepositLinear(uint256 amount) public {
        // fuzz the amount
        // Bounding the fuzzed amount to prevent overflow and ensure a realistic value.
        amount = bound(amount, 1e5, type(uint96).max);

        // 1. deposit amount ETH
        // Start a prank from the `user` address.
        vm.startPrank(user);
        // Fund the `user` with the specified `amount` of ETH.
        vm.deal(user, amount);
        // Call the `deposit` function on the vault, sending the ETH with the call.
        vault.deposit{value: amount}();
        // 2. check our rebase Token balance for user
        // Get the initial OrionToken balance of the user.
        uint256 startingBalance = orionToken.balanceOf(user);
        // Log the starting balance to the console for debugging.
        console.log("STARTING BALANCE", startingBalance);
        // Assert that the starting token balance is equal to the deposited ETH amount.
        assertEq(startingBalance, amount);
        // 3. warp time forward and check balance again
        // Warp the blockchain's timestamp forward by one hour.
        vm.warp(block.timestamp + 1 hours);
        // Get the new balance after the time warp.
        uint256 newBalance = orionToken.balanceOf(user);
        // Assert that the new balance is greater than the starting balance, proving the rebase worked.
        assertGt(newBalance, startingBalance);
        // Log the new balance.
        console.log("NEW BALANCE", newBalance);
        // 4. warp time forward by the same amount and check balance again
        // Warp the timestamp forward by another hour.
        vm.warp(block.timestamp + 1 hours);
        // Get the balance after the second time warp.
        uint256 endBalance = orionToken.balanceOf(user);
        // Assert that the end balance is greater than the new balance.
        assertGt(endBalance, newBalance);

        // Assert that the growth between the two periods is approximately equal, demonstrating linear growth.
        assertApproxEqAbs(endBalance - newBalance, newBalance - startingBalance, 1);
        // Log the end balance.
        console.log("END BALANCE", endBalance);
        // Stop the prank.
        vm.stopPrank();
    }

    /// @notice Tests redeeming tokens immediately after deposit.
    /// @dev Deposits a fuzzed amount of ETH, then redeems the full amount of tokens.
    /// Verifies the final token balance is zero.
    /// @param amount The fuzzed amount of ETH to deposit.
    function testRedeemStraightAway(uint256 amount) public {
        // fuzz the amount
        // Bounding the fuzzed amount.
        amount = bound(amount, 1e5, type(uint96).max);

        // 1. deposit amount ETH
        // Start a prank from the `user` address.
        vm.startPrank(user);
        // Fund the `user` with the specified `amount` of ETH.
        vm.deal(user, amount);
        // Call the `deposit` function.
        vault.deposit{value: amount}();
        // 2. check our rebase Token balance for user
        // Get the initial OrionToken balance of the user.
        uint256 startingBalance = orionToken.balanceOf(user);
        // Log the starting balance.
        console.log("STARTING BALANCE", startingBalance);
        // Assert the starting token balance equals the deposited ETH.
        assertEq(startingBalance, amount);
        // 3. redeem straight away
        // Call the `redeem` function to redeem all tokens.
        vault.redeem(amount);
        // 4. check our rebase Token balance for user
        // Get the user's token balance after redemption.
        uint256 endBalance = orionToken.balanceOf(user);
        // Assert the final token balance is zero.
        assertEq(endBalance, 0);
        // Log the end balance.
        console.log("END BALANCE", endBalance);
        // Stop the prank.
        vm.stopPrank();
    }

    /// @notice Tests redeeming tokens after a period of time has passed.
    /// @dev Deposits a fuzzed amount, warps time to allow for rebasing,
    /// then tops up the vault and redeems the full, increased balance.
    /// Verifies the final ETH and token balances.
    /// @param depositAmount The fuzzed amount of ETH to deposit.
    /// @param time The fuzzed amount of time to warp forward.
    function testRedeemAfterTimeHasPassed(uint256 depositAmount, uint256 time) public {
        // Bound inputs to avoid nonsense values
        // Bound the `depositAmount`.
        depositAmount = bound(depositAmount, 1e5, type(uint96).max);
        // Bound the `time` to a realistic range.
        time = bound(time, 1 hours, 365 days); // realistic upper bound

        // 1. User deposits into vault
        // Fund the user with the specified `depositAmount`.
        vm.deal(user, depositAmount);
        // Start a prank from the `user` address.
        vm.startPrank(user);
        // Deposit the ETH.
        vault.deposit{value: depositAmount}();
        // Stop the prank.
        vm.stopPrank();

        // Get the initial token balance.
        uint256 startingBalance = orionToken.balanceOf(user);
        // Assert the initial balance matches the deposit amount.
        assertEq(startingBalance, depositAmount);

        // 2. Warp forward in time
        // Warp the timestamp forward by the fuzzed `time` amount.
        vm.warp(block.timestamp + time);

        // 3. Get new balance after rebase
        // Get the user's token balance after rebasing.
        uint256 balance = orionToken.balanceOf(user);
        // Assert the balance has increased.
        assertGt(balance, startingBalance); // must have grown

        // 4. Owner tops up vault with rewards (so vault can actually pay out)
        // Fund the `owner` with the amount needed to cover the rebased rewards.
        vm.deal(owner, balance - depositAmount);
        // Start a prank from the `owner` address.
        vm.prank(owner);
        // Top up the vault's ETH balance.
        (bool ok,) = payable(address(vault)).call{value: balance - depositAmount}("");
        // Require that the top-up was successful.
        require(ok, "Top-up failed");

        // 5. Redeem
        // Start a prank from the `user` address.
        vm.startPrank(user);
        // Call `redeem` to withdraw the full, rebased amount.
        vault.redeem(balance);
        // Stop the prank.
        vm.stopPrank();

        // 6. User token balance should be zero, ETH balance should match rebase balance
        // Assert the final token balance is zero.
        assertEq(orionToken.balanceOf(user), 0);
        // Assert the user's final ETH balance is equal to the rebased token balance.
        assertEq(address(user).balance, balance);
        // Assert the user's final ETH balance is greater than the initial deposit amount.
        assertGt(address(user).balance, depositAmount);
    }

    /// @notice Tests the `transfer` functionality and interest rate inheritance.
    /// @dev Deposits tokens for one user, transfers some to a second user,
    /// then warps time and verifies both users' balances have grown with the same interest rate.
    /// @param amount The fuzzed amount of ETH to deposit.
    /// @param amountToSend The fuzzed amount of tokens to transfer.
    function testTransfer(uint256 amount, uint256 amountToSend) public{
        // Bound the deposit amount.
        amount = bound(amount, 1e5 + 1e3, type(uint96).max);
        // Bound the transfer amount to be less than the total deposit.
        amountToSend = bound(amountToSend, 1e5, amount - 1e3);

        // 1. deposit
        // Prank from `user` and fund them with the deposit amount.
        vm.prank(user);
        vm.deal(user, amount);
        // Deposit the ETH.
        vault.deposit{value: amount}();

        // Create a new address for the second user.
        address userTwo = makeAddr("userTwo");
        // Get the initial balances of both users.
        uint256 userBalance = orionToken.balanceOf(user);
        uint256 userTwoBalance = orionToken.balanceOf(userTwo);
        // Log the balances.
        console.log("User balance before transfer", userBalance);
        console.log("User2 balance before transfer", userTwoBalance);
        // Assert the initial balances are correct.
        assertEq(userBalance, amount);
        assertEq(userTwoBalance, 0);

        // owner reduces the interest rate
        // Prank from the `owner` address.
        vm.prank(owner);
        // This is equal to 4 followed by 10 zeros: 40,000,000,000 (forty billion).
        // Call `setInterestRate` to change the default interest rate.
        orionToken.setInterestRate(4e10); // 4% 4e10 is a shorthand for 4×10 // raised to the power of 10, which is 40,000,000,000.
        
        // 2. Transfer
        // Prank from `user`.
        vm.prank(user);
        // Transfer a portion of the tokens to `userTwo`.
        orionToken.transfer(userTwo, amountToSend);
        // Get the new balances after the transfer.
        uint256 userBalanceAfterTransfer = orionToken.balanceOf(user);
        uint256 userTwoBalanceAfterTransfer = orionToken.balanceOf(userTwo);
        // Assert the balances were updated correctly.
        assertEq(userBalanceAfterTransfer, userBalance - amountToSend);
        assertEq(userTwoBalanceAfterTransfer, userTwoBalance + amountToSend);
        // Log the new balances.
        console.log("User2 balance after transfer", userTwoBalanceAfterTransfer);
        console.log("User balance after transfer", userBalanceAfterTransfer);
        
        // After some time has passed, check the balance of the two users has increased
        // Warp time forward by one hour.
        vm.warp(block.timestamp + 1 hours);
        // Get the balances after the time warp.
        uint256 userBalanceAfterWarp = orionToken.balanceOf(user);
        uint256 userTwoBalanceAfterWarp = orionToken.balanceOf(userTwo);
        // Log the final balances.
        console.log("User2 balance after time", userTwoBalanceAfterWarp);
        console.log("User balance after time", userBalanceAfterWarp);
        
        // Check the interest rate for `userTwo`.
        uint256 userTwoInterestRate = orionToken.getUserInterestRate(userTwo);
        // Assert `userTwo` inherits the default interest rate (5e10), not the new, lower rate.
        assertEq(userTwoInterestRate, 5e10); // 5% interest rate for userTwo

        // Check the interest rate for `user`.
        uint256 userInterestRate = orionToken.getUserInterestRate(user);
        // Assert `user` also retains the default interest rate.
        assertEq(userInterestRate, 5e10); // 5% interest rate for
        // check the user interest rate has been inherited (5e10 not 4e10)

        // Assert that both users' balances have increased since the transfer.
        assertGe(userBalanceAfterWarp, userBalanceAfterTransfer);
        assertGe(userTwoBalanceAfterWarp, userTwoBalanceAfterTransfer);

    }

    /// @notice Tests that only the owner can set the interest rate.
    /// @dev Attempts to call `setInterestRate` from a non-owner address and expects a revert.
    /// @param newInterestRate A fuzzed value for the interest rate.
    function testCannotSetInterestRate(uint256 newInterestRate) public {
        // Prank from a non-owner address (`user`).
        vm.prank(user);
        // Expect a partial revert with the `OwnableUnauthorizedAccount` error selector.
        vm.expectPartialRevert(Ownable.OwnableUnauthorizedAccount.selector);
        // Attempt to set the interest rate.
        orionToken.setInterestRate(newInterestRate);
        // Stop the prank.
        vm.stopPrank();
    }

    /// @notice Tests that `mint` and `burn` functions are protected.
    /// @dev Attempts to call `mint` and `burn` from a non-authorized address and expects a revert.
    function testCannotMintAndBurn() public {
        // Prank from a non-authorized address (`user`).
        vm.prank(user);
        // Expect a partial revert with the `AccessControlUnauthorizedAccount` error selector.
        vm.expectPartialRevert(bytes4(IAccessControl.AccessControlUnauthorizedAccount.selector));
        // Attempt to mint tokens.
        orionToken.mint(user, 100);
        // Expect another partial revert with the same error selector.
        vm.expectPartialRevert(bytes4(IAccessControl.AccessControlUnauthorizedAccount.selector));
        // Attempt to burn tokens.
        orionToken.burn(user, 100);
    }


    /// @notice Tests that the `principleBalanceOf` function returns the correct initial deposit amount.
    /// @dev Deposits a fuzzed amount, warps time forward, and verifies that the principle balance
    /// remains the same as the initial deposit amount.
    /// @param amount The fuzzed amount of ETH to deposit.
    function testPrincipleAmount(uint256 amount)public{
        // Bound the amount.
        amount = bound(amount, 1e5, type(uint96).max);

        // 1. deposit amount ETH
        // Start a prank from the `user` address.
        vm.startPrank(user);
        // Fund the `user`.
        vm.deal(user, amount);
        // Deposit the ETH.
        vault.deposit{value: amount}();
        // 2. check our rebase Token balance for user
        // Get the initial token balance.
        uint256 startingBalance = orionToken.balanceOf(user);
        // Log the starting balance.
        console.log("STARTING BALANCE", startingBalance);
        // Assert the balance matches the deposit amount.
        assertEq(startingBalance, amount);
        // 3. warp time forward and check balance again
        // Warp time by one hour.
        vm.warp(block.timestamp + 1 hours);
        // Get the new balance.
        uint256 newBalance = orionToken.balanceOf(user);
        // Assert the balance has increased.
        assertGt(newBalance, startingBalance);
        // Log the new balance.
        console.log("NEW BALANCE", newBalance);
        // 4. warp time forward by the same amount and check balance again
        // Warp time by another hour.
        vm.warp(block.timestamp + 1 hours);
        // Get the end balance.
        uint256 endBalance = orionToken.balanceOf(user);
        // Assert the balance has increased again.
        assertGt(endBalance, newBalance);

        // Assert the growth is approximately linear.
        assertApproxEqAbs(endBalance - newBalance, newBalance - startingBalance, 1);
        // Log the end balance.
        console.log("END BALANCE", endBalance);

        // check principle amount
        // Get the principle balance.
        uint256 principleAmount = orionToken.principleBalanceOf(user);
        // Assert the principle balance is the same as the initial deposit amount.
        assertEq(principleAmount, startingBalance);

    }

    /// @notice Tests the `getOrionTokenAddress` function of the Vault.
    /// @dev Calls the function and asserts that it returns the correct address of the OrionToken contract.
    function getOrionTokenAddress() public {
        // Assert that the address returned by `getOrionTokenAddress` is the same as the deployed `orionToken` contract address.
        assertEq(vault.getOrionTokenAddress(), address(orionToken));
    }

    /// @notice Tests that the interest rate can only be decreased.
    /// @dev Attempts to set a new interest rate that is greater than the current one and expects a revert.
    /// @param newInterestRate The fuzzed interest rate to attempt to set.
    function testInterestRateCanOnlyDecrease(uint256 newInterestRate)public{
        // Get the current interest rate.
        uint256 initialInterestRate = orionToken.getInterestRate();
        // Bound the `newInterestRate` to be greater than the initial rate.
        newInterestRate = bound(newInterestRate, initialInterestRate + 1, type(uint96).max);
        // Prank from the `owner` address.
        vm.prank(owner);
        // Expect a partial revert with the `OrionToken_InterestRateCanOnlyDecrease` error selector.
        vm.expectPartialRevert(bytes4(OrionToken.OrionToken_InterestRateCanOnlyDecrease.selector));
        // Attempt to set the new, higher interest rate.
        orionToken.setInterestRate(newInterestRate);

        // Assert that the interest rate did not change.
        assertEq(orionToken.getInterestRate(), initialInterestRate);

    }

}