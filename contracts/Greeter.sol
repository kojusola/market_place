//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract MarketPlace {
    AggregatorV3Interface internal DAIPriceFeed;
    AggregatorV3Interface internal USDCPriceFeed;
    uint256 daiUsersNumbers;
    uint256 usdcUsersNumbers;
    IERC20Metadata USDCAddress ;
    // 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 ;
    IERC20Metadata DAIAddress ;
    // 0x6B175474E89094C44Da98b954EedeAC495271d0F ;
    enum tokens {DAI, USDC}
    event exchange(address sender, address receiver, uint amount, uint8 tokenType, uint receiverTokenAmount);

    struct users {
        address userAddress;
        uint256 tokenAmount;
        bool status;
    }

    mapping(uint=>users[]) usersDetails;
    // Rinkeby network;
    // DAIToUsd = 0x2bA49Aaa16E6afD2a993473cfB70Fa8559B523cF
    //USDCToDai = 0xa24de01df22b63d23Ebc1882a5E3d4ec0d907bFB
    constructor(IERC20Metadata _USDCAddress, IERC20Metadata _DAIAddress ) {
        DAIPriceFeed = AggregatorV3Interface(0x2bA49Aaa16E6afD2a993473cfB70Fa8559B523cF);
        USDCPriceFeed = AggregatorV3Interface(0xa24de01df22b63d23Ebc1882a5E3d4ec0d907bFB);
        USDCAddress = _USDCAddress;
        DAIAddress = _DAIAddress;
    }
      function getDaiPrices() private returns(int){
        (
            ,int price,
        ) = DAIPriceFeed.latestRoundData();
        return price;
    }
          function getUSDCPrices() private returns(int){
        (
            int price
        ) = USDCPriceFeed.latestRoundData();
        return price;
    }
    function comparePrices(uint256 DAIAmount, uint256 USDCAmount) private returns(bool){
       int DAIPrice = getDaiPrices();
       int USDCPrice = getUSDCPrices();
       return ((DAIAmount * uint(DAIPrice)) == (USDCAmount * uint(USDCAmount)));
    }

    function AddUserToDataBase(uint256 _amount, uint8 tokenType, bool _status) private returns(bool){
        users memory addedUser;
        addedUser.userAddress = msg.sender;
        addedUser.tokenAmount = _amount;
        addedUser.status = _status;
       usersDetails[tokenType].push(addedUser);
    }

    function DaiToUSDC(uint256 amount) public returns (bool) {
        require(amount > 0, "You need to sell at least some tokens");
        uint256 daiBalance = DAIAddress.balanceOf(msg.sender);
        require(daiBalance>= amount, "You do not have enough tokens");
        bool transferred = DAIAddress.transferFrom(msg.sender, address(this), amount);
        require(transferred, "Token Transfer Failed");
        users memory compartibleUser;
        for(uint i =0; i<usdcUsersNumbers; i++){
            bool results = comparePrices(amount, usersDetails[1][i].tokenAmount);
            if(results && !usersDetails[1][i].status){
                 compartibleUser = usersDetails[1][i];
            }
        }
        if(compartibleUser.userAddress != address(0)){
            USDCAddress.transfer(msg.sender, compartibleUser.tokenAmount);
            DAIAddress.transfer(compartibleUser.userAddress, amount);
             AddUserToDataBase(amount, 1, true);
             daiUsersNumbers;
        } else {
            AddUserToDataBase(amount, 1, false);
            daiUsersNumbers;
        }
        exchange(msg.sender,compartibleUser.userAddress, amount, 1,  compartibleUser.tokenAmount);
        return true;
    }

    function USDCToDai(uint256 _amount) public returns (bool)  {
         require(_amount > 0, "You need to sell at least some tokens");
        uint256 usdcBalance = USDCAddress.balanceOf(msg.sender);
        require(usdcBalance>= _amount, "You do not have enough tokens");
        bool transferred = USDCAddress.transferFrom(msg.sender, address(this), _amount);
        require(transferred, "Token Transfer Failed");
        users memory compartibleUser;
        for(uint i =0; i<daiUsersNumbers; i++){
            bool results = comparePrices( usersDetails[2][i].tokenAmount, _amount);
            if(results && !usersDetails[2][i].status){
                 compartibleUser = usersDetails[2][i];
            }
        }
        if(compartibleUser.userAddress != address(0)){
            DAIAddress.transfer(compartibleUser.userAddress, _amount);
            USDCAddress.transfer(msg.sender, compartibleUser.tokenAmount);
             AddUserToDataBase(_amount, 2, true);
             usdcUsersNumbers++;
        } else {
            AddUserToDataBase(_amount, 2, false);
            usdcUsersNumbers++;
        }
        exchange(msg.sender,compartibleUser.userAddress, _amount, 2,  compartibleUser.tokenAmount);
        return true;
    }
}
