// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Helper para usar el ERC-7955 CREATE2 Factory universal (0xC0DE...)
library Create2Pred {
    function compute(address factory, bytes32 salt, bytes memory initCode) internal pure returns (address) {
        bytes32 codeHash = keccak256(initCode);
        // address = keccak256(0xff || factory || salt || keccak256(init_code))[12:]
        return address(uint160(uint(keccak256(abi.encodePacked(bytes1(0xff), factory, salt, codeHash)))));
    }
}

contract ERC7955Deployer {
    address public constant FACTORY = 0xC0DEb853af168215879d284cc8B4d0A645fA9b0E;

    /// @notice Predice la dirección sin tocar la cadena
    function computeAddress(bytes32 salt, bytes memory initCode) external pure returns (address) {
        return Create2Pred.compute(FACTORY, salt, initCode);
    }

    /// @notice Despliega vía factory. Devuelve la dirección creada.
    /// El factory espera calldata = salt(32B) || init_code
    function deploy(bytes32 salt, bytes calldata initCode) external returns (address addr) {
        (bool ok, bytes memory ret) = FACTORY.call(abi.encodePacked(salt, initCode));
        require(ok, "Factory call failed");
        addr = abi.decode(ret, (address));
    }
}
