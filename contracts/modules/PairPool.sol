// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "../libraries/Library.sol";
import "../libraries/SafeMath.sol";
import "../libraries/TransferHelper.sol";
import "./CalcuModule.sol";
import "../interfaces/IProxy.sol";
import "../interfaces/IRainbowFactory.sol";
import "../interfaces/IPairPool.sol";
import "../token/RBLPToken.sol";

abstract contract PairPool is RBLPToken, IPairPool {
    using SafeMath for uint256;

    uint256 public override waitTime;
    uint256 public override identifier;

    address public override owner;
    address public rainbowAddr;
    address public factoryAddr;

    CalcuModule.PairPoolInfo pairPoolInfo;
    address[] tokens;

    uint32 opId;
    mapping(address => mapping(uint32 => CalcuModule.OPRecord)) public opRecord;
    struct OPID {
        uint32[] opIds;
    }
    mapping(address => OPID) mapOpIds;

    address[] lps;

    modifier rainbow() {
        require(rainbowAddr == msg.sender, "N R");
        _;
    }

    function setRainbow(address _rainbowAddr) external override rainbow {
        rainbowAddr = _rainbowAddr;
    }

    uint256 private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, "@2|2");
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function setOwner(address _OP) external override rainbow {
        owner = _OP;
    }


    function initialize(
        address[] memory _addrArray,
        address _tokenA,
        address _tokenB,
        uint256[] memory allUint,
        address _rewardToken,
        uint256 id,
        address ownerAddr,
        uint256 incomeRatio,
        uint256 exchangeTime
    ) external override {
        require(factoryAddr == msg.sender, "N F");
        pairPoolInfo.swapAddress = _addrArray;

        pairPoolInfo.lossRate = allUint[0];
        pairPoolInfo.rewardRiot = allUint[1];


        pairPoolInfo.dueDate = allUint[2];
        pairPoolInfo.rewardToken = _rewardToken;

        pairPoolInfo.reInvestment = _rewardToken == address(0) ? true : false;

        pairPoolInfo.tokenPair.tokenA = _tokenA;
        pairPoolInfo.tokenPair.tokenB = _tokenB;
        tokens.push(_tokenA);
        tokens.push(_tokenB);
        pairPoolInfo.state = true;
        pairPoolInfo.poolId = id;

        pairPoolInfo.incomeRatio = incomeRatio;
        pairPoolInfo.exchangeTime = exchangeTime;

        rainbowAddr = IRainbowFactory(msg.sender).rainbowAddr();
        owner = ownerAddr;
    }

    // function addExchange(address _exchange) external rainbow {
    //     pairPoolInfo.swapAddress.push(_exchange);
    // }

    function updatePoolPerShareAdd(uint256 reward) internal {
        uint256 perShare = pairPoolInfo.perShare;
        uint256 _totalSupply = totalSupply;
        pairPoolInfo.perShare = perShare.add(
            reward.mul(1e12).div(_totalSupply)
        );
    }

    function updatePoolPerShareSub(uint256 reward) internal {
        uint256 perShare = pairPoolInfo.perShare;
        uint256 _totalSupply = totalSupply;
        pairPoolInfo.perShare = perShare.sub(
            reward.mul(1e12).div(_totalSupply)
        );
    }

    function mint(address _to, uint256 _liquidity)
        public
        override
        lock
        rainbow
        returns (uint256 liquidity, uint256 rewardDebt)
    {
        require(_liquidity > 0, "@2|3");
        liquidity = _liquidity;
        _mint(_to, _liquidity);
        rewardDebt = liquidity.mul(pairPoolInfo.perShare).div(1e12);
        if (!lpIsExist(_to)) {
            lps.push(_to);
        }
        deposit();
    }

    function lpIsExist(address to) internal view returns (bool) {
        for (uint256 i; i < lps.length; i++) {
            if (lps[i] == to) {
                return true;
            }
        }
        return false;
    }

    function burn(
        uint256 _liquidity,
        uint256 _amountA,
        uint256 _amountB,
        address _to
    ) external override lock rainbow {
        _burn(address(this), _liquidity);
        TransferHelper.safeTransfer(
            pairPoolInfo.tokenPair.tokenA,
            _to,
            _amountA
        );

        TransferHelper.safeTransfer(
            pairPoolInfo.tokenPair.tokenB,
            _to,
            _amountB
        );
        (uint256 amount0, uint256 amount1) = getTotalAmounts();
        pairPoolInfo.lastAmounts.amountA = amount0;
        pairPoolInfo.lastAmounts.amountB = amount1;
    }

    function addLiquidity(
        address _agentAddress,
        uint256[] memory _amounts,
        uint256[] calldata callAndPut,
        uint32 _opId
    )
        external
        override
        rainbow
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        )
    {
        require(
            _amounts[0] <= pairPoolInfo.amounts.amountA &&
                _amounts[1] <= pairPoolInfo.amounts.amountB,
            "@2|4"
        );

        address[] memory paramAddr = tokens;
        // paramAddr[0] = pairPoolInfo.tokenPair.tokenA;
        // paramAddr[1] = pairPoolInfo.tokenPair.tokenB;

        TransferHelper.safeTransfer(
            pairPoolInfo.tokenPair.tokenA,
            _agentAddress,
            _amounts[0]
        );
        TransferHelper.safeTransfer(
            pairPoolInfo.tokenPair.tokenB,
            _agentAddress,
            _amounts[1]
        );

        uint256 tokenId;

        CalcuModule.OPRecord memory opr = opRecord[_agentAddress][_opId];

        (tokenId, amountA, amountB, liquidity) = IProxy(_agentAddress)
            .addLiquidity(
                paramAddr,
                _amounts,
                opr.tokenId,
                block.timestamp.add(3000)
            );

        _amounts[0] = amountA;
        _amounts[1] = amountB;

        setOpRecord(
            _agentAddress,
            _opId,
            _amounts,
            liquidity,
            tokenId,
            callAndPut
        );

        pairPoolInfo.amounts.amountA = pairPoolInfo.amounts.amountA.sub(
            amountA
        );
        pairPoolInfo.amounts.amountB = pairPoolInfo.amounts.amountB.sub(
            amountB
        );
    }

    function setOpRecord(
        address _agentAddress,
        uint32 _opId,
        uint256[] memory _amounts,
        uint256 _liquidity,
        uint256 _tokenId,
        uint256[] calldata callAndPut
    ) private returns (uint32) {
        if (_opId == 0) {
            opId++;
            OPID storage mapOpId = mapOpIds[_agentAddress];
            mapOpId.opIds.push(opId);
            CalcuModule.OPRecord storage ops = opRecord[_agentAddress][opId];
            /////////////////////////////////////////////////
            ops.amountA = _amounts[0];
            ops.amountB = _amounts[1];
            ops.lpTokenAmount = _liquidity;
            ops.tokenId = _tokenId;
            ////////////////////////////////////////////////////////
            ops.call = callAndPut[0];
            ops.put = callAndPut[1];
            ops.opId = opId;
            ops.swapAddress = _agentAddress;
            ops.initialOperatingTime = block.timestamp;
            return opId;
        } else {
            CalcuModule.OPRecord storage ops = opRecord[_agentAddress][_opId];
            ops.amountA = ops.amountA.add(_amounts[0]);
            ops.amountB = ops.amountB.add(_amounts[1]);
            ops.lpTokenAmount = ops.lpTokenAmount.add(_liquidity);
            ////////////////////////////////////////////////////////////////////////
            return _opId;
        }
    }

    function removeLiquidity(
        address agentAddress,
        uint256 liquidity,
        uint32 opid
    )
        external
        override
        rainbow
        returns (uint256 removeAmountA, uint256 removeAmountB)
    {
        address[] memory paramAddr = tokens;

        CalcuModule.OPRecord memory opr = opRecord[agentAddress][opId];
        (removeAmountA, removeAmountB) = IProxy(agentAddress).removeLiquidity(
            paramAddr,
            opr.tokenId,
            address(this),
            liquidity,
            block.timestamp.add(3000)
        );

        pairPoolInfo.amounts.amountA = pairPoolInfo.amounts.amountA.add(
            removeAmountA
        );
        pairPoolInfo.amounts.amountB = pairPoolInfo.amounts.amountB.add(
            removeAmountB
        );

        uint256 reward = withdrawMiningReward(agentAddress, liquidity, true);
        updatePoolPerShareAdd(reward);
        deleteOpRecord(
            agentAddress,
            opid,
            liquidity,
            removeAmountA,
            removeAmountB
        );
    }

    function deleteOpRecord(
        address _agentAddress,
        uint32 _opId,
        uint256 _liquidity,
        uint256 removeAmountA,
        uint256 removeAmountB
    ) private {
        CalcuModule.OPRecord storage ops = opRecord[_agentAddress][_opId];
        ops.lpTokenAmount = ops.lpTokenAmount.sub(_liquidity);
        if (ops.lpTokenAmount == 0) {
            delete opRecord[_agentAddress][_opId];
        } else {
            (ops.amountA, ops.amountB) = (ops.amountA > removeAmountA &&
                ops.amountB > removeAmountB)
                ? (
                    ops.amountA.sub(removeAmountA),
                    ops.amountB.sub(removeAmountB)
                )
                : (uint256(0), uint256(0));
            //////////////////////////////////////////////////////
        }
    }

    function withdrawMiningReward(
        address _agentAddress,
        uint256 _liquidity,
        bool isSubLiqudiity
    ) public override rainbow returns (uint256) {
        address[] memory paramAddr = tokens;

        uint256 reward;
        uint256 poolReward;
        address rewardToken = IProxy(_agentAddress).getRewardToken();
        if (_liquidity > 0 && rewardToken != address(0)) {
            reward = IProxy(_agentAddress).withdrawReward(
                paramAddr,
                address(this),
                _liquidity,
                isSubLiqudiity
            );
            poolReward = reward;
            if (
                rewardToken != pairPoolInfo.rewardToken &&
                !pairPoolInfo.reInvestment &&
                reward > 0
            ) {
                poolReward = swapExactTokensForTokens(
                    _agentAddress,
                    rewardToken,
                    pairPoolInfo.rewardToken,
                    reward
                );
            }
            // else if (pairPoolInfo.reInvestment && reward > 0) {
            //     reinvest(reward, rewardToken);
            //     reward = 0;
            // }
        }
        pairPoolInfo.reward = pairPoolInfo.reward.add(poolReward);
        return poolReward;
    }

    function removeAllRewrad() external override rainbow returns (uint256) {
        CalcuModule.OPRecord[] memory ops = getOPRecord();
        uint256 reward;
        uint256 aReward;
        for (uint256 index = 0; index < ops.length; index++) {
            if (ops[index].lpTokenAmount != 0) {
                aReward = withdrawMiningReward(
                    ops[index].swapAddress,
                    ops[index].lpTokenAmount,
                    false
                );
                reward = reward.add(aReward);
            }
        }
        if (reward > 0) {
            updatePoolPerShareAdd(reward);
        }

        return reward;
    }

    function swapExactTokensForTokens(
        address _agentAddress,
        address tokenA,
        address tokenB,
        uint256 amountIn
    ) public override rainbow returns (uint256 amountOut) {
        address[] memory path = new address[](2);
        path[0] = tokenA;
        path[1] = tokenB;
        TransferHelper.safeTransfer(tokenA, _agentAddress, amountIn);
        amountOut = IProxy(_agentAddress).swapExactTokensForTokens(
            amountIn,
            path,
            address(this),
            block.timestamp.add(3000)
        );
    }

    function opSwap(
        address swapAddr,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata swapPath,
        bool isRewardToken0,
        bool isRewardToken1
    ) external override rainbow returns (uint256 amountOut) {
        // address[] memory path = new address[](2);
        // path[0] = tokenA;
        // path[1] = tokenB;
        TransferHelper.safeTransfer(swapPath[0], swapAddr, amountIn);
        amountOut = IProxy(swapAddr).opSwap(
            amountIn,
            swapPath,
            address(this),
            amountOutMin
        );
        require(amountOut > 0, "swap tow little");
        updatePoolInfo(
            amountIn,
            amountOut,
            swapPath[0],
            swapPath[swapPath.length - 1],
            isRewardToken0,
            isRewardToken1
        );
    }

    function getPoolCurrentAmounts()
        public
        view
        override
        returns (uint256, uint256)
    {
        (uint256 balanceA, uint256 balanceB) = getPoolBalances();

        if (pairPoolInfo.tokenPair.tokenA == pairPoolInfo.rewardToken) {
            balanceA = balanceA.sub(pairPoolInfo.reward);
        }
        if (pairPoolInfo.tokenPair.tokenB == pairPoolInfo.rewardToken) {
            balanceB = balanceB.sub(pairPoolInfo.reward);
        }
        return (balanceA, balanceB);
    }

    function deposit() public override rainbow {
        (uint256 balanceA, uint256 balanceB) = getPoolCurrentAmounts();
        uint256 amountA = balanceA.sub(pairPoolInfo.amounts.amountA);
        uint256 amountB = balanceB.sub(pairPoolInfo.amounts.amountB);
        pairPoolInfo.amounts.amountA = pairPoolInfo.amounts.amountA.add(
            amountA
        );
        pairPoolInfo.amounts.amountB = pairPoolInfo.amounts.amountB.add(
            amountB
        );
        pairPoolInfo.lastAmounts.amountA = pairPoolInfo.lastAmounts.amountA.add(
            amountA
        );
        pairPoolInfo.lastAmounts.amountB = pairPoolInfo.lastAmounts.amountB.add(
            amountB
        );
    }

    function withdraw(
        uint256 amountA,
        uint256 amountB,
        uint256 reward
    ) public override rainbow {
        // (uint256 balanceA, uint256 balanceB) = getPoolCurrentAmounts();
        pairPoolInfo.amounts.amountA = pairPoolInfo.amounts.amountA.sub(
            amountA
        );
        pairPoolInfo.amounts.amountB = pairPoolInfo.amounts.amountB.sub(
            amountB
        );

        pairPoolInfo.reward = pairPoolInfo.reward.sub(reward);
    }


    function updatePoolReward(uint256 reward) external override rainbow {
        pairPoolInfo.reward = pairPoolInfo.reward.sub(reward);
    }

    function getMintingRewards(address _agentAddress)
        public
        view
        override
        returns (uint256)
    {
        address[] memory paramAddr = tokens;
        // paramAddr[0] = pairPoolInfo.tokenPair.tokenA;
        // paramAddr[1] = pairPoolInfo.tokenPair.tokenB;
        uint256 liquidity;
        OPID memory mapOpId = mapOpIds[_agentAddress];
        for (uint256 i; i < mapOpId.opIds.length; i++) {
            CalcuModule.OPRecord memory op = opRecord[_agentAddress][
                mapOpId.opIds[i]
            ];
            liquidity = liquidity.add(op.lpTokenAmount);
        }
        if (liquidity > 0) {
            return IProxy(_agentAddress).getRewards(paramAddr, liquidity);
        } else {
            return 0;
        }
    }

    function getPoolInfo()
        external
        view
        rainbow
        returns (CalcuModule.PairPoolInfo memory)
    {
        return pairPoolInfo;
    }

    function getLps() external view override returns (address[] memory) {
        return lps;
    }


    function getOPRecord() public view returns (CalcuModule.OPRecord[] memory) {
        uint256 length;
        for (uint256 i; i < pairPoolInfo.swapAddress.length; i++) {
            OPID memory mapOpId0 = mapOpIds[pairPoolInfo.swapAddress[i]];
            length += mapOpId0.opIds.length;
        }

        CalcuModule.OPRecord[] memory ops = new CalcuModule.OPRecord[](length);
        if (length == 0 || opId == 0) {
            return ops;
        }
        uint256 allOpId;
        for (uint256 index; index < pairPoolInfo.swapAddress.length; index++) {
            OPID memory mapOpId1 = mapOpIds[pairPoolInfo.swapAddress[index]];
            for (uint256 j; j < mapOpId1.opIds.length; j++) {
                if (
                    opRecord[pairPoolInfo.swapAddress[index]][mapOpId1.opIds[j]]
                        .lpTokenAmount != 0
                ) {
                    ops[allOpId] = opRecord[pairPoolInfo.swapAddress[index]][
                        mapOpId1.opIds[j]
                    ];
                    allOpId++;
                }
            }
        }

        uint256 vaildLen;
        for (vaildLen = 0; vaildLen < length; vaildLen++) {
            CalcuModule.OPRecord memory opRe = ops[vaildLen];
            if (opRe.lpTokenAmount == 0) {
                break;
            }
        }
        CalcuModule.OPRecord[] memory opRes = new CalcuModule.OPRecord[](
            vaildLen
        );
        for (uint256 len = 0; len < vaildLen; len++) {
            CalcuModule.OPRecord memory opRe = ops[len];
            opRes[len] = opRe;
        }
        return opRes;
    }

    function getConditionOPRecord(uint256 liquidity)
        public
        view
        override
        returns (
            address[] memory swapAddrs,
            uint32[] memory ids,
            uint256[] memory share
        )
    {
        uint256 _totalSupply = totalSupply;
        CalcuModule.OPRecord[] memory records = getOPRecord();
        if (records.length == 0) {
            return (swapAddrs, ids, share);
        }
        (swapAddrs, ids, share) = CalcuModule.getOprecords(
            records,
            liquidity,
            _totalSupply
        );
    }

    function getTotalAmounts() public view override returns (uint256, uint256) {
        (uint256 balanceA, uint256 balanceB) = getPoolCurrentAmounts();

        CalcuModule.OPRecord[] memory records = getOPRecord();

        (balanceA, balanceB) = CalcuModule.getTotalAmounts(
            records,
            balanceA,
            balanceB,
            pairPoolInfo.tokenPair.tokenA,
            pairPoolInfo.tokenPair.tokenB
        );
        return (balanceA, balanceB);
    }

    function allotReward(
        uint256 LPReward,
        address to,
        uint256 bronusRewards
    ) external override rainbow returns (uint256, address) {
        TransferHelper.safeTransfer(pairPoolInfo.rewardToken, to, LPReward);
        uint256 amount = bronusRewards;
        if (pairPoolInfo.rewardToken != getUSDTAddress()) {
            amount = swapExactTokensForTokens(
                pairPoolInfo.swapAddress[0],
                pairPoolInfo.rewardToken,
                getUSDTAddress(),
                bronusRewards
            );
        }
        TransferHelper.safeTransfer(getUSDTAddress(), msg.sender, amount);
        // pairPoolInfo.reward = pairPoolInfo.reward.sub(LPReward).sub(bronusRewards);
        // withdraw();
        return (amount, owner);
    }

    function getUSDTAddress() internal view virtual returns (address);

    /////////////////////////////////////////////////////////
    function deletePool(address dev) external override rainbow {
        address tokenA = pairPoolInfo.tokenPair.tokenA;
        address tokenB = pairPoolInfo.tokenPair.tokenB;
        address rewardToken = pairPoolInfo.rewardToken;
        uint256 balanceA = _tokenBalanceOf(tokenA);
        uint256 balanceB = _tokenBalanceOf(tokenB);

        if (balanceA > 0) {
            TransferHelper.safeTransfer(tokenA, dev, balanceA);
        }
        if (balanceB > 0) {
            TransferHelper.safeTransfer(tokenB, dev, balanceB);
        }
        if (rewardToken != address(0)) {
            uint256 balanceReward = _tokenBalanceOf(rewardToken);
            if (balanceReward > 0) {
                TransferHelper.safeTransfer(rewardToken, dev, balanceReward);
            }
        }

        delete pairPoolInfo;
    }

    function waitFor() external override rainbow {
        identifier = 1;
        waitTime = block.timestamp;
    }

    function updatePoolInfo(
        uint256 amount0,
        uint256 amount1,
        address token0,
        address token1,
        bool isRewardToken0,
        bool isRewardToken1
    ) public override rainbow {
        address tokenA = pairPoolInfo.tokenPair.tokenA;
        address tokenB = pairPoolInfo.tokenPair.tokenB;
        address rewardToken = pairPoolInfo.rewardToken;
        if (amount1 == 0) {
            if (isRewardToken0) {
                require(amount0 <= pairPoolInfo.reward, "reward no");
                if (token0 == tokenA) {
                    pairPoolInfo.reward = pairPoolInfo.reward.sub(amount0);
                    pairPoolInfo.amounts.amountA = pairPoolInfo
                        .amounts
                        .amountA
                        .add(amount0);
                } else {
                    pairPoolInfo.reward = pairPoolInfo.reward.sub(amount0);
                    pairPoolInfo.amounts.amountB = pairPoolInfo
                        .amounts
                        .amountB
                        .add(amount0);
                }
                updatePoolPerShareSub(amount0);
            } else {
                if (token0 == tokenA) {
                    pairPoolInfo.amounts.amountA = pairPoolInfo
                        .amounts
                        .amountA
                        .sub(amount0);
                    pairPoolInfo.reward = pairPoolInfo.reward.add(amount0);
                } else {
                    pairPoolInfo.amounts.amountB = pairPoolInfo
                        .amounts
                        .amountB
                        .sub(amount0);
                    pairPoolInfo.reward = pairPoolInfo.reward.add(amount0);
                }
                updatePoolPerShareAdd(amount0);
            }
        } else {
            if (isRewardToken0) {
                require(amount0 <= pairPoolInfo.reward, "reward no");
                if (token0 == tokenA) {
                    pairPoolInfo.reward = pairPoolInfo.reward.sub(amount0);
                    pairPoolInfo.amounts.amountB = pairPoolInfo
                        .amounts
                        .amountB
                        .add(amount1);
                } else if (token0 == tokenB) {
                    pairPoolInfo.reward = pairPoolInfo.reward.sub(amount0);
                    pairPoolInfo.amounts.amountA = pairPoolInfo
                        .amounts
                        .amountA
                        .add(amount1);
                } else if (rewardToken != tokenA && rewardToken != tokenB) {
                    if (token1 == tokenA) {
                        // R -> A
                        pairPoolInfo.reward = pairPoolInfo.reward.sub(amount0); // R -
                        pairPoolInfo.amounts.amountA = pairPoolInfo
                            .amounts
                            .amountA
                            .add(amount1); // A +
                    } else if (token1 == tokenB) {
                        // R -> B
                        pairPoolInfo.reward = pairPoolInfo.reward.sub(amount0); // R -
                        pairPoolInfo.amounts.amountB = pairPoolInfo
                            .amounts
                            .amountB
                            .add(amount1); // B +
                    }
                }
                updatePoolPerShareSub(amount0);
            } else {
                if (token0 == tokenA) {
                    if (isRewardToken1) {
                        // A -> R
                        pairPoolInfo.amounts.amountA = pairPoolInfo
                            .amounts
                            .amountA
                            .sub(amount0); // A -
                        pairPoolInfo.reward = pairPoolInfo.reward.add(amount1); // R +
                        updatePoolPerShareAdd(amount1);
                    } else {
                        // A -> B
                        pairPoolInfo.amounts.amountA = pairPoolInfo
                            .amounts
                            .amountA
                            .sub(amount0); // A -
                        pairPoolInfo.amounts.amountB = pairPoolInfo
                            .amounts
                            .amountB
                            .add(amount1); // B +
                    }
                } else if (token0 == tokenB) {
                    if (isRewardToken1) {
                        // B -> R
                        pairPoolInfo.amounts.amountB = pairPoolInfo
                            .amounts
                            .amountB
                            .sub(amount0); // B -
                        pairPoolInfo.reward = pairPoolInfo.reward.add(amount1); // R +
                        updatePoolPerShareAdd(amount1);
                    } else if (token1 == tokenA) {
                        // B -> A
                        pairPoolInfo.amounts.amountB = pairPoolInfo
                            .amounts
                            .amountB
                            .sub(amount0); // B -
                        pairPoolInfo.amounts.amountA = pairPoolInfo
                            .amounts
                            .amountA
                            .add(amount1); // A +
                    }
                }
            }
        }
        (uint256 amountA, uint256 amountB) = getTotalAmounts();
        pairPoolInfo.lastAmounts.amountA = amountA;
        pairPoolInfo.lastAmounts.amountB = amountB;
    }

    function emergencyRemoveLiquidity(address dev) external override rainbow {
        address[] memory _tokens = tokens;
        uint256 reward;
        address rewardToken;
        address swapAddr;
        uint256 liquidity;
        CalcuModule.OPRecord[] memory record = getOPRecord();
        if (record.length > 0) {
            for (uint256 index = 0; index < record.length; index++) {
                swapAddr = record[index].swapAddress;
                liquidity = record[index].lpTokenAmount;
                IProxy(swapAddr).removeLiquidity(
                    _tokens,
                    record[index].tokenId,
                    address(this),
                    liquidity,
                    block.timestamp
                );
                rewardToken = IProxy(swapAddr).getRewardToken();
                if (liquidity > 0 && rewardToken != address(0)) {
                    reward = IProxy(swapAddr).withdrawReward(
                        _tokens,
                        dev,
                        liquidity,
                        true
                    );
                }
            }
        }
    }

    function emergencyWithdraw(
        address to,
        uint256 amountA,
        uint256 amountB,
        uint256 amount0,
        uint256 amount1
    ) external override rainbow {
        uint256 lastAmountA = pairPoolInfo.lastAmounts.amountA;
        uint256 lastAmountB = pairPoolInfo.lastAmounts.amountB;

        amountA = (((amountA * 1e18) / lastAmountA) * amount0) / 1e18;
        amountB = (((amountB * 1e18) / lastAmountB) * amount1) / 1e18;
        amountA = amountA > amount0 ? amount0 : amountA;
        amountB = amountB > amount1 ? amount1 : amountB;
        TransferHelper.safeTransfer(pairPoolInfo.tokenPair.tokenA, to, amountA);
        TransferHelper.safeTransfer(pairPoolInfo.tokenPair.tokenB, to, amountB);
    }

    function _tokenBalanceOf(address token) internal view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }

    function getPoolBalances()
        public
        view
        override
        returns (uint256 amountA, uint256 amountB)
    {
        amountA = _tokenBalanceOf(tokens[0]);
        amountB = _tokenBalanceOf(tokens[1]);
    }
}
