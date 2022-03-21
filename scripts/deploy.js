// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
USDCTokenHolder = "0xc333e80ef2dec2805f239e3f1e810612d294f771";
DAItOkenHolder = "0x2acf35c9a3f4c5c3f4c78ef5fb64c3ee82f07c45";

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const Market = await hre.ethers.getContractFactory("MarketPlace");
  const market = await Market.deploy(
    "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48",
    "0x6b175474e89094c44da98b954eedeac495271d0f"
  );
  const usdcContract = await ethers.getContractAt(
    "IERC20",
    "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"
  );
  console.log(
    `Usdc balance before ${await usdcContract.balanceOf(USDCTokenHolder)}`
  );
  console.log(
    `Usdc balance before for dai holder ${await usdcContract.balanceOf(
      DAItOkenHolder
    )}`
  );

  const daiContract = await ethers.getContractAt(
    "IERC20",
    "0x6B175474E89094C44Da98b954EedeAC495271d0F"
  );

  console.log(
    `Dai balance before ${await daiContract.balanceOf(DAItOkenHolder)}`
  );
  console.log(
    `Dai balance for usdc owner before ${await daiContract.balanceOf(
      USDCTokenHolder
    )}`
  );

  await market.deployed();
  console.log("marketplace address", market.address);

  console.log(await market.getDaiPrices());
  console.log(await market.getUSDCPrices());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
