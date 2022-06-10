// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;
// import "./IPoolInfo.sol";

interface IRainbow{
    function getPoolAddress(uint256 poolId) external view returns (address);

    function setArbitragerAddr(address arb) external;

    function removeLiquidity(
        address agentAddress,
        uint256 liquidity,
        uint256 poolId,
        uint32 opId
    ) external  returns (uint256 removeAmountA, uint256 removeAmountB);

    function arbitragerRemoveAllRewrad(address poolAddr) external ;

    function getTotalValue(uint256 poolId, uint256[] memory amounts)
        external
        view
        returns (uint256);

    function getMiningRewards(address agentAddress, uint256 poolId)
        external
        view
        returns (uint256);

    function getPoolTotalAmounts(uint256 poolId) external view returns(uint256 amountA,uint256 amountB);

    function waitFor(uint256 poolId) external;
}
