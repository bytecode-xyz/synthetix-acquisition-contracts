// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {IConversion} from "./interfaces/IConversion.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title Kwenta Acquisition Token Conversion Contract
/// @notice Responsible for converting KWENTA tokens to SNX at a fixed rate of 1:17
/// @author Jeremy Chiaramonte (jeremy@bytecode.llc)
/// @author Andrew Chiaramonte (andrewc@kwenta.io)
contract Conversion is IConversion, Ownable {
    /*//////////////////////////////////////////////////////////////
                          CONSTANTS/IMMUTABLES
    //////////////////////////////////////////////////////////////*/

    /// @notice Fixed rate of 1:17 for KWENTA to SNX conversion
    uint256 public constant CONVERSION_RATE = 17;

    /// @notice Vesting cliff duration in seconds (3 months)
    uint256 public constant VESTING_CLIFF_DURATION = 90 days;

    /// @notice Linear vesting duration in seconds (9 months)
    uint256 public constant LINEAR_VESTING_DURATION = 270 days;

    /// @notice Withdrawal start time in seconds (2 years)
    uint256 public constant WITHDRAW_START = 730 days;

    /// @notice Amount of SNX inflation deposited to the contract
    uint256 public immutable SNX_INFLATION_AMOUNT;

    // CONTRACTS //////////////////////////////////////////

    /// @notice KWENTA token contract on OE
    IERC20 private immutable KWENTA;

    /// @notice SNX token contract
    IERC20 private immutable SNX;

    /*//////////////////////////////////////////////////////////////
                                STATE
    //////////////////////////////////////////////////////////////*/

    /// @notice Mapping of addresses to the amount of SNX owed
    /// @dev the amount of SNX owed is the amount of KWENTA * CONVERSION_RATE
    mapping(address => uint256) public owedSNX;

    /// @notice Mapping of addresses to the amount of SNX claimed
    mapping(address => uint256) public claimedSNX;

    /// @notice Global start time for vesting
    /// @dev From this derive 3 months cliff 9 month linear vesting
    uint256 public vestingStartTime;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /// @param _kwenta $KWENTA token address on OE
    /// @param _snx $SNX token address
    /// @param _vestingStartTime Global start time for vesting
    /// @param _snxInflationAmount Amount of SNX inflation deposited to the contract
    /// @param _owner Owner of the contract
    constructor(
        address _kwenta,
        address _snx,
        uint256 _vestingStartTime,
        uint256 _snxInflationAmount,
        address _owner
    ) Ownable(_owner) {
        if (_kwenta == address(0) || _snx == address(0)) {
            revert AddressZero();
        }
        if (_vestingStartTime == 0) {
            revert VestingStartTimeZero();
        }
        KWENTA = IERC20(_kwenta);
        SNX = IERC20(_snx);
        vestingStartTime = _vestingStartTime;

        if (_snxInflationAmount == 0) {
            revert InsufficientSNXInflation();
        }
        SNX_INFLATION_AMOUNT = _snxInflationAmount;
        SNX.transferFrom(msg.sender, address(this), _snxInflationAmount);
    }

    /*///////////////////////////////////////////////////////////////
                                VIEWS
    ///////////////////////////////////////////////////////////////*/

    /// @inheritdoc IConversion
    function vestableAmount(address _account)
        public
        view
        returns (uint256 vestableRemainder)
    {
        uint256 timeCliffEnds = vestingStartTime + VESTING_CLIFF_DURATION;
        if (block.timestamp < timeCliffEnds) {
            return 0;
        }
        if (block.timestamp > vestingStartTime + WITHDRAW_START) {
            return 0;
        }
        vestableRemainder = (
            owedSNX[_account] * (block.timestamp - timeCliffEnds)
        ) / LINEAR_VESTING_DURATION - claimedSNX[_account]; //todo consider when they find more kwenta to lock
    }

    /*///////////////////////////////////////////////////////////////
                            MUTATIVE FUNCTIONS
    ///////////////////////////////////////////////////////////////*/

    /// @inheritdoc IConversion
    function lockAndConvert() public {
        //todo consider the case where they get more kwenta and then do this again

        uint256 kwentaAmount = KWENTA.balanceOf(msg.sender);
        if (kwentaAmount == 0) {
            revert InsufficientKWENTA();
        }

        uint256 snxAmount = kwentaAmount * CONVERSION_RATE;
        owedSNX[msg.sender] += snxAmount;
        KWENTA.transferFrom(msg.sender, address(this), kwentaAmount);

        emit KWENTALocked(msg.sender, kwentaAmount);
    }

    /// @inheritdoc IConversion
    function vest() public returns (uint256) {
        return vest(msg.sender);
    }

    /// @inheritdoc IConversion
    function vest(address to) public returns (uint256 amountVested) {
        amountVested = vestableAmount(msg.sender);
        claimedSNX[msg.sender] += amountVested;
        SNX.transfer(to, amountVested);
        emit SNXVested(msg.sender, to, amountVested);
    }

    /// @inheritdoc IConversion
    function withdrawSNX() public onlyOwner {
        if (block.timestamp < vestingStartTime + WITHDRAW_START) {
            revert WithdrawalStartTimeNotReached();
        }
        SNX.transfer(msg.sender, SNX.balanceOf(address(this)));
    }
}
