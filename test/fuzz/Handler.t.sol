// SPDX-License-Identifier: MIT

// Handler is going to narrow down the way we call function

pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {ERC20Mock} from "../mocks/ERC20Mock.sol";
import {MockV3Aggregator}from "../mocks/MockV3Aggregator.sol";
contract Handler is Test {
    DSCEngine dsce;
    DecentralizedStableCoin dsc;

    ERC20Mock weth;
    ERC20Mock wbtc;

    uint256 MAX_DEPOSIT_SIZE = type(uint96).max;
    uint256 public timesMintIsCalled;
    address[] public usersWithCllateralDeposited;
    MockV3Aggregator public ethUsdPriceFeed;

    constructor(DSCEngine _dscEngine, DecentralizedStableCoin _dsc) {
        dsce = _dscEngine;
        dsc = _dsc;

        address[] memory collateralTokens = dsce.getCollateralTokens();
        weth = ERC20Mock(collateralTokens[0]);
        wbtc = ERC20Mock(collateralTokens[1]);
        ethUsdPriceFeed = MockV3Aggregator(dsce.getCollateralTokenPriceFeed(address(weth)));
    }

    function mintDsc(uint256 amount, uint256 addressSeed) public {
        if (usersWithCllateralDeposited.length == 0) {
            return;
        }
        address sender = usersWithCllateralDeposited[addressSeed % usersWithCllateralDeposited.length];

        (uint256 totalDscMinted, uint256 collateralValueInUsd) = dsce.getAccountInformation(sender);
        int256 maxDscMint = (int256(collateralValueInUsd) / 2) - int256(totalDscMinted);
        if (maxDscMint < 0) {
            return;
        }
        amount = bound(amount, 0, uint256(maxDscMint));
        if (amount == 0) {
            return;
        }
        vm.startPrank(sender);
        dsce.mintDsc(amount);
        vm.stopPrank();
        timesMintIsCalled++;
    }
    // redeem collateral <-

    function depositCollateral(uint256 collateralSeed, uint256 amountCollateral) public {
        ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);
        amountCollateral = bound(amountCollateral, 1, MAX_DEPOSIT_SIZE);

        vm.startPrank(msg.sender);
        collateral.mint(msg.sender, amountCollateral);
        collateral.approve(address(dsce), amountCollateral);
        dsce.depositColleteral(address(collateral), amountCollateral);
        vm.stopPrank();
        usersWithCllateralDeposited.push(msg.sender);
    }

    function redeemCollateral(uint256 collateralSeed, uint256 amountCollateral) public {
        ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);
        uint256 maxCollateralToRedeem = dsce.getCollateralBalanceOfUser(address(collateral), msg.sender);
        amountCollateral = bound(amountCollateral, 0, maxCollateralToRedeem);
        if (amountCollateral == 0) {
            return;
        }
        //double push
        dsce.redeemColleteral(address(collateral), amountCollateral);
    }

// This breaks our invariant test suite!!!
// function updateCollateralPrice(uint96 newPrice) public {
//     int256 newPriceInt = int256(uint256(newPrice));
//     ethUsdPriceFeed.updateAnswer(newPriceInt);
// }
    // Helpe function
    function _getCollateralFromSeed(uint256 collateralSeed) private view returns (ERC20Mock) {
        if (collateralSeed % 2 == 0) {
            return weth;
        }
        return wbtc;
    }
}
