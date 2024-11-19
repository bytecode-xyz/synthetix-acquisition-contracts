// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

interface IConversion {
    /*///////////////////////////////////////////////////////////////
                                VIEWS
    ///////////////////////////////////////////////////////////////*/

    /// @notice Returns the amount of SNX that can be vested
    function vestableAmount(address) external view returns (uint256);

    /*///////////////////////////////////////////////////////////////
                            MUTATIVE FUNCTIONS
    ///////////////////////////////////////////////////////////////*/

    /// @notice Locks KWENTA and converts it to SNX
    function lockAndConvert() external;

    /// @notice Vests SNX
    /// @return The amount of SNX vested
    function vest() external returns (uint256);

    /// @notice Vests SNX
    /// @param to The account that will receive the vested SNX
    /// @return The amount of SNX vested
    function vest(address to) external returns (uint256);

    /// @notice Withdraws leftover SNX after 2 years
    /// @dev only callable by the owner
    function withdrawSNX() external;

    /*///////////////////////////////////////////////////////////////
                                EVENTS
    ///////////////////////////////////////////////////////////////*/

    /// @notice emitted when KWENTA is deposited for conversion
    /// @param from The account that locked KWENTA
    /// @param value The amount of KWENTA that was locked
    event KWENTALocked(address indexed from, uint256 value);

    /// @notice emitted when KWENTA is deposited for conversion
    /// @param from The account that is vesting SNX
    /// @param from The account that is receiving vested SNX
    /// @param value The amount of SNX that was vested
    event SNXVested(address indexed from, address indexed to, uint256 value);

    /*//////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @notice thrown when address is 0
    error AddressZero();

    /// @notice thrown when vesting start time is 0
    error VestingStartTimeZero();

    /// @notice thrown when insufficient KWENTA is locked
    error InsufficientKWENTA();

    /// @notice thrown when insufficient SNX inflation amount is provided
    error InsufficientSNXInflation();

    /// @notice thrown when withdrawal start time is not reached
    error WithdrawalStartTimeNotReached();
}
