// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {StakeBooster, Pausable, Ownable} from "../src/StakeBooster.sol";
import {MockERC20, Helper} from "./Helper.t.sol";

contract StakeTest is Helper {
    function setUp() public {
        _setUp();
    }

    function test_stake_3months() public {
        vm.startPrank(user);

        //approve
        token.approve(address(stakeBooster), 1000 ether);
        stakeBooster.stake(three_months);

        vm.stopPrank();

        assertEq(token.balanceOf(address(stakeBooster)), 1000 ether);
        assertEq(token.balanceOf(user), 0);
        assertEq(stakeBooster.wallet_stakeEndTimer(user), block.timestamp + three_months);
    }

    function test_stake_6months() public {
        vm.startPrank(user);

        //approve
        token.approve(address(stakeBooster), 1000 ether);
        stakeBooster.stake(six_months);

        vm.stopPrank();

        assertEq(token.balanceOf(address(stakeBooster)), 1000 ether);
        assertEq(token.balanceOf(user), 0);
        assertEq(stakeBooster.wallet_stakeEndTimer(user), block.timestamp + six_months);
    }

    function test_stake_12months() public {
        vm.startPrank(user);

        //approve
        token.approve(address(stakeBooster), 1000 ether);
        stakeBooster.stake(twelve_months);

        vm.stopPrank();

        assertEq(token.balanceOf(address(stakeBooster)), 1000 ether);
        assertEq(token.balanceOf(user), 0);
        assertEq(stakeBooster.wallet_stakeEndTimer(user), block.timestamp + twelve_months);
    }

    function test_revert_stake_invalid_time() public {
        vm.startPrank(user);

        //approve
        token.approve(address(stakeBooster), 1000 ether);

        vm.expectRevert("Invalid time type");
        stakeBooster.stake(100 days);

        vm.stopPrank();

        assertEq(token.balanceOf(address(stakeBooster)), 0);
        assertEq(token.balanceOf(user), 1000 ether);
        assertEq(stakeBooster.wallet_stakeEndTimer(user), 0);
    }

    function testFail_revert_stake_invalid_amount() public {
        vm.startPrank(user);

        //transfer token to address 0x02 to make the balance not enough
        token.transfer(address(2), 900 ether);

        //approve
        token.approve(address(stakeBooster), 1000 ether);

        //Reason: ERC20InsufficientBalance(0x0000000000000000000000000000000000000001, 100000000000000000000 [1e20]
        stakeBooster.stake(three_months);

        vm.stopPrank();

        assertEq(token.balanceOf(address(stakeBooster)), 0);
        assertEq(token.balanceOf(user), 100 ether);
        assertEq(stakeBooster.wallet_stakeEndTimer(user), 0);
    }

    function test_revert_already_staked() public {
        vm.startPrank(user);

        //approve
        token.approve(address(stakeBooster), 1000 ether);
        stakeBooster.stake(three_months);

        vm.stopPrank();

        vm.startPrank(user);

        //approve
        token.approve(address(stakeBooster), 1000 ether);

        vm.expectRevert("You already have a stake, you should unstake or upgrade it");
        stakeBooster.stake(three_months);

        vm.stopPrank();

        assertEq(token.balanceOf(address(stakeBooster)), 1000 ether);
        assertEq(token.balanceOf(user), 0);
        assertEq(stakeBooster.wallet_stakeEndTimer(user), block.timestamp + three_months);
    }

    function test_pause_stake() public {
        vm.prank(user);
        //approve
        token.approve(address(stakeBooster), 1000 ether);

        vm.prank(owner);
        stakeBooster.pause();

        vm.startPrank(user);
        vm.expectRevert(abi.encodeWithSelector(Pausable.EnforcedPause.selector));
        stakeBooster.stake(three_months);
        vm.stopPrank();

        assertEq(token.balanceOf(address(stakeBooster)), 0);
        assertEq(token.balanceOf(user), 1000 ether);
        assertEq(stakeBooster.wallet_stakeEndTimer(user), 0);
    }

    function test_unpause_stake() public {
        vm.prank(user);
        //approve
        token.approve(address(stakeBooster), 1000 ether);

        vm.startPrank(owner);
        stakeBooster.pause();
        stakeBooster.unpause();
        vm.stopPrank();

        vm.startPrank(user);
        stakeBooster.stake(three_months);

        vm.stopPrank();

        assertEq(token.balanceOf(address(stakeBooster)), 1000 ether);
        assertEq(token.balanceOf(user), 0);
        assertEq(stakeBooster.wallet_stakeEndTimer(user), block.timestamp + three_months);
    }

    function test_cant_pause() public {
        vm.startPrank(user);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, user));
        stakeBooster.pause();
        vm.stopPrank();
    }

    function test_cant_unpause() public {
        vm.startPrank(user);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, user));
        stakeBooster.unpause();
        vm.stopPrank();
    }
}
