const argv = require("yargs")
  .option("network", {
    alias: "net",
    default: "mainnet",
  })
  .epilog("copyright 2021 rainbow fundation").argv

const Administer = artifacts.require("Administer")

let addressConf
let tokens
const { fncRun } = require("../migrations/tools")
// 0xEF50Fc14571Fe3B3f9f799DCbf8f4063242a98A7
// 0x41aF691f159753b60590DF1124FEEB7D2E395E09
// 0xe14a252ddbace662eb6dd5583acae2c9056c50f7
module.exports = async function (callback) {
  const network = argv.network
  try {
    await fncRun(network, run)
    callback()
  } catch (e) {
    callback(e)
  }
}

async function run(addressConfJson, tokensJson, network) {
  addressConf = addressConfJson
  tokens = tokensJson
  const adminContract = await Administer.at(addressConf.administer)
  console.log("-当前合约地址：", adminContract.address)

  ////////////////////////////////////////////////////////////
  // await admin(adminContract)
  // await setAdmin(adminContract);
  // console.log(await adminContract.newAdmin());
  // await adminContract.acceptAdmin();

  // op 部分
  // await addOP(adminContract);
  // await batchAddOp(adminContract)
  // await removeOP(adminContract);
  // await validateOP(adminContract);
  // await getAllOPs(adminContract)

  // 币部分
  // await addToken(adminContract);
  // await batchAddToken(adminContract)
  // await removeToken(adminContract);
  // await validateToken(adminContract);
  // await getAllTokens(adminContract)

  // 交易所部分
  // await addSwap(adminContract)
  // await batchAddSwap(adminContract)
  // await removeSwap(adminContract);
  // await validateSwap(adminContract)
  // await getAllSwaps(adminContract)

  // lp 部分
  // await addLP(adminContract)
  // await batchAddLp(adminContract);
  // await removeLP(adminContract);
  // await getAllLPs(adminContract);
  // await validateLP(adminContract)

  // 套利者
  // await addArbitrager(adminContract)
  // await batchAddArbitrager(adminContract);
  // await removeArbitrager(adminContract);
  // await getAllArbitragers(adminContract)
  // await validateArbitrager(adminContract);
}

async function admin(adminContract) {
  const admin = await adminContract.admin()
  console.log("-获取admin地址：", admin)
  const isAdmibAddr = await adminContract.isAdmin(addressConf.admin)
  console.log("-判断是否为admin地址：", isAdmibAddr)
}

async function setAdmin(adminContract) {
  const res = await adminContract.setAdmin(
    "0x359410a26960D68C9B82CF228e356C333E7990ee",
  )
  console.log(res)
}

async function getAllSwaps(adminContract) {
  // 获取所有交易所地址
  const swapArrays = []
  const getAllswapAddr = await adminContract.getAllSwaps()
  for (let index = 0; index < getAllswapAddr.length; index++) {
    const element = getAllswapAddr[index]
    const data = element.replace("000000000000000000000000", "")
    swapArrays.push(data)
  }
  console.log("-所有交易所地址：", swapArrays)
}

async function getAllTokens(adminContract) {
  // 获取所有币的地址
  const arrays = []
  const tokenAddrArray = await adminContract.getAllTokens()
  for (let index = 0; index < tokenAddrArray.length; index++) {
    const element = tokenAddrArray[index]
    const data = element.replace("000000000000000000000000", "")
    arrays.push(data)
  }
  console.log("-所有币地址：", arrays)
  // console.table(arrays);
}

async function getAllOPs(adminContract) {
  // 获取所有op地址
  const getAllOPAddr = []
  const allOPAddr = await adminContract.getAllOPs()
  for (let index = 0; index < allOPAddr.length; index++) {
    const element = allOPAddr[index]
    const data = element.replace("000000000000000000000000", "")
    getAllOPAddr.push(data)
  }
  console.log("-所有OP地址：", getAllOPAddr)
}

