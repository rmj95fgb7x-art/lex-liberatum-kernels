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
# Capture output, filtering for hex addresses relative to labels
OUT=$(forge script script/DeployMulti.s.sol --rpc-url $BASE_SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify -vvvv 2>&1)

# Log the full output for debugging if something goes wrong
echo "$OUT" > .deploy.log

# Extract addresses using robust hex pattern matching
extract_addr() {
    echo "$1" | grep -aA 1 "$2" | grep -oE "0x[a-fA-F0-9]{40}" | head -n 1
}

SPLITTER=$(extract_addr "$OUT" "RoyaltySplitter deployed at:")
BOP_ADDR=$(extract_addr "$OUT" "LexBOP:")
PAY_ADDR=$(extract_addr "$OUT" "LexPay:")
BLOOD_ADDR=$(extract_addr "$OUT" "LexBlood:")
ORBIT_ADDR=$(extract_addr "$OUT" "LexOrbit:")
ESG_ADDR=$(extract_addr "$OUT" "LexESG:")
WELL_ADDR=$(extract_addr "$OUT" "LexWell:")
YACHT_ADDR=$(extract_addr "$OUT" "LexYacht:")
PORT_ADDR=$(extract_addr "$OUT" "LexPort:")
SEAL_ADDR=$(extract_addr "$OUT" "LexSeal:")
CARBON_ADDR=$(extract_addr "$OUT" "LexCarbon:")

echo "--- Deployment Results ---"
echo "Splitter: $SPLITTER"
echo "LexBOP:   $BOP_ADDR"
echo "--------------------------"

if [ -z "$BOP_ADDR" ] || [ "$BOP_ADDR" == "0x0000000000000000000000000000000000000000" ]; then
    echo "Error: LexBOP address not found in deployment output. Check .deploy.log"
    exit 1
fi

echo "3. Sending One Decision (0.01 ETH)..."
# This triggers the 25bp royalty split to 0x44f8...D689
# Calling LexBop: checkBOP(testPsi, holdMinutes, tempDevC, sealHash)
echo "Executing cast send to $BOP_ADDR..."
TX_JSON=$(cast send $BOP_ADDR "checkBOP(uint256,uint256,uint256,bytes32)" \
  12000 3 15 0x0000000000000000000000000000000000000000000000000000000000000001 \
  --rpc-url $BASE_SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --value 0.001ether --json)

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
