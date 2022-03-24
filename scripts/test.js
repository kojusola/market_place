const hre = require("hardhat");
USDCTokenHolder = "0xc333e80ef2dec2805f239e3f1e810612d294f771";
DAItOkenHolder = "0x2acf35c9a3f4c5c3f4c78ef5fb64c3ee82f07c45";
marketPlaceContract = "0x4bf010f1b9beDA5450a8dD702ED602A104ff65EE";

async function main() {
  //impersonate holder of Dai tokens
  await hre.network.provider.request({
    method: "hardhat_impersonateAccount",
    params: [DAItOkenHolder],
  });
  const DaiHolder = await await ethers.provider.getSigner(DAItOkenHolder);
  const Market = await hre.ethers.getContractAt(
    "MarketPlace",
    marketPlaceContract,
    DaiHolder
  );
  // set eth balance of dai holder
  await hre.network.provider.send("hardhat_setBalance", [
    DAItOkenHolder,
    "0x1000000000000000000",
  ]);
  // call the daiContract has the dai holder
  const daiContract = await ethers.getContractAt(
    "IERC20",
    "0x6B175474E89094C44Da98b954EedeAC495271d0F",
    DaiHolder
  );

  console.log(
    `Dai balance before ${await daiContract.balanceOf(DAItOkenHolder)}`
  );
  // transfer some dai to the marketplace has dia holder
  console.log(
    `approved the contract to spend ${await daiContract.approve(
      marketPlaceContract,
      ethers.utils.parseUnits("0.999978", 18)
    )}`
  );
  console.log(await Market.DaiToUSDC(ethers.utils.parseUnits("0.999978", 6)));
  console.log(
    `Dai balance after ${await daiContract.balanceOf(DAItOkenHolder)}`
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
