import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "erc721a/contracts/ERC721A.sol";

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

// NFT Count 10000

contract TigerNFT is ERC721A, Ownable, ReentrancyGuard {

    using SafeMath for uint256;
    using Strings for uint256;

    bool public preSaleActive = false;
    bool public publicSaleActive = false;

    bool public paused = true;
    bool public revealed = false;

    uint256 public maxSupply; // 10000
    uint256 public preSalePrice; // ?
    uint256 public publicSalePrice; // ?

    string private _baseURIextended;
    
    string public NETWORK_PROVENANCE = "";
    string public notRevealedUri;

    uint256 public raffleReward = 1000000000000000000; // 1 ETH - ?

    constructor(string memory name, string memory symbol, uint256 _preSalePrice, uint256 _publicSalePrice, uint256 _maxSupply) ERC721A(name, symbol) ReentrancyGuard() {
        preSalePrice = _preSalePrice;
        publicSalePrice = _publicSalePrice;
        maxSupply = _maxSupply;
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    function preSaleMint(uint256 _amount) external payable nonReentrant{
        require(preSaleActive, "NFT-Tiger Pre Sale is not Active");
        mint(_amount, true);
    }

    function publicSaleMint(uint256 _amount) external payable nonReentrant {
        require(publicSaleActive, "NFT-Tiger Public Sale is not Active");
        mint(_amount, false);
    }

    function mint(uint256 amount,bool state) internal {
        require(!paused, "NFT-Tiger Minting is Paused");
        require(totalSupply().add(amount) <= maxSupply, "NFT-Tiger Maximum Supply Reached");
        if(state){
            require(preSalePrice*amount <= msg.value, "NFT-Tiger ETH Value Sent for Pre Sale is not enough");
        }
        else{
            require(publicSalePrice*amount <= msg.value, "NFT-Tiger ETH Value Sent for Public Sale is not enough");
        }
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

    function togglePreSale() external onlyOwner {
        preSaleActive = !preSaleActive;
    }

    function togglePublicSale() external onlyOwner {
        publicSaleActive = !publicSaleActive;
    }

    function setPreSalePrice(uint256 _preSalePrice) external onlyOwner {
        preSalePrice = _preSalePrice;
    }

    function setPublicSalePrice(uint256 _publicSalePrice) external onlyOwner {
        publicSalePrice = _publicSalePrice;
    }

    function airDrop(address[] memory _address) external onlyOwner {
        require(totalSupply().add(_address.length) <= maxSupply, "NFT-Tiger Maximum Supply Reached");
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


    function setProvenanceHash(string memory provenanceHash) external onlyOwner {
        NETWORK_PROVENANCE = provenanceHash;
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
        require(_exists(_tokenId), "NFT-Tiger URI For Token Non-existent");
        if(!revealed){
            return notRevealedUri;
        }
        string memory currentBaseURI = _baseURI(); 
        return bytes(currentBaseURI).length > 0 ? 
        string(abi.encodePacked(currentBaseURI,_tokenId.toString(),".json")) : "";
    }
}