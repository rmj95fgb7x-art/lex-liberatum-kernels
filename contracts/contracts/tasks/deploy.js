const { task } = require("hardhat/config");

task("deploy", "Deploy splitter + kernel, run 1 decision with 25 bp royalty")
  .setAction(async (_, { ethers }) => {
    const [signer] = await ethers.getSigners();
    console.log("Signer:", signer.address);

    const Splitter = await ethers.getContractFactory("RoyaltySplitter");
    const splitter = await Splitter.deploy();
    await splitter.waitForDeployment();
    const splAddr = await splitter.getAddress();
    console.log("RoyaltySplitter:", splAddr);

    const Lex = await ethers.getContractFactory("LexWingTest");
    const lex = await Lex.deploy(splAddr); // pass splitter addr
    await lex.waitForDeployment();
    const lexAddr = await lex.getAddress();
    console.log("LexWingTest:", lexAddr);

    // 1 decision with 0.01 ETH → 25 bp royalty (0.00025 ETH)
    const tx = await lex.decide(
      ethers.id("aviation:test:1"), // kernelId
      85,                             // score ≥ 80 → Certified
      1704067200,                     // nanos (any unix ts)
      { value: ethers.parseEther("0.01") }
    );
    const rcpt = await tx.wait();
    console.log("Decision tx:", rcpt.hash);
    console.log("Basescan link:", `https://sepolia.basescan.org/tx/${rcpt.hash}`);
  });
