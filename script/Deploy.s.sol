// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {CrowdFund, ThankYouNFT} from "../src/CrowdFund.sol";

contract Deploy is Script {
    function run() external returns (CrowdFund, ThankYouNFT) {
        vm.startBroadcast();
        ThankYouNFT nft = new ThankYouNFT();
        CrowdFund fund = new CrowdFund(5 ether, 30 days, address(nft));
        vm.stopBroadcast();
        return (fund, nft);
    }
}