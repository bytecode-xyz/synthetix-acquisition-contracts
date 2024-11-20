// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Bootstrap} from "test/utils/Bootstrap.sol";
import {IConversion} from "src/interfaces/IConversion.sol";

contract ConversionTest is Bootstrap {
    function setUp() public {
        initializeLocal();
        KWENTA.mint(TEST_USER_1, TEST_AMOUNT);
    }

    function testConversionRateFixed17to1() public {}

    function testLockAndConvert() public {
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
        assertEq(owedSNXAfter, TEST_AMOUNT * 17);
        assertEq(userKWENTAAfter, 0);
        assertEq(contractKWENTAAfter, TEST_AMOUNT);
    }

    function testLockAndConvertEmit() public {
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

    function testVest() public {}

    function testCannotWithdrawSNXUntilTwoYears() public {}
}
