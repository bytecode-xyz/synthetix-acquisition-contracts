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

contract Bootstrap is Test {
    using console2 for *;

    Conversion internal conversion;

    function initializeLocal() internal {
        BootstrapLocal bootstrap = new BootstrapLocal();
        (address conversionAddress) = bootstrap.init();

        conversion = Conversion(conversionAddress);
    }

    function initializeOptimismGoerli() internal {
        BootstrapOptimismGoerli bootstrap = new BootstrapOptimismGoerli();
        (address conversionAddress) = bootstrap.init();

        conversion = Conversion(conversionAddress);
    }

    function initializeOptimism() internal {
        BootstrapOptimismGoerli bootstrap = new BootstrapOptimismGoerli();
        (address conversionAddress) = bootstrap.init();

        conversion = Conversion(conversionAddress);
    }

    /// @dev add other networks here as needed (ex: Base, BaseGoerli)
}

contract BootstrapLocal is Setup {
    function init() public returns (address) {
        address conversionAddress = Setup.deploySystem();

        return conversionAddress;
    }
}

contract BootstrapOptimism is Setup, OptimismParameters {
    function init() public returns (address) {
        address conversionAddress = Setup.deploySystem();

        return conversionAddress;
    }
}

contract BootstrapOptimismGoerli is Setup, OptimismGoerliParameters {
    function init() public returns (address) {
        address conversionAddress = Setup.deploySystem();

        return conversionAddress;
    }
}

// add other networks here as needed (ex: Base, BaseGoerli)
