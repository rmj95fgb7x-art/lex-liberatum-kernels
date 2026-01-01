#!/usr/bin/env bash
set -e
echo "=== Lex Kernels – Multi-Kernel Deploy, Call & Dashboard Sync ==="
command -v forge >/dev/null 2>&1 || { echo "Install Foundry first: curl -L https://foundry.paradigm.xyz | bash"; exit 1; }
[ ! -f .env ] && cp .env.example .env && echo "1. Edit .env with your PRIVATE_KEY (test-net only) then re-run this script." && exit 1
source .env

if [ "$PRIVATE_KEY" == "0xYourPrivateKeyHere" ] || [ -z "$PRIVATE_KEY" ]; then
    echo "Error: PRIVATE_KEY is not set in .env"
    exit 1
fi

echo "2. Deploying Key Kernels to Base Sepolia..."
# Deploy 10 key kernels
OUT=$(forge script script/DeployMulti.s.sol --rpc-url $BASE_SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify -vvvv)

# Extract addresses for the proof call from the output
SPLITTER=$(echo "$OUT" | grep "Splitter:" | awk '{print $NF}')
BOP_ADDR=$(echo "$OUT" | grep "LexBOP:" | awk '{print $NF}')
PAY_ADDR=$(echo "$OUT" | grep "LexPay:" | awk '{print $NF}')
BLOOD_ADDR=$(echo "$OUT" | grep "LexBlood:" | awk '{print $NF}')
ORBIT_ADDR=$(echo "$OUT" | grep "LexOrbit:" | awk '{print $NF}')
ESG_ADDR=$(echo "$OUT" | grep "LexESG:" | awk '{print $NF}')
WELL_ADDR=$(echo "$OUT" | grep "LexWell:" | awk '{print $NF}')
YACHT_ADDR=$(echo "$OUT" | grep "LexYacht:" | awk '{print $NF}')
PORT_ADDR=$(echo "$OUT" | grep "LexPort:" | awk '{print $NF}')
SEAL_ADDR=$(echo "$OUT" | grep "LexSeal:" | awk '{print $NF}')
CARBON_ADDR=$(echo "$OUT" | grep "LexCarbon:" | awk '{print $NF}')

echo "3. Sending One Decision (0.01 ETH)..."
# This triggers the 25bp royalty split to 0x44f8...D689
TX_JSON=$(cast send $SEAL_ADDR "checkSeal(bool,bool,uint256)" \
  true true 365 \
  --rpc-url $BASE_SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --value 0.01ether --json)

TX_HASH=$(echo "$TX_JSON" | jq -r .transactionHash)

echo "4. Syncing deployment data to Dashboard..."
# Create data directory if it doesn't exist
mkdir -p dashboard/src/data

# Generate a clean JSON for the frontend
cat > dashboard/src/data/deployments.json <<EOF
{
  "network": "base-sepolia",
  "splitter": "$SPLITTER",
  "kernels": {
    "LexBOP": "$BOP_ADDR",
    "LexPay": "$PAY_ADDR",
    "LexBlood": "$BLOOD_ADDR",
    "LexOrbit": "$ORBIT_ADDR",
    "LexESG": "$ESG_ADDR",
    "LexWell": "$WELL_ADDR",
    "LexYacht": "$YACHT_ADDR",
    "LexPort": "$PORT_ADDR",
    "LexSeal": "$SEAL_ADDR",
    "LexCarbon": "$CARBON_ADDR"
  },
  "lastProofTx": "$TX_HASH",
  "timestamp": "$(date +%s)"
}
EOF

echo "=== DONE ==="
echo "Basescan tx: https://sepolia.basescan.org/tx/$TX_HASH"
echo "Dashboard updated at dashboard/src/data/deployments.json"
