require("dotenv").config()
require("@nomiclabs/hardhat-waffle")
require("@nomiclabs/hardhat-ethers")
require("hardhat-contract-sizer")
require("hardhat-gas-reporter")
require("hardhat-abi-exporter")
require("hardhat-tracer")
require("hardhat-deploy")
require("@nomiclabs/hardhat-truffle5")
require("@nomiclabs/hardhat-web3")

const fs = require("fs")

const privateName = ".private"
let mnemonic
let AlchemyKey
try {
  // ask a Siren dev to give you this file
  mnemonic = fs.readFileSync(`${privateName}.key`).toString().trim()
  AlchemyKey = fs.readFileSync(`${privateName}.mainnet.key`).toString().trim()
} catch {
  console.log("ERROR: .private.key file not found")
}

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async () => {
  const accounts = await ethers.getSigners()

  for (const account of accounts) {
    console.log(account.address)
  }
})

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    version: "0.8.0",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    rinkeby: {
      url: `https://eth-rinkeby.alchemyapi.io/v2/BPN4P_PC-KGvQR--VDVqkBcPg9160T6i`,
      accounts: [`${mnemonic}`],
      gas: 6000000, // default = 4712388
      gasPrice: 20000000000, // default = 10 gwei
      gasMultiplier: 5,
      timeout: 100000,
    },
  },

  throwOnTransactionFailures: true,
  accounts: {},

  contractSizer: {
    alphaSort: true,
    runOnCompile: true,
    disambiguatePaths: false,
  },

  gasReporter: {
    currency: "CHF",
    gasPrice: 21,
    enabled: true,
  },

  abiExporter: {
    path: "./data/abi",
    clear: true,
    flat: true,
    only: [
      "MainnetRainbow",
      "MainnetFactory",
      "MainnetPairPool",
      "BscRainbow",
      "BscFactory",
      "BscPairPool",
      "TestRainbow",
      "SuShiSwapProxy",
      "Arbitrager",
      "Administer",
      "PairPool",
    ],
    spacing: 2,
  },
}
