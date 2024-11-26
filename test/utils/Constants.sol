// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

/// @title Contract for defining constants used in testing
contract Constants {
    address internal constant SYNTHETIX_TREASURY = 0x99F4176EE457afedFfCB1839c7aB7A030a5e4A92;
    address internal constant TEST_USER_1 = address(0x2);
    address internal constant TEST_USER_2 = address(0x3);
    uint256 internal constant TEST_AMOUNT = 1000 * 10 ** 18;
    uint256 internal constant CONVERTED_SNX_AMOUNT = TEST_AMOUNT * 17;
    uint256 internal constant VESTING_CLIFF_DURATION = 90 days;
    uint256 internal constant VESTING_START_TIME = 1_731_628_800;
    uint256 internal constant WITHDRAW_START = 730 days;
    uint256 internal constant LINEAR_VESTING_DURATION = 270 days;
    uint256 internal constant MINT_AMOUNT = 1_000_000 * 10 ** 18;
}
