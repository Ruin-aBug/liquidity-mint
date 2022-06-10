const argv = require("yargs")
  .option("network", {
    alias: "net",
    default: "mainnet",
  })
  .epilog("copyright 2021 rainbow fundation").argv

const HecoPairPool = artifacts.require("HecoPairPool")
const bigNumber = require("bignumber.js")
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
  const pairpool = await HecoPairPool.at(
    "0x114B6B9Bd86bc417D56CFbAb6Ed2d8ada340ef0B",
  )
  console.log("pairpool 合约地址 ", pairpool.address)
  console.log(await pairpool.owner())

  // await getAmountsOut(pairpool)
  // await addLiquidity(pairpool)
  // await getTotalAmounts(pairpool)
  // await swap(pairpool);
  await getLps(pairpool)
  // await removeLiquidity(pairpool);
  // await opRecord(pairpool)
  // await getOPRecord(pairpool)
  // await getConditionOPRecord(pairpool);
  // await decimals(pairpool)
  // await getPoolInfo(pairpool);
  // await removeAllRewrad(pairpool)
}

async function removeAllRewrad(pairpool) {
  let res = await pairpool.removeAllRewrad()
  console.log(res)
}

async function getAmountsOut(pairpool) {
  const amounts = await pairpool.getAmountsOut(
    addressConfJson.mdexProxy,
    new bigNumber(1).times(1e18),
    tokenConfJson.UNI,
  )
  console.log("a,b", amounts.toString())
}

async function addLiquidity(pairpool) {
  const liquidity = await pairpool.addLiquidity(
    addressConfJson.mdexProxy,
    [new bigNumber(0.001).times(1e18), new bigNumber(0.02).times(1e18)],
    [0, 0],
    new bigNumber(0.2).times(1e18),
    new bigNumber(0.3).times(1e18),
    timestamp + 300,
    0,
  )

  console.log(
    liquidity[0].toString(),
    liquidity[1].toString(),
    liquidity[2].toString(),
  )
}

async function removeLiquidity(pairpool) {
  let remove = await pairpool.removeLiquidity(
    addressConfJson.sushiProxy,
    new bigNumber(3039555389528303513),
    1,
  )
  console.log(remove)
}

async function getTotalAmounts(pairpool) {
  let reward = new bigNumber(0)
  let totalAmounts = await pairpool.getTotalAmounts(reward)
  console.log(totalAmounts[0].toString())
  console.log(totalAmounts[1].toString())
}

async function swap(pairpool) {
  let res = await pairpool.swapExactTokensForTokens(
    addressConfJson.sushiProxy,
    tokens.XRK,
    tokens.SZCY,
    10,
  )
  console.log(res)
}

async function getLps(pairpool) {
  let lps = await pairpool.getLps()
  console.log(lps)
}

async function getPoolInfo(pairpool) {
  console.log("池子信息", await pairpool.getPoolInfo())
}

async function opRecord(pairpool) {
  let ops = await pairpool.opRecord(addressConfJson.sushiProxy, 1)
  console.log("amountA:", ops[2].toString())
  console.log("amountB:", ops[3].toString())
  console.log("liquidity:", ops[4].toString())
  console.log("opId:", ops[8].toNumber())
  console.log("swapAddr:", ops[9])
}

async function getOPRecord(pairpool) {
  let ops = await pairpool.getOPRecord()
  console.log(ops)
}

async function getConditionOPRecord(pairpool) {
  let amountA = new bigNumber("5000000000000000000")
  let amountB = new bigNumber("1880912460311136743")
  let res = await pairpool.getConditionOPRecord(amountA, amountB)
  console.log(res[0].toString())
  console.log(res[1].toString())
}

async function decimals(pairpool) {
  let d = await pairpool.decimals()
  console.log(d.toNumber())
}
