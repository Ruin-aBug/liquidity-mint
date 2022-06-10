// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "../libraries/SafeMath.sol";
import "../interfaces/IProxy.sol";

library CalcuModule {
    using SafeMath for uint256;

    // address internal constant USDT =
    //     address(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    // address internal constant USDT =
    // address(0xa71EdC38d189767582C38A3145b5873052c3e47a);

    function getTokenValue(
        address _agentAddress,
        uint256 _amount,
        address _token
    ) public view returns (uint256) {
        return IProxy(_agentAddress).getTokenValue(_amount, _token);
    }

    function getTotalValue(PairPoolInfo memory pool)
        external
        view
        returns (uint256)
    {
        uint256 valueA = getTokenValue(
            pool.swapAddress[0],
            pool.lastAmounts.amountA,
            pool.tokenPair.tokenA
        );
        uint256 valueB = getTokenValue(
            pool.swapAddress[0],
            pool.lastAmounts.amountB,
            pool.tokenPair.tokenB
        );
        uint256 valueReward = getTokenValue(
            pool.swapAddress[0],
            pool.reward,
            pool.rewardToken
        );
        return valueA.add(valueB.add(valueReward));
    }

    function getTokensValue(
        address _agentAddress,
        uint256 _amountA,
        uint256 _amountB,
        address tokenA,
        address tokenB
    ) public view returns (uint256) {
        uint256 valueA = getTokenValue(_agentAddress, _amountA, tokenA);
        uint256 valueB = getTokenValue(_agentAddress, _amountB, tokenB);
        return valueA + valueB;
    }

    function getRemoveLiquidity(
        address _agentAddress,
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 tokenId
    ) public view returns (uint256, uint256) {
        address[] memory tokens = new address[](2);
        tokens[0] = tokenA;
        tokens[1] = tokenB;
        (uint256 amount0, uint256 amount1) = IProxy(_agentAddress)
            .getRemoveLiquidity(tokens, liquidity, tokenId);
        return (amount0, amount1);
    }

    function calculateAllotShare(
        uint256 allUserAmountA,
        uint256 allUserAmountB,
        CalcuModule.PairPoolInfo memory pool
    ) external view returns (uint256[] memory) {
        uint256 allAmountA = allUserAmountA.add(pool.lastAmounts.amountA);
        uint256 allAmountB = allUserAmountB.add(pool.lastAmounts.amountB);
        uint256 allValueA = getTokenValue(
            pool.swapAddress[0],
            allAmountA,
            pool.tokenPair.tokenA
        );
        uint256 allValueB = getTokenValue(
            pool.swapAddress[0],
            allAmountB,
            pool.tokenPair.tokenB
        );
        uint256 lastValueA = (((pool.lastAmounts.amountA * 1e18) / allAmountA) *
            allValueA) / 1e18;
        uint256 lastValueB = (((pool.lastAmounts.amountB * 1e18) / allAmountB) *
            allValueB) / 1e18;
        uint256 allUserValueA = allValueA.sub(lastValueA);
        uint256 allUserValueB = allValueB.sub(lastValueB);
        uint256[] memory value = new uint256[](3);
        value[0] = lastValueA.add(lastValueB);
        value[1] = allUserValueA;
        value[2] = allUserValueB;
        return value;
    }

    function getOprecords(
        OPRecord[] memory records,
        uint256 liquidity,
        uint256 totalSupply
    )
        external
        pure
        returns (
            address[] memory,
            uint32[] memory,
            uint256[] memory
        )
    {
        address[] memory swapAddrs = new address[](records.length);
        uint32[] memory ids = new uint32[](records.length);
        uint256[] memory share = new uint256[](records.length);
        uint256 index;
        for (index; index < records.length; index++) {
            OPRecord memory oprecord = records[index];
            swapAddrs[index] = oprecord.swapAddress;
            ids[index] = oprecord.opId;
            share[index] = liquidity.mul(oprecord.lpTokenAmount).div(totalSupply);
        }
        return (swapAddrs, ids, share);
    }

    function getTotalAmounts(
        OPRecord[] memory records,
        uint256 totalAmountA,
        uint256 totalAmountB,
        address tokenA,
        address tokenB
    ) external view returns (uint256, uint256) {
        uint256 amountA0;
        uint256 amountB0;
        uint256 amount0;
        uint256 amount1;
        for (uint256 index; index < records.length; index++) {
            OPRecord memory oprecord = records[index];
            if (oprecord.swapAddress != address(0)) {
                (amount0, amount1) = getRemoveLiquidity(
                    oprecord.swapAddress,
                    tokenA,
                    tokenB,
                    oprecord.lpTokenAmount,
                    oprecord.tokenId
                );
                amountA0 += amount0;
                amountB0 += amount1;
            }
        }
        totalAmountA += amountA0;
        totalAmountB += amountB0;
        return (totalAmountA, totalAmountB);
    }


    struct PairPoolInfo {
        address[] swapAddress; 
        Amounts amounts; 
        Amounts lastAmounts;
        Tokens tokenPair;
        uint256 reward;
        uint256 perShare;
        uint256 lossRate;
        uint256 rewardRiot;
        address rewardToken;
        uint256 dueDate;
        bool reInvestment;
        bool state;
        uint256 poolId;
        uint256 incomeRatio;
        uint256 exchangeTime;
    }

    struct Tokens {
        address tokenA;
        address tokenB;
    }
    struct Amounts {
        uint256 amountA;
        uint256 amountB;
    }


    struct OPRecord {
        uint256 amountA;
        uint256 amountB;
        uint256 lpTokenAmount;
        uint256 call;
        uint256 put;
        uint32 opId; 
        address swapAddress;
        uint256 tokenId;
        uint256 initialOperatingTime;
    }

    function investmentRewardInfo(
        uint256 amountA,
        uint256 amountB,
        uint256 amount0,
        uint256 amount1,
        uint256 lpTokenRatio
    )
        external
        pure
        returns (
            uint256 lpA,
            uint256 lpB,
            uint256 lastA,
            uint256 lastB
        )
    {

        // lpA = lpTokenRatio * amountA / 1e18;
        // lpB = lpTokenRatio * amountB / 1e18;
        lastA = (lpTokenRatio * amount0) / 1e18;
        lastB = (lpTokenRatio * amount1) / 1e18;

        int256 rea = int256(amountA) - int256(lastA);
        int256 reb = int256(amountB) - int256(lastB);
        if (rea > 0) {
            lpA = amountA - (uint256(rea) * 253) / 1000;
        }
        if (reb > 0) {
            lpB = amountB - (uint256(reb) * 253) / 1000;
        }
    }
}
