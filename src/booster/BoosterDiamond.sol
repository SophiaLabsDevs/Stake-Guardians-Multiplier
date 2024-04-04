// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {StakeBooster} from "../StakeBooster.sol";

contract BoosterDiamond is StakeBooster {
    constructor(address _soph, string memory _uri3, string memory _uri6, string memory _uri12, address _owner)
        StakeBooster(_soph, 10000 ether, _uri3, _uri6, _uri12, _owner)
    {}
}
