# ERC7955Deployer  

How ​​to generate and deploy contracts on multiple networks with the **same address** using EIP-7702.  
The workflow relies on:  
- **SafeDev contract** → to obtain the `initCode`.  
- **ERC7955Deployer.sol** → to perform the `CREATE2` deployment.  

---

## 🛠️ Step-by-step guide to creating identical addresses with EIP-7702  

This guide explains **how to generate and deploy contracts on multiple networks** (Base, Ink, etc.) with the **same deterministic address**.

---

## 📌 Key Concepts  

- **EIP-7702**  
  Allows external accounts (EOA) to temporarily act as smart wallet contracts.  

- **CREATE2**  
  Ethereum mechanism that allows you to **predict the address of a contract before deployment**, based on:  
  - Deployer (factory) address  
  - Salt (any arbitrary value, e.g., `0x1234...`)  
  - `initCode` of the contract  

- **Goal**  
  If we use the **same factory + salt + initCode**, the resulting address will be **identical across all supported networks**.  

- **Factory already deployed by SafeDev**  
0xC0DEb853af168215879d284cc8B4d0A645fA9b0E

This exists on all networks supporting EIP-7702.  

---

## ⚙️ Step 1. Prepare your contract  

You need the Solidity contract you want to deploy on all networks.  

⚙️ Step 2. Deploy GetInit.sol (only once, on any network)
GetInit.sol is a helper contract that returns the initCode of your contract.
This only needs to be deployed once (e.g., on Sepolia).

Example:
// GetInit.sol

```
pragma solidity ^0.8.21;

import "./MyContract.sol";  // <- replace with your actual contract

contract InitCodeBuilder {
    function buildInit(address _owner, uint256 _param) external pure returns (bytes memory) {
        return abi.encodePacked(
            type(MyContract).creationCode,
            abi.encode(_owner, _param)
        );
    }
}
```

Deploy InitCodeBuilder.

Call buildInit(0xYourMetaMaskAddress, 1) → it returns a long hex string (e.g., 0x6080...).

This is your valid initCode.

Copy the initCode.

⚙️ Step 3. Deploy ERC7955Deployer.sol (must be deployed on every target network)
Unlike GetInit.sol (which is global), the ERC7955Deployer must be deployed on each network where you want the deterministic contract.

// ERC7955Deployer.sol
```
pragma solidity ^0.8.21;

interface IFactory {
    function deploy(bytes32 salt, bytes calldata initCode) external returns (address);
}

contract ERC7955Deployer {
    IFactory constant factory = IFactory(0xC0DEb853af168215879d284cc8B4d0A645fA9b0E);

    function deploy(bytes32 salt, bytes calldata initCode) external returns (address addr) {
        addr = factory.deploy(salt, initCode);
    }
}
```
⚙️ Step 4. Deploy your contract deterministically
In Remix, deploy ERC7955Deployer.sol.

Call:

deploy(0xYourSaltHere, 0xYourInitCodeHere)

Example:
```
deploy(
   0x0000000000000000000000000000000000000000000000000000000000007702,
   0x6080...   // your initCode from step 2
)
```
The transaction will return the contract address.

✅ That address will be the same across all EIP-7702-enabled networks.

🔍 Notes & Best Practices

GetInit.sol is deployed only once (any network).

ERC7955Deployer.sol must be deployed on each network where you want the cloned contract.

You can use the same salt across all networks to ensure identical addresses.

If you want multiple different deterministic deployments, just change the salt.

The factory at 0xC0DE... is universal across EIP-7702 networks, so you don’t need to redeploy it.

