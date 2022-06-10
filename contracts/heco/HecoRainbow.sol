// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "../const/Constant.sol";
import "../modules/Rainbow.sol";

// 路由合约
contract HecoRainbow is Rainbow, Constant {
    function getUSDTAddress() internal pure override returns (address) {
        return USDT;
    }

	constructor(address factory, address administer) {
        FactoryAddr = factory;
        AdministerAddr = administer;
        dev = Administer(administer).admin();
        rewardRatio = REWARD_RATIO({
            opRatio:800,
            adminRatio:197,
            arbitragerRatio:3
        });
        IRainbowFactory(factory).setRainbow(address(this));
    }
}