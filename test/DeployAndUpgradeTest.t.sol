// SPDX-License-Identifier: MIT

pragma solidity ^0.8.33;

import {Test} from "forge-std/Test.sol";
import {DeployBox} from "script/DeployBox.s.sol";
import {UpgradeBox} from "script/UpgradeBox.s.sol";
import {BoxV1} from "src/BoxV1.sol";
import {BoxV2} from "src/BoxV2.sol";

contract DeployAndUpgradeTest is Test {
    DeployBox public deployer;
    UpgradeBox public upgrader;
    address public owner = makeAddr("owner");

    address public proxy;

    function setUp() public {
        deployer = new DeployBox();
        upgrader = new UpgradeBox();

        proxy = deployer.run(); // proxy has BoxV1 implemntation
    }

    function testNoV2FunctionalityBeforeUpgrade() public {
        vm.expectRevert();
        BoxV2(proxy).setNumber(33);
    }

    function testUpgrades() public {
        assertEq(BoxV1(proxy).version(), 1);

        BoxV2 box2 = new BoxV2(); // deploy new implementation

        upgrader.upgradeBox(proxy, address(box2));
        assertEq(BoxV2(proxy).version(), 2);

        // test v2 functionality
        BoxV2(proxy).setNumber(42);
        assertEq(BoxV2(proxy).getNumber(), 42);
    }
}
