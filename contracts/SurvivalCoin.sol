// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import from node_modules @openzeppelin/contracts v4.0
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "hardhat/console.sol";

contract SurvivalCoin is ERC20, Ownable, ReentrancyGuard {

  address public gameContractAddress;
  uint256 public maxSupply = 10000000000000000000000000; // 10000000 SVC

    constructor() ERC20("SurvivalCoin", "SVC") {
      _mint(address(this), 5000000000000000000000000);
    }

    function mint(address account, uint256 amount) external returns (bool sucess) {
      require(account != address(0) && amount != uint256(0), "ERC20: function mint invalid input");
      _mint(account, amount);
      return true;
    }

    function setGameContractAddress(address _gameContractAddress) public onlyOwner {
        gameContractAddress = _gameContractAddress;
        _mint(gameContractAddress, 5000000000000000000000000);
    }

    function burn(address account, uint256 amount) public onlyOwner returns (bool success) {
      require(account != address(0) && amount != uint256(0), "ERC20: function burn invalid input");
      _burn(account, amount);
      return true;
    }

    function buy() public payable nonReentrant returns (bool success) {
      require(msg.sender.balance >= msg.value && msg.value != 0 ether, "SurvivalCoin: function buy invalid input");
      uint256 amount = msg.value * 100;
      _transfer(address(this), _msgSender(), amount);
      return true;
    }

    function withdraw(uint256 amount) public onlyOwner returns (bool success) {
      require(amount <= address(this).balance, "SurvivalCoin: function withdraw invalid input");
      payable(_msgSender()).transfer(amount);
      return true;
    }
}
