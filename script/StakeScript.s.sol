// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {BoosterGold} from "../src/booster/BoosterGold.sol";
import {BoosterBronze} from "../src/booster/BoosterBronze.sol";
import {BoosterDiamond} from "../src/booster/BoosterDiamond.sol";
import {BoosterTranscendence} from "../src/booster/BoosterTranscendence.sol";
import {BoosterSingularity} from "../src/booster/BoosterSingularity.sol";

//forge script StakeScript --broadcast --rpc-url $RPC_URL --verify --etherscan-api-key $ETHERSCAN_API --private-key $PRIVATE_KEY
contract StakeScript is Script {
    address sophToken = 0x73fBD93bFDa83B111DdC092aa3a4ca77fD30d380; // = address(0x1); TODO: replace with actual address
    string uriSingularity3 =
        "https://bafybeiapjqljlvbypsz7pnch2r4pbcgkwirpq4xygogmlcozw47overw3q.ipfs.nftstorage.link/13.json";
    string uriSingularity6 =
        "https://bafybeiapjqljlvbypsz7pnch2r4pbcgkwirpq4xygogmlcozw47overw3q.ipfs.nftstorage.link/14.json";
    string uriSingularity12 =
        "https://bafybeiapjqljlvbypsz7pnch2r4pbcgkwirpq4xygogmlcozw47overw3q.ipfs.nftstorage.link/15.json";
    string uriTranscendence3 =
        "https://bafybeiapjqljlvbypsz7pnch2r4pbcgkwirpq4xygogmlcozw47overw3q.ipfs.nftstorage.link/10.json";
    string uriTranscendence6 =
        "https://bafybeiapjqljlvbypsz7pnch2r4pbcgkwirpq4xygogmlcozw47overw3q.ipfs.nftstorage.link/11.json";
    string uriTranscendence12 =
        "https://bafybeiapjqljlvbypsz7pnch2r4pbcgkwirpq4xygogmlcozw47overw3q.ipfs.nftstorage.link/12.json";
    string uriDiamond3 =
        "https://bafybeiapjqljlvbypsz7pnch2r4pbcgkwirpq4xygogmlcozw47overw3q.ipfs.nftstorage.link/7.json";
    string uriDiamond6 =
        "https://bafybeiapjqljlvbypsz7pnch2r4pbcgkwirpq4xygogmlcozw47overw3q.ipfs.nftstorage.link/8.json";
    string uriDiamond12 =
        "https://bafybeiapjqljlvbypsz7pnch2r4pbcgkwirpq4xygogmlcozw47overw3q.ipfs.nftstorage.link/9.json";
    string uriGold3 = "https://bafybeiapjqljlvbypsz7pnch2r4pbcgkwirpq4xygogmlcozw47overw3q.ipfs.nftstorage.link/4.json";
    string uriGold6 = "https://bafybeiapjqljlvbypsz7pnch2r4pbcgkwirpq4xygogmlcozw47overw3q.ipfs.nftstorage.link/5.json";
    string uriGold12 = "https://bafybeiapjqljlvbypsz7pnch2r4pbcgkwirpq4xygogmlcozw47overw3q.ipfs.nftstorage.link/6.json";
    string uriBronze3 =
        "https://bafybeiapjqljlvbypsz7pnch2r4pbcgkwirpq4xygogmlcozw47overw3q.ipfs.nftstorage.link/1.json";
    string uriBronze6 =
        "https://bafybeiapjqljlvbypsz7pnch2r4pbcgkwirpq4xygogmlcozw47overw3q.ipfs.nftstorage.link/2.json";
    string uriBronze12 =
        "https://bafybeiapjqljlvbypsz7pnch2r4pbcgkwirpq4xygogmlcozw47overw3q.ipfs.nftstorage.link/3.json";
    address owner = 0x508aF7D60430DD2ef94E289206b5008902A3ec3f;

    function run()
        public
        returns (
            BoosterBronze boosterBronze,
            BoosterGold boosterGold,
            BoosterDiamond boosterDiamond,
            BoosterTranscendence boosterTranscendence,
            BoosterSingularity boosterSingularity
        )
    {
        vm.startBroadcast();

        boosterBronze = new BoosterBronze(sophToken, uriBronze3, uriBronze6, uriBronze12, owner);
        boosterGold = new BoosterGold(sophToken, uriGold3, uriGold6, uriGold12, owner);
        boosterDiamond = new BoosterDiamond(sophToken, uriDiamond3, uriDiamond6, uriDiamond12, owner);
        boosterTranscendence =
            new BoosterTranscendence(sophToken, uriTranscendence3, uriTranscendence6, uriTranscendence12, owner);
        boosterSingularity =
            new BoosterSingularity(sophToken, uriSingularity3, uriSingularity6, uriSingularity12, owner);

        vm.stopBroadcast();
    }
}
