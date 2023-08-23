import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";
import { Sukuk, WrappedISLM } from "../typechain-types";

describe("Sukut", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.

  let wrappedISLM: WrappedISLM;
  let sukuk: Sukuk;

  describe("Deployment", function () {
    it("Should be able to deploy WISLM ", async function () {
      const WrappedISLM = await ethers.getContractFactory("WrappedISLM");
      wrappedISLM = await WrappedISLM.deploy();
      await wrappedISLM.waitForDeployment();

      expect(await wrappedISLM.name()).to.equal("Wrapped ISLM");
    });
    it("Should be able to deploy sukuk", async function () {
      const Sukuk = await ethers.getContractFactory("Sukuk");
      sukuk = await Sukuk.deploy(await wrappedISLM.getAddress(), "Sukuk Wrapped Islm", "SUKUK-ISLM");
      await sukuk.waitForDeployment();

      expect(await sukuk.baseToken()).to.equal(await wrappedISLM.getAddress());
    });
  });

  describe("Sukuk Operations", function () {
    it("Should be able to deposit to sukuk", async function () {
      const [owner, otherAccount] = await ethers.getSigners();
      const tx = await wrappedISLM
        .connect(owner)
        .transfer(otherAccount.address, ethers.parseEther("500000"));
      await tx.wait();
      const tx2 = await wrappedISLM
        .connect(otherAccount)
        .approve(await sukuk.getAddress(), ethers.parseEther("500000"));
      await tx2.wait();
      const tx3 = await sukuk
        .connect(otherAccount)
        .deposit(ethers.parseEther("10000"));
      await tx3.wait();
      const tx4 = await wrappedISLM
        .connect(owner)
        .approve(await sukuk.getAddress(), ethers.parseEther("500000"));
      await tx4.wait();
      const tx5 = await sukuk
        .connect(owner)
        .deposit(ethers.parseEther("10000"));
      await tx5.wait();
    });

    it("Should be able to supply for sukuk", async function () {
      const [owner, otherAccount] = await ethers.getSigners();
      const tx = await sukuk.connect(owner).supply(ethers.parseEther("2000"));
      await tx.wait();
      console.log("Total supplied: ", await sukuk.totalSupplied());
    });

    it("Should be able to rent sukuk", async function () {
      const [owner, otherAccount] = await ethers.getSigners();
      console.log("Total supplied: ", await sukuk.totalSupplied());
      const tx = await sukuk
        .connect(otherAccount)
        .createRentContract(ethers.parseEther("1000"), 30 * 60 * 60 * 24);
      await tx.wait();

      console.log("rents: ",await sukuk.listRents(otherAccount.address))

    });

    it("Should be able to pay sukuk", async function () {
        const [owner, otherAccount] = await ethers.getSigners();
        const tx = await sukuk.connect(otherAccount).payRent(0);
        await tx.wait();
    })
    it("Should be able to withdraw sukuk", async function () {
 
        const [owner, otherAccount] = await ethers.getSigners();
        console.log("token Balance", await sukuk.tokenBalance(owner.address));
        console.log(await sukuk.totalSupplied());
        const tx = await sukuk.connect(owner).withdrawSupply(ethers.parseEther("2000"));
        await tx.wait();
    })
    it("Should be able to withdraw", async function () {
        const [owner, otherAccount] = await ethers.getSigners();
        console.log("Total supplied: ",await sukuk.totalSupplied());
        console.log("Total supply ", await sukuk.totalSupply());
        console.log("token Balance", await sukuk.tokenBalance(owner.address));

    })
  });
});
