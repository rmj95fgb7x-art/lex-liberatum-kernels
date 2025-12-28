#!/usr/bin/env bash
set -e
echo "=== Lex Kernels – Royalty Proof on Base Sepolia ==="

# 0. sanity check
command -v forge >/dev/null 2>&1 || { echo "Install Foundry first: curl -L https://foundry.paradigm.xyz | bash"; exit 1; }

# 1. env
RPC="https://sepolia.base.org"
PK=${PRIVATE_KEY:-""}
[ -z "$PK" ] && read -rp "Paste test-net private key (0x...): " PK
echo "Deployer: $(cast wallet address --private-key $PK)"

# 2. deploy RoyaltySplitter
echo "Deploying RoyaltySplitter..."
DEPLOY_OUT=$(forge create contracts/RoyaltySplitter.sol:RoyaltySplitter \
  --rpc-url $RPC --private-key $PK --broadcast --verify)
SPLITTER=$(echo "$DEPLOY_OUT" | grep "Deployed to:" | awk '{print $3}')
echo "RoyaltySplitter: $SPLITTER"

# 3. fund it (0.05 test ETH from deployer)
echo "Funding splitter with 0.05 ETH..."
cast send $SPLITTER --value 0.05ether --rpc-url $RPC --private-key $PK > /dev/null

# 4. trigger payout (anyone can call recordDecision)
echo "Triggering royalty payout..."
TX=$(cast send $SPLITTER "recordDecision(bytes32)" 0x0000000000000000000000000000000000000000000000000000000000000001 \
  --value 0.01ether --rpc-url $RPC --private-key $PK)
echo "Payout tx: $TX"

# 5. print screenshot-ready links
BASE_URL="https://sepolia.basescan.org"
echo ""
echo "=== SCREENSHOT TABLE ==="
echo "| Component         | Address / Link |"
echo "|-------------------|----------------|"
echo "| RoyaltySplitter   | [$SPLITTER]($BASE_URL/address/$SPLITTER) |"
echo "| Payout tx         | [$TX]($BASE_URL/tx/$TX) |"
echo ""
echo "Done – paste the table into README and screenshot the links."
