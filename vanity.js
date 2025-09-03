import { keccak256, encodePacked, toHex } from "viem";

const FACTORY = "0xC0DEb853af168215879d284cc8B4d0A645fA9b0E";

// ⚠️ tu bytecode como string:
const initCode = "0x60806040523461003a576001805460ff19168155600255..." // completo
const initCodeHash = keccak256(initCode);

function computeAddress(factory, salt, initCodeHash) {
  const packed = encodePacked(
    ["bytes1", "address", "bytes32", "bytes32"],
    ["0xff", factory, salt, initCodeHash]
  );
  const hash = keccak256(packed);
  return "0x" + hash.slice(-40); // últimos 20 bytes
}

let i = 0;
while (true) {
  const salt = toHex(i, { size: 32 }); // Uint → bytes32
  const addr = computeAddress(FACTORY, salt, initCodeHash);

  if (addr.startsWith("0x000") && addr.endsWith("000")) {
  console.log("Encontrado!", salt, addr);
  break;
}
/// una coincidencia más "fácil":
  // if (addr.startsWith("0x000") || addr.endsWith("0000")) {
  //   console.log("Encontrado!", salt, addr);
  //   break;
  // }
  i++;
}
