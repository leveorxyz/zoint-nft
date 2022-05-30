// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

contract NFTFactory {
    struct NFT {
        string name;
        string uid;
        string symbol;
    }

    NFT[] private mintedNFTs;
    mapping (string => address) private nftMinter;
    mapping (string => address) private nftOwner;

    modifier uniqueId(string memory _uid) {
        require(nftOwner[_uid] == address(0), "uid not unique");
        _;
    }

    function createNFT(
        string memory _nftName,
        string memory _nftSymbol,
        string memory _nftUid
    ) external uniqueId(_nftUid) {
        NFT memory nft = NFT({
            name: _nftName,
            symbol: _nftSymbol,
            uid: _nftUid
        });

        nftOwner[_nftUid] = msg.sender;
        nftMinter[_nftUid] = msg.sender;
        mintedNFTs.push(nft);

    }

    function getMintedNFTs() external view returns(NFT[] memory) {
        return mintedNFTs;
    }

    function getMintedNFTInfo(string memory _uid) external view returns(address) {
        return nftMinter[_uid];
    }
}