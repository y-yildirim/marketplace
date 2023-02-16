//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "hardhat/console.sol";

contract NFTMarketplace is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _itemsSold;

    uint256 listingPrice = 0.01 ether;
    address payable owner;

    mapping(uint256 => Item) private _idToItem;

    struct Item {
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    event ItemCreated(
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    constructor() ERC721("Paribu Hub Token", "PHTK") {
        owner = payable(msg.sender);
    }

    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    function updateListingPrice(uint256 _listingPrice) public payable {
        require(owner == msg.sender, "Only owner can update listing price.");
        listingPrice = _listingPrice;
    }

    function _createItem(uint256 tokenId, uint256 price) private {
        require(price > 0, "Price must be at least 1 wei.");
        require(msg.value == listingPrice, "Have to pay listing price.");

        _idToItem[tokenId] = Item(
            tokenId,
            payable(msg.sender),
            payable(address(this)),
            price,
            false
        );

        _transfer(msg.sender, address(this), tokenId);
        emit ItemCreated(tokenId, msg.sender, address(this), price, false);
    }

    function createToken(string memory tokenURI, uint256 price)
        public
        payable
        returns (uint256)
    {
        uint256 newTokenId = _tokenIds.current();

        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        _createItem(newTokenId, price);
        _tokenIds.increment();
        return newTokenId;
    }

    function sellToken(uint256 tokenId, uint256 price) public payable {
        require(
            _idToItem[tokenId].owner == msg.sender,
            "This action can only be performed by the item's owner."
        );
        require(
            msg.value == listingPrice,
            "Price must be equal to listing price"
        );
        _idToItem[tokenId].sold = false;
        _idToItem[tokenId].price = price;
        _idToItem[tokenId].seller = payable(msg.sender);
        _idToItem[tokenId].owner = payable(address(this));
        _itemsSold.decrement();
        _transfer(msg.sender, address(this), tokenId);
    }

    function createSale(uint256 tokenId) public payable {
        uint256 price = _idToItem[tokenId].price;
        require(
            msg.value == price,
            "Please submit the asking price in order purchase"
        );
        _idToItem[tokenId].owner = payable(msg.sender);
        _idToItem[tokenId].seller = payable(address(0));
        _idToItem[tokenId].sold = true;
        _itemsSold.increment();
        _transfer(address(this), msg.sender, tokenId);
        payable(owner).transfer(listingPrice);
        payable(_idToItem[tokenId].seller).transfer(msg.value);
    }

    function fetchItems() public view returns (Item[] memory) {
        uint256 itemCount = _tokenIds.current();
        uint256 unsoldItemCount = _tokenIds.current() - _itemsSold.current();
        uint256 currentIndex = 0;

        Item[] memory items = new Item[](unsoldItemCount);
        for (uint256 i = 0; i < itemCount; i++) {
            if (_idToItem[i].owner == address(this)) {
                uint256 currentId = i;
                Item storage currentItem = _idToItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    function fetchMyNFTs() public view returns (Item[] memory) {
        uint256 totalItemCount = _tokenIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (_idToItem[i].owner == msg.sender) {
                itemCount += 1;
            }
        }

        Item[] memory items = new Item[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (_idToItem[i].owner == msg.sender) {
                uint256 currentId = i;
                Item storage currentItem = _idToItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    function fetchItemsListed() public view returns (Item[] memory) {
        uint256 totalItemCount = _tokenIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (_idToItem[i].seller == msg.sender) {
                itemCount += 1;
            }
        }

        Item[] memory items = new Item[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (_idToItem[i].seller == msg.sender) {
                uint256 currentId = i;
                Item storage currentItem = _idToItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }
}
