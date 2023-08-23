import { ethers } from "hardhat";

async function main() {
  const currentTimestampInSeconds = Math.round(Date.now() / 1000);
  const unlockTime = currentTimestampInSeconds + 60;

  const lockedAmount = ethers.parseEther("0.001");

  const Wgold = await ethers.getContractFactory("WrappedGold");
  const wgold = await Wgold.deploy();
  await wgold.waitForDeployment();
  const wgoldAddress = await wgold.getAddress();
  console.log("Wrapped Gold deployed to: ", wgoldAddress);

  const Wislm = await ethers.getContractFactory("WrappedISLM");
  const wislm = await Wislm.deploy();
  await wislm.waitForDeployment();
  const wislmAddress = await wislm.getAddress();
  console.log("Wrapped ISLM deployed to: ", wislmAddress);

  const IslmSukuk = await ethers.getContractFactory("Sukuk");
  const islmSukuk = await IslmSukuk.deploy(
    wislmAddress,
    "Wrapped Islam Sukuk",
    "ISLM-SUKUK"
  );
  await islmSukuk.waitForDeployment();

  console.log("ISLM Sukuk deployed to: ", await islmSukuk.getAddress());

  const GoldSukuk = await ethers.getContractFactory("Sukuk");
  const goldSukuk = await GoldSukuk.deploy(
    wgoldAddress,
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
