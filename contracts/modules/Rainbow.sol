// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "../admin/Administer.sol";
import "../interfaces/IERC20.sol";

import "../libraries/TransferHelper.sol";
import "../interfaces/IProxy.sol";
import "../interfaces/IPairPool.sol";

import "./PairPool.sol";
import "./RainbowFactory.sol";
import "../interfaces/IRainbowFactory.sol";
import "../interfaces/IRainbow.sol";
import "./CalcuModule.sol";

abstract contract Rainbow is IRainbow {
    using SafeMath for uint256;
    uint256 internal constant BIG_N = 1e18;
    address public FactoryAddr;
    address public AdministerAddr;
    address public ArbitragerAddr;

    address public dev;

    mapping(address => uint256) public adminReward;
    mapping(address => uint256) public OPReward;

    function getUSDTAddress() internal pure virtual returns (address);


    struct UserInfo {
        uint256 amountA;
        uint256 amountB;
        uint256 liquidity;
        uint256 rewardDebt;
    }
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    struct REWARD_RATIO {
        uint256 adminRatio;
        uint256 opRatio;
        uint256 arbitragerRatio;
    }

    REWARD_RATIO public rewardRatio;

    function isAdmin() internal view returns (bool) {
        return Administer(AdministerAddr).isAdmin(msg.sender);
    }

    function isOP() internal view returns (bool) {
        return Administer(AdministerAddr).validateOP(msg.sender);
    }

    function isLp() internal view returns (bool) {
        return Administer(AdministerAddr).validateLP(msg.sender);
    }

    function setDev(address _dev) external {
        require(isAdmin(), "N A");
        dev = _dev;
    }

    function setRewardRatio(REWARD_RATIO memory _rewardRatio) external {
        require(isAdmin(), "N A");
        rewardRatio = _rewardRatio;
    }

    function setPoolOwnerAddr(address poolAddr, address owner) external {
        require(isAdmin(), "N A");
        IPairPool(poolAddr).setOwner(owner);
    }

    function setPoolRainbow(address poolAddr, address newRainbowAddr) external {
        require(isAdmin(), "N A");
        IPairPool(poolAddr).setRainbow(newRainbowAddr);
    }

    function setArbitragerAddr(address arb) external override {
        require(isAdmin(), "N A");
        ArbitragerAddr = arb;
    }

    function getPoolAddress(uint256 poolId)
        public
        view
        override
        returns (address)
    {
        return IRainbowFactory(FactoryAddr).poolAddress(poolId);
    }

    function getTokenValue(
        address agentAddress,
        uint256 amountIn,
        address token
    ) public view returns (uint256) {
        return IProxy(agentAddress).getTokenValue(amountIn, token);
    }

    function _caculSharesByAmounts(
        uint256 poolId,
        uint256 amountA,
        uint256 amountB
    )
        public
        view
        returns (
            uint256 liquidity,
            uint256 amount0,
            uint256 amount1
        )
    {
        address poolAddr = getPoolAddress(poolId);
        uint256 _totalSupply = IERC20(poolAddr).totalSupply();
        (uint256 totalA, uint256 totalB) = getPoolTotalAmounts(poolId);
        if (totalA == 0 && totalB == 0) {
            amount0 = amountA;
            amount1 = amountB;
            liquidity = amount0.max(amount1);
        } else {
            uint256 cross1 = amountA.mul(totalB);
            uint256 cross2 = amountB.mul(totalA);
            uint256 cross = cross1.min(cross2);
            liquidity = cross.mul(_totalSupply).div(totalA).div(totalB);
            amount0 = cross.sub(1).div(totalB).add(1);
            amount1 = cross.sub(1).div(totalA).add(1);
        }
    }

    function depositPairToken(
        address tokenA,
        address tokenB,
        uint256 poolId,
        uint256 amountADesired,
        uint256 amountBDesired,
        address to
    )
        external
        returns (
            uint256 liquidity,
            uint256 amount0,
            uint256 amount1
        )
    {
        require(isLp(), "n l");

        address poolAddr = getPoolAddress(poolId);
        IPairPool pairPool = IPairPool(poolAddr);
        require(pairPool.identifier() == 0, "no");
        _removeAllReward(poolAddr);

        (liquidity, amount0, amount1) = _caculSharesByAmounts(
            poolId,
            amountADesired,
            amountBDesired
        );

        TransferHelper.safeTransferFrom(tokenA, msg.sender, poolAddr, amount0);
        TransferHelper.safeTransferFrom(tokenB, msg.sender, poolAddr, amount1);
        uint256 rewardDebt;
        (liquidity, rewardDebt) = pairPool.mint(to, liquidity);

        UserInfo storage user = userInfo[poolId][to];
        user.amountA = user.amountA.add(amount0);
        user.amountB = user.amountB.add(amount1);
        user.liquidity = user.liquidity.add(liquidity);
        user.rewardDebt = user.rewardDebt.add(rewardDebt);
    }

    struct WithdrawPair {
        uint256 poolId;
        uint256 liquidity;
        address to;
        bool initialFunds;
    }

    function withdrawPairToken(WithdrawPair calldata w)
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 lpReward
        )
    {
        require(isLp(), "N l");
        address poolAddr = getPoolAddress(w.poolId);
        uint256 _totalSupply;
        _removeAllReward(poolAddr);

        CalcuModule.PairPoolInfo memory pool = getPoolInfo(w.poolId);
        UserInfo storage user = userInfo[w.poolId][msg.sender];

        (amountA, amountB, _totalSupply) = getLPLiquidity(
            w.poolId,
            w.liquidity
        );
        lpReward = user.liquidity.mul(pool.perShare).div(1e12).sub(
            user.rewardDebt
        );
        uint256 hAmountA = user.amountA.mul(w.liquidity).div(user.liquidity);
        uint256 hAmountB = user.amountB.mul(w.liquidity).div(user.liquidity);

        if (amountA > pool.amounts.amountA || amountB > pool.amounts.amountB) {
            remove(w.poolId, poolAddr, w.liquidity);
            pool = getPoolInfo(w.poolId);
            if (_totalSupply > 0) {
                amountA = w.liquidity.mul(pool.amounts.amountA).div(
                    _totalSupply
                );
                amountB = w.liquidity.mul(pool.amounts.amountB).div(
                    _totalSupply
                );
            }
            lpReward = user.liquidity.mul(pool.perShare).div(1e12).sub(
                user.rewardDebt
            );
        }
        IPairPool(poolAddr).withdraw(amountA, amountB, lpReward);

        if (w.initialFunds) {
            (amountA, amountB, lpReward) = balanceLPAmount(
                amountA,
                amountB,
                lpReward,
                hAmountA,
                hAmountB,
                poolAddr,
                pool
            );
        }

        TransferHelper.safeTransferFrom(
            poolAddr,
            msg.sender,
            poolAddr,
            w.liquidity
        );

        if (lpReward > 0) {
            rewardWithdraw(w.to, w.poolId, lpReward);
        }
        IPairPool(poolAddr).burn(w.liquidity, amountA, amountB, w.to);

        user.amountA = user.amountA.sub(hAmountA);
        user.amountB = user.amountB.sub(hAmountB);
        user.liquidity = user.liquidity.sub(w.liquidity);
        user.rewardDebt = user.liquidity.mul(pool.perShare).div(1e12);
    }

    function balanceLPAmount(
        uint256 amountA,
        uint256 amountB,
        uint256 reward,
        uint256 hAmountA,
        uint256 hAmountB,
        address poolAddr,
        CalcuModule.PairPoolInfo memory pool
    )
        internal
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 differenceA;
        uint256 differenceB;
        differenceA = amountA > hAmountA
            ? amountA - hAmountA
            : hAmountA - amountA;
        if (differenceA >= 1e5) {
            if (amountA > hAmountA) {
                amountB += swap(
                    poolAddr,
                    pool.swapAddress[0],
                    pool.tokenPair.tokenA,
                    pool.tokenPair.tokenB,
                    differenceA
                );
                amountA = amountA - differenceA;
            } else {
                uint256 needAmountB = getAmountsIn(
                    pool.swapAddress[0],
                    differenceA,
                    pool.tokenPair.tokenB,
                    pool.tokenPair.tokenA
                );
                needAmountB = amountB > needAmountB ? needAmountB : amountB;
                amountA += swap(
                    poolAddr,
                    pool.swapAddress[0],
                    pool.tokenPair.tokenB,
                    pool.tokenPair.tokenA,
                    needAmountB
                );
                amountB = amountB > needAmountB ? amountB - needAmountB : 0;
            }
        }

        differenceB = amountB > hAmountB
            ? amountB - hAmountB
            : hAmountB - amountB;

        if (differenceB >= 1e5) {
            if (amountB > hAmountB) {

                if (pool.tokenPair.tokenB == pool.rewardToken) {
                    reward = reward + differenceB;
                    amountB = amountB - differenceB;
                } else {
                    reward += swap(
                        poolAddr,
                        pool.swapAddress[0],
                        pool.tokenPair.tokenB,
                        pool.rewardToken,
                        differenceB
                    );
                    amountB = amountB - differenceB;
                }
            } else {
                if (reward > 0) {
                    if (pool.tokenPair.tokenB == pool.rewardToken) {
                        (amountB, reward) = reward > differenceB
                            ? (amountB + differenceB, reward - differenceB)
                            : (amountB + reward, 0);
                    } else {
                        uint256 needReward = getAmountsIn(
                            pool.swapAddress[0],
                            differenceB,
                            pool.rewardToken,
                            pool.tokenPair.tokenB
                        );
                        needReward = reward > needReward ? needReward : reward;
                        if (needReward != 0) {
                            amountB += swap(
                                poolAddr,
                                pool.swapAddress[0],
                                pool.rewardToken,
                                pool.tokenPair.tokenB,
                                needReward
                            );
                            reward = reward - needReward;
                        }
                    }
                }
            }
        }

        return (amountA, amountB, reward);
    }

    function getLPLiquidity(uint256 poolId, uint256 liquidity)
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        (uint256 totalAmount0, uint256 totalAmount1) = getPoolTotalAmounts(
            poolId
        );
        uint256 totalSupply = IERC20(getPoolAddress(poolId)).totalSupply();
        uint256 amountA;
        uint256 amountB;
        if (totalSupply > 0) {
            amountA = liquidity.mul(totalAmount0).div(totalSupply);
            amountB = liquidity.mul(totalAmount1).div(totalSupply);
        }
        return (amountA, amountB, totalSupply);
    }

    function getPoolTotalAmounts(uint256 poolId)
        public
        view
        override
        returns (uint256 amountA, uint256 amountB)
    {
        (amountA, amountB) = IPairPool(getPoolAddress(poolId))
            .getTotalAmounts();
    }

    function rewardWithdraw(
        address to,
        uint256 poolId,
        uint256 lPReward
    ) internal {
        uint256 DEN = 1000;
        uint256 rewardDivide = IRainbowFactory(FactoryAddr).rewardDivide(
            poolId
        );

        uint256 allotRewardRatio = DEN.sub(rewardDivide);
        REWARD_RATIO memory _rewardRatio = rewardRatio;
        uint256 OPAndAdmin = lPReward.mul(allotRewardRatio).div(DEN);

        (uint256 rewardU, address owner) = IPairPool(getPoolAddress(poolId))
            .allotReward(lPReward.sub(OPAndAdmin), to, OPAndAdmin);


        uint256 reward0 = rewardU.sub(
            rewardU.mul((lPReward.div(DEN)).div(OPAndAdmin))
        );


        uint256 opReward = (
            reward0.mul(_rewardRatio.opRatio.mul(1e18).div(DEN))
        ).div(1e18);

        uint256 admin = (
            reward0.mul(_rewardRatio.adminRatio.mul(1e18).div(DEN))
        ).div(1e18);

        TransferHelper.safeTransfer(
            getUSDTAddress(),
            ArbitragerAddr,
            reward0.sub(opReward).sub(admin)
        );

        OPReward[owner] = OPReward[owner].add(opReward).add(
            rewardU.sub(reward0)
        );
        adminReward[dev] = adminReward[dev].add(admin);
    }

    function getLPRewards(address to, uint256 poolId)
        public
        view
        returns (uint256)
    {
        CalcuModule.PairPoolInfo memory pool = getPoolInfo(poolId);
        uint256 rewardDivide = IRainbowFactory(FactoryAddr).rewardDivide(
            poolId
        );
        uint256 _totalSupply = IERC20(getPoolAddress(poolId)).totalSupply();
        uint256 aReward;
        uint256 allReward;
        address rewardToken;
        for (uint256 index; index < pool.swapAddress.length; index++) {
            aReward = getMiningRewards(pool.swapAddress[index], poolId);
            rewardToken = IProxy(pool.swapAddress[index]).getRewardToken();
            if (rewardToken != pool.rewardToken && aReward > 0) {
                aReward = IProxy(pool.swapAddress[index]).getAmountsOut(
                    aReward,
                    rewardToken,
                    pool.rewardToken
                );
            }
            allReward = allReward.add(aReward);
        }
        if (_totalSupply > 0) {
            pool.perShare = pool.perShare.add(
                allReward.mul(1e12).div(_totalSupply)
            );
        }

        UserInfo memory user = userInfo[poolId][to];
        uint256 lpReward = user.liquidity.mul(pool.perShare).div(1e12).sub(
            user.rewardDebt
        );
        return lpReward.mul(rewardDivide).div(1000);
    }

    function addLiquidity(
        address agentAddress,
        uint256[] memory paramAmount,
        uint256 poolId,
        uint256 call,
        uint256 put,
        uint32 opId
    )
        public
        returns (
            uint256 retAmountA,
            uint256 retAmountB,
            uint256 liquidity
        )
    {
        address poolAddr = getPoolAddress(poolId);
        IPairPool pairPool = IPairPool(poolAddr);
        require(
            getPoolOwner(poolId) == msg.sender && pairPool.identifier() == 0,
            "N O"
        );
        uint256[] memory callPut = new uint256[](2);
        callPut[0] = call;
        callPut[1] = put;
        (retAmountA, retAmountB, liquidity) = pairPool.addLiquidity(
            agentAddress,
            paramAmount,
            callPut,
            opId
        );
    }

    function _removeLiquidity(
        address agentAddress,
        uint256 liquidity,
        uint256 poolId,
        uint32 opId
    ) internal returns (uint256 removeAmountA, uint256 removeAmountB) {
        address poolAddr = getPoolAddress(poolId);
        (removeAmountA, removeAmountB) = IPairPool(poolAddr).removeLiquidity(
            agentAddress,
            liquidity,
            opId
        );
    }

    function opSwap(
        address swapAddr,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata swapPath,
        bool isRewardToken0,
        bool isRewardToken1,
        uint256 poolId
    ) external returns (uint256 amountOut) {
        require(getPoolOwner(poolId) == msg.sender, "N O");
        address poolAddr = getPoolAddress(poolId);
        address tokenA = swapPath[0];
        address tokenB = swapPath[swapPath.length-1];
        CalcuModule.PairPoolInfo memory pool = getPoolInfo(poolId);
        if (isPoolToken(tokenA, tokenB, poolId)) {
            amountOut = IPairPool(poolAddr).opSwap(
                swapAddr,
                amountIn,
                amountOutMin,
                swapPath,
                isRewardToken0,
                isRewardToken1
            );
        }

        if (tokenA == tokenB && tokenB == pool.rewardToken) {
            amountOut = amountIn;
            IPairPool(poolAddr).updatePoolInfo(
                amountIn,
                0,
                tokenA,
                tokenB,
                isRewardToken0,
                isRewardToken1
            );
        }
        require(
            (tokenA == tokenB && tokenB == pool.rewardToken) ||
                isPoolToken(tokenA, tokenB, poolId),
            "no swap"
        );
    }

    function isPoolToken(
        address tokenA,
        address tokenB,
        uint256 poolId
    ) internal view returns (bool) {
        CalcuModule.PairPoolInfo memory pool = getPoolInfo(poolId);
        bool isTokenA = tokenA == pool.tokenPair.tokenA ||
            tokenA == pool.tokenPair.tokenB ||
            tokenA == pool.rewardToken;
        bool isTokenB = tokenB == pool.tokenPair.tokenA ||
            tokenB == pool.tokenPair.tokenB ||
            tokenB == pool.rewardToken;
        return isTokenA && isTokenB && tokenA != tokenB;
    }

    function removeLiquidity(
        address agentAddress,
        uint256 liquidity,
        uint256 poolId,
        uint32 opId
    ) public override returns (uint256 removeAmountA, uint256 removeAmountB) {
        require(ownerOrArbitragerAddr(poolId), "n o a");
        (removeAmountA, removeAmountB) = _removeLiquidity(
            agentAddress,
            liquidity,
            poolId,
            opId
        );
    }

    function arbitragerRemoveAllRewrad(address poolAddr) external override {
        require(ArbitragerAddr == msg.sender);
        _removeAllReward(poolAddr);
    }

    function _removeAllReward(address poolAddress) internal returns (uint256) {
        return IPairPool(poolAddress).removeAllRewrad();
    }

    function remove(
        uint256 poolId,
        address poolAddr,
        uint256 liquidity
    ) internal {
        (
            address[] memory agentAddr,
            uint32[] memory _opId,
            uint256[] memory share
        ) = IPairPool(poolAddr).getConditionOPRecord(liquidity);
        for (uint256 index = 0; index < _opId.length; index++) {
            _removeLiquidity(
                agentAddr[index],
                share[index],
                poolId,
                _opId[index]
            );
        }
    }

    function withdrawBonus() external {
        if (isOP()) {
            TransferHelper.safeTransfer(
                getUSDTAddress(),
                msg.sender,
                OPReward[msg.sender]
            );
            OPReward[msg.sender] = 0;
        }
        if (dev == msg.sender) {
            TransferHelper.safeTransfer(
                getUSDTAddress(),
                msg.sender,
                adminReward[msg.sender]
            );
            adminReward[msg.sender] = 0;
        }
    }

    function getAllPoolInfo()
        public
        view
        returns (CalcuModule.PairPoolInfo[] memory)
    {
        uint256 polIdLength = IRainbowFactory(FactoryAddr).getLength();

        uint256 allPoolId;
        for (uint256 index; index < polIdLength; index++) {
            CalcuModule.PairPoolInfo memory poolInfo = getPoolInfo(index);
            if (poolInfo.state) {
                allPoolId++;
            }
        }

        CalcuModule.PairPoolInfo[]
            memory allPoolInfo = new CalcuModule.PairPoolInfo[](allPoolId);
        for (uint256 index; index < polIdLength; index++) {
            CalcuModule.PairPoolInfo memory poolInfo = getPoolInfo(index);
            if (poolInfo.state) {
                allPoolInfo[allPoolId - 1] = poolInfo;
                allPoolId--;
            }
        }

        return allPoolInfo;
    }

    function getSectionPoolInfo(uint256 startIndex, uint256 endIndex)
        external
        view
        returns (CalcuModule.PairPoolInfo[] memory)
    {
        CalcuModule.PairPoolInfo[] memory allPoolInfo = getAllPoolInfo();
        endIndex = endIndex < allPoolInfo.length
            ? endIndex
            : (allPoolInfo.length > 0 ? allPoolInfo.length - 1 : 0);
        if (endIndex != 0 && startIndex < endIndex) {
            CalcuModule.PairPoolInfo[]
                memory poolInfo = new CalcuModule.PairPoolInfo[](
                    endIndex - startIndex + 1
                );
            uint256 a;
            for (uint256 index = startIndex; index <= endIndex; index++) {
                poolInfo[a] = allPoolInfo[index];
                a++;
            }

            return poolInfo;
        }
        return allPoolInfo;
    }

    function getPoolInfo(uint256 poolId)
        public
        view
        returns (CalcuModule.PairPoolInfo memory poolInfo)
    {
        if (isOpLpAdmin() || ArbitragerAddr == msg.sender) {
            poolInfo = PairPool(getPoolAddress(poolId)).getPoolInfo();
        }
    }

    function getOPRecord(uint256 poolId)
        public
        view
        returns (CalcuModule.OPRecord[] memory record)
    {
        if (isOpLpAdmin()) {
            record = PairPool(getPoolAddress(poolId)).getOPRecord();
        }
    }

    function isOpLpAdmin() internal view returns (bool) {
        return isOP() || isLp() || isAdmin();
    }

    function getMiningRewards(address agentAddress, uint256 poolId)
        public
        view
        override
        returns (uint256)
    {
        return
            IPairPool(getPoolAddress(poolId)).getMintingRewards(agentAddress);
    }

    function getAmountsIn(
        address proxyAddr,
        uint256 amountOut,
        address tokenA,
        address tokenB
    ) public view returns (uint256) {
        return IProxy(proxyAddr).getAmountsIn(amountOut, tokenA, tokenB);
    }

    function getTokenOfUSDT(address agentAddress, address token)
        public
        view
        returns (uint256)
    {
        return getTokenValue(agentAddress, 10**IERC20(token).decimals(), token);
    }

    function getTokensOfUSDT(address agentAddress, address[] memory token)
        external
        view
        returns (uint256[] memory)
    {
        uint256[] memory price = new uint256[](token.length);
        for (uint256 index; index < token.length; index++) {
            price[index] = getTokenOfUSDT(agentAddress, token[index]);
        }
        return price;
    }

    function getTotalValue(uint256 poolId, uint256[] memory amounts)
        public
        view
        override
        returns (uint256)
    {
        CalcuModule.PairPoolInfo memory pool = getPoolInfo(poolId);
        uint256 totalValue = getTokenValue(
            pool.swapAddress[0],
            amounts[0],
            pool.tokenPair.tokenA
        ) +
            getTokenValue(
                pool.swapAddress[0],
                amounts[1],
                pool.tokenPair.tokenB
            );
        if (amounts.length == 3 && amounts[2] > 0) {
            totalValue = totalValue.add(
                getTokenValue(pool.swapAddress[0], amounts[2], pool.rewardToken)
            );
        }
        return totalValue;
    }

    function swap(
        address poolAddr,
        address agentAddr,
        address token0,
        address token1,
        uint256 amountIn
    ) internal returns (uint256 amountOut) {
        amountOut = IPairPool(poolAddr).swapExactTokensForTokens(
            agentAddr,
            token0,
            token1,
            amountIn
        );
    }

    struct Multi {
        address agentAddress;
        uint256[] param;
        address[] tokens;
        uint256 poolId;
        uint256 call;
        uint256 put;
        uint32 opId;
        uint8 flag;
    }

    function multiFunction(Multi[] memory multi) external {
        uint256[] memory param = new uint256[](3);
        for (uint256 i = 0; i < multi.length; i++) {
            if (multi[i].flag == 1) {
                if (multi[i].param[0] != 0 || multi[i].param[1] != 0) {
                    addLiquidity(
                        multi[i].agentAddress,
                        multi[i].param,
                        multi[i].poolId,
                        multi[i].call,
                        multi[i].put,
                        multi[i].opId
                    );
                } else {
                    param[2] = multi[i].param[2];
                    addLiquidity(
                        multi[i].agentAddress,
                        param,
                        multi[i].poolId,
                        multi[i].call,
                        multi[i].put,
                        multi[i].opId
                    );
                }
            } else if (multi[i].flag == 2) {
                (param[0], param[1]) = removeLiquidity(
                    multi[i].agentAddress,
                    multi[i].param[0],
                    multi[i].poolId,
                    multi[i].opId
                );
                // param[2] = multi[i].param[1];
            } else if (multi[i].flag == 3) {
                param[0] = swap(
                    getPoolAddress(multi[i].poolId),
                    multi[i].agentAddress,
                    multi[i].tokens[0],
                    multi[i].tokens[1],
                    multi[i].param[0]
                );
                (param[0], param[1]) = (multi[i].tokens[0] < multi[i].tokens[1])
                    ? (uint256(0), param[0])
                    : (param[0], 0);
            } else {
                revert("N F");
            }
        }
    }

    function deletePool(uint256 poolId) external {
        address poolAddr = getPoolAddress(poolId);
        uint256 due = 30 days;
        CalcuModule.PairPoolInfo memory pool = getPoolInfo(poolId);
        if (isAdmin()) {
            IPairPool(poolAddr).deletePool(dev);
        } else if (getPoolOwner(poolId) == msg.sender) {
            if (due.add(pool.dueDate) <= block.timestamp && pool.dueDate != 0) {
                IPairPool(poolAddr).deletePool(dev);
            } else {
                revert("NOT DUE");
            }
        } else {
            revert("N D");
        }
    }

    function waitFor(uint256 poolId) external override {
        require(ownerOrArbitragerAddr(poolId), "noa");
        IPairPool(getPoolAddress(poolId)).waitFor();
    }

    function ownerOrArbitragerAddr(uint256 poolId)
        internal
        view
        returns (bool)
    {
        return
            getPoolOwner(poolId) == msg.sender || ArbitragerAddr == msg.sender;
    }

    function getPoolOwner(uint256 poolId) public view returns (address) {
        return IPairPool(getPoolAddress(poolId)).owner();
    }

    function emergencyWithdraw(uint256 poolId) external {
        require(isAdmin(), "N A");
        address poolAddr = getPoolAddress(poolId);
        IPairPool pairPool = IPairPool(poolAddr);
        pairPool.emergencyRemoveLiquidity(dev);
        (uint256 amount0, uint256 amount1) = pairPool.getPoolBalances();
        require(amount0 > 0 || amount1 > 0, "no balance");
        address[] memory lps = pairPool.getLps();
        UserInfo memory user;
        for (uint256 index = 0; index < lps.length; index++) {
            user = userInfo[poolId][lps[index]];
            if (user.liquidity > 0) {
                pairPool.emergencyWithdraw(
                    lps[index],
                    user.amountA,
                    user.amountB,
                    amount0,
                    amount1
                );
                delete user;
            }
        }
        pairPool.deletePool(dev);
    }
}
