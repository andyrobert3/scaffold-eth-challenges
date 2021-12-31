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
  


  
}