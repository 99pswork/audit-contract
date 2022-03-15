const { ethers } = require("hardhat");
const CONFIG = require("../credentials.json");
//const truffleContract = require('@truffle/contract');

contract("NFT deployment", () => {
	let nft;

	const provider = new ethers.providers.JsonRpcProvider(
		CONFIG["RINKEBY"]["URL"]
	);

	before(async () => {
    const NFT = await ethers.getContractFactory("TheTigerClan");
		nft = await NFT.deploy(
			"Tiger",
			"TIGER",
			"150000000000000000",
			"200000000000000000",
			12
		);
		//nft = await NFT.deploy();
		await nft.deployed();

		console.log("NFT deployed at address: ", nft.address);
	});

	it("should print contract address", async () => {
		console.log("NFT deployed at address: ", nft.address);
	});

});
