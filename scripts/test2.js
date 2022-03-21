const hre = require("hardhat");
USDCTokenHolder = "0xc333e80ef2dec2805f239e3f1e810612d294f771";
DAItOkenHolder = "0x2acf35c9a3f4c5c3f4c78ef5fb64c3ee82f07c45";
marketPlaceContract = "0x4bf010f1b9beDA5450a8dD702ED602A104ff65EE";

async function main() {
  // set eth balance of usdc holder
  await hre.network.provider.send("hardhat_setBalance", [
    USDCTokenHolder,
    "0x1000000000000000000",
  ]);
  await hre.network.provider.request({
    method: "hardhat_impersonateAccount",
    params: [USDCTokenHolder],
  });
  const usdcHolder = await await ethers.provider.getSigner(USDCTokenHolder);
  const daiContract = await ethers.getContractAt(
    "IERC20",
    "0x6B175474E89094C44Da98b954EedeAC495271d0F"
  );
  const MarketUsdc = await ethers.getContractAt(
    "MarketPlace",
    marketPlaceContract,
    usdcHolder
  );
  const usdcContract = await ethers.getContractAt(
    "IERC20",
    "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
    usdcHolder
  );
  console.log(
    `Dai balance for usdc owner before ${await daiContract.balanceOf(
      USDCTokenHolder
    )}`
  );
  console.log(
    `Usdc balance before for usdc owner before ${await usdcContract.balanceOf(
      USDCTokenHolder
    )}`
  );
  console.log(
    `Usdc balance before for dai holder before ${await usdcContract.balanceOf(
      DAItOkenHolder
    )}`
  );
  // transfer some usdc to the marketplace has dia holder
  console.log(
    `approved the contract to spend ${await usdcContract.approve(
      marketPlaceContract,
      ethers.utils.parseUnits("1", 6)
    )}`
  );
  console.log(
    `Usdc balance approval for market place ${await usdcContract.allowance(
      USDCTokenHolder,
      marketPlaceContract
    )}`
  );
  console.log(await MarketUsdc.USDCToDai(ethers.utils.parseUnits("1", 6)));
  console.log(
    `Dai balance for usdc owner after ${await daiContract.balanceOf(
      USDCTokenHolder
    )}`
  );
  console.log(
    `Usdc balance for usdc owner after ${await usdcContract.balanceOf(
      USDCTokenHolder
    )}`
  );
  console.log(
    `Usdc balance before for dai holder after ${await usdcContract.balanceOf(
      DAItOkenHolder
    )}`
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
