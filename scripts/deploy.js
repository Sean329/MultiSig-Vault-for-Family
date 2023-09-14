// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");
require('dotenv').config();

async function main() {
  const owners = ['','']; // MODIFY your owners list here before deploying the contract
  const require = 0; // MODIFY the threshold integer here before deploying the contract
  const multisig = await hre.ethers.deployContract("MultiSig", [owners, require]);
  await multisig.waitForDeployment();

  console.log(
    `deployed to ${multisig.target}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
