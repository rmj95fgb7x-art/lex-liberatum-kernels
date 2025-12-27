require("@nomicfoundation/hardhat-toolbox");
module.exports = {
  networks: {
    baseSepolia: {
      url: "https://sepolia.base.org",
      accounts: [process.env.PK], // export PK=0x...
    },
  },
  solidity: "0.8.25",
};
