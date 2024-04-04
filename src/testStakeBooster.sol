// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";

contract testStakeBooster is ERC1155, ReentrancyGuard, Pausable {
    //address of soph token
    address public soph;
    uint256 public minimumAmount;
    string public uri3;
    string public uri6;
    string public uri12;
    uint256 public stakeTime5 = 5 minutes;
    uint256 public stakeTime10 = 10 minutes;
    uint256 public stakeTime15 = 15 minutes;

    //mapping of address to stake time
    mapping(address => uint256 time) public wallet_stakeEndTimer;
    mapping(address => uint256 stakeTimeType) public wallet_stakeTimeType;

    //events
    event Staked(address indexed user, uint256 stakeType);
    event Upgraded(address indexed user, uint256 stakeType);
    event Unstaked(address indexed user, uint256 stakeType);

    //constructor that takes soph token address as argument
    constructor(address _soph, uint256 _minimumAmount, string memory _uri3, string memory _uri6, string memory _uri12)
        ERC1155("")
    {
        require(_soph != address(0), "Invalid address");

        //set soph token address
        soph = _soph;
        minimumAmount = _minimumAmount;

        //set uris
        uri3 = _uri3;
        uri6 = _uri6;
        uri12 = _uri12;
    }

    ///@notice function to stake soph tokens, either for 90, 180 or 15 minutes
    function stake(uint256 _timeType) external nonReentrant whenNotPaused {
        //require _timeType to be 90, 180 or 15 minutes
        require(_timeType == 5 minutes || _timeType == 10 minutes || _timeType == 15 minutes, "Invalid time type"); //3 months, 6 months, 12 months
        console.log("stake type: %s", _timeType);

        //if stake type is 5 minutes , then mint id = 3
        //if stake type is 10 minutes , then mint id = 6
        //if stake type is 15 minutes , then mint id = 12
        uint256 mint_id;
        if (_timeType == 5 minutes) mint_id = 3;
        else if (_timeType == 10 minutes) mint_id = 6;
        else if (_timeType == 15 minutes) mint_id = 12;

        uint256 _amount = minimumAmount;
        address _wallet = msg.sender;

        //require user does not have nft with id = _timeType
        require(balanceOf(_wallet, mint_id) == 0, "You already have a stake badge of this type");

        //require user does not have a stake
        uint256 current_stakeTimeType = wallet_stakeTimeType[_wallet];
        if (current_stakeTimeType > 0) {
            revert("You already have a stake, you should unstake or upgrade it");
        }

        //set the sender's stake time
        wallet_stakeEndTimer[_wallet] = block.timestamp + _timeType;
        wallet_stakeTimeType[_wallet] = _timeType;

        //transfer soph tokens from sender to this contract
        require(IERC20(soph).transferFrom(_wallet, address(this), _amount), "Transfer failed");

        emit Staked(_wallet, _timeType);
    }

    ///@notice function to unstake soph tokens if the sender already has a stake and the stake has matured, then mint a soulbound nft
    function unstake(address _receiver) external nonReentrant {
        address _wallet = msg.sender;
        //require user has a stake
        require(wallet_stakeEndTimer[_wallet] > 0, "You have no stake");
        //require that the sender's stake has matured
        require(block.timestamp >= wallet_stakeEndTimer[_wallet], "Your stake has not matured yet");

        //if stake type is 5 minutes , then mint id = 3
        //if stake type is 10 minutes , then mint id = 6
        //if stake type is 15 minutes , then mint id = 12
        uint256 mint_id;
        uint256 _timeType = wallet_stakeTimeType[_wallet];
        if (_timeType == 5 minutes) mint_id = 3;
        else if (_timeType == 10 minutes) mint_id = 6;
        else if (_timeType == 15 minutes) mint_id = 12;

        //reset the user's stake time
        wallet_stakeEndTimer[_wallet] = 0;
        //reset the user's stake type
        wallet_stakeTimeType[_wallet] = 0;

        uint256 amount = minimumAmount;

        //transfer the sender's stake back to the sender
        require(IERC20(soph).transfer(_receiver, amount), "Transfer failed");

        //mint soulbound nft
        _mint(_receiver, mint_id, amount, "");

        emit Unstaked(_wallet, mint_id);
    }

    ///@notice add time to the sender's stake and changing the stake type
    function upgradeStake(uint256 _timeType) external nonReentrant whenNotPaused {
        address _wallet = msg.sender;
        uint256 current_stakeTimeType = wallet_stakeTimeType[_wallet];
        require(current_stakeTimeType > 0, "You have no stake to upgrade");

        //require _timeType to be 180 or 15 minutes
        require(_timeType == 10 minutes || _timeType == 15 minutes, "Invalid time type"); //6 months, 12 months

        require(_timeType > current_stakeTimeType, "You can only upgrade to a longer stake time");

        //increase the sender's stake time
        wallet_stakeEndTimer[_wallet] += _timeType - current_stakeTimeType;
        wallet_stakeTimeType[_wallet] = _timeType;
    }

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /// override transfer functions to only allow this contract to call them
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 id, uint256 value, bytes memory data) public override {
        revert("This function is not allowed");
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) public override {
        revert("This function is not allowed");
    }

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /// override uri function to return the id with uri for all token types
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     * @param _id The ID of the token
     * @notice _id must be 3, 6 or 12 as these are the only valid ids
     */
    function uri(uint256 _id) public view override returns (string memory) {
        if (_id == 3) return uri3;
        else if (_id == 6) return uri6;
        else if (_id == 12) return uri12;
        else return "";
    }
}
