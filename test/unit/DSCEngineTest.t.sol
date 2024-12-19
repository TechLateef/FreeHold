// SPDX-License-Identifier:MIT
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {ERC20Mock} from "../mocks/ERC20Mock.sol";
// import "forge-std/console.sol";

contract DSCEngineTest is Test {
    DSCEngine public dsce;
    DecentralizedStableCoin public dsc;
    HelperConfig public helperConfig;

    address public ethUsdPriceFeed;
    address public btcUsdPriceFeed;
    address public weth;
    address public wbtc;
    uint256 public deployerKey;

    address public USER = makeAddr("user");
    address public LIQUIDATOR = makeAddr('user1');
    uint256 public constant AMOUNT_COLLATERAL = 10 ether;
    uint256 public constant AMOUNT_DSC = 20e18;

    uint256 public constant STARTING_USER_BALANCE = 10 ether;
    uint256 private constant LIQUIDATION_THRESHOLD = 50; //This means you need to be 200% over-collateralzed
    uint256 private constant LIQUIDATION_BONUS = 10; //This means you get assets at 10% discount when liquidating
    uint256 private constant LIQUIDATION_PRECISION = 100;
    uint256 private constant MIN_HEALTH_FACTOR = 1e18;

    function setUp() external {
        DeployDSC deployer = new DeployDSC();
        (dsc, dsce, helperConfig) = deployer.run();
        (ethUsdPriceFeed, btcUsdPriceFeed, weth, wbtc,) = helperConfig.activeNetworkConfig();

        ERC20Mock(weth).mint(USER, STARTING_USER_BALANCE);
    }

    //////////////////////
    // Constructor Tests//
    //////////////////////
    address[] public tokenAddresses;
    address[] public priceFeedAddresses;

    function testRevertIfTokenLengthDoesntMatchPriceFeeds() public {
        tokenAddresses.push(weth);
        priceFeedAddresses.push(ethUsdPriceFeed);
        priceFeedAddresses.push(btcUsdPriceFeed);
        vm.expectRevert(DSCEngine.DSCEngine_TokenAddressesAndPriceFeedAddressesMustBeSameLength.selector);
        new DSCEngine(tokenAddresses, priceFeedAddresses, address(dsc));
    }

    ////////////////
    // Price Tests//
    ////////////////
    function testGetUsdValue() public view {
        uint256 ethAmount = 15e18;
        // 15e18 ETH * $2000/ETH = $30,000e18
        uint256 expectedUsd = 30_000e18;
        uint256 usdValue = dsce.getUsdValue(weth, ethAmount);
        assertEq(usdValue, expectedUsd);
    }

    function testGetTokenAmountFromUsd() public view {
        uint256 usdAmount = 100 ether;
        uint256 expectedWeth = 0.05 ether;
        uint256 actualWeth = dsce.getTokenAmountFromUsd(weth, usdAmount);
        assertEq(expectedWeth, actualWeth);
    }
    ////////////////////////////
    // depositCollateral Tests//
    ////////////////////////////

    function testRevertsIfCollateralZero() public {
        vm.prank(USER);
        ERC20Mock(weth).approve(address(dsc), AMOUNT_COLLATERAL);
        vm.expectRevert(DSCEngine.DSCEngine__NeedsMoreThanZero.selector);
        dsce.depositColleteral(weth, 0);
        vm.stopPrank();
    }

    function testRevertWithUnapprovedCollateral() public {
        ERC20Mock ranToken = new ERC20Mock("RAN", "RAN", USER, AMOUNT_COLLATERAL);
        vm.startPrank(USER);
        vm.expectRevert(DSCEngine.DSCEngine_NotAllowedToken.selector);
        dsce.depositColleteral(address(ranToken), AMOUNT_COLLATERAL);
        vm.stopPrank();
    }

    modifier depositedCollateral() {
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(dsce), AMOUNT_COLLATERAL);
        dsce.depositColleteral(weth, AMOUNT_COLLATERAL);
        vm.stopPrank();
        _;
    }

    function testCanDepositCollateralAndGetAccountInfo() public depositedCollateral {
        (uint256 totalDscMinted, uint256 collateralValueInUsd) = dsce.getAccountInformation(USER);

        uint256 expectedTotalDscMinted = 0;
        uint256 expectedDepositedAmount = dsce.getTokenAmountFromUsd(weth, collateralValueInUsd);
        assertEq(totalDscMinted, expectedTotalDscMinted);
        assertEq(AMOUNT_COLLATERAL, expectedDepositedAmount);
    }

    ////////////////////////////
    // MintDsc Tests//
    ////////////////////////////

    function testMintAtBoundaryHealthFactor() public depositedCollateral {
        vm.startPrank(USER);
        uint256 mintedAmount = 10e18;
        uint256 expectedRemainingCollateral = 10e18;
        dsce.mintDsc(mintedAmount);
        (uint256 totalDscMinted, uint256 collateralValueInUsd) = dsce.getAccountInformation(USER);
        uint256 remainingCollateralAmount = dsce.getTokenAmountFromUsd(weth, collateralValueInUsd);
        assertEq(totalDscMinted, mintedAmount);
        assertEq(remainingCollateralAmount, expectedRemainingCollateral);
        vm.stopPrank();
    }

    function testRevertWithUnderCollaterize() public depositedCollateral {
        vm.startPrank(USER);
        // Attempt to mint DSC that exceeds health factor threshold
        uint256 mintedAmount = 20_000e18;
        vm.expectRevert(abi.encodeWithSelector(DSCEngine.DSCEngine__BreaksHealthFactor.selector, 5e17));
        dsce.mintDsc(mintedAmount);

        vm.stopPrank();
    }


    ////////////////////////////
    // BurnDsc Tests////////////
    ////////////////////////////

    function testBurnDsc() public depositedCollateral {
        vm.startPrank(USER);
        dsce.mintDsc(AMOUNT_DSC);

        // Grant allowance to the DSCEngine contract
        dsc.approve(address(dsce), AMOUNT_DSC);
        dsce.burnDsc(AMOUNT_DSC);
        (uint256 totalDscMinted, ) = dsce.getAccountInformation(USER);
        uint256 expectedBalanceAfterBurn = 0;
        assertEq(totalDscMinted, expectedBalanceAfterBurn );
        vm.stopPrank();
    }


    function testCalculateHealthFactor() public {
        uint256 collateralValueInUsd = 20_000e8;
        uint256 expectedHealthFactor = 0;
        vm.startPrank(USER);
       uint256 healthFactorValue = dsce.calculateHealthFactor(AMOUNT_DSC, collateralValueInUsd);
       assertEq(healthFactorValue, expectedHealthFactor);

    }

    function testGetAccountInfo() public depositedCollateral {

        vm.startPrank(USER);
        uint256 expectedCollateralInUsd = 20_000e18;
        uint256 expectedMintedDsc = 0;
        (uint256 mintDsc, uint256 collateralValueInUsd) = dsce.getAccountInformation(USER);
        assertEq(mintDsc, expectedMintedDsc);
        assertEq(collateralValueInUsd, expectedCollateralInUsd);
    }


    ////////////////////////////
    // liquidate Tests//////////
    ////////////////////////////

