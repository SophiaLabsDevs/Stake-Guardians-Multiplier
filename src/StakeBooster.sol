// SPDX-License-Identifier: MIT
///@author SophiaVerse
///@title Stake Booster contract for staking soph tokens
///@notice This contract allows users to stake a minimum amount of soph tokens for 90, 180 or 360 days
///@dev This contract is pausable and reentrant guard is used to prevent reentrancy attacks, pausable for emergency situations if needed to stop staking
///@dev This contract uses ERC1155 to mint soulbound nfts for users who unstake their soph tokens
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract StakeBooster is ERC1155, ReentrancyGuard, Pausable, Ownable {
    //address of soph token
    address public soph;
    uint256 public minimumAmount;
    string public uri3;
    string public uri6;
    string public uri12;

    //mapping of address to stake time
    mapping(address => uint256 time) public wallet_stakeEndTimer;
    mapping(address => uint256 stakeTimeType) public wallet_stakeTimeType;

    //events
    event Staked(address indexed user, uint256 stakeType);
    event Upgraded(address indexed user, uint256 stakeType);
    event Unstaked(address indexed user, uint256 stakeType);

    ///@notice constructor to set the soph token address and the minimum amount of soph tokens to stake
    ///@param _soph address of soph token
    ///@param _minimumAmount minimum amount of soph tokens to stake
    ///@param _uri3 uri of the nft for 90 days stake
    ///@param _uri6 uri of the nft for 180 days stake
    ///@param _uri12 uri of the nft for 360 days stake
    constructor(
        address _soph,
        uint256 _minimumAmount,
        string memory _uri3,
        string memory _uri6,
        string memory _uri12,
        address _owner
    ) ERC1155("") Ownable(_owner) {
        require(_soph != address(0), "Invalid address");

        //set soph token address
        soph = _soph;
        minimumAmount = _minimumAmount;

        //set uris
        uri3 = _uri3;
        uri6 = _uri6;
        uri12 = _uri12;
    }

    ///@notice function to pause the contract
    ///@dev only the owner can pause the contract
    function pause() external onlyOwner {
        _pause();
    }

    ///@notice function to unpause the contract
    ///@dev only the owner can unpause the contract
    function unpause() external onlyOwner {
        _unpause();
    }

    ///@notice function to stake soph tokens
    ///@param _timeType time type of the stake, either 90, 180 or 360 days
    ///@dev the user must not have a stake already
    ///@dev the user must not have a nft with the same id as the stake type
    ///@dev the user must have the minimum amount of soph tokens to stake
    function stake(uint256 _timeType) external nonReentrant whenNotPaused {
        //require _timeType to be 90, 180 or 360 days
        require(_timeType == 90 days || _timeType == 180 days || _timeType == 360 days, "Invalid time type"); //3 months, 6 months, 12 months

        //if stake type is 90 days , then mint id = 3
        //if stake type is 180 days , then mint id = 6
        //if stake type is 360 days , then mint id = 12
        uint256 mint_id;
        if (_timeType == 90 days) mint_id = 3;
        else if (_timeType == 180 days) mint_id = 6;
        else if (_timeType == 360 days) mint_id = 12;

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
    ///@param _receiver address to receive the unstaked soph tokens
    ///@dev the user must have a stake
    function unstake(address _receiver) external nonReentrant {
        address _wallet = msg.sender;
        //require user has a stake
        require(wallet_stakeEndTimer[_wallet] > 0, "You have no stake");
        //require that the sender's stake has matured
        require(block.timestamp >= wallet_stakeEndTimer[_wallet], "Your stake has not matured yet");

        //if stake type is 90 days , then mint id = 3
        //if stake type is 180 days , then mint id = 6
        //if stake type is 360 days , then mint id = 12
        uint256 mint_id;
        uint256 _timeType = wallet_stakeTimeType[_wallet];
        if (_timeType == 90 days) mint_id = 3;
        else if (_timeType == 180 days) mint_id = 6;
        else if (_timeType == 360 days) mint_id = 12;

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
    ///@param _timeType time type of the stake, either 180 or 360 days
    ///@dev the user must have a stake
    ///@dev the user must upgrade to a longer stake time
    function upgradeStake(uint256 _timeType) external nonReentrant whenNotPaused {
        address _wallet = msg.sender;
        uint256 current_stakeTimeType = wallet_stakeTimeType[_wallet];
        require(current_stakeTimeType > 0, "You have no stake to upgrade");

        //require _timeType to be 180 or 360 days
        require(_timeType == 180 days || _timeType == 360 days, "Invalid time type"); //6 months, 12 months

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

    function setURIs(string memory _uri3, string memory _uri6, string memory _uri12) external onlyOwner {
        uri3 = _uri3;
        uri6 = _uri6;
        uri12 = _uri12;
    }
}
