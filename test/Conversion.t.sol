// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Bootstrap} from "test/utils/Bootstrap.sol";

contract ConversionTest is Bootstrap {
    function setUp() public {
        /// @dev uncomment the following line to test in a forked environment
        /// at a specific block number
        // vm.rollFork(NETWORK_BLOCK_NUMBER);

        initializeOptimismGoerli();
    }

    function testConversionRateFixed17to1() public {}

    function testDeposit() public {}

    function testVest() public {}

    function testCannotWithdrawSNXUntilTwoYears() public {}
}
