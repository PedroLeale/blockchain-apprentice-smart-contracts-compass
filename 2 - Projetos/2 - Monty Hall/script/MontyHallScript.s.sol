// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {MontyHall} from "../src/MontyHall.sol";

contract MontyHallScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("SEPOLIA_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        MontyHall montyHall = new MontyHall{value: 0.01 ether}(
            sha256(abi.encodePacked(vm.envUint("DEFAULT_NONCE"), vm.envUint("DOOR_0"))),
            sha256(abi.encodePacked(vm.envUint("DEFAULT_NONCE"), vm.envUint("DOOR_1"))),
            sha256(abi.encodePacked(vm.envUint("DEFAULT_NONCE"), vm.envUint("DOOR_2"))),
            0.01 ether,
            30 days
        );

        vm.stopBroadcast();

        console.log("MontyHall contract address: ", address(montyHall));
    }
}
