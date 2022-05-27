// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
import "@openzeppelin/contracts@4.4.0/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTFactory is IERC721Receiver{

    struct MintedNFT {
        string _uid;
        address _address;
    }

    MintedNFT[] private mintedNFTs;
    mapping (string => address) private nftAddress;
    mapping (string => address) private nftMinter;
    mapping (string => address) private nftOwner;
    address private constant platformAddress = 0xAaC0c3338A52e5D8D98bDdf8C5C5F54e093Ac49f;
    address private constant feeToken = 0x11D634457F99595aBE7B582739fd52b7ed48995A;
    uint private constant fee = 1000000000000;

    modifier uniqueId(string memory _uid) {
        require(nftAddress[_uid] == address(0), "uid not unique");
        _;
    }

    modifier validId(string memory _uid) {
        require(nftAddress[_uid] != address(0), "invalid uid");
        _;
    }

    modifier minimumBalance() {
        require(IERC20(feeToken).balanceOf(msg.sender) >= fee, "not enough balance");
        _;
    }

    modifier onlyOwner(string memory _uid) {
        require(nftOwner[_uid] == msg.sender, "not owner");
        _;
    }

    event NFTCreated(address _address);

    function createNFT(
        string memory _nftName,
        string memory _nftSymbol,
        string memory _nftDescription,
        string memory _nftUid,
        uint _nftPrice
    ) external payable uniqueId(_nftUid) minimumBalance{
        // Take the security fee
        bool sent = IERC20(feeToken).transferFrom(msg.sender, platformAddress, fee);
        require(sent, "transaction failed");

        // Mint nft
        ZointNFT zointNFT = new ZointNFT(_nftName, _nftSymbol, _nftDescription, _nftUid, _nftPrice);
        zointNFT.safeMint(address(this), 1);

        // Emit event
        emit NFTCreated(address(zointNFT));

        // Update information
        nftAddress[_nftUid] = address(zointNFT);
        nftOwner[_nftUid] = msg.sender;
        nftMinter[_nftUid] = msg.sender;
        mintedNFTs.push(MintedNFT({
            _uid: _nftUid,
            _address: address(zointNFT)
        }));

    }

    function getNFTInfo(string memory _uid) external view validId(_uid) returns(string memory, string memory, string memory, string memory, uint) {
        return ZointNFT(nftAddress[_uid]).getInfo();
    }

    function getMintedNFTs() external view returns(MintedNFT[] memory) {
        return mintedNFTs;
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