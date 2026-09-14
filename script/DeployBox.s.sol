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

        bytes memory data = abi.encodeCall(BoxV1.initialize, ()); // encode the initializer
        Proxy proxy = new Proxy(address(box), data); // deploy proxy and call intializer
        vm.stopBroadcast();
        return address(proxy);
    }
}
