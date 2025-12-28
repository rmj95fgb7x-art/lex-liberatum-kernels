#!/usr/bin/env bash
set -e
echo "=== Lex Kernels – Base-Sepolia Deploy & Call in 60 s ==="
command -v forge >/dev/null 2>&1 || { echo "Install Foundry first: curl -L https://foundry.paradigm.xyz | bash"; exit 1; }
[ ! -f .env ] && cp .env.example .env && echo "1. Edit .env with your PRIVATE_KEY (test-net only) then re-run this script." && exit 0
source .env
echo "2. Deploy RoyaltySplitter…"
S_OUT=$(forge create contracts/RoyaltySplitter.sol:RoyaltySplitter \
  --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --verify)
SPLITTER=$(echo "$S_OUT" | grep "Deployed to:" | awk '{print $3}')
echo "SPLITTER=$SPLITTER" >> .env
echo "3. Deploy LexWingTest…"
K_OUT=$(forge create contracts/LexWingTest.sol:LexWingTest \
  --constructor-args $SPLITTER \
  --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --verify)
KERNEL=$(echo "$K_OUT" | grep "Deployed to:" | awk '{print $3}')
echo "KERNEL=$KERNEL" >> .env
echo "4. Send one decision (0.01 ETH → 25 bp royalty)…"
TX=$(cast send $KERNEL "decide(bytes32,uint8,uint64)(uint8,uint64)" \
  0x0000000000000000000000000000000000000000000000000000000000000001 85 1704067200 \
  --rpc-url $RPC_URL --private-key $PRIVATE_KEY --value 0.01ether)
echo "=== DONE ==="
echo "Basescan tx: https://sepolia.basescan.org/tx/$(echo "$TX" | jq -r .transactionHash)"
echo "Screenshot that link → drop into contracts/out/ → README glory."
