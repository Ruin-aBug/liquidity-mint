let fs = require("fs")
const path = require("path")
const { basename } = require("path")
const paths = require("./config.json")

// 路径配置参考自述文件
const src = `${paths.proxy}conf`
const src1 = `${paths.rainbow}conf`

const abiPath1 = `${paths.proxy}data/abi`
const abiPath2 = `${paths.rainbow}data/abi`

let ProxyList = []
let RainbowList = []
let ABIList = []

  ; (async function test() {
    // 将 proxy 和 rainbow 的部署地址写入conf文件夹下
    let proxyList = await listFile(src)
    let rainbowList = await pathRainbowArray(src1)
    await wFileConf(proxyList, rainbowList)

    // 将 proxy 和 rainbow 项目的 ABI 读取到当前的 data 目录下
    let abiArray = await pathABIArray(abiPath1, abiPath2)
    await wFileDataABI(abiArray)
  })()

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
    } catch (err) { }
  }
}

// 遍历文件夹下的所有文件返回文件的路径
async function listFile(dir) {
  var arr = fs.readdirSync(dir)
  arr.forEach(function (item) {
    var fullpath = path.join(dir, item)
    var stats = fs.statSync(fullpath)
    if (stats.isDirectory()) {
      listFile(fullpath)
    } else {
      ProxyList.push(fullpath)
    }
  })
  return ProxyList
}

// 将所有的部署的地址文件循环写入当前conf文件夹下
async function wFileConf(pathNameArr, rainbowConf) {
  for (let index = 0; index < pathNameArr.length; index++) {
    console.log(`------------------开始写入第${index}个文件---------------`)
    let datas
    const filePath = pathNameArr[index]
    console.log("文件路径：", filePath)
    let data = await loadjson(filePath)
    console.log("需要写入文件中的数据：", data)
    let fileName1 = basename(filePath)

    for (let i = 0; i < rainbowConf.length; i++) {
      const filePath2 = rainbowConf[i]
      let fileName2 = basename(filePath2)
      if (fileName2 == fileName1) {
        let data2 = await loadjson(filePath2)
        console.log("rainbow数据：", data2)
        datas = Object.assign(data2, data)
        console.log("全部数据：", datas)
        break
      } else {
        continue
      }
    }
    console.log("文件名：", basename(filePath))
    let wFileName = `./rainbowConf/conf/${basename(filePath)}`
    console.log("写入文件的路径：", wFileName)
    await savejson(wFileName, datas)
    console.log(`------------------第${index}个文件写入完成---------------`)
  }
}

// addr rainbow 路径数组
async function pathRainbowArray(dir) {
  var arr = fs.readdirSync(dir)
  arr.forEach(function (item) {
    var fullpath = path.join(dir, item)
    var stats = fs.statSync(fullpath)
    if (stats.isDirectory()) {
      listFile(fullpath)
    } else {
      RainbowList.push(fullpath)
    }
  })
  return RainbowList
}

// ABI 路径数组
async function pathABIArray(dir, dar1) {
  var arr = fs.readdirSync(dir)
  arr.forEach(function (item) {
    var fullpath = path.join(dir, item)
    var stats = fs.statSync(fullpath)
    if (stats.isDirectory()) {
      listFile(fullpath)
    } else {
      ABIList.push(fullpath)
    }
  })

  var arr1 = fs.readdirSync(dar1)
  arr1.forEach(function (item) {
    var fullpath = path.join(dar1, item)
    var stats = fs.statSync(fullpath)
    if (stats.isDirectory()) {
      listFile(fullpath)
    } else {
      ABIList.push(fullpath)
    }
  })

  return ABIList
}
// 将 proxy 和 rainbow 合约的部署 abi 复制到当前的 data 文件夹
async function wFileDataABI(abiArray) {
  for (let index = 0; index < abiArray.length; index++) {
    let abiPath = abiArray[index]
    let data = await loadjson(abiPath)

    let wFileName = `./rainbowConf/data/abi/${basename(abiPath)}`
    await savejson(wFileName, data)
  }
}
