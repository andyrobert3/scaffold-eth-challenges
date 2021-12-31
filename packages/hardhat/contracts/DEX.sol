pragma solidity >=0.8.0 <0.9.0;
// SPDX-License-Identifier: MIT
// import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DEX {

  IERC20 token;
  uint256 totalLiquidity;
  mapping(address => uint) public liquidity;

  constructor(address token_addr) {
    token = IERC20(token_addr);
  }

  function init(uint tokens) public payable returns (uint256) {
    require(totalLiquidity == 0, "Total liquidity is non-zero");
    
    totalLiquidity = address(this).balance;
    liquidity[msg.sender] = totalLiquidity;

    // Transfer to itself
    require(token.transferFrom(msg.sender, address(this), tokens));
    return totalLiquidity;
  }
  
  // Price of ETH, with 0.3% comission fee depending on reserves (AMM)
  function price(uint256 input_amount, uint256 input_reserve, 
    uint256 output_reserve) public pure returns (uint256) {

    uint256 inputAmountWithFee = input_amount * 997; // 0.3% fee
    // ( input amount * output reserve ) / total input reserve = price
    uint numerator = inputAmountWithFee * (output_reserve);
    
    // New input reserve
    uint denominator = (input_reserve  * 1000) + (inputAmountWithFee);

    return numerator / denominator;
  }

  // ETH to Balloon
  function ethToBalloon() public payable returns (uint256) {
    uint256 tokenReserve = token.balanceOf(address(this));
   
    // Why subtract ETH here?
    uint256 ethReserve = address(this).balance - msg.value;

    uint256 tokenPrice = price(msg.value, ethReserve, tokenReserve);
    uint256 tokensBought = tokenPrice * msg.value;

    require(token.transfer(msg.sender, tokensBought)); // Payable handles ETH transfer here, we do not need to
    return tokensBought;
  }

  // Balloon to ETH
  function balloonToEth(uint balloonAmount) public returns (uint256) {
    uint256 ethReserve = address(this).balance; // input reserve

    // Why not subtract here?
    uint256 balloonReserve = token.balanceOf(address(this)); // output reserve

    uint256 ethPrice = price(balloonAmount, balloonReserve, ethReserve);
    uint256 ethBought = ethPrice * balloonAmount;

    // When to use "transfer" vs "call"
    msg.sender.call{ value: ethBought }(""); // ETH transfer needs to be handled (not payable)
    require(token.transferFrom(msg.sender, address(this), balloonAmount)); // transfer tokens
    
    return ethBought;
  }


  
}