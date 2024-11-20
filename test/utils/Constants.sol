// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

/// @title Contract for defining constants used in testing
contract Constants {
    address internal constant TEST_OWNER = address(0x1);
    address internal constant TEST_USER_1 = address(0x2);
    address internal constant TEST_USER_2 = address(0x3);
    uint256 internal constant TEST_AMOUNT = 1_000 * 10**18;
    uint256 internal constant CONVERTED_SNX_AMOUNT = TEST_AMOUNT * 17;
    uint256 internal constant VESTING_CLIFF_DURATION = 90 days;
    uint256 internal constant VESTING_START_TIME = 1731628800;
    uint256 internal constant LINEAR_VESTING_DURATION = 270 days;
}
