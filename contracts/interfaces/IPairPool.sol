// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

interface IPairPool {

    function initialize(
        address[] memory _addrArray,
        address _tokenA,
        address _tokenB,
        uint256[] memory allUint,
        address _rewardToken,
        uint256 poolId,
        address ownerAddr,
        uint256 incomeRatio,
        uint256 exchangeTime
    ) external;

    function waitTime() external returns (uint256);

    function identifier() external returns (uint256);

    function setRainbow(address _rainbowAddr) external;

    function setOwner(address _OP) external;

    function owner() external view returns (address);

    // function addExchange(address _exchange) external;

    function mint(address _to, uint256 _liquidity)
        external
        returns (uint256 liquidity, uint256 rewardDebt);

    function burn(
        uint256 _liquidity,
        uint256 _liquidityA,
        uint256 _liquidityB,
        address _to
    ) external;

    function deposit() external;

    function withdraw(
        uint256 amountA,
        uint256 amountB,
        uint256 reward
    ) external;

    function addLiquidity(
        address _agentAddress, 
        uint256[] memory _amounts, 
        uint256[] calldata _callAndPut, 
        uint32 _opId 
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function removeLiquidity(
        address _agentAddress,
        uint256 _liquidity,
        uint32 _opId
    ) external returns (uint256 removeAmountA, uint256 removeAmountB);

    function removeAllRewrad() external returns (uint256);

    function withdrawMiningReward(
        address _agentAddress,
        uint256 _liquidity,
        bool isSubLiqudiity
    ) external returns (uint256);

    function updatePoolReward(uint256 reward) external;

    function getMintingRewards(address _agentAddress)
        external
        view
        returns (uint256);

    function allotReward(
        uint256 LPReward,
        address to,
        uint256 bronusRewards
    ) external returns (uint256, address);

    function swapExactTokensForTokens(
        address _agentAddress,
        address tokenA,
        address tokenB,
        uint256 amountIn
    ) external returns (uint256 amountOut);

    function opSwap(
        address swapAddr,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata swapPath,
        bool isRewardToken0,
        bool isRewardToken1
    ) external returns (uint256 amountOut);

    function updatePoolInfo(
        uint256 amountIn,
        uint256 amountOut,
        address tokenA,
        address tokenB,
        bool isRewardToken0,
        bool isRewardToken1
    ) external;

    function getConditionOPRecord(uint256 liquidity)
        external
        view
        returns (
            address[] memory,
            uint32[] memory,
            uint256[] memory share
        );

    function getTotalAmounts() external view returns (uint256, uint256);

    function getPoolCurrentAmounts() external view returns (uint256, uint256);

    function getLps() external view returns (address[] memory);

    function deletePool(address dev) external;

    function waitFor() external;

    function emergencyRemoveLiquidity(address dev) external;

    function emergencyWithdraw(
        address to,
        uint256 amountA,
        uint256 amountB,
        uint256 amount0,
        uint256 amount1
    ) external;

    function getPoolBalances()
        external
        view
        returns (uint256 amountA, uint256 amountB);
}
