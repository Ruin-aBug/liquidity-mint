const argv = require("yargs")
  .option("network", {
    alias: "net",
    default: "mainnet",
  })
  .epilog("copyright 2021 rainbow fundation").argv

const Arbitrager = artifacts.require("Arbitrager")
let addressConfJson
let tokens
const { fncRun } = require("../migrations/tools")

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
  const arbitrager = await Arbitrager.at(addressConfJson.arbitrager)
  console.log("arbitrager 合约地址 ", arbitrager.address)
  // console.log(await arbitrager.rainbowAddr())

  // await checkLiquidation(arbitrager) // 查询清仓条件

  // await processLiquidation(arbitrager) // 执行清仓

  // await checkCallAndPut(arbitrager) // 查询上涨下跌条件

  // await processCallAndPut(arbitrager) // 执行上涨下跌

  // await checkTimeOut(arbitrager) // 查询收益时间

  // await checkProfit(arbitrager) // 查询收益比

  // await processProfitAndTimeOut(arbitrager) // 执行 收益时间 收益比

  // await setRainbowAddr(arbitrager);
  // console.log(await arbitrager.rainbowAddr());
  // for (var i = 0; i < 10; i++) {
  //   console.log(`第${i}个池子`)
  //   console.log(await arbitrager.first(i))
  //   console.log("========================================")
  // }
}

async function setRainbowAddr(arbitrager) {
  let res = await arbitrager.setRainbowAddr(addressConfJson.rainbow)
  console.log(res)
}

// 查询清仓条件
async function checkLiquidation(arbitrager) {
  let t = await arbitrager.checkLiquidation(0)
  console.log("清仓条件：", t)
}

// 执行清仓
async function processLiquidation(arbitrager) {
  let t = await arbitrager.processLiquidation(poolId)
  console.log(t)
}

// 查询上涨下跌条件
async function checkCallAndPut(arbitrager) {
  let t = await arbitrager.checkCallAndPut(0)
  console.log(t[1])
}

// 执行上涨下跌
async function processCallAndPut(arbitrager) {
  let res = await arbitrager.checkCallAndPut(0)
  let t = await arbitrager.processCallAndPut(0, res[1])
  console.log(t)
}

// 查询收益时间
async function checkTimeOut(arbitrager) {
  let t = await arbitrager.checkTimeOut(0)
  console.log(t)
}

// 查询收益比
async function checkProfit(arbitrager) {
  let t = await arbitrager.checkProfit(0)
  console.log(t)
}

// 执行 收益时间 收益比
async function processProfitAndTimeOut(arbitrager) {
  let t = await arbitrager.processProfitAndTimeOut(poolId)
  console.log(t)
}
