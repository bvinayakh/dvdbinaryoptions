const { mneumonic, projectId, etherscan } = require("./secrets.json");
const HDWalletProvider = require("@truffle/hdwallet-provider");

module.exports = {
  networks: {
    kovan: {
      provider: () =>
        new HDWalletProvider(
          mneumonic,
          "https://kovan.infura.io/v3/" + projectId
        ),
      network_id: 42,
      from: "0x0CcA67351d8384800836B937Ad61C4Ac853b744C",
      gas: 5500000,
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true,
    },
  },

  plugins: ["truffle-plugin-verify"],
  api_keys: {
    etherscan: etherscan,
  },
  // Set default mocha options here, use special reporters etc.
  mocha: {
    // timeout: 100000
  },

  compilers: {
    solc: {
      version: "0.8.0",
    },
  },
};
