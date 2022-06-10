// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "../modules/PairPool.sol";
import "../interfaces/IProxy.sol";
import "../const/Constant.sol";

contract HecoPairPool is PairPool, Constant {

    constructor() {
        factoryAddr = msg.sender;
    }

    function getUSDTAddress() internal pure override returns (address) {
        return USDT;
    }
}
