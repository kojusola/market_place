//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract MarketPlace {
    AggregatorV3Interface internal DAIPriceFeed;
    AggregatorV3Interface internal USDCPriceFeed;
    IERC20 USDCAddress ;
    // 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 ;
    IERC20 DAIAddress ;
    // 0x6B175474E89094C44Da98b954EedeAC495271d0F ;
    event exchange( address receiver, uint amount, uint8 tokenType);
    // Rinkeby network;
    // DAIToUsd = 0x2bA49Aaa16E6afD2a993473cfB70Fa8559B523cF
    //USDCToDai = 0xa24de01df22b63d23Ebc1882a5E3d4ec0d907bFB
    constructor(address _USDCAddress, address _DAIAddress ) {
        DAIPriceFeed = AggregatorV3Interface(0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6);
        USDCPriceFeed = AggregatorV3Interface(0xAed0c38402a5d19df6E4c03F4E2DceD6e29c1ee9);
        USDCAddress = IERC20(_USDCAddress);
        DAIAddress = IERC20(_DAIAddress);
    }
      function getDaiPrices() public view returns(int){
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = DAIPriceFeed.latestRoundData();
        return price;
    }
          function getUSDCPrices() public view returns(int){
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = USDCPriceFeed.latestRoundData();
        // console.log("usdc price:",price);
        return price;
    }
    function getPrices(uint256 amount, uint8 tokenType) private view returns(uint256 result){
        int DAIPrice = getDaiPrices();
        int USDCPrice = getUSDCPrices();
        if(tokenType == 0){
             result = ((amount * uint(DAIPrice)) / uint(USDCPrice)) / 10**12;
        }else if(tokenType == 1){
             result = ((amount * uint(USDCPrice)) / uint(DAIPrice)) * 10**12;
        }
    }

    function DaiToUSDC(uint256 amount) public returns (bool) {
        require(amount > 0, "You need to sell at least some tokens");
        bool transferred = DAIAddress.transferFrom(msg.sender, address(this), amount);
        require(transferred, "Token Transfer Failed");
        uint result = getPrices( amount, 0);
        USDCAddress.transfer(msg.sender, result);
        emit exchange(msg.sender, amount, 0);
        return true;
    }

    function USDCToDai(uint256 _amount) public returns (bool)  {
         require(_amount > 0, "You need to sell at least some tokens");
        bool transferred = USDCAddress.transferFrom(msg.sender, address(this), _amount);
        require(transferred, "Token Transfer Failed");
        uint result = getPrices( _amount, 1);
        DAIAddress.transfer(msg.sender, result);
        emit exchange(msg.sender, result, 1);
        return true;
    }
}
