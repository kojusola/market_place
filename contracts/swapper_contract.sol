//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract MarketPlace {
    AggregatorV3Interface internal DAIPriceFeed;
    AggregatorV3Interface internal USDCPriceFeed;
    uint256 daiUsersNumbers = 0;
    uint256 usdcUsersNumbers = 0;
    IERC20 USDCAddress ;
    // 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 ;
    IERC20 DAIAddress ;
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
    function comparePrices(uint256 DAIAmount, uint256 USDCAmount) private view returns(bool){
       int DAIPrice = getDaiPrices();
       int USDCPrice = getUSDCPrices();
       console.log("DAI amount",(DAIAmount * uint(DAIPrice))/ (10**8));
       console.log("USDC amount",(USDCAmount * uint(USDCPrice))/ (10**8));
       return ((DAIAmount * uint(DAIPrice) / (10**8)) == (USDCAmount * uint(USDCPrice)/ (10**8)));
    }

    function AddUserToDataBase(uint256 _amount, uint8 tokenType, bool _status) private returns(bool){
        users memory addedUser;
        addedUser.userAddress = msg.sender;
        addedUser.tokenAmount = _amount;
        addedUser.status = _status;
       usersDetails[tokenType].push(addedUser);
       return true;
    }

    function DaiToUSDC(uint256 amount) public returns (bool) {
        require(amount > 0, "You need to sell at least some tokens");
        uint256 daiBalance = DAIAddress.balanceOf(msg.sender);
        require(daiBalance>= amount, "You do not have enough tokens");
        bool transferred = DAIAddress.transferFrom(msg.sender, address(this), amount * 10 ** 12);
        require(transferred, "Token Transfer Failed");
        users memory compartibleUser;
        uint user;
        for(uint i =0; i<usersDetails[2].length; i++){
            bool results = comparePrices(amount, usersDetails[2][i].tokenAmount);
            console.log(!usersDetails[2][i].status);
            if(results && !usersDetails[2][i].status){
                 compartibleUser = usersDetails[2][i];
                  user = i;
            }
        }
        if(compartibleUser.userAddress != address(0)){
            USDCAddress.transfer(msg.sender, compartibleUser.tokenAmount);
            DAIAddress.transfer(compartibleUser.userAddress, amount * 10 ** 12);
             AddUserToDataBase(amount, 1, true);
             daiUsersNumbers += 1;
            usersDetails[1][user].status = true;
        } else {
            AddUserToDataBase(amount, 1, false);
            daiUsersNumbers += 1;
        }
        console.log(daiUsersNumbers);
        emit exchange(msg.sender,compartibleUser.userAddress, amount, 1,  compartibleUser.tokenAmount);
        return true;
    }

    function USDCToDai(uint256 _amount) public returns (bool)  {
         require(_amount > 0, "You need to sell at least some tokens");
        uint256 usdcBalance = USDCAddress.balanceOf(msg.sender);
        require(usdcBalance>= _amount, "You do not have enough tokens");
        bool transferred = USDCAddress.transferFrom(msg.sender, address(this), _amount);
        console.log(transferred);
        require(transferred, "Token Transfer Failed");
        users memory compartibleUser;
        uint user;
        console.log(daiUsersNumbers);
        console.log(usersDetails[2].length);
        for(uint i =0; i< usersDetails[1].length; i++){
            bool results = comparePrices( usersDetails[1][i].tokenAmount, _amount);
            console.log(!usersDetails[1][i].status);
            if(results && !usersDetails[1][i].status){
                 compartibleUser = usersDetails[1][i];
                 user = i;
            }
        }
        console.log(compartibleUser.userAddress);
        if(compartibleUser.userAddress != address(0)){
            DAIAddress.transfer(msg.sender, compartibleUser.tokenAmount * 10 ** 12);
            USDCAddress.transfer(compartibleUser.userAddress, _amount);
             AddUserToDataBase(_amount, 2, true);
             usdcUsersNumbers += 1;
             usersDetails[1][user].status = true;
        } else {
            AddUserToDataBase(_amount, 2, false);
            usdcUsersNumbers += 1;
        }
        emit exchange(msg.sender,compartibleUser.userAddress, _amount, 2,  compartibleUser.tokenAmount);
        return true;
    }
}
