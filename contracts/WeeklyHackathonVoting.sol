// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./libraries/VotingLib.sol";
import "./interfaces/IWeeklyHackathon.sol";
/**
 * @title WeeklyHackathonVoting
 * @dev Contract for managing weekly hackathon voting
 */
contract WeeklyHackathonVoting is Ownable {
    IWeeklyHackathon public hackathonContract;
    address public signer;
    
    // Mapping: week => projectId => voteCount
    mapping(uint256 => mapping(uint256 => uint256)) public votes;
    // Mapping: week => voter => hasVoted
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    constructor(
        address _hackathonContract,
        address _signer
    ) Ownable(msg.sender) {
        require(_hackathonContract != address(0), "Invalid hackathon contract address");
        require(_signer != address(0), "Invalid signer address");
        require(_signer.code.length == 0, "Signer must be a wallet");
        hackathonContract = IWeeklyHackathon(_hackathonContract);
        signer = _signer;
    }

    function setHackathonContract(address _newHackathonContract) external onlyOwner {
        require(_newHackathonContract != address(0), "Invalid hackathon contract address");
        require(_newHackathonContract != address(hackathonContract), "Same address as current");
        hackathonContract = IWeeklyHackathon(_newHackathonContract);
    }

    function setSigner(address _newSigner) external onlyOwner {
        require(_newSigner != address(0), "Invalid signer address");
        require(_newSigner != signer, "Same address as current");
        require(_newSigner.code.length == 0, "Signer must be a wallet");
        signer = _newSigner;
    }

    function vote(
        uint256 week,
        uint256[] calldata allocations, // ALWAYS in descending order
        uint256[] calldata projects,
        bytes calldata signature
    ) external {
        require(!hasVoted[week][msg.sender], "Already voted this week");
        require(VotingLib.verifyVote(week, msg.sender, allocations, signature, signer), "Invalid vote");
        require(projects.length == allocations.length, "Invalid arr length");

        hasVoted[week][msg.sender] = true;
        
          for (uint256 i = 0; i < projects.length;) {
              require(hackathonContract.projects(projects[i]).weekNumber == week, "Invalid project week");
              votes[week][projects[i]] += allocations[i];
              unchecked { i++; }
          }
    }
}
