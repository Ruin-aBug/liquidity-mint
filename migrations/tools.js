const fs = require("fs")

async function readConfFile(fileName) {
  return new Promise(async (resolve, reject) => {
    try {
      fs.readFile(fileName, "utf-8", (err, data) => {
        if (err) {
          reject(err)
        } else {
          resolve(data)
        }
      })
    } catch (e) {
      reject(e)
    }
  })
}

async function moduleExcute(deployer, network, accounts, run) {
  deployer.then(async () => {
    console.log("当前部署网络：", network)
    try {
      const confFileName = `conf/address-${network}.json`
      console.log(confFileName)
      const fileName = await readConfFile(confFileName)
      const addressConfJson = JSON.parse(fileName)

      await run(addressConfJson, confFileName, deployer, accounts, network)

      fs.writeFileSync(confFileName, JSON.stringify(addressConfJson), "utf8")
    } catch (e) {
      console.log(e)
    }
  })
}

async function moduleRun(network, run) {
  try {
    const confFileName = `conf/address-${network}.json`
    const fileName = await readConfFile(confFileName)
    const addressConf = JSON.parse(fileName)

    await run(addressConf, confFileName, network)

    fs.writeFileSync(confFileName, JSON.stringify(addressConf), "utf8")
  } catch (e) {
    console.log(e)
  }
}

async function fncRun(network, run) {
  try {
    const confFileName = `conf/address-${network}.json`
    const tokenFileName = `test/tokensAddr/tokens-${network}.json`
    const fileName = await readConfFile(confFileName)
    const tokenFile = await readConfFile(tokenFileName)
    const addressConf = JSON.parse(fileName)
    const tokens = JSON.parse(tokenFile)

    await run(addressConf, tokens, network)
  } catch (e) {
    console.log(e)
  }
}

function upStrFirstChar(str) {
  return str[0].toUpperCase() + str.substr(1)
}

function getUseNetworkName(str) {
  if (str == "Rinkeby") {
    return "Mainnet"
  }
  return str
}

module.exports = {
  upStrFirstChar,
  moduleExcute,
  readConfFile,
  getUseNetworkName,
  moduleRun,
  fncRun,
}
