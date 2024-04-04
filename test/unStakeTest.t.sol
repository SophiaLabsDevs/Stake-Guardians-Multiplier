// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./Helper.t.sol";

contract unStakeTest is Helper {
    uint256 timer = three_months;
    uint256 userStake = 1000 ether;
    address module_tested = 0xf2E6A3a2b6823DB8620D9D0F369312A81A678fd5; //module implementation address of account contract

    function setUp() public {
        vm.createSelectFork(vm.envString("RPC_URL"));
        _setUp();
    }

    function _pre_stake() internal {
        vm.startPrank(user);
        //approve & stake
        token.approve(address(stakeBooster), userStake);
        stakeBooster.stake(timer);
        vm.stopPrank();
    }

    function test_unstake() public {
        _pre_stake();

        vm.warp(block.timestamp + timer);

        vm.startPrank(user);
        stakeBooster.unstake(user);
        vm.stopPrank();

        assertEq(token.balanceOf(address(stakeBooster)), 0);
        assertEq(token.balanceOf(user), userStake);
        assertEq(stakeBooster.wallet_stakeEndTimer(user), 0);
        assertEq(stakeBooster.balanceOf(user, 3), userStake, "3 months badge");
        assertEq(stakeBooster.balanceOf(user, 6), 0, "no 6 months badge");
        assertEq(stakeBooster.balanceOf(user, 12), 0, "no 12 months badge");

        //assert nft cant be transfered by safeTransferFrom(address from, address to, uint256 id, uint256 value, bytes memory data)
        vm.expectRevert("This function is not allowed");
        stakeBooster.safeTransferFrom(user, address(0x2), 3, 100, "");

        //assert nft cant be transfered by function safeBatchTransferFrom(address from,address to,uint256[] memory ids,uint256[] memory values,bytes memory data)
        vm.expectRevert("This function is not allowed");
        stakeBooster.safeBatchTransferFrom(user, address(0x2), new uint256[](1), new uint256[](1), "");
    }

    function test_cant_unstake() public {
        _pre_stake();
        vm.warp(block.timestamp + timer - 1);

        vm.startPrank(user);

        vm.expectRevert("Your stake has not matured yet");
        stakeBooster.unstake(user);

        vm.stopPrank();

        assertEq(token.balanceOf(address(stakeBooster)), userStake);
        assertEq(token.balanceOf(user), 0);
        assertEq(stakeBooster.balanceOf(user, 3), 0, "no 3 months badge");
        assertEq(stakeBooster.balanceOf(user, 6), 0, "no 6 months badge");
        assertEq(stakeBooster.balanceOf(user, 12), 0, "no 12 months badge");
    }

    function test_zero_unstake() public {
        _pre_stake();
        vm.startPrank(address(2));

        vm.expectRevert("You have no stake");
        stakeBooster.unstake(address(2));

        vm.stopPrank();
    }

    function test_already_have_nft() public {
        _pre_stake();
        vm.warp(block.timestamp + timer);

        vm.startPrank(user);
        stakeBooster.unstake(user);
        vm.stopPrank();

        vm.startPrank(user);

        vm.expectRevert("You already have a stake badge of this type");
        stakeBooster.stake(timer);

        vm.stopPrank();
    }

    function test_receive_in_module() public {
        _pre_stake();
        vm.warp(block.timestamp + timer);

        vm.startPrank(user);
        stakeBooster.unstake(address(2));
        vm.stopPrank();
    }

    function test_unstake_id6() public {
        vm.startPrank(user);
        //approve & stake
        token.approve(address(stakeBooster), userStake);
        stakeBooster.stake(six_months);
        vm.stopPrank();

        vm.warp(block.timestamp + six_months);

        vm.prank(user);
        stakeBooster.unstake(user);

        assertEq(token.balanceOf(address(stakeBooster)), 0);
        assertEq(token.balanceOf(user), userStake);
        assertEq(stakeBooster.wallet_stakeEndTimer(user), 0);
        assertEq(stakeBooster.balanceOf(user, 3), 0, "no 3 months badge");
        assertEq(stakeBooster.balanceOf(user, 6), userStake, "6 months badge");
        assertEq(stakeBooster.balanceOf(user, 12), 0, "no 12 months badge");
    }

    function test_unstake_id12() public {
        vm.startPrank(user);
        //approve & stake
        token.approve(address(stakeBooster), userStake);
        stakeBooster.stake(twelve_months);
        vm.stopPrank();

        vm.warp(block.timestamp + twelve_months);

        vm.prank(user);
        stakeBooster.unstake(user);

        assertEq(token.balanceOf(address(stakeBooster)), 0);
        assertEq(token.balanceOf(user), userStake);
        assertEq(stakeBooster.wallet_stakeEndTimer(user), 0);
        assertEq(stakeBooster.balanceOf(user, 3), 0, "no 3 months badge");
        assertEq(stakeBooster.balanceOf(user, 6), 0, "no 6 months badge");
        assertEq(stakeBooster.balanceOf(user, 12), userStake, "12 months badge");
    }
}
