// // SPDX-License-Identifier: MIT

// // Have our invariant aka properties

// // What are our invariants?

// // 1. The total supply of DSC should be less than the total value of collateral

// // 2. Getter view functions should never revert <- evergreen invariant

// pragma solidity ^0.8.28;

// import {Test} from "forge-std";
// import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
// import {DSCEngine} from "../../src/DSCEngine.sol";
// import {DeployDSC} from "../../script/DeployDSC.s.sol";
// import {}

// contract
