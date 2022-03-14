const { ethers } = require("hardhat");
const CONFIG = require("../scripts/credentials.json");

contract("NFT deployment", () => {
	let nft;

	const provider = new ethers.providers.JsonRpcProvider(
		CONFIG["RINKEBY"]["URL"]
	);

	before(async () => {
		const NFT = await ethers.getContractFactory("NFT");
		nft = await NFT.deploy();
		await nft.deployed();

		console.log("NFT deployed at address: ", nft.address);
	});

	it("should print contract address", async () => {
		console.log("NFT deployed at address: ", nft.address);
	});

	it("Should check for contract's ownership!", async function () {
		console.log(await nft.owner());
		expect(await nft.owner()).to.equal("");
	});
});
