// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

// 代理合约公共接口
interface IProxy {

    function getRewards(address[] memory tokens, uint256 liquidity)
        external
        view
        returns (uint256);

    function withdrawReward(
        address[] memory tokens,
        address to,
        uint256 poolLiquidity,
        bool isSubLiqudiity
    ) external  returns (uint256 mdxAmount);

    function getAmountOutForAmountIn(
        address tokenA,
        address tokenB,
        uint24 fee,
        int24 tickLower,
        int24 tickUpper,
        uint256 amountIn
    ) external view returns (uint256);

    function getTokenValue(uint256 _amountIn, address _token)
        external
        view
        returns (uint256);

    function getAmountsOut(
        uint256 _amountIn,
        address tokenA,
        address tokenB
    ) external view returns (uint256);

    function getAmountsIn(
        uint256 amountOut,
        address tokenA,
        address tokenB
    ) external view returns (uint256);

    function addLiquidity(
        address[] memory token,
        uint256[] memory amountDesired,
        uint256 _tokenId,
        uint256 deadline
    )
        external
        returns (
            uint256 tokenId,
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function removeLiquidity(
        address[] memory tokens,
        uint256 tokenId,
        address to,
        uint256 liquidity,
        uint256 deadline
    ) external  returns (uint256 amountA, uint256 amountB);

    function getRemoveLiquidity(
        address[] memory tokens,
        uint256 liquidity,
        uint256 tokenId
    ) external view returns (uint256, uint256);

    function swapExactTokensForTokens(
        uint256 amountIn,
        address[] memory path,
        address to,
        uint256 deadline
    ) external returns (uint256 amountOut);

    function opSwap(
        uint256 amountIn,
        address[] memory path,
        address to,
        uint256 amountOutMin
    ) external returns(uint256 amountOut);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] memory path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function getRewardToken() external view returns (address);
}
