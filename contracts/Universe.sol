// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
import "hardhat/console.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Universe is Ownable, AccessControl {
    // Basic structure of Project, we will first define here mostly who can acess/ modify the project
    // Other elements of project TBD
    struct Project {
        uint256 projectId;
        bytes32 READ_ONLY_ACCESS_ROLE;
        bytes32 FULL_ACCESS_ROLE;
    }

    uint256 public projectIdCounter;

    mapping(uint256 => Project) public projects;

    // Events

    event ProjectCreated(
        uint256 projectId,
        address[] readyOnlyAccess,
        address[] fullAccess
    );
    event ProjectDeleted(uint256 projectId);

    //TBD if everyone can create a Project, if it costs something and if you mint something when you create it
    //TBD when we define more elements of the project structure we will need to make new arguments in create function
    function createProject(
        address[] memory readOnlyAccess,
        address[] memory fullAccess
    ) external {
        uint256 projectId = projectIdCounter++;

        Project storage newProject = projects[projectId];

        // We will concatenate the projectId to have the identifier for this project only

        //Defining role readOnlyAccess role for this project Id

        newProject.READ_ONLY_ACCESS_ROLE = keccak256(
            abi.encodePacked("READ_ONLY_ACCESS_ROLE", toString(projectId))
        );

        //Defining role fullAccess role  for this project Id
        newProject.FULL_ACCESS_ROLE = keccak256(
            abi.encodePacked("READ_ONLY_ACCESS_ROLE", toString(projectId))
        );

        //Starting addresses that can access/modify the project
        for (uint256 i = 0; i < readOnlyAccess.length; ++i) {
            _setupRole(newProject.READ_ONLY_ACCESS_ROLE, readOnlyAccess[i]);
        }

        for (uint256 i = 0; i < fullAccess.length; ++i) {
            _setupRole(newProject.FULL_ACCESS_ROLE, fullAccess[i]);
        }

        //The sender address that creates the project has full control of the project
        _setupRole(newProject.FULL_ACCESS_ROLE, msg.sender);

        emit ProjectCreated(projectId, readOnlyAccess, fullAccess);
    }

    function deleteProject(uint256 projectId)
        external
        onlyRole(projects[projectId].FULL_ACCESS_ROLE)
    {
        delete projects[projectId];

        emit ProjectDeleted(projectId);
    }

    function addFullAccessUser(uint256 projectId, address[] memory newAddress)
        external
        onlyRole(projects[projectId].FULL_ACCESS_ROLE)
    {
        Project storage project = projects[projectId];

        for (uint256 i = 0; i < newAddress.length; ++i) {
            _setupRole(project.FULL_ACCESS_ROLE, newAddress[i]);
        }
    }

    function removeFullAccess(uint256 projectId, address[] memory removeAddress)
        external
        onlyRole(projects[projectId].FULL_ACCESS_ROLE)
    {
        Project storage project = projects[projectId];

        for (uint256 i = 0; i < removeAddress.length; ++i) {
            _revokeRole(project.FULL_ACCESS_ROLE, removeAddress[i]);
        }
    }

    function addReadOnlyAccess(uint256 projectId, address[] memory newAddress)
        external
        onlyRole(projects[projectId].FULL_ACCESS_ROLE)
    {
        Project storage project = projects[projectId];

        for (uint256 i = 0; i < newAddress.length; ++i) {
            _setupRole(project.FULL_ACCESS_ROLE, newAddress[i]);
        }
    }

    function removeReadOnlyAccess(
        uint256 projectId,
        address[] memory removeAddress
    ) external onlyRole(projects[projectId].FULL_ACCESS_ROLE) {
        Project storage project = projects[projectId];

        for (uint256 i = 0; i < removeAddress.length; ++i) {
            _revokeRole(project.FULL_ACCESS_ROLE, removeAddress[i]);
        }
    }

    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}
