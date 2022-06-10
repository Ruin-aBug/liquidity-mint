const CalcuModule = artifacts.require("CalcuModule")
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

const { moduleExcute, upStrFirstChar } = require("./tools")

module.exports = async function (deployer, network, accounts) {
  await moduleExcute(deployer, network, accounts, run)
}

async function run(addressConfJson, confFileName, deployer, accounts, network) {
  let networkName = upStrFirstChar(network.toLowerCase())
  if (networkName == "Rinkeby") {
    networkName = "Mainnet"
  } else if (networkName == "Bsctest") {
    networkName = "Bsc"
  }
  const HecoFactory = artifacts.require(`${networkName}Factory`)
  const Rainbow = artifacts.require(`${networkName}Rainbow`)
  console.log("部署者地址：", accounts[0])

  console.log("开始部署工厂合约：.......")
  // await deployer.deploy(CalcuModule)
  await deployer.link(CalcuModule, HecoFactory)
  await deployer.link(CalcuModule, Rainbow)
  const factory = await deployer.deploy(HecoFactory, addressConfJson.administer)
  console.log("factory 合约地址：", factory.address)

  console.log(`将部署地址写入 ${confFileName} 文件：....`)
  addressConfJson.factory = factory.address
}
