// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {MyToken, IERC20, IUniswapV2Router01, IUniswapV2Router02, IUniswapV2Pair} from "../src/MyToken.sol";
import {MyTokenScript} from "../script/MyTokenScript.s.sol";
import {Test, console} from "forge-std/Test.sol";
import {IWETH} from "../src/ExampleSwap.sol";

contract MyTokenTest is Test {
    MyToken myToken;
    MyTokenScript myTokenScript;

    address immutable BOB = makeAddr("bob");
    address immutable USER = makeAddr("user");
    address immutable USER2 = makeAddr("user2");
    address LOJAY = makeAddr("lojay");
    address ALICE = makeAddr("alice");

    address private constant UNISWAP_V2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; //ETH

    // address private constant WETH = payable(0x4200000000000000000000000000000000000006); //BASE
    address private constant WETH = payable(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2); //ETH

    IUniswapV2Router01 private _router01 = IUniswapV2Router01(UNISWAP_V2_ROUTER);
    IUniswapV2Router02 private _router02 = IUniswapV2Router02(UNISWAP_V2_ROUTER);
    IUniswapV2Pair private _pair = IUniswapV2Pair(address(myToken));
    IWETH private wethArtifact = IWETH(WETH);
    IERC20 private wethInterface;

    function setUp() external {
        vm.deal(USER, 10 ether);
        vm.deal(USER2, 10 ether);
        vm.deal(BOB, 10 ether);
        vm.deal(LOJAY, 10 ether);
        vm.deal(ALICE, 10 ether);

        console.log("Here 3");
        myTokenScript = new MyTokenScript();
        console.log("Here 4");
        (myToken) = myTokenScript.run();
        console.log("Here 5");
        // myToken = myTokenA;
    }

    // function testName() public view {
    //     string memory dName = "MyTokenX";
    //    assert(myToken.name() == dName);
    // }

    function testDecimal() public view {
        assert(myToken.decimals() == 9);
    }

    function testName() public {
        string memory name = "TokenX";
        assertEq(myToken.name(), name);
    }

    function testTotalSupply() public {
        uint256 totalSupply = 10000000000000000;
        assertEq(myToken.totalSupply(), totalSupply);
    }

    modifier depositETH() {
        uint256 depositAmt = 10 ether;
        vm.prank(LOJAY);
        wethArtifact.deposit{value: depositAmt}();
        _;
    }

    function addLiquidity() public depositETH {
        address tokenA = WETH;
        address tokenB = address(myToken);
        uint256 amountADesired = 10 ether;
        uint256 amountBDesired = 7000000000000000;
        uint256 amountAMin = 1;
        uint256 amountBMin = 1;
        address to = LOJAY;
        uint256 deadline = block.timestamp + 10 seconds;

        console.log(myToken.balanceOf(USER), "USER balance");
        address owm = myToken.owner();
        console.log(owm, "Contract Owner");
        console.log(myToken.balanceOf(owm), "Contract Owner Balance");

        vm.startPrank(LOJAY);
        IERC20(WETH).approve(UNISWAP_V2_ROUTER, amountADesired);
        console.log(amountADesired, "amountADesired");
        IERC20(myToken).approve(UNISWAP_V2_ROUTER, amountBDesired);
        console.log(amountBDesired, "amountBDesired");
        _router01.addLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin, to, deadline);
        console.log(to, "to");
        vm.stopPrank();

        // 0x037eDa3aDB1198021A9b2e88C22B464fD38db3f3 myToken
        //   0x0000000000000000000000000000000000000000 HelerConfig
        //   0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f ScmyToken
        //  Address i Balance 0x0000000000000000000000000000000000000009
        //   Address i Balance 9965000000000000000
        //   Address this 0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496
        //   Address this Balance 79228162514264337593543950335
        //   Msg Sender 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38
        //   Msg Sender Balance 79228162514533779393543950335
    }

    function attemptBuy() public {
        uint256 amountOutMin = 1;
        address[] memory path = new address[](2);
        path[0] = WETH; // WETH address
        path[1] = address(myToken); // Token address

        address to = BOB;
        uint256 deadline = block.timestamp + 20 seconds;

        // 10 eth = 7,000,000,000,000,000,000 100%
        // 1 eth = 700,000,000,000,000,000 10%
        // 0.1 eth = 70,000,000,000,000,000 1%
        // 0.025 eth = 17,500,000,000,000,000 0.25%
        // 0.02 eth = 14,000,000,000,000,000 0.2%
        // 0.035 eth = 24,500,000,000,000,000 0.4%
        // 0.01 eth = 7,000,000,000,000,000 0.1%
        // 0.005 eth = 3,500,000,000,000,000 0.05%
        // 0.001 eth = 700,000,000,000,000 0.01%

        // vm.expectRevert("UniswapV2: TRANSFER_FAILED");
        vm.prank(BOB);
        _router02.swapExactETHForTokensSupportingFeeOnTransferTokens{value: 0.035 ether}(
            amountOutMin, path, to, deadline
        );
    }

    function attemptSell() public {
        // IERC20(WETH).approve(UNISWAP_V2_ROUTER, 10 ether);
        uint256 balanceOf = myToken.balanceOf(BOB);
        console.log(balanceOf, "balanceOF");

        uint256 amountIn = 10000000000000;
        uint256 amountOutMin = 0;
        address[] memory path = new address[](2);
        path[0] = address(myToken); // Token address
        path[1] = WETH; // WETH address

        address to = BOB;
        uint256 deadline = block.timestamp + 20 seconds;
        vm.startPrank(BOB);
        IERC20(myToken).approve(UNISWAP_V2_ROUTER, balanceOf);
        console.log("Approved BOB");
        _router02.swapExactTokensForETHSupportingFeeOnTransferTokens(amountIn, amountOutMin, path, to, deadline);
        vm.stopPrank();
    }

    function removeLiquidity() public {
        address getPair = myToken.uniswapV2Pair();
        uint256 checkBal = IERC20(getPair).balanceOf(LOJAY);

        address tokenA = WETH;
        address tokenB = address(myToken);
        uint256 liquidity = checkBal;
        uint256 amountAMin = 0;
        uint256 amountBMin = 0;
        address to = LOJAY;
        uint256 deadline = block.timestamp + 20;

        vm.startPrank(LOJAY);
        IERC20(getPair).approve(UNISWAP_V2_ROUTER, checkBal);
        _router01.removeLiquidity(tokenA, tokenB, liquidity, amountAMin, amountBMin, to, deadline);
        vm.stopPrank();
    }

    function testMultipleBuy() public {
        uint160 startingIndex = 1;
        uint160 numbersOfBuyers = 50;

        addLiquidity();
        console.log("Add LP Succeed");
        // console.log("---------------------------------");
        // console.log(address(myToken), "myToken");
        // console.log(address(helperConfig), "HelperConfig");
        // console.log(address(scmyToken), "ScmyToken");
        // console.log("---------------------------------");
        vm.prank(LOJAY);
        myToken.enableTrade();
        console.log("Launched");

        for (uint160 i = startingIndex; i < numbersOfBuyers; i++) {
            hoax(address(i), 10 ether);

            uint256 amountOutMin = 1;
            address[] memory path = new address[](2);
            path[0] = WETH; // WETH address
            path[1] = address(myToken); // Token address

            address to = address(i);
            uint256 deadline = block.timestamp + 20 seconds;

            _router02.swapExactETHForTokensSupportingFeeOnTransferTokens{value: 0.035 ether}(
                amountOutMin, path, to, deadline
            );

            // uint256 eachAddress = myToken.balanceOf(address(i));
            // console.log("Addresses", address(i));
            // console.log("EachAddresses", eachAddress);
        }
        console.log("Buy completed");

        testUpdateFees();
        console.log("Tax Adjusted");

        // attemptBuy();

        // uint256 balanceOf1 = myToken.balanceOf((BOB));
        // uint256 balanceOf1 = myToken.balanceOf((0x0000000000000000000000000000000000000001));
        // console.log(balanceOf1, "balanceOF1");

        // triggerRebase();

        console.log("COmpleted Rebase!!");

        uint256 numbersOfSellers = 10;

        for (uint160 i = startingIndex; i < numbersOfSellers; i++) {
            uint256 balanceOf = myToken.balanceOf(address(i));
            // console.log(balanceOf, "balanceOF");

            uint256 amountIn = 10000000000000;
            uint256 amountOutMin = 0;
            address[] memory path = new address[](2);
            path[0] = address(myToken); // Token address
            path[1] = WETH; // WETH address

            address to = address(i);
            uint256 deadline = block.timestamp + 1 hours;

            vm.startPrank((address(i)));
            IERC20(myToken).approve(UNISWAP_V2_ROUTER, balanceOf);
            // uint256 a;
            // a += 1;
            // console.log("------------------------------------------------------");
            // console.log(a , "a");
            // console.log("Address i Balance", address(i));
            // console.log("Address i Balance", address(i).balance);
            // // console.log("-----------------");
            // console.log("Address this", address(this));
            // console.log("Address this Balance", address(this).balance);
            // // console.log("-----------------");
            // console.log("Msg Sender", address(msg.sender));
            // console.log("Msg Sender Balance", address(msg.sender).balance);
            // console.log("--------------------------------------------------------");
            // console.log("Approved BOB");
            _router02.swapExactTokensForETHSupportingFeeOnTransferTokens(amountIn, amountOutMin, path, to, deadline);
            vm.stopPrank();
        }
        console.log("Sell Completed");
        removeLiquidity();
        console.log("LP REMOVED!!");
    }

    function testUpdateFees() public {
        vm.prank(LOJAY);
        myToken.setFees(3, 3);
    }

    function testUniswapSwapT() public {
        uint256 userWethBal = wethArtifact.balanceOf(USER);
        console.log(userWethBal, "User Weth Bal");

        addLiquidity();
        console.log("Add LP Succeed");
        vm.prank(LOJAY);
        myToken.enableTrade();
        console.log("Launched");

        // uint256 launchTime = block.timestamp + 61;
        attemptBuy();
        console.log("Attempted Buy");
        attemptSell();
        console.log("Attempted Sell");
        // triggerRebase();
        // console.log("Rebase Triggered");
        removeLiquidity();
        console.log("Removed!!");

        // if(block.timestamp > launchTime) {
        // }

        // uint256 amountOutMin = 1;
        // address[] memory path = new address[](2);
        // path[0] = WETH; // WETH address
        // path[1] = address(myToken); // Token address

        // address to = msg.sender;
        // uint256 deadline = block.timestamp + 20 seconds;

        // vm.expectRevert("UniswapV2: TRANSFER_FAILED");
        // _router02.swapExactETHForTokensSupportingFeeOnTransferTokens{value: 1 ether}(amountOutMin, path, to, deadline);
    }

    function testBalanceOf() public view {
        address owner = myToken.owner();
        // console.log(owner);
        uint256 bO = myToken.totalSupply();
        assert(myToken.balanceOf(owner) == bO);
    }

    function testExcludeFromFees() public {
        vm.startPrank(LOJAY);
        myToken.excludeFromFees(address(this), true);
        myToken.transfer(address(this), 10000000000);
        vm.stopPrank();
        // assert(myToken._isExcludedFromFees(USER2) == true);
    }

    function testTransfer() public {
        testExcludeFromFees();
        vm.prank(LOJAY);
        myToken.enableTrade();
        myToken.transfer(USER2, 10000000000);
        assert(myToken.balanceOf(USER2) == 10000000000);
    }
}