function testLiquidateFailsWhenHealthFactorIsOk() public depositedCollateral {
    vm.startPrank(USER);
    uint256 mintedAmount = 50e18;
    dsce.mintDsc(mintedAmount);

    vm.expectRevert(DSCEngine.DSCEngine__HealthFactorOk.selector);
    dsce.liquidate(weth, USER, 10e18);

    vm.stopPrank();
}

//     modifier liquidated() {
//         vm.startPrank(user);
//         ERC20Mock(weth).approve(address(dsce), amountCollateral);
//         dsce.depositCollateralAndMintDsc(weth, amountCollateral, amountToMint);
//         vm.stopPrank();
//         int256 ethUsdUpdatedPrice = 18e8; // 1 ETH = $18

//         MockV3Aggregator(ethUsdPriceFeed).updateAnswer(ethUsdUpdatedPrice);
//         uint256 userHealthFactor = dsce.getHealthFactor(user);

//         ERC20Mock(weth).mint(liquidator, collateralToCover);

//         vm.startPrank(liquidator);
//         ERC20Mock(weth).approve(address(dsce), collateralToCover);
//         dsce.depositCollateralAndMintDsc(weth, collateralToCover, amountToMint);
//         dsc.approve(address(dsce), amountToMint);
//         dsce.liquidate(weth, user, amountToMint); // We are covering their whole debt
//         vm.stopPrank();
//         _;
//     }
//   function testLiquidationPayoutIsCorrect() public liquidated {
//         uint256 liquidatorWethBalance = ERC20Mock(weth).balanceOf(liquidator);
//         uint256 expectedWeth = dsce.getTokenAmountFromUsd(weth, amountToMint)
//             + (dsce.getTokenAmountFromUsd(weth, amountToMint) / dsce.getLiquidationBonus());
//         uint256 hardCodedExpected = 6_111_111_111_111_111_110;
//         assertEq(liquidatorWethBalance, hardCodedExpected);
//         assertEq(liquidatorWethBalance, expectedWeth);
//     }

}
// 500000000000000000
//Todo s
//_getAccountInformation
// _healthFactor
// _getUsdValue
//_calculateHealthFactor
//revertHealthIfFactorIsBroken
//getTokenAmountFromUsd
//getAccountCollateralValue
// calculateHealthFactor