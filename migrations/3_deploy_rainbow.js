const CalcuModule = artifacts.require("CalcuModule")

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
  const HecoRainbow = artifacts.require(`${networkName}Rainbow`)
  // await deployer.link(CalcuModule, HecoRainbow)
  console.log("开始部署 rainbow 合约：")
  const rainbow = await deployer.deploy(
    HecoRainbow,
    addressConfJson.factory,
    addressConfJson.administer,
  )
  console.log("rainbow 合约部署地址：", rainbow.address)

  // console.log("设置factory中rainbow地址:\n")
  // const factory = await Factory.at(addressConfJson.factory)
  // const setRainbow = await factory.setRainbow(rainbow.address)

  console.log(`将部署地址写入 ${confFileName} 文件：....`)
  addressConfJson.rainbow = rainbow.address
}
