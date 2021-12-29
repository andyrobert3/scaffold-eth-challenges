pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

// Questions
// 1. How to enable hot-reloading? or is it not possible here?
// 2. How to debug contracts?

contract Staker {

  ExampleExternalContract public exampleExternalContract;
  
  // Staking variables
  mapping (address => uint256) public balances;
  uint256 public constant threshold = 1 ether;
  uint256 public deadline  = block.timestamp + 30 seconds;
  bool public openToWithdraw = false;
  
  event Stake(address indexed staker, uint256 amount);
  event Withdraw(address indexed withdrawer, uint256 amount);

  constructor(address exampleExternalContractAddress) public {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
  function stake() public payable {
      require(msg.value > 0, "You must stake some ether");
      balances[msg.sender] += msg.value;
      emit Stake(msg.sender, msg.value);
  }

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns(uint256) {
    if (block.timestamp >= deadline) {
      return 0;
    }
    return deadline - block.timestamp;
  }


  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
  function execute() public {
    require(block.timestamp >= deadline, "Must execute after deadline");
    require(!openToWithdraw, "Must have never been enabled to withdraw");

    if (address(this).balance >= threshold) {
      exampleExternalContract.complete{
        value: address(this).balance
      }();
    } else {
      openToWithdraw = true;
    }
  }

  // if the `threshold` was not met, allow everyone to call a `withdraw()` function


  // Add a `withdraw(address payable)` function lets users withdraw their balance
  function withdraw(address payable withdrawer) public {
    require(openToWithdraw, "Cannot withdraw yet");
    uint256 balance = balances[withdrawer];

    require(balance > 0, "Balance is 0, cannot withdraw");
    balances[msg.sender] = 0;
    
    (bool sent, ) = withdrawer.call{ value: balance }("");
    require(sent, "Withdraw failed");

    emit Withdraw(withdrawer, balance);
  }



  // Add the `receive()` special function that receives eth and calls stake()
  function receive(address payable sender) public {
    stake();
  }

}
