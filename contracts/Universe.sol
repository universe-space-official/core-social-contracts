// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Universe is Ownable, AccessControl {
    // Basic structure of Profile, we will first define here mostly who can acess/ modify the Profile
    // Other elements of Profile TBD
    struct Profile {
        uint256 ProfileId;
        bytes32 READ_ONLY_ACCESS_ROLE;
        bytes32 FULL_ACCESS_ROLE;
        string profileHandle;
        bool isProject;
    }

    uint256 public profileIdCounter = 1;

    mapping(uint256 => Profile) public profiles;

    mapping(bytes32 => uint256) public profileIdByHandle;

    // Events

    event ProfileCreated(
        uint256 ProfileId,
        address[] readyOnlyAccess,
        address[] fullAccess
    );
    event ProfileDeleted(uint256 ProfileId);

    //TBD if everyone can create a Profile, if it costs something and if you mint something when you create it
    //TBD when we define more elements of the Profile structure we will need to make new arguments in create function
    function createProfile(
        address[] memory readOnlyAccess,
        address[] memory fullAccess,
        string calldata profileHandle,
        bool isProject
    ) external {
        uint256 profileId = profileIdCounter++;

        Profile storage newProfile = profiles[profileId];

        bytes32 handleHash = keccak256(bytes(profileHandle));

        require(profileIdByHandle[handleHash] == 0, "Handle taken");

        profileIdByHandle[handleHash] = profileId;

        newProfile.profileHandle = profileHandle;
        newProfile.isProject = isProject;

        // We will concatenate the ProfileId to have the identifier for this Profile only
        //Defining role readOnlyAccess role for this Profile Id

        newProfile.READ_ONLY_ACCESS_ROLE = keccak256(
            abi.encodePacked("READ_ONLY_ACCESS_ROLE", toString(profileId))
        );

        //Defining role fullAccess role  for this Profile Id
        newProfile.FULL_ACCESS_ROLE = keccak256(
            abi.encodePacked("FULL_ACCESS_ROLE", toString(profileId))
        );

        //Starting addresses that can access/modify the Profile
        for (uint256 i = 0; i < readOnlyAccess.length; ++i) {
            _setupRole(newProfile.READ_ONLY_ACCESS_ROLE, readOnlyAccess[i]);
        }

        for (uint256 i = 0; i < fullAccess.length; ++i) {
            _setupRole(newProfile.FULL_ACCESS_ROLE, fullAccess[i]);
        }

        //The sender address that creates the Profile has full control of the Profile
        _setupRole(newProfile.FULL_ACCESS_ROLE, msg.sender);

        emit ProfileCreated(profileId, readOnlyAccess, fullAccess);
    }

    function deleteProfile(uint256 profileId)
        external
        onlyRole(profiles[profileId].FULL_ACCESS_ROLE)
    {
        delete profiles[profileId];

        emit ProfileDeleted(profileId);
    }

    function addFullAccessUser(uint256 profileId, address[] memory newAddress)
        external
        onlyRole(profiles[profileId].FULL_ACCESS_ROLE)
    {
        Profile storage profile = profiles[profileId];

        for (uint256 i = 0; i < newAddress.length; ++i) {
            _setupRole(profile.FULL_ACCESS_ROLE, newAddress[i]);
        }
    }

    function removeFullAccess(uint256 profileId, address[] memory removeAddress)
        external
        onlyRole(profiles[profileId].FULL_ACCESS_ROLE)
    {
        Profile storage profile = profiles[profileId];

        for (uint256 i = 0; i < removeAddress.length; ++i) {
            _revokeRole(profile.FULL_ACCESS_ROLE, removeAddress[i]);
        }
    }

    function addReadOnlyAccess(uint256 profileId, address[] memory newAddress)
        external
        onlyRole(profiles[profileId].FULL_ACCESS_ROLE)
    {
        Profile storage profile = profiles[profileId];

        for (uint256 i = 0; i < newAddress.length; ++i) {
            _setupRole(profile.FULL_ACCESS_ROLE, newAddress[i]);
        }
    }

    function removeReadOnlyAccess(
        uint256 ProfileId,
        address[] memory removeAddress
    ) external onlyRole(profiles[ProfileId].FULL_ACCESS_ROLE) {
        Profile storage profile = profiles[ProfileId];

        for (uint256 i = 0; i < removeAddress.length; ++i) {
            _revokeRole(profile.FULL_ACCESS_ROLE, removeAddress[i]);
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
