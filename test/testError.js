const { expect } = require("chai")
const { default: BigNumber } = require("bignumber.js")
const fs = require("fs")

const addressConfJson = require("../conf/address-rinkeby.json")
const tokens = require("./tokensAddr/ETH_Rinkeby_Tokens.json")

const TestRainbow = artifacts.require("TestRainbow")
const Proxy = artifacts.require("SuShiSwapProxy")

describe("TestRainbow", function () {
  // it("depositPairToken", async function () {
  //   const testRainbow = await TestRainbow.at(addressConfJson.rainbow);
  //   const amountA = BigNumber("3000000000000000000000");
  //   const tokenA = tokens.ETH;
  //   const tokenB = tokens.USDT;
  //   let token0;
  //   let token1;
  //   // (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
  //   if(tokenA<tokenB){
  //     token0 = tokenA;
  //     token1 = tokenB;
  //   }else{
  //     token0 = tokenB;
  //     token1 = tokenA;
  //   }
  //   const res =await testRainbow.depositPairToken(
  //       token0,
  //       token1,
  //       0,
  //       amountA,
  //       addressConfJson.admin,
  //       0
  //   );
  //   console.log(res);
  // });

  // it("addLiquidity", async function () {
  // 	const testRainbow = await TestRainbow.at(addressConfJson.rainbow);
  // 	const proxy = await Proxy.at(addressConfJson.sushiProxy);
  // 	const amountA = BigNumber("300000000000000000000");
  // 	const tokenA = tokens.ETH;
  // 	const tokenB = tokens.USDT;
  // 	let token0;
  // 	let token1;
  // 	// (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
  // 	if (tokenA < tokenB) {
  // 		token0 = tokenA;
  // 		token1 = tokenB;
  // 	} else {
  // 		token0 = tokenB;
  // 		token1 = tokenA;
  // 	}
  // 	let amountB = await proxy.getAmountOutForAmountIn(
  // 		token0,
  // 		token1,
  // 		0,
  // 		0,
  // 		0,
  // 		amountA,
  // 	);
  // 	console.log(amountB.toString());
  // 	const res = await testRainbow.addLiquidity(
  // 		addressConfJson.sushiProxy,
  // 		[amountA, amountB, 0],
  // 		0,
  // 		BigNumber(0.5).times(1e18),
  // 		BigNumber(0.5).times(1e18),
  // 		0,
  // 	);
  // 	console.log(res);
  // });

  // it("removeLiquidity", async function () {
  //     const testRainbow = await TestRainbow.at(addressConfJson.rainbow);
  //     let liquidity = BigNumber("5477168078450328820");
  //     const remove = await testRainbow.removeLiquidity(
  //         addressConfJson.sushiProxy,
  //         liquidity,
  //         0,
  //         1,
  //     );
  //     console.log(remove);
  // });

  it("withdrawPairToken", async function () {
    const testRainbow = await TestRainbow.at(addressConfJson.rainbow)
    let liquidity = BigNumber("3000000000000000000000")

    for (var i = 1; i >= 1; i--) {
      try {
        const remove = await testRainbow.withdrawPairToken(
          0,
          liquidity,
          addressConfJson.admin,
          0,
        )
        console.log("step=", i)
        console.log(remove)
        console.log("===================================")
      } catch (error) {
        console.log("step=", i)
        console.log(error)
        console.log("===================================")
      }
    }
  })

  // it("remove", async function () {
  //     const testRainbow = await TestRainbow.at(addressConfJson.rainbow);
  //     let amountA = BigNumber("5000000000000000000");
  //     let amountB = BigNumber("1880912460311136743")
  //     const remove = await testRainbow.remove(
  //         0,
  //         amountA,
  //         amountB,
  //         10,
  //     );
  //     console.log(remove);
  // });

  // it("balancePool",async function(){
  //     const testRainbow = await TestRainbow.at(addressConfJson.rainbow);
  //     const balancePool = await testRainbow.balancePool(0,0);
  //     console.log(balancePool);
  // })

  // it("balanceTokenA",async function(){
  //     let amountA = BigNumber("3000000000000000000000");
  //     const testRainbow = await TestRainbow.at(addressConfJson.rainbow);
  //     const balancePool = await testRainbow.balanceTokenA(amountA,0,0);
  //     console.log(balancePool);
  // })

  // it("balanceTokenB",async function(){
  //     let amountB = BigNumber("1003011024072216649");
  //     const testRainbow = await TestRainbow.at(addressConfJson.rainbow);
  //     const balancePool = await testRainbow.balanceTokenB(amountB,0,0);
  //     console.log(balancePool);
  // })
})
