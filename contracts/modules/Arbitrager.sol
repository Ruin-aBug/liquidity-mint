// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "../admin/Administer.sol";

import "../interfaces/IRainbow.sol";
import "../libraries/TransferHelper.sol";
import "../interfaces/IPairPool.sol";
import "./PairPool.sol";
import "./Rainbow.sol";
import "../interfaces/IProxy.sol";
import "./CalcuModule.sol";
import "../const/Constant.sol";

contract Arbitrager is Constant {

    address public AdministerAddr;
    address public rainbowAddr;
    uint256 public reward; 

    constructor(address administer, address rainbow) {
        AdministerAddr = administer;
        rainbowAddr = rainbow;
    }

    uint256 private locking1 = 1;
    uint256 private locking2 = 1;
    uint256 private locking3 = 1;
    modifier lock1() {
        require(locking1 == 1, "LOCKING");
        locking1 = 0;
        _;
        locking1 = 1;
    }
    modifier lock2() {
        require(locking2 == 1, "LOCKING");
        locking2 = 0;
        _;
        locking2 = 1;
    }
    modifier lock3() {
        require(locking3 == 1, "LOCKING");
        locking3 = 0;
        _;
        locking3 = 1;
    }

    function setRainbowAddr(address _rainbowAddr) external {
        require(Administer(AdministerAddr).isAdmin(msg.sender), "N A");
        rainbowAddr = _rainbowAddr;
    }

    function setReward(uint256 _reward) external {
        require(Administer(AdministerAddr).isAdmin(msg.sender), "N A");
        reward = _reward;
    }

    modifier ArbitratorRestriction() {
        require(
            Administer(AdministerAddr).validateArbitrager(msg.sender),
            "n ar"
        );
        _;
    }

    function checkLiquidation(uint256 poolId)
        public
        view
        ArbitratorRestriction
        returns (bool)
    {
        address poolAddr = IRainbow(rainbowAddr).getPoolAddress(poolId);
        CalcuModule.PairPoolInfo memory poolInfo = Rainbow(rainbowAddr)
            .getPoolInfo(poolId);
        CalcuModule.OPRecord[] memory record = PairPool(poolAddr).getOPRecord();
        if (!poolInfo.state || record.length == 0) {
            return false;
        }
        address[] memory swapAddr = poolInfo.swapAddress;
        uint256 TReward;
        uint256 rewardA;
        for (uint256 index = 0; index < swapAddr.length; index++) {
            rewardA = IRainbow(rainbowAddr).getMiningRewards(
                swapAddr[index],
                poolId
            );
            address rewardToken = IProxy(swapAddr[index]).getRewardToken();
            TReward += IProxy(swapAddr[index]).getAmountsOut(
                rewardA,
                rewardToken,
                poolInfo.tokenPair.tokenA
            );
        }
        uint256 TamountAC;
        uint256 TamountBC;
        (TamountAC, TamountBC) = IRainbow(rainbowAddr).getPoolTotalAmounts(
            poolId
        );
        TamountAC = TamountAC + TReward;

        uint256 amountAR = (poolInfo.lastAmounts.amountA *
            (1e18 - poolInfo.lossRate)) / 1e18;
        uint256 amountBR = (poolInfo.lastAmounts.amountB *
            (1e18 - poolInfo.lossRate)) / 1e18;

        if (poolInfo.dueDate != 0) {
            if(poolInfo.dueDate <= block.timestamp){
                return true;
            }
        }

        if (TamountAC < amountAR) {
            if (TamountBC < amountBR) {
                return true;
            } else {
                uint256 outA = IProxy(swapAddr[0]).getAmountsOut(
                    TamountBC - amountBR,
                    poolInfo.tokenPair.tokenB,
                    poolInfo.tokenPair.tokenA
                );
                return TamountAC + outA < amountAR;
            }
        } else {
            if (amountBR < TamountBC) {
                return false;
            } else {
                uint256 outB = IProxy(swapAddr[0]).getAmountsOut(
                    TamountAC - amountAR,
                    poolInfo.tokenPair.tokenA,
                    poolInfo.tokenPair.tokenB
                );
                return TamountBC + outB < amountBR;
            }
        }
    }

    event ProcessLiquidation(uint256 date, uint256 poolId);

    function processLiquidation(uint256 poolId)
        public
        lock1
        ArbitratorRestriction
    {
        address poolAddr = IRainbow(rainbowAddr).getPoolAddress(poolId);
        CalcuModule.OPRecord[] memory record = PairPool(poolAddr).getOPRecord();
        require(record.length > 0, "no record");
        for (uint256 index = 0; index < record.length; index++) {
            IRainbow(rainbowAddr).removeLiquidity(
                record[index].swapAddress,
                record[index].lpTokenAmount,
                poolId,
                record[index].opId
            );
        }

        IRainbow(rainbowAddr).waitFor(poolId);
        emit ProcessLiquidation(block.timestamp, poolId);
        transferSafe(msg.sender);
    }

    function checkCallAndPut(uint256 poolId)
        public
        view
        ArbitratorRestriction
        returns (bool, uint256[] memory)
    {
        CalcuModule.PairPoolInfo memory poolInfo = Rainbow(
            rainbowAddr
        ).getPoolInfo(poolId);

        CalcuModule.OPRecord[] memory record = PairPool(
            IRainbow(rainbowAddr).getPoolAddress(poolId)
        ).getOPRecord();
        if (!poolInfo.state || record.length == 0) {
            return (false, new uint256[](0));
        }
        uint256 id;
        uint256[] memory opIds = new uint256[](record.length);
        for (uint256 index = 0; index < record.length; index++) {
            uint256 amountA;
            uint256 amountB;
            uint256 amount0;
            uint256 amount1;

            amountA = record[index].amountA;
            amountB = record[index].amountB;

            address[] memory tokens = new address[](2);
            tokens[0] = poolInfo.tokenPair.tokenA;
            tokens[1] = poolInfo.tokenPair.tokenB;

            (amount0, amount1) = IProxy(record[index].swapAddress)
                .getRemoveLiquidity(
                    tokens,
                    record[index].lpTokenAmount,
                    record[index].tokenId
                );
            uint256 originalRatio = (amountA * 1e18) / amountB;
            uint256 currentRatio = (amount0 * 1e18) / amount1;

            if (originalRatio < currentRatio) {
                uint256 call = ((currentRatio - originalRatio) * 1e18) /
                    originalRatio;
                if (record[index].call < call) {
                    opIds[id] = record[index].opId;
                    id++;
                }
            } else {

                uint256 put = ((originalRatio - currentRatio) * 1e18) /
                    originalRatio;
                if (record[index].put < put) {
                    opIds[id] = record[index].opId;
                    id++;
                }
            }
        }
        uint256[] memory opIdss = new uint256[](id);
        for (uint256 index; index < id; index++) {
            opIdss[index] = opIds[index];
        }

        return (id != 0, opIdss);
    }

    event ProcessCallAndPut(uint256 date, uint256 poolId);

    function processCallAndPut(uint256 poolId, uint256[] memory opIds)
        external
        lock2
        ArbitratorRestriction
    {
        CalcuModule.OPRecord[] memory record = PairPool(
            IRainbow(rainbowAddr).getPoolAddress(poolId)
        ).getOPRecord();
        uint256 lock;
        for (uint256 index = 0; index < record.length; index++) {
            for (uint256 i = 0; i < opIds.length; i++) {
                if (record[index].opId == opIds[i]) {
                    IRainbow(rainbowAddr).removeLiquidity(
                        record[index].swapAddress,
                        record[index].lpTokenAmount,
                        poolId,
                        record[index].opId
                    );
                    lock++;
                }
            }
        }
        require(lock != 0, "no id");
        emit ProcessCallAndPut(block.timestamp, poolId);
        transferSafe(msg.sender);
    }

    mapping(address => uint256) public first;

    function checkTimeOut(uint256 poolId)
        public
        view
        ArbitratorRestriction
        returns (bool)
    {
        address poolAddr = IRainbow(rainbowAddr).getPoolAddress(poolId);
        CalcuModule.PairPoolInfo memory poolInfo = Rainbow(rainbowAddr).getPoolInfo(poolId);

        CalcuModule.OPRecord[] memory record = PairPool(poolAddr).getOPRecord();

        if (
            poolInfo.exchangeTime == 0 || !poolInfo.state || record.length == 0
        ) {
            return false;
        }

        uint256 timeDifference;
        if (first[poolAddr] == 0) {
            timeDifference = block.timestamp - record[0].initialOperatingTime;
        } else {
            timeDifference = block.timestamp - first[poolAddr];
        }

        return timeDifference >= poolInfo.exchangeTime;
    }

    function checkProfit(uint256 poolId)
        public
        view
        ArbitratorRestriction
        returns (bool)
    {
        address poolAddr = IRainbow(rainbowAddr).getPoolAddress(poolId);
        CalcuModule.PairPoolInfo memory poolInfo = Rainbow(rainbowAddr).getPoolInfo(poolId);
        CalcuModule.OPRecord[] memory record = PairPool(poolAddr).getOPRecord();
        if (
            poolInfo.incomeRatio == 0 || !poolInfo.state || record.length == 0
        ) {
            return false;
        }
        address rewardToken;
        uint256 rewardAmountIn;
        uint256 rewardByUSD;
        for (uint256 index = 0; index < poolInfo.swapAddress.length; index++) {
            rewardToken = IProxy(poolInfo.swapAddress[index]).getRewardToken();
            rewardAmountIn = IRainbow(rainbowAddr).getMiningRewards(
                poolInfo.swapAddress[0],
                poolId
            );
            rewardByUSD += IProxy(poolInfo.swapAddress[index]).getTokenValue(
                rewardAmountIn,
                rewardToken
            );
        }

        uint256 totaValue = getTotalValue(poolInfo);
        uint256 currentActualIncomeRatio = (rewardByUSD * 1e18) / totaValue;

        return currentActualIncomeRatio >= poolInfo.incomeRatio;
    }

    function getTotalValue(CalcuModule.PairPoolInfo memory poolInfo)
        internal
        view
        returns (uint256 totaValue)
    {
        uint256 amountAValue = IProxy(poolInfo.swapAddress[0]).getTokenValue(
            poolInfo.lastAmounts.amountA,
            poolInfo.tokenPair.tokenA
        );
        uint256 amountBValue = IProxy(poolInfo.swapAddress[0]).getTokenValue(
            poolInfo.lastAmounts.amountB,
            poolInfo.tokenPair.tokenB
        );
        totaValue = amountAValue + amountBValue;
    }

    event ProcessProfitAndTimeOut(uint256 date, uint256 poolId);

    function processProfitAndTimeOut(uint256 poolId)
        external
        lock3
        ArbitratorRestriction
    {
        address poolAddr = IRainbow(rainbowAddr).getPoolAddress(poolId);
        CalcuModule.PairPoolInfo memory poolInfo = Rainbow(rainbowAddr).getPoolInfo(poolId);
        IRainbow(rainbowAddr).arbitragerRemoveAllRewrad(poolAddr);
        if (poolInfo.exchangeTime != 0) {
            first[poolAddr] = block.timestamp;
        }

        emit ProcessProfitAndTimeOut(block.timestamp, poolId);
        transferSafe(msg.sender);
    }

    function getPairCurrencyTotalValue(
        address swapAddress,
        uint256[] memory amounts,
        address tokenA,
        address tokenB,
        address rewardToken
    ) public view returns (uint256) {
        uint256 totaValue = IProxy(swapAddress).getTokenValue(
            amounts[0],
            tokenA
        ) + IProxy(swapAddress).getTokenValue(amounts[1], tokenB);
        if (amounts.length == 3) {
            uint256 rewardByUSD = IProxy(swapAddress).getTokenValue(
                amounts[2],
                rewardToken
            );
            totaValue = totaValue + rewardByUSD;
        }

        return totaValue;
    }

    function adminWithdraw(address token, uint256 extractedBalance) external {
        require(Administer(AdministerAddr).isAdmin(msg.sender), "get out!!");
        uint256 balance = IERC20(token).balanceOf(address(this));
        if (extractedBalance <= balance) {
            IERC20(token).transfer(msg.sender, extractedBalance);
        }
    }

    function getBalanceOf(address token) public view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }

    function transferSafe(address to) internal {
        uint256 balance = getBalanceOf(USDT);
        uint256 _reward = reward == 0 ? 10 : reward; 
        require(balance > _reward, "reward Insufficient");
        TransferHelper.safeTransfer(USDT, to, _reward);
    }
}
