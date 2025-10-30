// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title VibeCoding - A simple concentration challenge on blockchain
/// @author ...
/// @notice Beginner-friendly Solidity example
contract VibeCoding {
    address public owner;
    uint256 public entryFee = 0.01 ether; // cost to play
    uint256 public rewardPool; // total ETH collected
    uint256 public challengeId;

    struct Challenge {
        address player;
        bool completed;
        uint256 startTime;
        uint256 endTime;
        uint256 reward;
    }

    mapping(uint256 => Challenge) public challenges;

    event ChallengeStarted(uint256 challengeId, address indexed player);
    event ChallengeCompleted(uint256 challengeId, address indexed player, bool success, uint256 reward);

    constructor() {
        owner = msg.sender;
    }

    /// @notice Player starts a concentration challenge
    function startChallenge() external payable {
        require(msg.value == entryFee, "Must pay exact entry fee");

        challengeId++;
        rewardPool += msg.value;

        challenges[challengeId] = Challenge({
            player: msg.sender,
            completed: false,
            startTime: block.timestamp,
            endTime: 0,
            reward: 0
        });

        emit ChallengeStarted(challengeId, msg.sender);
    }

    /// @notice Player completes the challenge (simulated for now)
    /// @dev In a real version, this would be based on verifiable logic or an oracle
    function completeChallenge(uint256 _id, bool success) external {
        Challenge storage challenge = challenges[_id];
        require(challenge.player == msg.sender, "Not your challenge");
        require(!challenge.completed, "Already completed");

        challenge.completed = true;
        challenge.endTime = block.timestamp;

        if (success) {
            uint256 reward = entryFee * 2;
            require(rewardPool >= reward, "Not enough funds");
            challenge.reward = reward;
            rewardPool -= reward;
            payable(msg.sender).transfer(reward);
        }

        emit ChallengeCompleted(_id, msg.sender, success, challenge.reward);
    }

    /// @notice Owner can withdraw remaining funds
    function withdraw() external {
        require(msg.sender == owner, "Only owner");
        payable(owner).transfer(address(this).balance);
    }

    /// @notice Check contract balance
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}

