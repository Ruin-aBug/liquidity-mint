// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "../modules/RainbowFactory.sol";
import "./BscPairPool.sol";
import "../modules/CalcuModule.sol";

contract BscFactory is RainbowFactory {
    constructor(address adminAddr_) {
        adminAddr = adminAddr_;
    }

    function createPool(
        address[] memory addrArray,
        address tokenA,
        address tokenB,
        uint256[] memory allUint,
        address rewardToken,
        string calldata _poolName,
        uint256 incomeRatio,
        uint256 exchangeTime,
        uint256 divideOption
    ) external override returns (address poolAddr) {
        require(isOPAndTokenAndSwap(tokenA, tokenB, addrArray), "@F:1");
        uint256 pairPoolId = poolAddress.length;
        bytes memory bytecode = type(BscPairPool).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(tokenA, tokenB, pairPoolId));
        assembly {
            poolAddr := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        poolName[pairPoolId] = _poolName;
        if (divideOption < rewardOption.length) {
            rewardDivide[pairPoolId] = rewardOption[divideOption];
        } else {
            revert("D E");
        }
        IPairPool(poolAddr).initialize(
            addrArray,
            tokenA,
            tokenB,
            allUint,
            rewardToken,
            pairPoolId,
            msg.sender,
            incomeRatio,
            exchangeTime
        );
        poolAddress.push(poolAddr);
    }
}
