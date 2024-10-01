// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Script} from "forge-std/Script.sol";
import {ContractA} from '../src/ContractA.sol';
import {ContractB} from '../src/ContractB.sol';
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {Options} from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract UpgradesScript is Script {

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy `ContractA` as a transparent proxy using the Upgrades Plugin
        // address transparentProxy = Upgrades.deployTransparentProxy(
        //     "ContractA.sol",
        //     msg.sender,
        //     abi.encodeCall(ContractA.initialize, 10)
        // );

        // Specifying the address of the existing transparent proxy
        address transparentProxy = address(0x5aEedfF9cE71187C9E837eAb4E51a626c7628379);

        // Setting options for validating the upgrade
        Options memory opts;
        opts.referenceContract = "ContractA.sol";

        // Validating the compatibility of the upgrade
        Upgrades.validateUpgrade("ContractB.sol", opts);

        // Upgrading to ContractB and attempting to increase the value
        Upgrades.upgradeProxy(transparentProxy, "ContractB.sol", abi.encodeCall(ContractB.increaseValue, ()));
    }
}