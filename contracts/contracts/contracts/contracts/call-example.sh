#!/usr/bin/env bash
source .env
cast send $KERNEL_CONTRACT_ADDRESS \
  "decide(bytes32,uint8,uint64)(uint8,uint64)" \
  0x0000000000000000000000000000000000000000000000000000000000000001 85 1704067200 \
  --rpc-url $BASE_SEPOLIA_RPC_URL \
  --account deployer \
  --value 0.01ether
echo "Done—check splitter balance:"
cast call $SPLITTER_CONTRACT_ADDRESS "totalRoyaltyWei()(uint256)" --rpc-url $BASE_SEPOLIA_RPC_URL
