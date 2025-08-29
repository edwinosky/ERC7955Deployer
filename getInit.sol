// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./MyContract.sol"; // importa tu contrato real

contract InitCodeBuilder {
    function buildInit(address owner, uint256 x) external pure returns (bytes memory) {
        return abi.encodePacked(
            type(MyContact).creationCode,
            abi.encode(owner, x) // aquí van los argumentos del constructor
        );
    }
}
