import { ethers } from "hardhat";

async function main() {
  const currentTimestampInSeconds = Math.round(Date.now() / 1000);
  const unlockTime = currentTimestampInSeconds + 60;

  const lockedAmount = ethers.parseEther("0.001");



  const IslmSukuk = await ethers.getContractFactory("Sukuk");
  const islmSukuk = await IslmSukuk.deploy(
    "0xC07C3994eE7CEa9De35f06f548d242009CE2108D",
    "Wrapped Islam Sukuk",
    "ISLM-SUKUK"
  );
  await islmSukuk.waitForDeployment();

  console.log("ISLM Sukuk deployed to: ", await islmSukuk.getAddress());

  const GoldSukuk = await ethers.getContractFactory("Sukuk");
  const goldSukuk = await GoldSukuk.deploy(
    "0xd81a414F1e73194d2c288057FAa139A8076a806f",
    "Wrapped Gold Sukuk",
    "GOLD-SUKUK"
  );
  await goldSukuk.waitForDeployment();

  console.log("Gold Sukuk deployed to: ", await goldSukuk.getAddress());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
