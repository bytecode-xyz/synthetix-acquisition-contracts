// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

interface IConversion {

    /*///////////////////////////////////////////////////////////////
                                VIEWS
    ///////////////////////////////////////////////////////////////*/

    function vestableAmount() public view returns (uint256) external;

    /*///////////////////////////////////////////////////////////////
                            MUTATIVE FUNCTIONS
    ///////////////////////////////////////////////////////////////*/

    function lockAndConvert() external;

    function vest() external returns (uint256);

    function vest(address to) external returns (uint256);

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
}