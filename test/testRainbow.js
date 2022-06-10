const argv = require("yargs")
  .option("network", {
    alias: "net",
    default: "mainnet",
  })
  .epilog("copyright 2021 rainbow fundation").argv

const HecoRainbow = artifacts.require("MainnetRainbow")
const HecoFactory = artifacts.require("HecoFactory")
const Proxy = artifacts.require("SuShiSwapProxy")
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
  // "0xa13280546ce36FC909Ff1295b80127A83175e5B3"
  const rainbow = await HecoRainbow.at(addressConfJson.rainbow)
  console.log("rainbow 合约地址 ", rainbow.address)
  // const amount = await rainbow.dev();
  // console.log(amount);
  // console.log(
  //   (
  //     await rainbow.poolTotalValue("0x5d01470dbe2c800bd7c28d4bDDc75a1fC49d2485")
  //   ).toString(),
  // )
  // console.log(await rainbow.dev());

  // await idLength(rainbow) // 查询池子个数
  // await getPoolInfo(rainbow) // 查询某个池子信息
  // await getPoolTotalAmounts(rainbow)
  // await getPoolAddress(rainbow) //获取池子地址
  // await getAllPoolInfo(rainbow) // 查询所有池子信息
  // await getSectionPoolInfo(rainbow) //查询部分池子信息
  // await getAllJobIDInfo(rainbow) // 查询所有 jobid
  // await getPoolName(rainbow) // 获取池子名称
  // await getWalletBalance(rainbow) // 获取钱包余额

  // await addExchange(rainbow,addressConfJson.mdexProxy) // 向池子添加proxy地址
  // await getPiceRiot(rainbow)

  // await depositPairToken(rainbow) //LP抵押
  // await LPUserInfo(rainbow) // 获取LP用户信息

  // await getLPLiquidity(rainbow) //lptokenB可提取量

  // await withdrawPairToken(rainbow) //LP提取
  // await getTokenbByTokena(rainbow) //通过tokenA查询tokenB的量
  // await addLiquidity(rainbow) //op添加流动性
  // await getOPRecord(rainbow) //查询op操作
  // await balancePool(rainbow)
  // await allotPool(rainbow);
  // await getAllUserReward(rainbow);
  // await getAllUserAmounts(rainbow);

  // op swap 功能
  // await opSwap(rainbow);

  // await removeLiquidity(rainbow) //OP移除流动性

  // await remove(rainbow);
  // await getTokenOfUSDT(rainbow);
  // await getWalletBalances(rainbow);
  // await getTokensOfUSDT(rainbow);
  // await getTotalValue(rainbow);

  // await getMintReward(rainbow)

  // await getLPRewards(rainbow)

  //   await getAllJobIDInfo(rainbow)
  // await cashing(rainbow) // 收益兑付

  //   await updatePoolValue(rainbow)
  // await getAmountsOut(rainbow);
  // await withdrawBonus(rainbow)
  // await testWithdraw(rainbow) // 提取测试的币
  // await emergencyWithdraw(rainbow);

  // await deletePool(rainbow);

  // await multiFunction(rainbow);
  // await adminReward(rainbow);
  // await OPReward(rainbow);
  // await setArbitragerAddr(rainbow)
  // console.log(await rainbow.ArbitragerAddr());
  // await setDev(rainbow);
  // console.log(await rainbow.dev());
}

async function setDev(rainbow) {
  let res = await rainbow.setDev("0x359410a26960D68C9B82CF228e356C333E7990ee")
  console.log(res)
}

async function setArbitragerAddr(rainbow) {
  let res = await rainbow.setArbitragerAddr(addressConfJson.arbitrager)
  console.log(res)
}

async function adminReward(rainbow) {
  let adReward = await rainbow.adminReward(addressConfJson.admin)
  console.log(adReward.toString())
}

async function OPReward(rainbow) {
  let opReward = await rainbow.OPReward(
    "0xDFb2220a6eE743AfD43C9cE456805C33CB3BE606",
  )
  console.log(opReward.toString())
}

