require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: "0.8.18",
  networks: {
    mumbai: {
      url: "https://polygon-mumbai.infura.io/v3/4458cf4d1689497b9a38b1d6bbf05e78",
      accounts: ["7c23e82060b84b2556413e2e91e57393783867d4f826b8d4710eca1b9ed07dbe"],
    }
  }
};