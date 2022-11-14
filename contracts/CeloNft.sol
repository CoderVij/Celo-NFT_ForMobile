//SPDX-License-Identifier:Unlicensed

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

//Simple NFT contract
contract CeloNft is ERC721
{
    constructor() ERC721("CeloNFT", "cNFT")
    {
        for(uint i=0;i <5; i++)
        {
            _mint(msg.sender, i);
        }
    }

    //metadata
    function tokenURI(uint) public pure override returns(string memory)
    {
        return "ipfs://QmTy8w65yBXgyfG2ZBg5TrfB2hPjrDQH3RCQFJGkARStJb";
    }
}