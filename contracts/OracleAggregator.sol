// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IUniswapV3Pool {
    function observe(uint32[] calldata secondsAgos) external view
        returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s);
}

/// @title OracleAggregator — Multi-source price oracle for Base L2
contract OracleAggregator is Ownable {
    AggregatorV3Interface public chainlinkFeed;
    address public uniswapPool;
    uint32 public twapPeriod = 1800; // 30 min TWAP
    uint256 public maxDeviationBps = 500; // 5% max deviation
    uint256 public maxStaleness = 3600; // 1 hour

    event PriceUpdated(uint256 price, uint256 source);
    event CircuitBreakerTriggered(uint256 chainlinkPrice, uint256 twapPrice);

    constructor(address _chainlink, address _uniPool) Ownable(msg.sender) {
        chainlinkFeed = AggregatorV3Interface(_chainlink);
        uniswapPool = _uniPool;
    }

    function getPrice() external view returns (uint256 price, bool valid) {
        (uint256 clPrice, bool clValid) = getChainlinkPrice();
        (uint256 twapPrice, bool twapValid) = getTWAPPrice();

        if (!clValid && !twapValid) return (0, false);
        if (!clValid) return (twapPrice, true);
        if (!twapValid) return (clPrice, true);

        // Check deviation
        uint256 deviation = clPrice > twapPrice
            ? ((clPrice - twapPrice) * 10000) / clPrice
            : ((twapPrice - clPrice) * 10000) / twapPrice;

        if (deviation > maxDeviationBps) return (0, false); // Circuit breaker

        // Return median (average of 2 sources)
        return ((clPrice + twapPrice) / 2, true);
    }

    function getChainlinkPrice() public view returns (uint256, bool) {
        try chainlinkFeed.latestRoundData() returns (uint80, int256 price, uint256, uint256 updatedAt, uint80) {
            if (price <= 0) return (0, false);
            if (block.timestamp - updatedAt > maxStaleness) return (0, false);
            return (uint256(price), true);
        } catch { return (0, false); }
    }

    function getTWAPPrice() public view returns (uint256, bool) {
        if (uniswapPool == address(0)) return (0, false);
        try IUniswapV3Pool(uniswapPool).observe([twapPeriod, 0]) returns (int56[] memory ticks, uint160[] memory) {
            int56 tickDiff = ticks[1] - ticks[0];
            int56 avgTick = tickDiff / int56(uint56(twapPeriod));
            uint256 price = uint256(int256(10**18)) * uint256(int256(1001)) ** uint256(uint56(avgTick < 0 ? -avgTick : avgTick)) / uint256(int256(1000)) ** uint256(uint56(avgTick < 0 ? -avgTick : avgTick));
            return (price, true);
        } catch { return (0, false); }
    }

    function setParams(uint32 twap, uint256 deviation, uint256 staleness) external onlyOwner {
        twapPeriod = twap; maxDeviationBps = deviation; maxStaleness = staleness;
    }
}