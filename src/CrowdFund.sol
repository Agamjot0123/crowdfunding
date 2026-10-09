// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract ThankYouNFT is ERC721 {
    uint256 public tokenCounter;

    constructor() ERC721("CrowdFund Supporter", "CFS") {}

    function mint(address to) external returns (uint256) {
        uint256 tokenId = tokenCounter;
        _safeMint(to, tokenId);
        tokenCounter++;
        return tokenId;
    }
}

contract CrowdFund is Ownable {
    uint256 public immutable i_goal; // funding goal in wei
    uint256 public immutable i_deadline; // block.timestamp of deadline
    address public immutable i_nft; // ThankYouNFT address
    mapping(address => uint256) public s_amountFunded;

    event Funded(address indexed funder, uint256 amount);
    event Withdrawn(address indexed owner, uint256 amount);
    event Refunded(address indexed funder, uint256 amount);

    error CrowdFund__NotEnoughSent();
    error CrowdFund__GoalReachedOrDeadlineNotPassed();
    error CrowdFund__NothingToRefund();

    constructor(uint256 goal, uint256 duration, address nftAddress) Ownable(msg.sender) {
        i_goal = goal;
        i_deadline = block.timestamp + duration;
        i_nft = nftAddress;
    }

    function fund() external payable {
        if (msg.value == 0) revert CrowdFund__NotEnoughSent();
        s_amountFunded[msg.sender] += msg.value;
        ThankYouNFT(i_nft).mint(msg.sender);
        emit Funded(msg.sender, msg.value);
    }

    function withdraw() external onlyOwner {
        if (address(this).balance < i_goal || block.timestamp < i_deadline) {
            revert CrowdFund__GoalReachedOrDeadlineNotPassed();
        }
        uint256 amount = address(this).balance;
        (bool ok,) = payable(owner()).call{value: amount}("");
        require(ok);
        emit Withdrawn(owner(), amount);
    }

    function refund() external {
        if (block.timestamp < i_deadline || address(this).balance >= i_goal) {
            revert CrowdFund__GoalReachedOrDeadlineNotPassed();
        }
        uint256 amount = s_amountFunded[msg.sender];
        if (amount == 0) revert CrowdFund__NothingToRefund();
        s_amountFunded[msg.sender] = 0;
        (bool ok,) = payable(msg.sender).call{value: amount}("");
        require(ok);
        emit Refunded(msg.sender, amount);
    }

    receive() external payable {
        s_amountFunded[msg.sender] += msg.value;
        emit Funded(msg.sender, msg.value);
    }

    fallback() external payable {
        s_amountFunded[msg.sender] += msg.value;
        emit Funded(msg.sender, msg.value);
    }
}