async function idLength(rainbow) {
  // 查询池子个数
  const length = new bigNumber(await rainbow.idLength())
  console.log("查询池子个数 ", length.toNumber())
}

async function getPoolAddress(rainbow) {
  for (let i = 1; i < 2; i++) {
    const address = await rainbow.getPoolAddress(0)
    console.log(`池子${i}地址:`, address)
  }
}

async function getPoolInfo(rainbow) {
  const res = await rainbow.getPoolInfo(3)
  // 查询某个池子信息
  console.log("\n=================池子信息======================")
  let tableData = []
  let a = "============================================="

  tableData.push(["poolId:", res.poolId])
  tableData.push(["tokenA:", res.tokenPair.tokenA])
  tableData.push(["tokenB:", res.tokenPair.tokenB])
  tableData.push(["rewardToken:", res.rewardToken])
  tableData.push(["amountA:", res.amounts.amountA])
  tableData.push(["lastAmountA:", res.lastAmounts.amountA])
  tableData.push(["amountB:", res.amounts.amountB])
  tableData.push(["lastAmountB:", res.lastAmounts.amountB])
  tableData.push(["reward:", res.reward])
  tableData.push(["perShare:", res.perShare])
  tableData.push(["时间", res.exchangeTime])
  console.table(tableData)
}

async function getPoolTotalAmounts(rainbow) {
  const res = await rainbow.getPoolTotalAmounts(0)
  console.log(res[0].toString())
  console.log(res[1].toString())
}

async function getAllPoolInfo(rainbow) {
  // 查询所有池子信息
  console.log("所有池子信息 ", await rainbow.getAllPoolInfo())
}

async function getSectionPoolInfo(rainbow) {
  const pool = await rainbow.getSectionPoolInfo(0, 3)
  console.log(pool)
}

async function getPoolName(rainbow) {
  // 获取池子名称
  console.log("获取池子名称 ", await rainbow.getPoolName(2))
}

async function getWalletBalance(rainbow) {
  // 获取钱包余额
  const WalletBalance = await rainbow.getWalletBalance(
    addressConfJson.admin,
    tokens.SZCY,
  )
  const HBTCBalance = new bigNumber(WalletBalance)
  console.log("钱包余额 ", HBTCBalance.toNumber())
}

async function addExchange(rainbow, addr) {
  // 向池子添加proxy地址
  console.log("向池子添加proxy地址 ", await rainbow.addExchange(addr, 1))
}

async function LPUserInfo(rainbow) {
  // 获取LP用户信息
  let user = await rainbow.userInfo(0, addressConfJson.admin)
  console.log("amountA:", user[0].toString())
  console.log("amountB:", user[1].toString())
  console.log("liquidity:", user[2].toString())
  console.log("rewardDebt:", user[3].toString())
}

async function getPiceRiot(rainbow) {
  const amountA = new bigNumber(1000).times(1e18)
  let amountB = await rainbow.getPiceRiot(2, amountA)
  console.log(
    "通过 tokenA 的数量按照池子比例计算出应该添加 tokenB 的数量：",
    amountB.toString(),
  )
}

async function depositPairToken(rainbow) {
  const amountA = new bigNumber("100000000000000000000")
  const proxy = await Proxy.at(addressConfJson.pancakeProxy)
  const amountB = await proxy.getAmountsOut(amountA, tokens.USDT, tokens.ETH)
  const deposit = await rainbow.depositPairToken(
    tokens.USDT,
    tokens.ETH,
    0,
    amountA,
    amountB,
    addressConfJson.admin,
  )
  console.log(deposit)
  console.log("LP抵押", await deposit)
}

async function getLPLiquidity(rainbow) {
  const liquidityB = await rainbow.getLPLiquidity(
    0,
    new bigNumber("300000000000000000000"),
  )
  console.log(liquidityB[0].toString())
  console.log(liquidityB[1].toString())
}
// 497200093672379
// 12257884000914785

