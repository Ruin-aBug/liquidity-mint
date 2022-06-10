// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

interface IRainbowFactory {
    function getLength() external view returns(uint256);
    function rainbowAddr() external view returns(address);

    function poolAddress(uint256 index) external view returns(address);

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
        )
        external
        returns (address poolAddr);

    function setRainbow(address _rainbowAddr) external;

    function rewardDivide(uint256 poolId) external view returns(uint256);
}
