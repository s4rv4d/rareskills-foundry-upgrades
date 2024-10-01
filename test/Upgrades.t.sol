// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "openzeppelin-foundry-upgrades/Upgrades.sol";
import {IBeacon} from "@openzeppelin/contracts/proxy/beacon/IBeacon.sol";
import {Options} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import "../src/ContractA.sol";
import "../src/ContractB.sol";

contract UpgradesTest is Test {

    //     The initial test involves three main actions:
    // 1. Deploying `ContractA` with an initial value using a transparent proxy.
    // 2. Upgrading to `ContractB`.
    // 3. Lastly, invoking `increaseValue` to modify the state.
    function testTransparent() public {
        // Deploy a transparent proxy with ContractA as the implementation and initialize it with 10
        address proxy = Upgrades.deployTransparentProxy("ContractA.sol", msg.sender, abi.encodeCall(ContractA.initialize, (10)));

        // get the instance of the contract
        ContractA instance = ContractA(proxy);

        // get the implementation address of the proxy
        address implAddrV1 = Upgrades.getImplementationAddress(proxy);

        // get the admin address of proxy
        address adminAddr = Upgrades.getAdminAddress(proxy);

        // Ensure the admin address is valid
        assertFalse(adminAddr == address(0));

        // Log the initial value
        console.log("----------------------------------");
        console.log("Value before upgrade --> ", instance.value());
        console.log("----------------------------------");

        // Verify initial value is as expected
        assertEq(instance.value(), 10);

        // Upgrade the proxy implementation contract
        Upgrades.upgradeProxy(proxy, "ContractB.sol", "", msg.sender);

        // Get the new implementation address after upgrade
        address implAddrV2 = Upgrades.getImplementationAddress(proxy);

        // Verify admin address remains unchanged
        assertEq(Upgrades.getAdminAddress(proxy), adminAddr);

        // Verify implementation address has updated
        assertFalse(implAddrV1 == implAddrV2);

        // Invoke the increaseValue function separately - calling with proxy as context -  try with proxy next
        ContractB(address(instance)).increaseValue();

        // Log and verify the updated value
        console.log("----------------------------------");
        console.log("Value after upgrade --> ", instance.value());
        console.log("----------------------------------");
        assertEq(instance.value(), 20);
    }

    function testBeacon() public {
        address beacon = Upgrades.deployBeacon("ContractA.sol", msg.sender);

        // get the implementation address of the beacon
        address implAddrV1 = IBeacon(beacon).implementation();

        // deploy first beacon proxy and initialize it
        address proxy1 = Upgrades.deployBeaconProxy(beacon, abi.encodeCall(ContractA.initialize, 15));
        ContractA instance1 = ContractA(proxy1);

        // Deploy the second beacon proxy and initialize it
        address proxy2 = Upgrades.deployBeaconProxy(beacon, abi.encodeCall(ContractA.initialize, 20));
        ContractA instance2 = ContractA(proxy2);

        // Check if both proxies point to the same beacon
        assertEq(Upgrades.getBeaconAddress(proxy1), beacon);
        assertEq(Upgrades.getBeaconAddress(proxy2), beacon);

        console.log("----------------------------------");
        console.log("Value before upgrade in Proxy 1 --> ", instance1.value());
        console.log("Value before upgrade in Proxy 2 --> ", instance2.value());
        console.log("----------------------------------");

        // Validate the new implementation before upgrading
        Options memory opts;
        opts.referenceContract = "ContractA.sol";
        Upgrades.validateUpgrade("ContractB.sol", opts);

        // Upgrade the beacon to use ContractB
        Upgrades.upgradeBeacon(beacon, "ContractB.sol", msg.sender);

        // Get the new implementation address of the beacon after upgrade
        address implAddrV2 = IBeacon(beacon).implementation();

        // Activate the increaseValue function in both proxies
        ContractB(address(instance1)).increaseValue();
        ContractB(address(instance2)).increaseValue();

        console.log("----------------------------------");
        console.log("Value after upgrade in Proxy 1 --> ", instance1.value());
        console.log("Value after upgrade in Proxy 2 --> ", instance2.value());
        console.log("----------------------------------");

        // Check if the values have been correctly increased
        assertEq(instance1.value(), 25);
        assertEq(instance2.value(), 30);

        // Check if the implementation address has updated
        assertFalse(implAddrV1 == implAddrV2);
    }
}