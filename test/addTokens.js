const fs = require("fs")

// heco 币地址文件
// const TokensConfigJson = require("../tokens.json")
// 以太坊币地址文件
const TokensConfigJson = require("../ethTokens.json")

async function run() {
  // const arrysTokens = [
  //   "0xA2c49cEe16a5E5bDEFDe931107dc1fae9f7773E3",
  //   "0x64FF637fB478863B7468bc97D30a5bF3A428a1fD",
  //   "0x66a79D23E58475D2738179Ca52cd0b41d73f0BEa",
  //   "0xae3a768f9aB104c69A7CD6041fE16fFa235d1810",
  //   "0x5545153CCFcA01fbd7Dd11C0b23ba694D9509A6F",
  //   "0x0298c2b32eaE4da002a15f36fdf7615BEa3DA047",
  //   "0xecb56cf772B5c9A6907FB7d32387Da2fCbfB63b4",
  //   "0x25D2e80cB6B86881Fd7e07dd263Fb79f4AbE033c",
  //   "0x777850281719d5a96C29812ab72f822E0e09F3Da",
  //   "0x22C54cE8321A4015740eE1109D9cBc25815C46E6",
  //   "0xa71EdC38d189767582C38A3145b5873052c3e47a",
  // ]

  // const tokenName = [
  //   "DOT",
  //   "ETH",
  //   "BTC",
  //   "FIL",
  //   "HT",
  //   "HUSD",
  //   "LTC",
  //   "MDX",
  //   "SNX",
  //   "UNI",
  //   "USDT",
  // ]

  // 以太坊主网币地址
  const arrysTokens = [
    "0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984",
    "0xdAC17F958D2ee523a2206206994597C13D831ec7",
    "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
    "0x6B3595068778DD592e39A122f4f5a5cF09C90fE2",
  ]
  // 以太坊主网币地址
  const tokenName = ["UNI", "USDT", "WETH", "SUSHI"]

  for (let index = 0; index < arrysTokens.length; index++) {
    TokensConfigJson[tokenName[index]] = arrysTokens[index]
  }

  // heco 币地址文件
  // fs.writeFileSync("./tokens.json", JSON.stringify(TokensConfigJson), "utf8")
  // 以太坊币地址文件
  fs.writeFileSync("./ethTokens.json", JSON.stringify(TokensConfigJson), "utf8")
}

module.exports = async (callback) => {
  try {
    await run()
    callback()
  } catch (e) {
    callback(e)
  }
}
