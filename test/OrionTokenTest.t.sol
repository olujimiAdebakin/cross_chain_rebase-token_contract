// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {Vault} from "../src/Vault.sol";
import {OrionToken} from "../src/OrionToken.sol";
import {IOrionToken} from "../src/interface/IOrionToken.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";

contract OrionTokenTest is Test {
    OrionToken private orionToken;
    Vault private vault;

    address public owner = makeAddr("owner");
    address public user = makeAddr("user");

    function setUp() public {
        vm.startPrank(owner);
        orionToken = new OrionToken();
        vault = new Vault((IOrionToken(address(orionToken))));
        orionToken.grantMintAndBurnRole(address(vault));
        (bool success,) = payable(address(vault)).call{value: 1e18}("");
        success;
        //      require(success, "Failed to send Ether");
        vm.stopPrank();
        // require(success, "Failed to send Ether");
    }

    function testDepositLinear(uint256 amount) public {
        // fuzz the amount

        amount = bound(amount, 1e5, type(uint96).max);

        // 1. deposit amount ETH
        vm.startPrank(user);
        vm.deal(user, amount);
        vault.deposit{value: amount}();
        // 2. check our rebase Token balance for user
        uint256 startingBalance = orionToken.balanceOf(user);
        console.log("STARTING BALANCE", startingBalance);
        assertEq(startingBalance, amount);
        // 3. warp time forward and check balance again
        vm.warp(block.timestamp + 1 hours);
        uint256 newBalance = orionToken.balanceOf(user);
        assertGt(newBalance, startingBalance);
        console.log("NEW BALANCE", newBalance);
        // 4. warp time forward by the same amount and check balance again
        vm.warp(block.timestamp + 1 hours);
        uint256 endBalance = orionToken.balanceOf(user);
        assertGt(endBalance, newBalance);

        assertApproxEqAbs(endBalance - newBalance, newBalance - startingBalance, 1);
        console.log("END BALANCE", endBalance);
        vm.stopPrank();
    }

    function testRedeemStraightAway(uint256 amount) public {
        // fuzz the amount
        amount = bound(amount, 1e5, type(uint96).max);

        // 1. deposit amount ETH
        vm.startPrank(user);
        vm.deal(user, amount);
        vault.deposit{value: amount}();
        // 2. check our rebase Token balance for user
        uint256 startingBalance = orionToken.balanceOf(user);
        console.log("STARTING BALANCE", startingBalance);
        assertEq(startingBalance, amount);
        // 3. redeem straight away
        vault.redeem(amount);
        // 4. check our rebase Token balance for user
        uint256 endBalance = orionToken.balanceOf(user);
        assertEq(endBalance, 0);
        console.log("END BALANCE", endBalance);
        vm.stopPrank();
    }

    function testRedeemAfterTimeHasPassed(uint256 depositAmount, uint256 time) public {
        // Bound inputs to avoid nonsense values
        depositAmount = bound(depositAmount, 1e5, type(uint96).max);
        time = bound(time, 1 hours, 365 days); // realistic upper bound

        // 1. User deposits into vault
        vm.deal(user, depositAmount);
        vm.startPrank(user);
        vault.deposit{value: depositAmount}();
        vm.stopPrank();

        uint256 startingBalance = orionToken.balanceOf(user);
        assertEq(startingBalance, depositAmount);

        // 2. Warp forward in time
        vm.warp(block.timestamp + time);

        // 3. Get new balance after rebase
        uint256 balance = orionToken.balanceOf(user);
        assertGt(balance, startingBalance); // must have grown

        // 4. Owner tops up vault with rewards (so vault can actually pay out)
        vm.deal(owner, balance - depositAmount);
        vm.prank(owner);
        (bool ok,) = payable(address(vault)).call{value: balance - depositAmount}("");
        require(ok, "Top-up failed");

        // 5. Redeem
        vm.startPrank(user);
        vault.redeem(balance);
        vm.stopPrank();

        // 6. User token balance should be zero, ETH balance should match rebase balance
        assertEq(orionToken.balanceOf(user), 0);
        assertEq(address(user).balance, balance);
        assertGt(address(user).balance, depositAmount);
    }

    function testTransfer(uint256 amount, uint256 amountToSend) public{
      amount = bound(amount, 1e5 + 1e3, type(uint96).max);
      amountToSend = bound(amountToSend, 1e5, amount - 1e3);

      // 1. deposit
      vm.prank(user);
      vm.deal(user, amount);
      vault.deposit{value: amount}();

      address userTwo = makeAddr("userTwo");
      uint256 userBalance = orionToken.balanceOf(user);
      uint256 userTwoBalance = orionToken.balanceOf(userTwo);
      console.log("User balance before transfer", userBalance);
      console.log("User2 balance before transfer", userTwoBalance);
      assertEq(userBalance, amount);
      assertEq(userTwoBalance, 0);

      // owner reduces the interest rate
      vm.prank(owner);
      // This is equal to 4 followed by 10 zeros: 40,000,000,000 (forty billion).
      orionToken.setInterestRate(4e10); // 4% 4e10 is a shorthand for 4×10 // raised to the power of 10, which is 40,000,000,000.
      
      // 2. Transfer
      vm.prank(user);
      orionToken.transfer(userTwo, amountToSend);
      uint256 userBalanceAfterTransfer = orionToken.balanceOf(user);
      uint256 userTwoBalanceAfterTransfer = orionToken.balanceOf(userTwo);
      assertEq(userBalanceAfterTransfer, userBalance - amountToSend);
      assertEq(userTwoBalanceAfterTransfer, userTwoBalance + amountToSend);
      console.log("User2 balance after transfer", userTwoBalanceAfterTransfer);
      console.log("User balance after transfer", userBalanceAfterTransfer);
     
//      After some time has passed, check the balance of the two users has increased
      vm.warp(block.timestamp + 1 hours);
      uint256 userBalanceAfterWarp = orionToken.balanceOf(user);
      uint256 userTwoBalanceAfterWarp = orionToken.balanceOf(userTwo);
      console.log("User2 balance after time", userTwoBalanceAfterWarp);
      console.log("User balance after time", userBalanceAfterWarp);
      
      uint256 userTwoInterestRate = orionToken.getUserInterestRate(userTwo);
      assertEq(userTwoInterestRate, 5e10); // 5% interest rate for userTwo

      uint256 userInterestRate = orionToken.getUserInterestRate(user);
      assertEq(userInterestRate, 5e10); // 5% interest rate for
      // check the user interest rate has been inherited (5e10 not 4e10)

      assertGe(userBalanceAfterWarp, userBalanceAfterTransfer);
      assertGe(userTwoBalanceAfterWarp, userTwoBalanceAfterTransfer);

    }

    function testCannotSetInterestRate(uint256 newInterestRate) public {
      vm.prank(user);
      vm.expectPartialRevert(Ownable.OwnableUnauthorizedAccount.selector);
      orionToken.setInterestRate(newInterestRate);
      vm.stopPrank();
    }

    function testCannotMintAndBurn() public {
      vm.prank(user);
      vm.expectPartialRevert(bytes4(IAccessControl.AccessControlUnauthorizedAccount.selector));
      orionToken.mint(user, 100);
      vm.expectPartialRevert(bytes4(IAccessControl.AccessControlUnauthorizedAccount.selector));
      orionToken.burn(user, 100);
    }


    function testPrincipleAmount(uint256 amount)public{
      amount = bound(amount, 1e5, type(uint96).max);

      // 1. deposit amount ETH
      vm.startPrank(user);
      vm.deal(user, amount);
      vault.deposit{value: amount}();
      // 2. check our rebase Token balance for user
      uint256 startingBalance = orionToken.balanceOf(user);
      console.log("STARTING BALANCE", startingBalance);
      assertEq(startingBalance, amount);
      // 3. warp time forward and check balance again
      vm.warp(block.timestamp + 1 hours);
      uint256 newBalance = orionToken.balanceOf(user);
      assertGt(newBalance, startingBalance);
      console.log("NEW BALANCE", newBalance);
      // 4. warp time forward by the same amount and check balance again
      vm.warp(block.timestamp + 1 hours);
      uint256 endBalance = orionToken.balanceOf(user);
      assertGt(endBalance, newBalance);

      assertApproxEqAbs(endBalance - newBalance, newBalance - startingBalance, 1);
      console.log("END BALANCE", endBalance);

      // check principle amount
      uint256 principleAmount = orionToken.principleBalanceOf(user);
      assertEq(principleAmount, startingBalance);

    }

    function getOrionTokenAddress() public {
      assertEq(vault.getOrionTokenAddress(), address(orionToken));
    }

    function testInterestRateCanOnlyDecrease(uint256 newInterestRate)public{
      uint256 initialInterestRate = orionToken.getInterestRate();
      newInterestRate = bound(newInterestRate, initialInterestRate + 1, type(uint96).max);
      vm.prank(owner);
      vm.expectPartialRevert(bytes4(OrionToken.OrionToken_InterestRateCanOnlyDecrease.selector));
      orionToken.setInterestRate(newInterestRate);

      assertEq(orionToken.getInterestRate(), initialInterestRate);

    }

}
