// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

/// @title Contract for defining constants used in testing
contract Constants {
    address internal constant TEST_OWNER = address(0x1);
    address internal constant TEST_USER_1 = address(0x2);
    address internal constant TEST_USER_2 = address(0x3);
    uint256 internal constant TEST_AMOUNT = 1_000 * 10**18;
}
