// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {testStakeBooster} from "../src/testStakeBooster.sol";

//forge script testStakeScript --broadcast --rpc-url $RPC_URL --verify --etherscan-api-key $ETHERSCAN_API --private-key $PRIVATE_KEY
//forge verify-contract 0x620B03474D3562678c0F28AC63fd273A89df8CdB testStakeBooster --chain-id 11155111 --etherscan-api-key $ETHERSCAN_API --constructor-args $(cast abi-encode "constructor(address,uint256,string,string,string)" 0x913b55d1ad953B9D7fe2f78Ff844ADDd74CEeF3f 1000000000000000000 bronzURI3 bronzURI6 bronzURI12)
contract testStakeScript is Script {
    address sophToken = 0x913b55d1ad953B9D7fe2f78Ff844ADDd74CEeF3f; // = address(0x1); TODO: replace with actual address
    string uriBronze3 = "bronzURI3";
    string uriBronze6 = "bronzURI6";
    string uriBronze12 = "bronzURI12";
    address owner = 0x508aF7D60430DD2ef94E289206b5008902A3ec3f;

    function run() public returns (testStakeBooster boosterBronze) {
        vm.startBroadcast();

        boosterBronze = new testStakeBooster(sophToken, 1 ether, uriBronze3, uriBronze6, uriBronze12);

        vm.stopBroadcast();
    }
}
