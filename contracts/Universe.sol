// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Roles.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";

contract Universe is Ownable {
    using Roles for Roles.Role;
    // Basic structure of Project, we will first define here mostly who can acess/ modify the project
    // Other elements of project TBD
    struct Project {
        uint256 projectId;
        Roles.Role readyOnlyAccess;
        Roles.Role fullAccess;
    }

    uint256 projectIdCounter;

    mapping(uint256 => Project) public projects;

    // Events

    event ProjectCreated(uint256 projectId, address[] readyOnlyAccess);
    event ProjectDeleted(uint256 projectId);

    //TBD if everyone can create a Project, if it costs something and if you mint something when you create it
    //TBD when we define more elements of the project structure we will need to make new arguments in create function
    function createProject(
        address[] memory readOnlyAccess,
        address[] memory fullAccess
    ) external {
        uint256 projectId = projectId++;

        Project storage newProject = projects[projectId];

        //Starting addresses that can access/modify the project
        for (uint256 i = 0; i < readOnlyAccess.length; ++i) {
            newProject.readOnlyAccess.add(readOnlyAccess[i]);
        }

        for (uint256 i = 0; i < fullAccess.length; ++i) {
            newProject.fullAccess.add(fullAccess[i]);
        }

        //The sender address that creates the project has full control of the project
        newProject.fullAccess.add(msg.sender);

        emit ProjectCreated(projectId, readOnlyAccess, fullAccess);
    }

    function deleteProject(uint256 projectId) onlyFullAccess(projectId) {
        delete projects[projectId];

        emit ProjectDeleted(projectId);
    }

    modifier onlyFullAccess(uint256 projectId) {
        require(
            projects[projectId].fullAccess.has(msg.sender),
            "DOES_NOT_HAVE_FULL_ACCESS_TO_PROJECT"
        );
        _;
    }

    function addFullAccessUser(uint256 projectId, address[] memory newAddress)
        onlyFullAccess(projectId)
    {
        Project storage project = projects[projectId];

        for (uint256 i = 0; i < newAddress.length; ++i) {
            project.fullAccess.add(newAddress[i]);
        }
    }

    function removeFullAccess(uint256 projectId, address[] memory removeAddress)
        onlyFullAccess(projectId)
    {
        Project storage project = projects[projectId];

        for (uint256 i = 0; i < newAddress.length; ++i) {
            project.fullAccess.remove(newAddress[i]);
        }
    }

    function addReadOnlyAccess(uint256 projectId, address[] memory newAddress)
        onlyFullAccess(projectId)
    {
        Project storage project = projects[projectId];

        for (uint256 i = 0; i < newAddress.length; ++i) {
            project.readyOnlyAccess.add(newAddress[i]);
        }
    }

    function removeReadOnlyAccess(
        uint256 projectId,
        address[] memory removeAddress
    ) onlyFullAccess(projectId) {
        Project storage project = projects[projectId];

        for (uint256 i = 0; i < newAddress.length; ++i) {
            project.readyOnlyAccess.remove(newAddress[i]);
        }
    }
}
