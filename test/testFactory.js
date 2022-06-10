const argv = require("yargs")
  .option("network", {
    alias: "net",
    default: "mainnet",
  })
  .epilog("copyright 2021 rainbow fundation").argv

const timestamp = Math.ceil(new Date().getTime() / 1000)
const bigNumber = require("bignumber.js")
let addressConfJson
let tokens
const { fncRun, upStrFirstChar } = require("../migrations/tools")

module.exports = async function (callback) {
  const network = argv.network
  try {
    await fncRun(network, run)
    callback()
  } catch (e) {
    callback(e)
  }
}

async function run(addressConf, tokensJson, network) {
  addressConfJson = addressConf
  tokens = tokensJson
  let networkName = upStrFirstChar(network.toLowerCase())
  if (networkName == "Rinkeby") {
    networkName = "Mainnet"
  } else if (networkName == "Bsctest") {
    networkName = "Bsc"
  }
  const Factory = artifacts.require(`${networkName}Factory`)
  const factory = await Factory.at(addressConfJson.factory)
  console.log("factory 合约地址 ", factory.address)
  // console.log(await factory.rewardDivide(0))
  await createPool(factory)
  // await poolName(factory)
  // await rainbowAddr(factory);
  // await poolAddress(factory)

  // await setRainbow(factory);
}

async function createPool(factory) {
  const tokenA = tokens.ETH
  const tokenB = tokens.USDT
  const rewardToken = tokens.CAKE
  let token0
  let token1
  // (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
  if (tokenA < tokenB) {
    token0 = tokenA
    token1 = tokenB
  } else {
    token0 = tokenB
    token1 = tokenA
  }
  // 创建池子
  const createPool = await factory.createPool(
    [addressConfJson.pancakeProxy],
    token0,
    token1,
    [new bigNumber(0.01).times(1e18), new bigNumber(200).times(1e18), 0],
    rewardToken,
    "test4",
    new bigNumber(0.01).times(1e18),
    new bigNumber(600),
    8,
  )
  console.log("创建池子", createPool)
}

async function poolName(factory) {
  let name = await factory.poolName(0)
  console.log(name)
}

async function rainbowAddr(factory) {
  let rainbow = await factory.rainbowAddr()
  console.log(rainbow)
}

async function poolAddress(factory) {
  let poolAddr = await factory.poolAddress(0)
  console.log(poolAddr)
}

async function setRainbow(factory) {
  const rainbow = await factory.setRainbow(addressConfJson.rainbow)
}
