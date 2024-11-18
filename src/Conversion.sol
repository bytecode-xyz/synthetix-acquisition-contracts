// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import "./interfaces/IConversion.sol";

/// @title Kwenta Acquisition Token Conversion Contract
/// @notice Responsible for converting KWENTA tokens to SNX at a fixed rate of 1:17
/// @author Jeremy Chiaramonte (jeremy@bytecode.llc)
/// @author Andrew Chiaramonte (andrewc@kwenta.io)
contract Conversion is IConversion {

    /// @notice Fixed rate of 1:17 for KWENTA to SNX conversion
    constant uint256 public CONVERSION_RATE = 17;
    
    mapping(address => uint256) public owedSNX;
    mapping(address => uint256) public claimedSNX;

    /// @notice Global start time for vesting
    /// @dev From this derive 3 months cliff 9 month linear vesting
    uint256 public vestingStartTime;

    /*///////////////////////////////////////////////////////////////
                                VIEWS
    ///////////////////////////////////////////////////////////////*/

    function vestableAmount() public view returns (uint256) {
        /// calculate the amount of SNX that can be vested
        /// vestableRemainder = (owedSNX * vested percentage) - claimed balance
    }

    /*///////////////////////////////////////////////////////////////
                            MUTATIVE FUNCTIONS
    ///////////////////////////////////////////////////////////////*/

    function lockAndConvert() public {
        /// take all KWENTA tokens from message sender
        /// increase owed SNX balance for message sender
        /// emit KwentaLocked(msg.sender, amount) event
    }

    function vest() public returns (uint256) {
        return vest(msg.sender);
    }

    function vest(address to) public returns (uint256) {
        /// get vestableAmount()
        /// increase claimed balance
        /// transfer SNX to
        /// emit SNXVested(msg.sender, to, amount) event
    }

    function withdrawSNX() public {
        /// allow withdrawing of SNX **after two years**
    }
}
