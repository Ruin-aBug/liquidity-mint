// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "../admin/Administer.sol";
import "../interfaces/IPairPool.sol";
import "../interfaces/IRainbowFactory.sol";

abstract contract RainbowFactory is IRainbowFactory{

    address internal adminAddr;
    address public override rainbowAddr;
    address[] public override poolAddress;

    mapping(uint256 => string) public poolName;
    uint16[] rewardOption = [99,199,299,399,499,599,699,799,899];

    mapping(uint256 => uint256) public override rewardDivide;

    function getLength() external view override returns (uint256) {
        return poolAddress.length;
    }
    uint8 lock = 0;

    function setRainbow(address _rainbowAddr) external override {
        require(Administer(adminAddr).isAdmin(msg.sender) || lock == 0, "N A");
        rainbowAddr = _rainbowAddr;
        lock = 1;
    }

    function isOPAndTokenAndSwap(
        address tokenA,
        address tokenB,
        address[] memory addrArray
    ) internal view returns (bool) {
        address _adminAddr = adminAddr;
        bool isSwap;
        for (uint256 index = 0; index < addrArray.length; index++) {
            isSwap = Administer(_adminAddr).validateSwap(addrArray[index]);
            if (!isSwap) {
                break;
            }
        }
        return
            Administer(_adminAddr).validateOP(msg.sender) &&
            Administer(_adminAddr).validateToken(tokenA) &&
            Administer(_adminAddr).validateToken(tokenB) &&
            isSwap &&
            tokenA != address(0) &&
            tokenA != tokenB;
    }

}
