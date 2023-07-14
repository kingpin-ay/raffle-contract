// SPDX-License-Identifier : MIT

pragma solidity ^0.8.18;

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

/**
 * @title a sample Raffle contract
 * @author kingpin-ay
 * @notice this contract is for creating a sample contract
 * @dev Implements Chainlink VRF V2
 */

contract Raffle is VRFConsumerBaseV2 {
    error Raffle_NotEnoughEth();
    error Raffle_TransferUnsuccessful();
    error Raffle_NotOpen();
    error Raffle__UpkeepNotNeeded(
        uint256 currentBalance,
        uint256 numPlayers,
        uint256 raffleState
    );
    enum RaffleState {
        OPEN,
        CALCULATING
    }

    uint16 private constant REQUEST_CONFORMATION = 3;
    uint32 private constant NUM_WORD = 1;

    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    bytes32 private immutable i_gasLane;
    VRFCoordinatorV2Interface private immutable i_vrfCordinator;

    address payable[] private s_players;
    address private s_recent_winner;
    uint256 private s_lastTimeStamp;
    RaffleState private s_RaffleState;

    /** Events */
    event EnteredRaffe(address indexed player);
    event PickedWinner(address indexed winner);

    constructor(
        uint256 entranceFee,
        uint256 intervals,
        address vrfCordinator,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2(vrfCordinator) {
        i_entranceFee = entranceFee;
        i_interval = intervals;
        i_vrfCordinator = VRFCoordinatorV2Interface(vrfCordinator);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        s_RaffleState = RaffleState.OPEN;
        i_callbackGasLimit = callbackGasLimit;
    }

    /** Original Functionalities */
    function enterRaffle() public payable {
        if (msg.value < i_entranceFee) revert Raffle_NotEnoughEth();
        if (s_RaffleState != RaffleState.OPEN) revert Raffle_NotOpen();
        s_players.push(payable(msg.sender));
        emit EnteredRaffe(msg.sender);
    }



    function checkUpkeep(
        bytes memory /* checkData */
    )
        public
        view
        returns (bool upkeepNeeded, bytes memory /* performData */)
    {
        bool isOpen = RaffleState.OPEN == s_RaffleState;
        bool timePassed = ((block.timestamp - s_lastTimeStamp) > i_interval);
        bool hasPlayers = s_players.length > 0;
        bool hasBalance = address(this).balance > 0;
        upkeepNeeded = (timePassed && isOpen && hasBalance && hasPlayers);
        return (upkeepNeeded, "0x0"); // can we comment this out?
    }


    function pickWinner() external {
        (bool upkeepNeeded, ) = checkUpkeep("");
        // require(upkeepNeeded, "Upkeep not needed");
        if (!upkeepNeeded) {
            revert Raffle__UpkeepNotNeeded(
                address(this).balance,
                s_players.length,
                uint256(s_RaffleState)
            );
        }
        s_RaffleState = RaffleState.CALCULATING;
        i_vrfCordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFORMATION,
            i_callbackGasLimit,
            NUM_WORD
        );
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        uint256 winnerIndex = _randomWords[0] % s_players.length;
        address payable winner = s_players[winnerIndex];
        s_recent_winner = winner;
        s_RaffleState = RaffleState.OPEN;

        s_players = new address payable[](0);
        s_lastTimeStamp = block.timestamp;

        (bool success , ) = s_recent_winner.call{value: address(this).balance}("");
        if(!success) revert Raffle_TransferUnsuccessful();
        
        emit PickedWinner(winner);

    }

    /** Getter Functions for private variables */
    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
    function getRaffleState() external view returns (RaffleState) {
        return s_RaffleState;
    }
    function getPlayerLength() external view returns (uint256) {
        return s_players.length;
    }
    function getPlayerData(uint256 playerIndex) external view returns (address) {
        return s_players[playerIndex];
    }
}
