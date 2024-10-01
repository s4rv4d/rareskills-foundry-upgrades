// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/// @custom:oz-upgrades-from ContractA
contract ContractB is Initializable {
    /// @custom:storage-location erc7201:ContractA.storage.MyStorage
    struct MyStorage {
        uint256 value;
    }

    // keccak256(abi.encode(uint256(keccak256("ContractA.storage.MyStorage")) - 1)) & ~bytes32(uint256(0xff));
    bytes32 private constant MyStorageLocation = 0xd255ccbed1486709ef10c220c9b584c9ad5cacd00961bdfc2156c2c7f2e4fc00;

    function _getMyStorage() private pure returns (MyStorage storage $) {
        assembly {
            $.slot := MyStorageLocation
        }
    }

    function value() public view returns (uint256) {
        MyStorage storage $ = _getMyStorage();
        return $.value;
    }

    function initialize(uint256 _setValue) public initializer {
        MyStorage storage $ = _getMyStorage();
        $.value = _setValue;
    }

    function increaseValue() public {
        MyStorage storage $ = _getMyStorage();
        $.value += 10;
    }
}