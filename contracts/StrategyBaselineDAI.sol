// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "./strategy/StrategyBaseline.sol";

contract StrategyBaselineDAI is StrategyBaseline {
    constructor() public StrategyBaseline(address(0x6B175474E89094C44Da98b954EedeAC495271d0F),address(0xDc03b4900Eff97d997f4B828ae0a45cd48C3b22d)) {
    }
}