// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.25 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "forge-std/src/console2.sol";

contract MyNFT is ERC721 {
    constructor() ERC721("MyNFT", "MN") {
        _mint(msg.sender, 10);
    }
}

// If Alice deposits an NFT (say id 10 without loss of generality)
// Bob can steal it
contract Game {
    IERC721 nft;

    mapping(uint256 id => address depositor) originalOwner;

    constructor(IERC721 nft_) {
        nft = nft_;
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    )
        external
        returns (bytes4)
    {
        console2.log(operator);
        console2.log(from);
        console2.log(tokenId);
        console2.logBytes(data);
        originalOwner[tokenId] = from;
        return IERC721Receiver.onERC721Received.selector;
    }

    // token is not deleted on transfer
    // second deposit from same owner will erase the first NFT
    //
    function withdraw(uint256 tokenId) external {
        require(originalOwner[tokenId] == msg.sender);
        delete originalOwner[tokenId];
        nft.safeTransferFrom(address(this), msg.sender, tokenId);
    }
}
