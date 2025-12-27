## Deploy on phone (Foundry + cast)
1. Install Foundry in a-Shell/Termux:  
   `curl -L https://foundry.paradigm.xyz | bash && source ~/.bashrc`
2. `cd contracts`
3. Add test-net PK: `cast wallet import deployer --interactive`
4. Get Sepolia ETH: https://faucet.quicknode.com/base/base-sepolia
5. Run: `bash foundry-deploy.sh`
6. Screenshot the two Basescan links that print at the end → drop into `contracts/out/`
