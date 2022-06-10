const Administer = artifacts.require("Administer")

const { moduleExcute } = require("./tools")

module.exports = async function (deployer, network, accounts) {
  await moduleExcute(deployer, network, accounts, run)
}

async function run(jsonConf, confFile, deployer, accounts) {
  console.log(`开始部署 Administer 合约`)
  await deployer.deploy(Administer)
  const adminImpl = await Administer.deployed()
  console.log("Administer 合约部署地址：", adminImpl.address)

  console.log(`将管理员地址和部署地址写入 ${confFile} 文件`)
  // jsonConf.admin = accounts[0]
  jsonConf.administer = adminImpl.address
}
