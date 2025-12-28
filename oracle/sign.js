/* Oracle-side signer for KL-039-AML-Oracle (Node ≥ 18) */
import { randomBytes } from 'crypto';
import { keccak256 } from 'ethereum-cryptography/keccak.js';
import { sign } from 'ethereum-cryptography/secp256k1.js';

const ORACLE_PRIV = process.env.ORACLE_PRIVATE_KEY; // 64-char hex, no 0x prefix
if (!ORACLE_PRIV) throw new Error("export ORACLE_PRIVATE_KEY");

const msg = JSON.stringify({
  v: 1,                                    // version byte
  rule_id: "LexBank-AML-039",
  expiry: Math.floor(Date.now() / 1000) + 3600, // +1 hr
  nonce: randomBytes(8).toString('hex'),
  decision: "A"                            // "A" = Allow, "D" = Deny
});

const msgBuf  = Buffer.from(msg);
const hash    = keccak256(msgBuf);
const sig     = await sign(hash, Buffer.from(ORACLE_PRIV, 'hex'));
const payload = Buffer.concat([msgBuf, Buffer.from(sig)]);

console.log("Signed payload (hex):", payload.toString('hex'));
