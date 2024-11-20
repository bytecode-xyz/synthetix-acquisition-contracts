// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Bootstrap} from "test/utils/Bootstrap.sol";
import {IConversion} from "src/interfaces/IConversion.sol";

contract ConversionTest is Bootstrap {
    function setUp() public {
        initializeLocal();
        /// @dev warp ahead of the vesting start time to simulate deployment conditions
        vm.warp(VESTING_START_TIME + 1 weeks);
    }

    function testConversionRateFixed17to1() public {}

    function testLockAndConvert() public {
        KWENTA.mint(TEST_USER_1, TEST_AMOUNT);
        uint256 owedSNXBefore = conversion.owedSNX(TEST_USER_1);
        uint256 userKWENTABefore = KWENTA.balanceOf(TEST_USER_1);
        uint256 contractKWENTABefore = KWENTA.balanceOf(address(conversion));
        assertEq(owedSNXBefore, 0);
        assertEq(userKWENTABefore, TEST_AMOUNT);
        assertEq(contractKWENTABefore, 0);

        vm.startPrank(TEST_USER_1);
        KWENTA.approve(address(conversion), TEST_AMOUNT);
        conversion.lockAndConvert();
        vm.stopPrank();

        uint256 owedSNXAfter = conversion.owedSNX(TEST_USER_1);
        uint256 userKWENTAAfter = KWENTA.balanceOf(TEST_USER_1);
        uint256 contractKWENTAAfter = KWENTA.balanceOf(address(conversion));
        assertEq(owedSNXAfter, CONVERTED_SNX_AMOUNT);
        assertEq(userKWENTAAfter, 0);
        assertEq(contractKWENTAAfter, TEST_AMOUNT);
    }

    function testLockAndConvertEmit() public {
        KWENTA.mint(TEST_USER_1, TEST_AMOUNT);
        vm.startPrank(TEST_USER_1);
        KWENTA.approve(address(conversion), TEST_AMOUNT);
        vm.expectEmit(true, true, true, true);
        emit KWENTALocked(TEST_USER_1, TEST_AMOUNT);
        conversion.lockAndConvert();
        vm.stopPrank();
    }

    function testLockAndConvertInsufficientKWENTA() public {
        uint256 balance = KWENTA.balanceOf(TEST_USER_2);
        assertEq(balance, 0);

        vm.startPrank(TEST_USER_2);
        KWENTA.approve(address(conversion), TEST_AMOUNT);
        vm.expectRevert(IConversion.InsufficientKWENTA.selector);
        conversion.lockAndConvert();
        vm.stopPrank();
    }

    function testVestableAmountBeforeCliff() public {
        basicLock();

        uint256 vestableAmount = conversion.vestableAmount(TEST_USER_1);
        assertEq(vestableAmount, 0);

        vm.warp(VESTING_START_TIME + VESTING_CLIFF_DURATION);
        vestableAmount = conversion.vestableAmount(TEST_USER_1);
        assertEq(vestableAmount, 0);

        vm.warp(block.timestamp + 1);
        vestableAmount = conversion.vestableAmount(TEST_USER_1);
        assertGt(vestableAmount, 0);
    }

    function testVestableAmountLinear() public {
        basicLock();

        vm.warp(VESTING_START_TIME + VESTING_CLIFF_DURATION);
        uint256 vestableAmount = conversion.vestableAmount(TEST_USER_1);
        assertEq(vestableAmount, 0);

        vm.warp(block.timestamp + 1);
        vestableAmount = conversion.vestableAmount(TEST_USER_1);
        assertEq(vestableAmount, CONVERTED_SNX_AMOUNT / LINEAR_VESTING_DURATION);

        vm.warp(VESTING_START_TIME + VESTING_CLIFF_DURATION + LINEAR_VESTING_DURATION / 3);
        vestableAmount = conversion.vestableAmount(TEST_USER_1);
        assertEq(vestableAmount, CONVERTED_SNX_AMOUNT / 3);

        vm.warp(VESTING_START_TIME + VESTING_CLIFF_DURATION + LINEAR_VESTING_DURATION / 2);
        vestableAmount = conversion.vestableAmount(TEST_USER_1);
        assertEq(vestableAmount, CONVERTED_SNX_AMOUNT / 2);

        vm.warp(VESTING_START_TIME + VESTING_CLIFF_DURATION + LINEAR_VESTING_DURATION);
        vestableAmount = conversion.vestableAmount(TEST_USER_1);
        assertEq(vestableAmount, CONVERTED_SNX_AMOUNT);
    }

    function testVestableAmountLinearFuzz(uint64 amount) public {
        basicLock();

        vm.warp(VESTING_START_TIME + VESTING_CLIFF_DURATION);
        uint256 vestableAmount = conversion.vestableAmount(TEST_USER_1);
        assertEq(vestableAmount, 0);

        vm.warp(block.timestamp + amount);
        vestableAmount = conversion.vestableAmount(TEST_USER_1);
        if (amount > LINEAR_VESTING_DURATION) {
            assertEq(vestableAmount, CONVERTED_SNX_AMOUNT);
        } else {
            assertEq(vestableAmount, CONVERTED_SNX_AMOUNT * amount / LINEAR_VESTING_DURATION);
        }
    }

    function testVestableAmountVest() public {
        basicLock();

        vm.warp(VESTING_START_TIME + VESTING_CLIFF_DURATION);
        uint256 vestableAmount = conversion.vestableAmount(TEST_USER_1);
        assertEq(vestableAmount, 0);

        vm.warp(VESTING_START_TIME + VESTING_CLIFF_DURATION + LINEAR_VESTING_DURATION / 2);
        vestableAmount = conversion.vestableAmount(TEST_USER_1);
        assertEq(vestableAmount, CONVERTED_SNX_AMOUNT / 2);

        vm.prank(TEST_USER_1);
        conversion.vest(TEST_USER_1);

        vestableAmount = conversion.vestableAmount(TEST_USER_1);
        assertEq(vestableAmount, 0);

        vm.warp(VESTING_START_TIME + VESTING_CLIFF_DURATION + LINEAR_VESTING_DURATION);
        vestableAmount = conversion.vestableAmount(TEST_USER_1);
        assertEq(vestableAmount, CONVERTED_SNX_AMOUNT / 2);
    }

    function testVestableAmountLockMore() public {
        basicLock();

        vm.warp(VESTING_START_TIME + VESTING_CLIFF_DURATION);
        uint256 vestableAmount = conversion.vestableAmount(TEST_USER_1);
        assertEq(vestableAmount, 0);

        vm.warp(VESTING_START_TIME + VESTING_CLIFF_DURATION + LINEAR_VESTING_DURATION / 2);
        vestableAmount = conversion.vestableAmount(TEST_USER_1);
        assertEq(vestableAmount, CONVERTED_SNX_AMOUNT / 2);

        basicLock();
        vestableAmount = conversion.vestableAmount(TEST_USER_1);
        assertEq(vestableAmount, CONVERTED_SNX_AMOUNT);

        vm.warp(VESTING_START_TIME + VESTING_CLIFF_DURATION + LINEAR_VESTING_DURATION);
        vestableAmount = conversion.vestableAmount(TEST_USER_1);
        assertEq(vestableAmount, CONVERTED_SNX_AMOUNT * 2);
    }

    function testVestableAmountLockMoreAndVest() public {
        basicLock();

        vm.warp(VESTING_START_TIME + VESTING_CLIFF_DURATION);
        uint256 vestableAmount = conversion.vestableAmount(TEST_USER_1);
        assertEq(vestableAmount, 0);

        vm.warp(VESTING_START_TIME + VESTING_CLIFF_DURATION + LINEAR_VESTING_DURATION / 2);
        vestableAmount = conversion.vestableAmount(TEST_USER_1);
        assertEq(vestableAmount, CONVERTED_SNX_AMOUNT / 2);

        basicLock();
        vestableAmount = conversion.vestableAmount(TEST_USER_1);
        assertEq(vestableAmount, CONVERTED_SNX_AMOUNT);

        vm.prank(TEST_USER_1);
        conversion.vest(TEST_USER_1);

        vm.warp(VESTING_START_TIME + VESTING_CLIFF_DURATION + LINEAR_VESTING_DURATION);
        vestableAmount = conversion.vestableAmount(TEST_USER_1);
        assertEq(vestableAmount, CONVERTED_SNX_AMOUNT);
    }

    function testVest() public {}

    function testCannotWithdrawSNXUntilTwoYears() public {}

    // helpers

    function basicLock() public {
        KWENTA.mint(TEST_USER_1, TEST_AMOUNT);
        vm.startPrank(TEST_USER_1);
        KWENTA.approve(address(conversion), TEST_AMOUNT);
        conversion.lockAndConvert();
        vm.stopPrank();
    }
}
