# base-oracle-aggregator

> Multi-Source Price Oracle Aggregator for Base L2

Combine multiple price sources (Chainlink, Uniswap v3 TWAP, Pyth Network) into a single manipulation-resistant price feed. Uses median pricing and circuit breakers for safety.

## Price Sources
| Source | Latency | Manipulation Resistance |
|--------|---------|------------------------|
| Chainlink | ~1 min | High (decentralized) |
| Uniswap v3 TWAP | Configurable | Medium (capital cost) |
| Pyth Network | <1 sec | High (multi-chain) |
| Median (all 3) | ~1 min | Very High |

## Features
- 📊 Median price from 3+ sources
- 🚨 Circuit breaker (max deviation threshold)
- ⏰ Staleness check (reject old prices)
- 🔒 Access control for consumer contracts
- 📈 Historical price storage (24h)

## Installation
```bash
forge install && forge build && forge test
```

## Chainlink Feeds on Base
| Pair | Address |
|------|---------|
| ETH/USD | `0x71041dddad3595F9CEd3dCCFBe3D1F4b0a16Bb70` |
| BTC/USD | `0xCCADC697c55bbB68dc5bCdf8d3CBe83CdD4E071E` |
| USDC/USD | `0x7e860098F58bBFC8648a4311b374B1D669a2bc9b` |

## License
MIT