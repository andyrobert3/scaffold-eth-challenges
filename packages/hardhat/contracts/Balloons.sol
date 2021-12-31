pragma solidity >=0.8.0 <0.9.0;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Balloons is ERC20 {
  constructor() ERC20("Balloons", "BAL") {
      // **You can update the msg.sender address with your 
      // front-end address to mint yourself tokens.
      _mint(0xF9C9ace25ad601c06934115aba3f9B22D07Fb80f, 10000 ether);
      // This mints to the deployer
      _mint(msg.sender, 10000 ether);
  }
}
