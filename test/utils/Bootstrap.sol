// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

import {console2} from "lib/forge-std/src/console2.sol";
import {
    Conversion,
    OptimismGoerliParameters,
    OptimismParameters,
    Setup
} from "script/Deploy.s.sol";
import {Test} from "lib/forge-std/src/Test.sol";
import {MockToken} from "test/utils/MockToken.sol";
import {Constants} from "./Constants.sol";

contract Bootstrap is Test, Constants {
    using console2 for *;

    /// @dev for testing
    event KWENTALocked(address indexed from, uint256 value);
    event SNXVested(address indexed from, address indexed to, uint256 value);

    Conversion internal conversion;
    MockToken internal KWENTA;
    MockToken internal SNX;

    function initializeLocal() internal {
        KWENTA = new MockToken();
        SNX = new MockToken();
        BootstrapLocal bootstrap = new BootstrapLocal();
        (address conversionAddress) =
            bootstrap.init(address(KWENTA), address(SNX), TEST_OWNER);
        SNX.transfer(conversionAddress, MINT_AMOUNT);
        conversion = Conversion(conversionAddress);
    }

    // function initializeOptimismGoerli() internal {
    //     BootstrapOptimismGoerli bootstrap = new BootstrapOptimismGoerli();
    //     (address conversionAddress) = bootstrap.init();

    //     conversion = Conversion(conversionAddress);
    // }

    // function initializeOptimism() internal {
    //     BootstrapOptimismGoerli bootstrap = new BootstrapOptimismGoerli();
    //     (address conversionAddress) = bootstrap.init();

    //     conversion = Conversion(conversionAddress);
    // }

    /// @dev add other networks here as needed (ex: Base, BaseGoerli)
}

contract BootstrapLocal is Setup {
    function init(address _kwenta, address _snx, address _owner)
        public
        returns (address)
    {
        address conversionAddress = Setup.deploySystem(_kwenta, _snx, _owner);

        return conversionAddress;
    }
}

// contract BootstrapOptimism is Setup, OptimismParameters {
//     function init() public returns (address) {
//         address conversionAddress = Setup.deploySystem();

//         return conversionAddress;
//     }
// }

// contract BootstrapOptimismGoerli is Setup, OptimismGoerliParameters {
//     function init() public returns (address) {
//         address conversionAddress = Setup.deploySystem();

//         return conversionAddress;
//     }
// }

// add other networks here as needed (ex: Base, BaseGoerli)
