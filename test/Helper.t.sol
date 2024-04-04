// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {StakeBooster, Pausable} from "../src/StakeBooster.sol";

import {MockERC20} from "./MockERC20.sol";

contract Helper is Test {
    StakeBooster stakeBooster;
    address user = address(0x1);
    uint256 three_months = 90 days;
    uint256 six_months = 180 days;
    uint256 twelve_months = 360 days;
    MockERC20 token;
    address owner = 0x508aF7D60430DD2ef94E289206b5008902A3ec3f;

    function _setUp() public {
        token = new MockERC20("SOPH", "SOPH");
        token.mint(user, 1000 ether);
        stakeBooster = new StakeBooster(address(token), 1000 ether, "testURI3", "testURI6", "testURI12", owner);
    }
}
