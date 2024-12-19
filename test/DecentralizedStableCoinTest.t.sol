// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {DecentralizedStableCoin} from "../src/DecentralizedStableCoin.sol";

contract DecentralizedStableCoinTest is Test {
    DecentralizedStableCoin public decentralizedStableCoin;
    address public mk = address(0x1);
    address public yu = address(0x2);

    function setUp() public {
        vm.prank(mk);
        decentralizedStableCoin = new DecentralizedStableCoin();
    }

    function testMintToken() public {
        // Simulate the minting function being called by 'mk'
        vm.prank(mk);
        decentralizedStableCoin.mint(yu, 1 ether);

        // Get the balance of 'yu' from the token contract
        uint256 balance = decentralizedStableCoin.balanceOf(yu);

        // Assert that the balance of 'yu' is 1 ether
        assertEq(balance, 1 ether, "Balance mismatch after minting");
    }

    function testOnlyOwnerCanMint() public {
        // Ensure `yu` is NOT the owner
        assert(decentralizedStableCoin.owner() != yu);

        // Simulate `yu` attempting to mint
        vm.prank(yu);

        // Expect the revert message from OpenZeppelin's onlyOwner
        vm.expectRevert();
        decentralizedStableCoin.mint(mk, 1 ether);
    }

    // function testOnlyOwnerCanBurn(){

    // }
}
