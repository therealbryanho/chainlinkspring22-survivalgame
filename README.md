# chainlinkspring22-survivalgame

Entry for Chainlink Spring Hackathon 2022

Name: Survival Game
Devpost URL: https://devpost.com/software/survivors-game

Smart Contracts on Mumbai
- coin 0x21c02c830b5A1cDAA0DD384b695afD03e8662C35  https://mumbai.polygonscan.com/address/0x21c02c830b5A1cDAA0DD384b695afD03e8662C35
- game 0xE5B77B3dcB4b3C6B2Eb163eCa1C3A9fe27c83f21  https://mumbai.polygonscan.com/address/0xE5B77B3dcB4b3C6B2Eb163eCa1C3A9fe27c83f21

Chainlink VRF Subscription
- https://vrf.chain.link/mumbai/407


How does the game work?
- Buy SVC tokens, use SVC tokens to play the game.
- Keyboard to move, mouse to aim and shoot at enemies.
- Beat the high score, submit your high score to claim prize - more SVC tokens.

How does Chainlink VRF play a part in the game?
- Treasure Chest appear within the game, when player goes near the treasure chest, player will be given the option to open the treasure chest.
- If open the treasure chest, the smart contract will call VRF to get a random number
- The random number determines what is in the treasure chest. It may be an enemy waiting inside, or free points to collect.
