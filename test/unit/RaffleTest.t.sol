// SPDX-License-Identifier : MIT


pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {Raffle} from "../../src/Raffle.sol";
import {DeployRaffle} from "../../script/DeployRaffle.s.sol";

contract RuffleTest is Test {

    /** Event */
    event EnteredRaffe(address indexed player);
    
    Raffle raffle ;
    address public user = makeAddr("Ayush");
    address public user2 = makeAddr("Alice");
    uint256 public constant STARTING_BALANCE = 10 ether;
    
    
    
    function setUp() external {
        DeployRaffle dRaffle = new DeployRaffle();
        raffle = dRaffle.run();
        vm.deal(user , STARTING_BALANCE);
        vm.deal(user2 , STARTING_BALANCE);
    }


    function testRaffleContractInitializesWithOpen() public {
        assertEq(uint256(raffle.getRaffleState()), uint256(Raffle.RaffleState.OPEN));
    }


    function testRaffleEnterRaffle() public {
        vm.prank(user);
        raffle.enterRaffle{value: 0.1 ether}();
        assertEq(raffle.getPlayerLength(), 1);
    }
    function testRaffleNotEnoughEntranceFee() public {
        vm.expectRevert();
        vm.prank(user);
        raffle.enterRaffle{value: 0.01 ether}();
    }

    function testRafflePlayersMatched() public {
        vm.prank(user2);
        raffle.enterRaffle{value: 0.1 ether}();
        assertEq(raffle.getPlayerData(0), user2);
    }   
    function testRaffleEmitsWorking() public {
        vm.prank(user2);
        vm.expectEmit(true , false , false , false , address(raffle));
        emit EnteredRaffe(user2);
        raffle.enterRaffle{value: 0.4 ether}();
    }   

}