async function addOP(adminContract) {
  // 添加OP地址
  const opAddrs = "0x41aF691f159753b60590DF1124FEEB7D2E395E09"
  // const opAddrs = addressConf.admin
  const validateOP = await adminContract.validateOP(opAddrs)
  console.log("校验OP是否存在", validateOP)
  if (!validateOP) {
    const OPAddr = await adminContract.addOP(opAddrs)
    console.log("添加OP", OPAddr)
  } else {
    console.log("OP地址已经存在")
  }
}

async function batchAddOp(adminContract) {
  const addrs = [
    "0xEF50Fc14571Fe3B3f9f799DCbf8f4063242a98A7",
    "0x41aF691f159753b60590DF1124FEEB7D2E395E09",
  ]
  const info = await adminContract.batchAddOp(addrs)
  console.log("批量添加 op 地址：", info.toString())
  await getAllOPs(adminContract)
}

async function validateOP(adminContract) {
  const addrRainbow = addressConf.rainbow
  const info = await adminContract.validateOP(addrRainbow)
  console.log(" rainbow 是否为 op：", info.toString())

  const addrOP = addressConf.admin
  const info1 = await adminContract.validateOP(addrOP)
  console.log(" admin 是否为 op：", info1.toString())
}

async function removeOP(adminContract) {
  // 移除 OP
  const opAddrs = addressConf.admin
  const validateOP = await adminContract.validateOP(opAddrs)
  console.log("校验OP是否存在", validateOP)
  if (validateOP) {
    const validateOP = await adminContract.removeOP(opAddrs)
    console.log("OP移除", opAddrs)
  } else {
    console.log("OP已经移除")
  }
}

async function validateToken(adminContract) {
  // 校验币是否存在
  const addr = "0x250632378E573c6Be1AC2f97Fcdf00515d0Aa91B"
  // const addr = tokens.WBNB
  const dataToken = await adminContract.validateToken(addr)
  console.log("-校验币是否存在", dataToken)
}

async function addToken(adminContract) {
  // 添加一个币白名单
  const tokenAddr = "0x6d00950525041f45ba7458F5A3e99A7c962574d8"
  const dataToken = await adminContract.validateToken(tokenAddr)
  console.log("-校验币是否存在", dataToken)
  if (dataToken == false) {
    const addToken = await adminContract.addToken(tokenAddr)
    console.log("添加一个币白名单", addToken)
  } else {
    console.log("币已经存在")
  }
}

async function removeToken(adminContract) {
  // 移除币白名单地址
  const tokenAddr = "0x250632378E573c6Be1AC2f97Fcdf00515d0Aa91B"
  // const tokenAddr = tokens.BETH
  const dataToken = await adminContract.validateToken(tokenAddr)
  console.log("-校验币是否存在", dataToken)
  if (dataToken) {
    const removeToken = await adminContract.removeToken(tokenAddr)
    console.log("-移除币白名单地址", removeToken)
  } else {
    console.log("币不存在")
  }
}

async function batchAddSwap(adminContract) {
  // 批量添加交易所地址
  const exchangseArray = [addressConf.pancakeProxy, addressConf.mdexProxy]
  const exchangeArray = await adminContract.batchAddSwap(exchangseArray)
  console.log("-批量添加交易所", exchangeArray)
}

async function validateSwap(adminContract) {
  const exchangeAddr = addressConf.mdexProxy
  const exchange = await adminContract.validateSwap(exchangeAddr)
  console.log("交易所地址是否存在", exchange)
}

async function addSwap(adminContract) {
  // 添加交易所
  const swapAddr = addressConf.pancakeProxy
  const exchange = await adminContract.validateSwap(swapAddr)
  console.log("交易所地址是否存在", exchange)
  if (exchange) {
    console.log("交易所已存在")
  } else {
    const result = await adminContract.addSwap(swapAddr)
    console.log("添加交易所", result)
  }
}

