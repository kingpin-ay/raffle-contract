// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2Mock} from 'chainlink-brownie-contracts/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol';

contract HelperConfig is Script {
    struct NetworkConfig {
        uint256 entranceFee;
        uint256 interval;
        address vrfCordinator;
        bytes32 gasLane;
        uint64 subscriptionId;
        uint32 callbackGasLimit;
    }

    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155111)
            activeNetworkConfig = getSepoliaNetworkConfig();
        else activeNetworkConfig = getOrCreateAnvilNetworkConfig();
    }

    function getSepoliaNetworkConfig() public pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                entranceFee: 0.1 ether,
                interval: 30,
                vrfCordinator: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
                gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
                subscriptionId: 0,
                callbackGasLimit: 500000
            });
    }

    function getOrCreateAnvilNetworkConfig()
        public
        returns (NetworkConfig memory)
    {
        if(activeNetworkConfig.vrfCordinator != address(0)) return activeNetworkConfig;
        
        uint96 basefee = 0.25 ether; // 250000000000000000
        uint96 gasPriceLink = 1e9; // 1 gwei
        vm.startBroadcast();
        VRFCoordinatorV2Mock vrfCordinator = new VRFCoordinatorV2Mock(basefee , gasPriceLink);
        vm.stopBroadcast();

        return
            NetworkConfig({
                entranceFee: 0.1 ether,
                interval: 30,
                vrfCordinator: address(vrfCordinator),
                gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
                subscriptionId: 0,
                callbackGasLimit: 500000
            });
    }
}
