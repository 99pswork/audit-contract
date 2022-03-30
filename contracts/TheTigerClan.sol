// SPDX-License-Identifier: MIT
// NFT Count 10000

pragma solidity ^0.8.4;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "erc721a/contracts/ERC721A.sol";

contract TheTigerClan is ERC721A, Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using Strings for uint256;

    bool public preSaleActive = true;
    bool public publicSaleActive = false;

    bool public paused = true;
    bool public revealed = false;

    uint256 public maxSupply = 10000; 
    uint256 public maxPreSale = 10;
    uint256 public preSalePrice = 0.15 ether; 
    uint256 public publicSalePrice = 0.18 ether;  

    string private _baseURIextended;
    string public notRevealedUri;

    mapping(address => uint256) public nftMinted;

    constructor(string memory name, string memory symbol) ERC721A(name, symbol) ReentrancyGuard() {
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    function preSaleMint(uint256 _amount) external payable nonReentrant{
        require(preSaleActive, "TTC Pre Sale is not Active");
        require(nftMinted[msg.sender].add(_amount) <= maxPreSale, "TTC Maximum Pre Sale Minting Limit Reached");
        mint(_amount, true);
    }

    function publicSaleMint(uint256 _amount) external payable nonReentrant {
        require(publicSaleActive, "TTC Public Sale is not Active");
        mint(_amount, false);
    }

    function mint(uint256 amount,bool state) internal {
        require(!paused, "TTC Minting is Paused");
        require(totalSupply().add(amount) <= maxSupply, "TTC Maximum Supply Reached");
        if(state){
            require(preSalePrice*amount <= msg.value, "TTC ETH Value Sent for Pre Sale is not enough");
        }
        else{
            require(publicSalePrice*amount <= msg.value, "TTC ETH Value Sent for Public Sale is not enough");
        }
        nftMinted[msg.sender] = nftMinted[msg.sender].add(amount);
        _safeMint(msg.sender, amount);
    }

    function _baseURI() internal view virtual override returns (string memory){
        return _baseURIextended;
    }

    function setBaseURI(string calldata baseURI_) external onlyOwner {
        _baseURIextended = baseURI_;
    }

    function togglePauseState() external onlyOwner {
        paused = !paused;
    }

    function toggleSaleMode() external onlyOwner {
        preSaleActive = !preSaleActive;
        publicSaleActive = !publicSaleActive;
    }

    function setPreSalePrice(uint256 _preSalePrice) external onlyOwner {
        preSalePrice = _preSalePrice;
    }

    function setPublicSalePrice(uint256 _publicSalePrice) external onlyOwner {
        publicSalePrice = _publicSalePrice;
    }

    function airDrop(address[] memory _address) external onlyOwner {
        require(totalSupply().add(_address.length) <= maxSupply, "TTC Maximum Supply Reached");
        for(uint i=1; i <= _address.length; i++){
            _safeMint(_address[i-1], 1);
        }
    }

    function reveal() external onlyOwner {
        revealed = true;
    }

    function withdrawTotal() external onlyOwner {
        uint balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    function setNotRevealedURI(string memory _notRevealedUri) external onlyOwner {
        notRevealedUri = _notRevealedUri;
    }

    function raffleNumberGenerator(uint _limit) public view returns(uint256) {
        uint256 seed = uint256(keccak256(abi.encodePacked(
            block.timestamp + block.difficulty + ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
            block.gaslimit + ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) + block.number
        )));
        return 1 + (seed - ((seed / _limit) * _limit));
        
    }

    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        require(_exists(_tokenId), "TTC URI For Token Non-existent");
        if(!revealed){
            return notRevealedUri;
        }
        string memory currentBaseURI = _baseURI(); 
        return bytes(currentBaseURI).length > 0 ? 
        string(abi.encodePacked(currentBaseURI,_tokenId.toString(),".json")) : "";
    }
}