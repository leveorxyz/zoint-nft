// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTFactory is IERC721Receiver{
    mapping (string => address) private nftAddress;
    mapping (string => address) private nftMinter;
    mapping (string => address) private nftOwner;

    function createNFT(
        string memory _nftName,
        string memory _nftSymbol,
        string memory _nftDescription,
        string memory _nftUid,
        uint _nftPrice
    ) external {
        ZointNFT zointNFT = new ZointNFT(_nftName, _nftSymbol, _nftDescription, _nftUid, _nftPrice);
        nftAddress[_nftUid] = address(zointNFT);
        nftOwner[_nftUid] = msg.sender;
        nftMinter[_nftUid] = msg.sender;
    }

    function getNFTAddress(string memory _uid) external view returns(address) {
        return nftAddress[_uid];
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure override(IERC721Receiver) returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

contract ZointNFT is ERC721, ERC721Burnable, Ownable {
    string private _description;
    string private _uid;
    uint private _price;

    constructor(string memory name_, string memory symbol_, string memory description_, string memory uid_, uint price_) ERC721(name_, symbol_) {
        _description = description_;
        _uid = uid_;
        _price = price_;
    }

    function getInfo() external view returns (string memory, string memory, string memory, string memory, uint) {
        return (name(), symbol(), _description, _uid, _price);
    }

    function safeMint(address to, uint256 tokenId) public onlyOwner {
        _safeMint(to, tokenId);
    }

    function updatePrice(uint price_) external onlyOwner {
        _price = price_;
    }
}