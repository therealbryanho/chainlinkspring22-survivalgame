// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract SurvivalGame is Ownable, ReentrancyGuard, VRFConsumerBaseV2 {

VRFCoordinatorV2Interface COORDINATOR;
  uint64 public s_subscriptionId = 407;
  address vrfCoordinator = 0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed;
  bytes32 public keyHash = 0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f;
  uint32 public callbackGasLimit = 100000;
  uint16 public requestConfirmations = 3;
  uint32 public numWords =  1;
  uint256[] public s_randomWords;
  uint256 public s_requestId;

IERC20 public payToken;
address public payTokenAddress;
address public currentHighScorer;
address public gameowner;
uint public playCount = 0;
uint public playCountSinceContract = 0;
uint256 public currentPrizeValue = 1000000000000000000000; // 1000 SVC
uint256 public costPerPlay = 4000000000000000000; // 4 SVC;
uint256 public topupPercent;
uint256 public contractTopUp = (costPerPlay * 5) / 100;
uint256 public highestScore;
uint256 public defaultHighestScore = 10;
uint256 public currentHighScore = defaultHighestScore;
address public highestScorer;
uint256 public contractMinimum = 10000000000000000000000; // 10000 SVC
uint public totalPlays = 0;

    constructor(address _survivalCoin) VRFConsumerBaseV2(vrfCoordinator) {
        setPayToken(_survivalCoin);    
        gameowner = msg.sender;
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
    }

    // Assumes the subscription is funded sufficiently.
    function requestRandomWords() public {
        // Will revert if subscription is not set and funded.
        s_requestId = COORDINATOR.requestRandomWords(
        keyHash,
        s_subscriptionId,
        requestConfirmations,
        callbackGasLimit,
        numWords
        );
    }
    
    function fulfillRandomWords(
        uint256, /* requestId */
        uint256[] memory randomWords
    ) internal override {
        s_randomWords = randomWords;
    }

    function setContractMinimum(uint256 _contractMinimum) public onlyOwner {
        contractMinimum = _contractMinimum;
    }

    function setTopup(uint256 _topupPercent) public onlyOwner {
        topupPercent = _topupPercent;
    }

    function setPayToken(address _payTokenAddress) public onlyOwner {
        payTokenAddress = _payTokenAddress;
        payToken = IERC20(_payTokenAddress);
        payToken.approve(address(this),10000000000000000000000000);
    }

    function setCost(uint256 _costPerPlay) public onlyOwner {
        costPerPlay = _costPerPlay;
    }

    function setCurrentHighScore(uint256 _currentHighScore) public onlyOwner {
        currentHighScore = _currentHighScore;
    }

    function setCurrentPrizeValue(uint256 _currentPrizeValue) public onlyOwner {
        currentPrizeValue = _currentPrizeValue;
    }

    function setDefaultHighScore(uint256 _defaultHighestScore) public onlyOwner {
        defaultHighestScore = _defaultHighestScore;
    }

    function setPlayCount(uint _playCount) public onlyOwner {
        playCount = _playCount;
    }

    function reset() public onlyOwner {
        playCount = 0;
        currentHighScore = defaultHighestScore;
    }

    function login() public view returns (bool loginStatus) {
        uint256 playerBalance = payToken.balanceOf(msg.sender);
        require(playerBalance > costPerPlay, "Not enough tokens to play");
        loginStatus = true;
        return loginStatus;
    }

    event PlayGame(address _player, uint256 _value, uint256 _cost);

    function play() public payable returns (bool playStatus) {
        uint256 playerBalance = payToken.balanceOf(msg.sender);
        require(playerBalance >= costPerPlay, "Not enough tokens to play");
        uint256 allowance = payToken.allowance(msg.sender, address(this));
        require(allowance >= costPerPlay, "Check the token allowance");
        
        uint256 addToPool = costPerPlay - contractTopUp;
        payToken.transferFrom(msg.sender, payTokenAddress, contractTopUp);
        payToken.transferFrom(msg.sender, address(this), addToPool);
        totalPlays = totalPlays + 1;
        playCountSinceContract = playCountSinceContract + 1;
        if(playCount>500){
            currentHighScore = defaultHighestScore; //reset to default 
            playCount = 0;
        }
        playCount = playCount+1;

        emit PlayGame(msg.sender, msg.value, costPerPlay);
        playStatus = true;
        return playStatus;
    }

    event WinPrize(address _player, uint256 _score, uint256 _prize);

    function submitScore(uint256 _score) public {
        require(_score > currentHighScore, "You did not beat the high score this time");
        if(highestScore < _score){
            highestScore = _score;
            highestScorer = msg.sender;
        }
        if(currentHighScore < _score){
            currentHighScore = _score;
            currentHighScorer = msg.sender;
        }

        //resets the play count since last won and high score
        playCount = 0;

        payToken.approve(address(this), currentPrizeValue);
        payToken.transferFrom(address(this), msg.sender, currentPrizeValue);

        uint256 contractBalance = payToken.balanceOf(address(this)); 
     
        if(contractBalance < contractMinimum) {
            payToken.transfer(gameowner, contractMinimum);
        }
        //return playCount;
        emit WinPrize(msg.sender, _score, currentPrizeValue);
    }

}