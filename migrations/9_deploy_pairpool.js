const CalcuModule = artifacts.require("CalcuModule")
const SafeMath = artifacts.require("SafeMath")
const HecoPairPool = artifacts.require("HecoPairPool")
const Administer = artifacts.require("Administer")

const { moduleExcute } = require("./tools")

module.exports = async function (deployer, network, accounts) {
  await moduleExcute(deployer, network, accounts, run)
}

async function run(addressConfJson, confFile, deployer) {
  await deployer.link(CalcuModule, HecoPairPool)
  await deployer.link(SafeMath, HecoPairPool)
  const pairpool = await deployer.deploy(HecoPairPool)
  // console.log(pairpool)
}
