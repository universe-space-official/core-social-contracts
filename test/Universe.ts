import { Provider } from "@ethersProfile/providers";
import { expect } from "chai";
import { Signer } from "ethers";
import { ethers } from "hardhat";
import { Universe } from "../typechain-types";
import { PromiseOrValue } from "../typechain-types/common";

describe("Universe Tests", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.

  let deployer;
  let user2: { signer: string | Signer | Provider; address: PromiseOrValue<string>; };
  let user3: { signer: string | Signer | Provider; address: PromiseOrValue<string> };
  let user4: { address: PromiseOrValue<string>; };
  let user5: { address: PromiseOrValue<string>; };

  let universeContract: Universe;
  before(async function () {
    const getAccounts = async function () {
      const accounts = [];
      let signers = [];
      signers = await ethers.getSigners();
      for (const signer of signers) {
        // eslint-disable-next-line no-await-in-loop
        accounts.push({ signer, address: await signer.getAddress() });
      } // populates the accounts array with addresses.
      return accounts;
    };

    // REFACTOR
    [deployer, user2, user3, user4, user5] = await getAccounts();
  });

  before((done) => {
    setTimeout(done, 2000);
  });


  describe("Deployment", function () {
    it("Should deploy correctly", async function () {
      const universeFactory = await ethers.getContractFactory("Universe");
      universeContract = await universeFactory.deploy();
      expect(universeContract).not.to.be.reverted;
    });

    it("Should create a new profile", async function () {

      const tx1 = await universeContract.createProfile([], [], "Perfil1", false);
      await tx1.wait();
      expect(await universeContract.profileIdCounter()).to.equal(2);



    });

    it("Should be able to add user to fullaccess role", async function () {

      const tx1 = await universeContract.addFullAccessUser(1, [user2.address]);
      await tx1.wait();


    });

    it("User without fullaccess role should not be able to give access", async function () {
      await expect(universeContract.connect(user3.signer).addFullAccessUser(1, [user3.address])).to.be.reverted;


    });

    it("User with access in profile 0 should not have access in profile 1", async function () {

      const tx1 = await universeContract.createProfile([user3.address], [user4.address, user5.address], "Perfil2", false);
      await tx1.wait();

      await expect(universeContract.connect(user2.signer).addFullAccessUser(1, [user3.address])).not.to.be.reverted;

      await expect(universeContract.connect(user2.signer).addFullAccessUser(2, [user3.address])).to.be.reverted;


    });

    it("Should revert when trying to create user with same handle", async function () {


      await expect(universeContract.createProfile([user3.address], [user4.address, user5.address], "Perfil1", false)).to.be.reverted;


    });
  });
});
