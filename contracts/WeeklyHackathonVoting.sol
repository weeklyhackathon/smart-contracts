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
    
    event VoteCast(
        address indexed voter,
        uint256 indexed week,
        uint256 totalAllocation
    );

    // Mapping: week => projectId => voteCount
    mapping(uint256 => mapping(uint256 => uint256)) public votes;
    // Mapping: week => voter => hasVoted
    mapping(uint256 => mapping(address => bool)) public hasVoted;
    // Mapping: week => voteDuration
    mapping(uint256 => uint256) public votingDuration;

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
        require(_newHackathonContract != address(hackathonContract), "Same addresst");
        hackathonContract = IWeeklyHackathon(_newHackathonContract);
    }

    function setSigner(address _newSigner) external onlyOwner {
        require(_newSigner != address(0), "Invalid signer");
        require(_newSigner != signer, "Signer same");
        require(_newSigner.code.length == 0, "Signer not wallet");
        signer = _newSigner;
    }

    function vote(
        uint256 week,
        uint256[] calldata allocations, // ALWAYS in descending order
        uint256[] calldata projects,
        bytes calldata signature
    ) external {
        require(isVotingOpen(week), "Voting closed");
        require(!hasVoted[week][msg.sender], "Already voted");
        require(VotingLib.verifyVote(week, msg.sender, allocations, signature, signer), "Invalid vote");
        require(projects.length == allocations.length, "Invalid arrs");

        hasVoted[week][msg.sender] = true;
        
        uint256 totalAllocation;
        for (uint256 i = 0; i < projects.length;) {
            require(hackathonContract.projects(projects[i]).weekNumber == week, "Invalid project week");
            votes[week][projects[i]] += allocations[i];
            totalAllocation += allocations[i];
            unchecked { i++; }
        }

        emit VoteCast(msg.sender, week, totalAllocation);
    }

    function setVotingDuration(
        uint256 week,
        uint64 startTime,
        uint64 endTime
    ) external onlyOwner {
        require(endTime > startTime, "Invalid range");
        
        // Pack the times into a single uint256
        // startTime takes the first 64 bits, endTime takes the next 64 bits
        uint256 packed = (uint256(endTime) << 64) | uint256(startTime);
        votingDuration[week] = packed;
    }

    /**
     * @dev Checks if voting is currently active for the given week
     * @param week The week number to check
     * @return bool True if voting is active, false otherwise
     */
    function isVotingOpen(uint256 week) public view returns (bool) {
        uint256 packed = votingDuration[week];
        uint256 startTime = uint256(uint64(packed));
        uint256 endTime = uint256(uint64(packed >> 64));
        
        return (block.timestamp >= startTime && block.timestamp <= endTime);
    }
}
