// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./Helper.t.sol";

contract upgradeStakeTest is Helper {
    uint256 userStake = 1000 ether;

    function setUp() public {
        _setUp();
    }

    function test_upgradeStake_3_to_6() public {
        vm.startPrank(user);
        //approve & stake
        token.approve(address(stakeBooster), userStake);
        stakeBooster.stake(three_months);
        vm.stopPrank();

        vm.warp(block.timestamp + three_months);

        //upgrade stake
        vm.startPrank(user);
        stakeBooster.upgradeStake(six_months);
        vm.stopPrank();

        assertEq(stakeBooster.wallet_stakeEndTimer(user), block.timestamp + three_months);
        assertEq(stakeBooster.wallet_stakeTimeType(user), six_months);
    }

    function test_upgradeStake_3_to_12() public {
        vm.startPrank(user);
        //approve & stake
        token.approve(address(stakeBooster), userStake);
        stakeBooster.stake(three_months);
        vm.stopPrank();

        vm.warp(block.timestamp + 10 days);

        //upgrade stake
        vm.startPrank(user);
        stakeBooster.upgradeStake(twelve_months);
        vm.stopPrank();

        assertEq(stakeBooster.wallet_stakeEndTimer(user), block.timestamp + twelve_months - 10 days);
        assertEq(stakeBooster.wallet_stakeTimeType(user), twelve_months);
    }

    function test_upgradeStake_6_to_12() public {
        vm.startPrank(user);
        //approve & stake
        token.approve(address(stakeBooster), userStake);
        stakeBooster.stake(six_months);
        vm.stopPrank();

        vm.warp(block.timestamp + 30 days);

        //upgrade stake
        vm.startPrank(user);
        stakeBooster.upgradeStake(twelve_months);
        vm.stopPrank();

        assertEq(stakeBooster.wallet_stakeEndTimer(user), block.timestamp + twelve_months - 30 days);
        assertEq(stakeBooster.wallet_stakeTimeType(user), twelve_months);
    }

    function test_upgradeRevert_12_to_6() public {
        vm.startPrank(user);
        //approve & stake
        token.approve(address(stakeBooster), userStake);
        stakeBooster.stake(twelve_months);
        vm.stopPrank();

        vm.warp(block.timestamp + 10 days);

        //upgrade stake
        vm.startPrank(user);
        vm.expectRevert("You can only upgrade to a longer stake time");
        stakeBooster.upgradeStake(six_months);
        vm.stopPrank();

        assertEq(stakeBooster.wallet_stakeEndTimer(user), block.timestamp + twelve_months - 10 days);
        assertEq(stakeBooster.wallet_stakeTimeType(user), twelve_months);
    }

    function test_upgradeRevert_no_stake() public {
        vm.startPrank(address(2));
        vm.expectRevert("You have no stake to upgrade");
        stakeBooster.upgradeStake(six_months);
        vm.stopPrank();
    }

    function test_upgradeRevert_invalid_time() public {
        vm.startPrank(user);
        //approve & stake
        token.approve(address(stakeBooster), userStake);
        stakeBooster.stake(three_months);
        vm.stopPrank();

        vm.warp(block.timestamp + three_months);

        //upgrade stake
        vm.startPrank(user);
        vm.expectRevert("Invalid time type");
        stakeBooster.upgradeStake(90 days);
        vm.stopPrank();
    }

    function test_upgrade_pause() public {
        vm.startPrank(user);
        //approve & stake
        token.approve(address(stakeBooster), userStake);
        stakeBooster.stake(three_months);
        vm.stopPrank();

        vm.warp(block.timestamp + three_months);

        //pause
        vm.startPrank(owner);
        stakeBooster.pause();
        vm.stopPrank();

        //upgrade stake
        vm.startPrank(user);
        vm.expectRevert(abi.encodeWithSelector(Pausable.EnforcedPause.selector));
        stakeBooster.upgradeStake(six_months);
        vm.stopPrank();
    }

    function test_upgrade_unpause() public {
        vm.startPrank(user);
        //approve & stake
        token.approve(address(stakeBooster), userStake);
        stakeBooster.stake(three_months);
        vm.stopPrank();

        //pause
        vm.startPrank(owner);
        stakeBooster.pause();
        stakeBooster.unpause();
        vm.stopPrank();

        //upgrade stake
        vm.startPrank(user);
        stakeBooster.upgradeStake(six_months);
        vm.stopPrank();

        assertEq(stakeBooster.wallet_stakeEndTimer(user), block.timestamp + six_months, "stake end timer");
        assertEq(stakeBooster.wallet_stakeTimeType(user), six_months, "stake time type");
    }
}
