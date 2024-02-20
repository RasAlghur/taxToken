// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {MyToken} from "../src/MyToken.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract MyTokenScript is Script {
    address LOJAY = makeAddr("lojay");
    address ALICE = makeAddr("alice");
    HelperConfig helperConfig;
    uint256 totalSupply = 10000000;

    function run() external returns (MyToken) {
        vm.deal(LOJAY, 10 ether);
        helperConfig = new HelperConfig();
        (address _router, address _weth) = helperConfig.v2_router();
        console.log(_router);
        console.log(msg.sender);
        console.log(address(this));
        console.log(address(helperConfig));
        // console.log(address(myToken));
        // vm.prank(LOJAY);
        console.log("Here");
        vm.startBroadcast();
        MyToken myToken = new MyToken("TokenX", "TKS",totalSupply, LOJAY, ALICE, _router);
        // MyToken myToken = new MyToken(LOJAY, _router, ALICE, totalSupply);
        vm.stopBroadcast();
        console.log("Here 2");
        return myToken;
    }
}
