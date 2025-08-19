// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/*
* @title OrionToken an implememntation of a rebase (elastic token);
* @author Adebakin Olujimi
* @notice This is a cross-chain rebase token (OrionToken) that incentivizes users to deposit into a vault
* @notice The intereste rate in the smart contract can only decrease and the rebase token can
* @notice Each users will have there own interest rate that is the global interest rate at the time of depositing
 */
contract OrionToken is ERC20 {
    error OrionToken_InterestRateCanOnlyDecrease(uint256 oldInterestRate, uint256 newInterestRate, string message);

    uint256 private s_interestRate = 5e16; // 5% interest rate
    mapping(address => uint256) private s_userInterestRates; // User-specific interest rates
    mapping(address => uint256) private s_userLastUpdatedTimeStamp; // Last updated timestamp for each user
    uint256 private constant PRECISION_FACTOR = 1e18;

    event InterestRateSet(uint256 newInterestRate);

    constructor() ERC20("Orion Token", "ORT") {}

    /**
     * @notice Set the global interest rate for the contract.
     * @param _newInterestRate The new interest rate to set.
     * @dev The interest rate can only decrease. Add access control (e.g., onlyOwner).
     */
    function setInterestRate(uint256 _newInterestRate) external {
        //   set the intereste rate for the rebase token
        //   This function can be modified to set the interest rate based on some logic
        if (_newInterestRate > s_interestRate) {
            revert OrionToken_InterestRateCanOnlyDecrease(
                s_interestRate, _newInterestRate, "Interest rate can only decrease"
            );
            // revertInterestRateTooLow();
        }
        s_interestRate = _newInterestRate;
        emit InterestRateSet(_newInterestRate);
    }

    /**
     * @notice Mints tokens to a user, typically upon deposit.
     * @dev Also mints accrued interest and locks in the current global rate for the user.
     * @param _to The address to mint tokens to.
     * @param _amount The principal amount of tokens to mint.
     */
    function mint(address _to, uint256 _amount) external {
        _mintAccruedInterest(_to);
        s_userInterestRates[_to] = s_interestRate; // Set user's interest rate to the current global rate

        // Ensure the amount is greater than zero
        require(_amount > 0, "Amount must be greater than zero");
        // Ensure the recipient address is valid
        require(_to != address(0), "Cannot mint to the zero address");
        // Mint new tokens to the specified address
        _mint(_to, _amount);
    }

    /**
     * @notice Returns the current balance of an account, including accrued interest.
     * @param _user The address of the account.
     * @return The total balance including interest.
     */
    function balanceOf(address _user) public view override returns (uint256) {
        // get the current principles balance of the user (the number of tokens that have actually been minted to the user)
        // multiply the principal balance by the interest rate that has accumulated in the time since the balance was last updated
        // Return the balance of the user
        return super.balanceOf(_user) * _caculatedUserAccumulatedInterestSinceLastUpdate(_user)
            / PRECISION_FACTOR;
    }

    function _caculatedUserAccumulatedInterestSinceLastUpdate(address _user)
        internal
        view
        returns (uint256 linearInterest)
    {
        // we need to calculate the interest that has accumulated since the last update
        // this is going to be linear growth with time
        // 1. calculate the amount of linear growth
        // 2. calculate the time since the last update

        // (principal amount) + (principal amount * user interest rate * time elapsed)

        // deposit : 10 tokens
        // interest rate: 0.5 tokens per second
        // last updated timestamp: 10 seconds ago
        // current timestamp: now
        // amount of linear growth: 5 seconds * 0.5 tokens per second = 2.5 tokens
        // total amount: 10 tokens + 2.5 tokens = 12.5 tokens

        uint256 timeElapsed = block.timestamp - s_userLastUpdatedTimeStamp[_user];
        linearInterest = (PRECISION_FACTOR + (s_userInterestRates[_user] * timeElapsed));

        if (timeElapsed == 0 || s_userInterestRates[_user] == 0) {
            return PRECISION_FACTOR;
        }
    }

    /**
     * @dev Internal function to calculate and mint accrued interest for a user.
     * @dev Updates the user's last updated timestamp.
     * @param _user The address of the user.
     */
    function _mintAccruedInterest(address _user) internal {
        // (1) find their current balance of rebase tokens that have been minted to the user --> principle balance
        uint256 currentBalance = balanceOf(_user);

        // (2)calculate there current balance including any interest --> balanceOf(_user) + interest accrued

        // (3) calculate the number of tokens that need to be minted as interest to the user --> (2) - (1)

        // call _mint to mint the interest tokens to the user
        // set the users last updated timestamp
        s_userLastUpdatedTimeStamp[_user] = block.timestamp;
    }

    /**
     * @notice Gets the locked-in interest rate for a specific user.
     * @param _user The address of the user.
     * @return The user's specific interest rate.
     */
    function getUserInterestRate(address _user) external view returns (uint256) {
        // Get the current global interest rate
        return s_userInterestRates[_user];
    }
}
