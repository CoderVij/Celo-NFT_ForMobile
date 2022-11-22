//SPDX-License-Identifier:Unlicensed

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";


contract NftMarketPlace 
{
    struct Listing
    {
        uint price;
        address seller;
    }

    mapping(address =>mapping(uint256=>Listing)) public listings;


    modifier isNFTOwner(address nftAddress, uint256 tokenId)
    {
        require(IERC721(nftAddress).ownerOf(tokenId) == msg.sender, "Not owner");
        _;
    }

    modifier isNotListed(address nftAddress, uint256 tokenId)
    {
        require(listings[nftAddress][tokenId].price == 0, "Already listed");
        _;
    }

    modifier isListed(address nftAddress, uint256 tokenId)
    {
        require(listings[nftAddress][tokenId].price > 0, "Not listed");
        _;
    }

    event ListingCreated
    (
        address nftAddress,
        uint256 tokenId,
        uint256 price,
        address seller
    );

    //create listing
    function createListing(address nftAdress, uint256 tokenId, uint256 price) external
    isNotListed(nftAdress,tokenId) isNFTOwner(nftAdress, tokenId)
    {
        require(price > 0, "Price cannot be 0");
        //check if it's listed
        require(listings[nftAdress][tokenId].price == 0, "Already listed");

        //check if caller is the owner of nft and has approved the marketplace
        IERC721 nftContract = IERC721(nftAdress);
 
        require(nftContract.isApprovedForAll(msg.sender, address(this)) || nftContract.getApproved(tokenId) == address(this),
        "No approval");

        listings[nftAdress][tokenId] = Listing(
            {
                price:price,
                seller:msg.sender
            }
        );

        emit ListingCreated(nftAdress, tokenId, price, msg.sender);
    }

    event ListingCanceled(address nftAddress, uint256 tokenId, address seller);

    //cancel listing
    function  cancelListing(address nftAddress,uint256 tokenId) external
    isListed(nftAddress, tokenId)
    isNFTOwner(nftAddress, tokenId)
    {
        delete listings[nftAddress][tokenId];

        emit ListingCanceled(nftAddress, tokenId, msg.sender);
    }

    event ListingUpdated(address nftAddress, uint256 tokenId, uint256 newPrice, address seller);
    //update listing
    function updateListing(address nftAddress, uint256 tokenId, uint256 newPrice) external
    isListed(nftAddress,tokenId)
    isNFTOwner(nftAddress,tokenId)
    {
        require(newPrice > 0, "Price must be > 0");

        listings[nftAddress][tokenId].price = newPrice;

        emit ListingUpdated(nftAddress, tokenId, newPrice, msg.sender);
    }

    event ListingPurchased(address nftAddress, uint256 tokenId, address seller, address buyer);
    //purchase listing

    function purchaseListing(address nftAddress, uint256 tokenId) external payable
    isListed(nftAddress, tokenId)
    {
        Listing memory listing = listings[nftAddress][tokenId];
        
        require(listing.price == msg.value, "incorred eth supplied");

        delete listings[nftAddress][tokenId];

        //transfer
        IERC721(nftAddress).safeTransferFrom(listing.seller, msg.sender, tokenId);

        //transfer amount of eth to seller
        (bool success, ) = payable(listing.seller).call{value:msg.value}("");
        require(success, "failed to transfer");

        emit ListingPurchased(nftAddress,tokenId,listing.seller, msg.sender);
    }
}