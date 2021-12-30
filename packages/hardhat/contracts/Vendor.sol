pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {

  YourToken yourToken;
  uint256 public constant tokensPerEth = 100;

  event BuyTokens(address buyer, uint256 amountOfETH, uint amountOfTokens);

  constructor(address tokenAddress) public {
    yourToken = YourToken(tokenAddress);
  }

  // ToDo: create a payable buyTokens() function [ETH]: 
  function buyTokens() public payable returns (uint256 tokenAmount) {
    require(msg.value > 0, "Buyer needs to spend more than 0 ETH");
    uint amountToBuy = msg.value * tokensPerEth; // (ETH * Tokens per ETH) = Tokens

    uint tokenVendorBalance = yourToken.balanceOf(address(this));
    require(tokenVendorBalance >= amountToBuy, "Vendor balance needs to be more than buy amount");

    (bool sent) = yourToken.transfer(msg.sender, amountToBuy);
    require(sent, "Error sending tokens to buyer");

    emit BuyTokens(msg.sender, msg.value, amountToBuy);

    return amountToBuy;
  }


  // ToDo: create a withdraw() function that lets the owner withdraw ETH
  function withdraw() public onlyOwner {
    uint ownerBalance = address(this).balance;
    require(ownerBalance > 0, "Only can withdraw if you have some tokens stored");
    
    (bool sent, ) = msg.sender.call{ value: ownerBalance }("");
    require(sent, "Error when withdrawing ETH");
  }

  // ToDo: create a sellTokens() function:
  function sellTokens(uint tokenAmountToSell) public payable {
    require(tokenAmountToSell > 0, "Must sell more than 0 tokens");
    
    // Check user balance is enough
    uint userBalance = yourToken.balanceOf(msg.sender);
    require(userBalance >= tokenAmountToSell, "User does not have enough tokens to sell");

    // Check ETH vendor balance is enough
    uint256 ethAmountToSell = tokenAmountToSell / tokensPerEth;
    uint256 vendorBalance = address(this).balance;
    require(vendorBalance >= ethAmountToSell, "Vendor balance not enough for ETH amount to sell");

    // Transfer tokens
    (bool transferred)= yourToken.transferFrom(
      msg.sender, 
      address(this), 
      tokenAmountToSell
    );
    require(transferred, "Your token transferred failed");

    // Tranfer ETH
    (bool sent, ) = msg.sender.call{ value: ethAmountToSell }("");
    require(sent, "ETH to transfer failed");
  }

}
