// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";

contract HelperConfig is Script {
    V2_Router public v2_router;

    struct V2_Router {
        address s_router;
        address s_weth;
    }

    constructor() {
        if (block.chainid == 1) {
            v2_router = getUniswapRouter();
        } else if (block.chainid == 8453) {
            v2_router = getSushiswapRouter();
        }
    }

    function getUniswapRouter() public pure returns (V2_Router memory) {
        V2_Router memory e3reum = V2_Router({
            s_router: 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D,
            s_weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
        });
        return e3reum;
    }

    function getSushiswapRouter() public pure returns (V2_Router memory) {
        V2_Router memory basech = V2_Router({
            s_router: 0x6BDED42c6DA8FBf0d2bA55B2fa120C5e0c8D7891,
            s_weth: 0x4200000000000000000000000000000000000006
        });
        return basech;
    }
}
