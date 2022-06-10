const Arbitrager = artifacts.require("Arbitrager")
const CalcuModule = artifacts.require("CalcuModule")

const HecoRainbow = artifacts.require("MainnetRainbow")

const { moduleExcute, upStrFirstChar } = require("./tools")

module.exports = async function (deployer, network, accounts) {
  await moduleExcute(deployer, network, accounts, run)
}

async function run(addressConfJson, confFileName, deployer, accounts, network) {
  await deployer.link(CalcuModule, Arbitrager)
  console.log("开始部署 arbitrager 合约：")
  const arbitrager = await deployer.deploy(
    Arbitrager,
    addressConfJson.administer,
    addressConfJson.rainbow,
  )
  console.log("arbitrager 合约部署地址：", arbitrager.address)
  const rainbow = await HecoRainbow.at(addressConfJson.rainbow)
  await rainbow.setArbitragerAddr(arbitrager.address)

  console.log(`将部署地址写入 ${confFileName} 文件：....`)
  addressConfJson.arbitrager = arbitrager.address
}
