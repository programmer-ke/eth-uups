// SPDX-License-Identifier: MIT

pragma solidity ^0.8.33;

import {Script} from "forge-std/Script.sol";
import {BoxV1} from "src/BoxV1.sol";
import {Proxy} from "src/Proxy.sol";

contract DeployBox is Script {
    function run() external returns (address) {
        address proxy = deployBox();
        return proxy;
    }

    function deployBox() public returns (address) {
        vm.startBroadcast();
        BoxV1 box = new BoxV1(); // deploy implementation
        Proxy proxy = new Proxy(address(box), ""); // deploy proxy
        BoxV1(address(proxy)).initialize(); // call implementation initializer
        vm.stopBroadcast();
        return address(proxy);
    }
}
