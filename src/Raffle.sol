// SPDX-License-Identifier : MIT


pragma solidity ^0.8.18;

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";


/**
 * @title a sample Raffle contract
 * @author kingpin-ay
 * @notice this contract is for creating a sample contract
 * @dev Implements Chainlink VRF V2
 */


contract Raffle {
    error Raffle_NotEnoughEth();

    uint256 private constant REQUEST_CONFORMATION = 3;
    uint256 private constant NUM_WORD = 1;
    
    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    bytes32 private immutable i_gasLane;
    address private immutable i_vrfCordinator;

    address payable [] private s_players;
    uint256 private s_lastTimeStamp;

    /** Events */
    event EnteredRaffe (address indexed player);

    constructor (uint256 entranceFee , uint256 intervals , address vrfCordinator , bytes32 gasLane ,uint64 subscriptionId , uint32 callbackGasLimit){
        i_entranceFee = entranceFee;
        i_interval = intervals;
        i_vrfCordinator = vrfCordinator;
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
    }

    /** Original Functionalities */
    function enterRaffle() public payable {
        if(msg.value < i_entranceFee) revert Raffle_NotEnoughEth();
        s_players.push(payable(msg.sender));
        emit EnteredRaffe(msg.sender);
    }


    function pickWinner() external {
        if((block.timestamp - s_lastTimeStamp) < i_interval) revert();
        uint256 requestId = i_vrfCordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFORMATION,
            i_callbackGasLimit,
            NUM_WORD
        );
    }

    /** Getter Functions for private variables */
    function getEntranceFee () external view returns (uint256){
        return i_entranceFee;
    }
}