async function removeSwap(adminContract) {
  // 移除交易所地址(代理合约)
  const removeSwapAddr = "0xED7d5F38C79115ca12fe6C0041abb22F0A06C300"
  const exchange = await adminContract.validateSwap(exchangeAddr)
  console.log("交易所地址是否存在", exchange)
  if (exchange) {
    const removeSwap = await adminContract.removeSwap(removeSwapAddr)
    console.log("-移除交易所地址", removeSwap)
  } else {
    console.log("-移除的交易所地址不存在")
  }
}

async function batchAddToken(adminContract) {
  // 测试币地址
  const tokenName = ["USDT", "ETH", "BTCB"]
  const arrysTokens = []
  for (var i = 0; i < tokenName.length; i++) {
    arrysTokens.push(tokens[tokenName[i]])
  }

  console.log("币", arrysTokens)
  const addToken = await adminContract.batchAddToken(arrysTokens)
  console.log("-添加所有白名单币：", addToken)
}

async function addLP(adminContract) {
  // 0x41aF691f159753b60590DF1124FEEB7D2E395E09
  // const lp1 = addressConf.admin
  // const lp1 = "0x4457ac90bcf438b8F5D4F6540601106135D8367E"
  const lp1 = "0xddbb730463b187a8f7b853e40f7a34717ed7ddbc"
  const info = await adminContract.addLP(lp1)
  console.log("添加 lp 白名单：", info)
}

async function batchAddLp(adminContract) {
  const addrs = [
    "0x2cbB250b265c722616de09D1456C3b714CAf75fe",
    "0x9676D644493d91a55BE8e10c86aDc8315Fc61e17",
    "0xef7ee555FA86bafA9d8910A4C4799dA5B6E6E5e5",
    "0x1d58168BFEA341711748016C3b6195F2660c9cba",
    "0x035C96bCeD3Ad0B6c617d385818754EF055AeeC6",
    "0x7f5658eb8B6700C62c849Cee5867269E466ab2B2",
    "0x3684B70dfD8135B969e7Ba2C6cc99b247B003488",
    "0xDFb2220a6eE743AfD43C9cE456805C33CB3BE606",
    "0xF9758dB6571Cfe61e6eB9146D82A0f0FF7ACBc45",
  ]
  const info = await adminContract.batchAddLp(addrs)
  console.log("批量添加 lp 地址：", info)
}

async function removeLP(adminContract) {
  const addr = ""
  const info = await adminContract.removeLP(addr)
  console.log("移除 lp 地址：", info.toString())
}

async function getAllLPs(adminContract) {
  // 所有 LP 地址
  const getAllLPAddr = []
  const info = await adminContract.getAllLPs()
  for (let index = 0; index < info.length; index++) {
    const element = info[index]
    const data = element.replace("000000000000000000000000", "")
    getAllLPAddr.push(data)
  }
  console.log("获取所有的 lp 地址", getAllLPAddr)
}

async function validateLP(adminContract) {
  const lp = "0xddbb730463b187a8f7b853e40f7a34717ed7ddbc"
  const info = await adminContract.validateLP(lp)
  console.log("校验 lp 是否存在：", info.toString())
}

async function addArbitrager(adminContract) {
  const lp1 = addressConf.admin
  // const lp1 = "0x7fBEF1a7d5f81D9d192f154Aa9Bd555da0d81B85"
  const info = await adminContract.addArbitrager(lp1)
  console.log("添加 Arbitrager 白名单：", info)
}

async function getAllArbitragers(adminContract) {
  const allArbitrager = await adminContract.getAllArbitragers()
  const getAllAr = []
  for (let index = 0; index < allArbitrager.length; index++) {
    const element = allArbitrager[index]
    const data = element.replace("000000000000000000000000", "")
    getAllAr.push(data)
  }
  console.log("所有套利者地址:", getAllAr)
}

async function batchAddArbitrager(adminContract) {
  const res = await adminContract.batchAddArbitrager([
    "0xEF50Fc14571Fe3B3f9f799DCbf8f4063242a98A7",
    "0x41aF691f159753b60590DF1124FEEB7D2E395E09",
  ])
  console.log(res)
}
