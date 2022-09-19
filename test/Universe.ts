import { expect } from "chai";
import { ethers } from "hardhat";

describe("Universe", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.

  describe("Deployment", function () {
    it("Should deploy correctly", async function () {
      const UniverseContract = await ethers.getContractFactory("Universe");
      const universeContract = await UniverseContract.deploy();
      expect(universeContract).not.to.be.reverted;
    });
  });
});