async function withdrawPairToken(rainbow) {
  const liquidity = new bigNumber("200000000000000000623").toString(16)
  const withdraw = await rainbow.withdrawPairToken({
    poolId: 0,
    liquidity: "0x" + liquidity,
    to: addressConfJson.admin,
    initialFunds: false,
  })
  console.log("LP提取", withdraw)
}

async function FactoryAddr(rainbow) {
  console.log("工厂合约地址：", await rainbow.FactoryAddr())
}

async function getTokenOfUSDT(rainbow) {
  const pice = await rainbow.getTokenOfUSDT(
    addressConfJson.mdexProxy,
    tokens.DOGE,
  )
  console.log(pice.toString())
}

async function getTokenbByTokena(rainbow) {
  // 9979548055799576513662712915
  // 5114185906287672788898042383
  let amountA = new bigNumber(9955824844.385632874319036236).times(1e18)
  const getBByA = await rainbow.getTokenbByTokena(
    addressConfJson.uniswapProxy,
    amountA,
    3000,
    -17940,
    92100,
    1,
  )
  console.log("通过tokenA查询tokenB的量", getBByA.toString())
}

async function addLiquidity(rainbow) {
  const proxy = await Proxy.at(addressConfJson.pancakeProxy)
  let amountA = new bigNumber("90000000000000000000")
  let amountB = await await proxy.getAmountOutForAmountIn(
    tokens.USDT,
    tokens.ETH,
    0,
    0,
    0,
    amountA,
  )
  console.log(amountB.toString())
  let tickUpper = new bigNumber(92100).times(new bigNumber(2).pow(48))
  let tickLower = new bigNumber(17940).times(new bigNumber(2).pow(24))
  let fee = new bigNumber(3000)
  let data = new bigNumber(fee.plus(tickUpper).plus(tickLower))
    .plus(new bigNumber(2).pow(47))
    .toString(16)
  const add = await rainbow.addLiquidity(
    addressConfJson.pancakeProxy,
    [amountA, amountB, 0],
    0,
    new bigNumber(0.01).times(1e18),
    new bigNumber(0.01).times(1e18),
    0,
  )
  console.log(add)
}

async function removeLiquidity(rainbow) {
  let liquidity = new bigNumber("2951788387831040890").toString(16)
  const remove = await rainbow.removeLiquidity(
    addressConfJson.pancakeProxy,
    "0x" + liquidity,
    0,
    1,
  )
  console.log(remove)
}

async function remove(rainbow) {
  let poolAddr = await rainbow.getPoolAddress(0)
  let rem = await rainbow.remove(0, poolAddr, 0, 0)
  console.log(rem)
}

async function balancePool(rainbow) {
  let res = await rainbow.balancePool(0)
  console.log(res)
}

async function allotPool(rainbow) {
  let poolId = 0
  let poolAddr = await rainbow.getPoolAddress(poolId)
  let allUserReward = await rainbow.getAllUserReward(poolId)
  let res = await rainbow.allotPool(poolId, poolAddr, allUserReward)
  console.log(res)
}

async function getAllUserReward(rainbow) {
  let allUserReward = await rainbow.getAllUserReward(0)
  console.log(allUserReward.toString())
}

async function getAllUserAmounts(rainbow) {
  let res = await rainbow.getAllUserAmounts(2, [addressConfJson.admin])
  console.log(res[0].toString())
  console.log(res[1].toString())
}

async function getOPRecord(rainbow) {
  const opOPRecord = await rainbow.getOPRecord(1)
  console.log("查询OP操作", opOPRecord)
}

async function getWalletBalances(rainbow) {
  const balance = await rainbow.getWalletBalances(
    "0xfA6CeADb393bBE09AdeE919AA5386669ccA060df",
    [
      // tokenConfJson.UNI,
      // tokenConfJson.USDT,
      "0xe066281CD0b913b097cB86eA71C031603343Fcf6",
    ],
  )
  console.log(balance[0].toString())
  // console.log(balance[1].toString());
}

async function getTokensOfUSDT(rainbow) {
  const amount = await rainbow.getTokensOfUSDT(addressConfJson.mdexProxy, [
    tokens.UNI,
    tokens.BUSD,
  ])
  console.log(amount[0].toString(), amount[1].toString())
}

