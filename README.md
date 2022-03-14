Tiger NFT ERC721

// Set up hardhat 
npm i -j hardhat
npx hardhat
// Install necessary files
npm i --save-dev @nomiclabs/hardhat-ethers ethers @nomiclabs/hardhat-waffle ethereum-waffle chai @openzeppelin contracts @nomiclabs/hardhat-etherscan @nomiclabs/hardhat-truffle5
// Install ERC721A 
npm install --save-dev erc721a


npx hardhat compile // Compile Code
npx hardhat node // Set local accounts for deploying and testing
npx hardhat test --localhost // Deploy code on local and test
