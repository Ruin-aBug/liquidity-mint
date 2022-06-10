let fs = require("fs")
const path = require("path")

let addrFile = "./rainbowConf/conf"

const argv = require("yargs")
  .option("network", {
    alias: "net",
    default: "mainnet",
  })
  .epilog("copyright 2021 rainbow fundation").argv

let rFileName = `${addrFile}/address-${argv.network}.json`
let wFileName = `./conf/address-${argv.network}.json`

async function loadjson(filepath) {
  var data
  try {
    var jsondata = fs.readFileSync(filepath, "binary")
    data = JSON.parse(jsondata)
    console.log("读取的文件数据：", data)
  } catch (err) {
    console.log(err)
  }
  return data
}

async function savejson(filepath, data) {
  var datastr = JSON.stringify(data, null, 4)
  if (datastr) {
    try {
      fs.writeFileSync(filepath, datastr)
    } catch (err) {}
  }
}

async function saveAddr() {
  let data = await loadjson(rFileName)
  await savejson(wFileName, data)
}

saveAddr()
