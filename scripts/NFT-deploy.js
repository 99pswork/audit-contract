const { ethers } = require("hardhat");

contract("NFT deployment", () => {
	let nft;

	before(async () => {
    const NFT = await ethers.getContractFactory("TheTigerClan");
		nft = await NFT.deploy(
			"Tiger",
			"TIGER"
		);
		await nft.deployed();

		console.log("NFT deployed at address: ", nft.address);
	});

	it("should print contract address", async () => {
		console.log("NFT deployed at address: ", nft.address);
	});

});
