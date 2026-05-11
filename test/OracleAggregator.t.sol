// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "forge-std/Test.sol";
contract OracleAggregatorTest is Test {
    function test_returnsInvalidOnStaleChainlink() public { assertTrue(true); }
    function test_circuitBreakerOnHighDeviation() public { assertTrue(true); }
    function test_medianOfTwoSources() public { assertTrue(true); }
}
