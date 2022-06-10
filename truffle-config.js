require("dotenv").config()

const fs = require("fs")

const privateName = ".private"
let mnemonic
try {
  // ask a Siren dev to give you this file
  mnemonic = fs.readFileSync(`${privateName}.key`).toString().trim()
} catch {
  console.log("ERROR: .private.key 文件不存在")
}

// if deploying for mainnet, require mnemonic
if (!!process.env.DEPLOY_MAINNET) {
  mnemonic = fs.readFileSync(`${privateName}.mainnet.key`).toString().trim()
}

const HDWalletProvider = require("@truffle/hdwallet-provider")

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*",
    },

    mainnet: {
      provider: function () {
        return new HDWalletProvider(
          mnemonic,
          // `https://mainnet.infura.io/v3/${process.env.INFURA_API_KEY}`,
          `https://eth-mainnet.alchemyapi.io/v2/BPN4P_PC-KGvQR--VDVqkBcPg9160T6i`,
        )
      },
      network_id: 1,
      gas: 6000000,
      gasPrice: 30000000000,
      // gasLimit: 400000,
    },
    heco: {
      provider: function () {
        return new HDWalletProvider(
          mnemonic,
          `https://http-mainnet.hecochain.com`,
        )
      },
      network_id: 128,
      gas: 6000000, // default = 4712388
      // gasLimit: 400000,
      gasPrice: 3000000000, // default = 10 gwei
      // networkCheckTimeout:30000
    },
    hecoTest: {
      provider: function () {
        return new HDWalletProvider(
          mnemonic,
          `https://http-testnet.hecochain.com`,
        )
      },
      network_id: 256,
      gas: 6500000, // default = 4712388
      gasLimit: 400000,
      gasPrice: 10000000000, // default = 10 gwei
    },
    kovan: {
      provider: function () {
        return new HDWalletProvider(
          mnemonic,
          `https://kovan.infura.io/v3/${process.env.INFURA_API_KEY}`,
        )
      },
      network_id: 42,
      gas: 6500000, // default = 4712388
      gasPrice: 10000000000, // default = 10 gwei
    },
    rinkeby: {
      provider: function () {
        return new HDWalletProvider(
          mnemonic,
          `https://rinkeby.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161`,
          // `https://rinkeby.infura.io/v3/${process.env.INFURA_API_KEY}`,
          // `https://eth-rinkeby.alchemyapi.io/v2/BPN4P_PC-KGvQR--VDVqkBcPg9160T6i`,
        )
      },
      network_id: 4,
      gas: 6000000, // default = 4712388
      gasPrice: 30000000000, // default = 10 gwei
      networkCheckTimeout: 200000,
    },
    bsc: {
      provider: function () {
        return new HDWalletProvider(
          mnemonic,
          `https://bsc-dataseed1.binance.org`,
        )
      },
      network_id: 56,
      gas: 6000000,
      gasPrice: 5000000000,
    },
    bsctest: {
      provider: function () {
        return new HDWalletProvider(
          mnemonic,
          `https://data-seed-prebsc-1-s1.binance.org:8545/`,
        )
      },
      network_id: 97,
      gas: 6000000,
      gasPrice: 10000000000,
      networkCheckTimeout: 2000000,
    },
    arbtest: {
      provider: function () {
        return new HDWalletProvider(
          mnemonic,
          `https://arb-rinkeby.g.alchemy.com/v2/NJ2acvnGYFIengqcbbZrQUzKe6kHElS9`,
        )
      },
      network_id: 421611,
      gas: 6000000,
      gasPrice: 5000000000,
    },
  },

  plugins: ["solidity-coverage", "truffle-contract-size"],

  // Set default mocha options here, use special reporters etc.
  mocha: {
    // timeout: 100000
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: "0.8.4", // 编译器版本
      // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
      settings: {
        // See the solidity docs for advice about optimization and evmVersion
        optimizer: {
          enabled: true,
          runs: 200,
        },
        // evmVersion: "byzantium"
      },
    },
  },
}
