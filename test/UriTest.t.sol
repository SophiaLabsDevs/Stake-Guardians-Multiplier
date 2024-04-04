// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {StakeBooster} from "../src/StakeBooster.sol";
import {MockERC20, Helper} from "./Helper.t.sol";

contract UriTest is Helper {
    function setUp() public {
        _setUp();
    }

    function test_uri() public {
        assertEq(stakeBooster.uri(3), "testURI3");
        assertEq(stakeBooster.uri(6), "testURI6");
        assertEq(stakeBooster.uri(12), "testURI12");
        assertEq(stakeBooster.uri(0), "");
    }

    function test_set_uris() public {
        vm.prank(owner);
        stakeBooster.setURIs("newURI3", "newURI6", "newURI12");
        assertEq(stakeBooster.uri(3), "newURI3");
        assertEq(stakeBooster.uri(6), "newURI6");
        assertEq(stakeBooster.uri(12), "newURI12");
        assertEq(stakeBooster.uri(0), "");
    }

    function test_cant_set_uris() public {
        //vm.prank(owner);
        vm.expectRevert("Only owner can call this function");
        stakeBooster.setURIs("newURI3", "newURI6", "newURI12");
        vm.prank(user);
        assertEq(stakeBooster.uri(3), "testURI3");
        assertEq(stakeBooster.uri(6), "testURI6");
        assertEq(stakeBooster.uri(12), "testURI12");
        assertEq(stakeBooster.uri(0), "");
    }
}
