// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

struct Project {
    string projectName;
    string projectDescription;
    address owner;
    uint256 weekNumber;
    bool isActive;
    string repoUrl;
}

/**
 * @title IWeeklyHackathon
 * @dev Interface for the WeeklyHackathon contract
 */
interface IWeeklyHackathon {
  function projects(uint256 projectId) external view returns (Project memory);
}