async function getMintReward(rainbow) {
  const reward = await rainbow.getMiningRewards(addressConfJson.pancakeProxy, 0)
  console.log(reward.toString())
}

async function getTotalValue(rainbow) {
  const value = await rainbow.getTotalValue(5, [
    new bigNumber(0.01).times(1e18),
    new bigNumber(30).times(1e18),
    0,
  ])
  console.log(value)
}

async function getLPRewards(rainbow) {
  const lpReward = await rainbow.getLPRewards(addressConfJson.admin, 1)
  console.log(lpReward.toString())
}

async function testWithdraw(rainbow) {
  const poolAddress = await rainbow.getPoolAddress(2)
  const withdraw = await rainbow.testWithdraw(
    poolAddress,
    "0xBf5140A22578168FD562DCcF235E5D43A02ce9B1",
    addressConfJson.admin,
  )
  console.log("提取", withdraw)
}

async function emergencyWithdraw(rainbow) {
  const res = await rainbow.emergencyWithdraw(0)
  console.log(res)
}

async function withdrawBonus(rainbow) {
  const res = await rainbow.withdrawBonus()
  console.log(res)
}

async function getAllJobIDInfo(rainbow) {
  console.log("查询所有jobid:", await rainbow.getAllJobIDInfo())
}

async function cashing(rainbow) {
  console.log("收益兑付：", await rainbow.cashing(1))
}

async function updatePoolValue(rainbow) {
  const value = await rainbow.updatePoolValue(2)
  console.log("更新池子总价值:", value.toString())
}

async function setPoolRainbow(rainbow) {
  let poolAddr = await getPoolAddress(rainbow)
  await rainbow.setPoolRainbow(poolAddr, addressConfJson.rainbow)
}

async function multiFunction(rainbow) {
  let amountA = new bigNumber(1).times(1e18).toString(16)
  let amountB = await rainbow.getTokenbByTokena(
    addressConfJson.uniswapProxy,
    "0x" + amountA,
    3000,
    -17940,
    92100,
    1,
  )
  let tickUpper = new bigNumber(92100).times(new bigNumber(2).pow(48))
  let tickLower = new bigNumber(17940).times(new bigNumber(2).pow(24))
  let fee = new bigNumber(3000)
  let data = new bigNumber(fee.plus(tickUpper).plus(tickLower))
    .plus(new bigNumber(2).pow(47))
    .toString(16)
  let token = [tokenConfJson.XRK, tokenConfJson.SZCY]
  let callput = new bigNumber(5).times(1e17)
  let re = new bigNumber(100000000000000000).toString(16)
  let multi = [
    {
      agentAddress: addressConfJson.uniswapProxy,
      param: ["0x" + amountA, "0x" + amountB.toString(16)],
      tokens: [tokenConfJson.XRK, tokenConfJson.SZCY],
      poolId: 1,
      call: callput,
      put: callput,
      opId: 0,
      flag: 1,
    },
  ]
  let res = await rainbow.multiFunction(multi)
  console.log(res)
}

async function getAmountsOut(rainbow) {
  const amountin = new bigNumber(1).times(1e18)
  const p = await rainbow.getAmountsOut(
    addressConfJson.sushiProxy,
    amountin,
    tokens.XRK,
  )
  console.log("价额", p)
}

async function deletePool(rainbow) {
  const res = await rainbow.deletePool(2)
  console.log(res)
}

async function opSwap(rainbow) {
  const swapAddr = addressConfJson.pancakeProxy
  const amountIn = new bigNumber("90629399495076158")
  const amountOutMin = "0"
  const tokenA = tokens.ETH
  const tokenB = tokens.USDT
  const isRewardToken0 = false
  const isRewardToken1 = false
  const poolId = 0
  const amountOut = await rainbow.opSwap(
    swapAddr,
    amountIn,
    amountOutMin,
    tokenA,
    tokenB,
    isRewardToken0,
    isRewardToken1,
    poolId,
  )
  console.log(amountOut)
}
