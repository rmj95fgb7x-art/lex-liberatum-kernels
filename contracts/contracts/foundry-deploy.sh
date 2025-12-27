#!/usr/bin/env bash
set -e
source .env

# 1. import key (interactive) – phone keyboard entry
cast wallet import deployer --interactive

# 2. dry-run (no broadcast)
echo "=== DRY RUN ==="
forge create contracts/RoyaltySplitter.sol:RoyaltySplitter \
  --rpc-url $BASE_SEPOLIA_RPC_URL \
  --account deployer

# 3. real deploy
echo "=== BROADCAST ==="
DEPLOY_OUT=$(forge create contracts/RoyaltySplitter.sol:RoyaltySplitter \
  --rpc-url $BASE_SEPOLIA_RPC_URL \
  --account deployer \
  --broadcast)

echo "$DEPLOY_OUT"
# grab address
SPLITTER=$(echo "$DEPLOY_OUT" | grep "Deployed to:" | awk '{print $3}')
echo "SPLITTER_CONTRACT_ADDRESS=$SPLITTER" >> .env

# 4. deploy kernel, passing splitter address
echo "=== DEPLOY KERNEL ==="
K_OUT=$(forge create contracts/LexWingTest.sol:LexWingTest \
  --constructor-args $SPLITTER \
  --rpc-url $BASE_SEPOLIA_RPC_URL \
  --account deployer \
  --broadcast)

echo "$K_OUT"
KERNEL=$(echo "$K_OUT" | grep "Deployed to:" | awk '{print $3}')
echo "KERNEL_CONTRACT_ADDRESS=$KERNEL" >> .env

# 5. verify both (optional but gives green checkmark)
echo "=== VERIFY ==="
forge verify-contract $SPLITTER contracts/RoyaltySplitter.sol:RoyaltySplitter --chain-id 84532
forge verify-contract $KERNEL  contracts/LexWingTest.sol:LexWingTest --chain-id 84532

echo "=== DONE ==="
echo "Splitter: https://sepolia.basescan.org/address/$SPLITTER"
echo "Kernel:   https://sepolia.basescan.org/address/$KERNEL"
