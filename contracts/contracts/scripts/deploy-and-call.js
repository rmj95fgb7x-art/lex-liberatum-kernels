/* Mobile-friendly script for Base Sepolia test-net
   Run inside https://remix.ethereum.org on phone browser */
const SPLITTER_ABI = [{"inputs":[],"name":"decisionsToday","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"bytes32","name":"_kernelId","type":"bytes32"}],"name":"recordDecision","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[],"name":"totalDecisions","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"totalRoyaltyWei","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"}];

async function run() {
  const provider = new ethers.providers.Web3Provider(window.ethereum);
  await provider.send("eth_requestAccounts", []);
  const signer = provider.getSigner();

  // 1. deploy RoyaltySplitter
  const splitterFactory = new ethers.ContractFactory(SPLITTER_ABI, SPLITTER_BYTECODE, signer);
  const splitter = await splitterFactory.deploy();
  await splitter.deployed();
  console.log("RoyaltySplitter deployed at:", splitter.address);

  // 2. mock kernel decision: 0.0025 ETH (25 bp on $8 notional)
  const kernelId = ethers.utils.keccak256(ethers.utils.toUtf8Bytes("lexwing-decision-1"));
  const tx = await splitter.recordDecision(kernelId, { value: ethers.utils.parseEther("0.0025") });
  await tx.wait();
  console.log("Decision recorded, tx:", tx.hash);

  // 3. read counters
  const decisions = await splitter.decisionsToday();
  const royalties = await splitter.totalRoyaltyWei();
  console.log("Total decisions:", decisions.toString());
  console.log("Total royalty (wei):", royalties.toString());
}

/*  COPY-PASTE BYTECODE OUTPUT FROM REMIX COMPILER HERE  */
const SPLITTER_BYTECODE = "0x608060405234801561001057600080fd5b506004361061004c5760003560e01c806360fe47b1146100515780639a4a8c4f1461006d578063c82f3e9514610089578063d21f97b0146100a5575b600080fd5b61006b600480360381019061006691906101b0565b6100c1565b005b6100756100e0565b60405161008291906101ec565b60405180910390f35b6100936100e6565b6040516100a09190610228565b60405180910390f35b6100c160048036038101906100bc91906101b0565b6100ec565b005b600160008082825401925050819055507f8b84a7d7cde294678a37d5ce8216a2f54cb4b5d11ba3266c6b712343c815c986338260405161010092919061023f565b60405180910390a15b50565b60005481565b60015481565b600080549050610129610144565b610133838361014c565b6001819055507f8b84a7d7cde294678a37d5ce8216a2f54cb4b5d11ba3266c6b712343c815c986338260405161016592919061023f565b60405180910390a15b505050565b600061017d610
