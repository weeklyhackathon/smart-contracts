// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

/**
 * @title IVotedPoap
 * @dev ERC721 token for Weekly Hackathon voting participation proof
 */
contract IVotedPoap is ERC721, Ownable {
    address public minter;
    uint256 private _nextTokenId;

    struct VoteInfo {
        uint256 week;
        address voter;
        uint256 voteCount;
    }

    // Mapping from token ID to vote information
    mapping(uint256 => VoteInfo) public voteInfo;

    event MinterUpdated(address indexed previousMinter, address indexed newMinter);

    modifier onlyMinter() {
        require(msg.sender == minter, "Only minter can call");
        _;
    }

    constructor(address initialMinter) ERC721("WeeklyHackathon Vote POAP", "IVOTED") Ownable(msg.sender) {
        require(initialMinter != address(0), "Invalid minter");
        minter = initialMinter;
    }

    function setMinter(address newMinter) external onlyOwner {
        require(newMinter != address(0), "Invalid minter");
        address oldMinter = minter;
        minter = newMinter;
        emit MinterUpdated(oldMinter, newMinter);
    }

    function mint(
        address to,
        uint256 week,
        uint256 voteCount
    ) external onlyMinter returns (uint256) {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);

        voteInfo[tokenId] = VoteInfo({
            week: week,
            voter: to,
            voteCount: voteCount
        });

        return tokenId;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);
        VoteInfo memory info = voteInfo[tokenId];
        
        string memory svg = string(abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" width="400" height="400"><style>text { font-family: monospace; fill: white; }</style><rect width="400" height="400" fill="#1E1E1E"/><text x="20" y="40">I Voted POAP</text>',
            '<text x="20" y="80">Week: ', Strings.toString(info.week), '</text>',
            '<text x="20" y="120">Voter: ', addressToString(info.voter), '</text>',
            '<text x="20" y="160">Votes: ', Strings.toString(info.voteCount), '</text>',
            '</svg>'
        ));

        string memory encodedSvg = Base64.encode(bytes(svg));
        
        return string(abi.encodePacked(
            'data:image/svg+xml;base64,',
            encodedSvg
        ));
    }

    function addressToString(address addr) internal pure returns (string memory) {
        return string(abi.encodePacked(
            "0x",
            toHexString(uint256(uint160(addr)), 20)
        ));
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length);
        for (uint256 i = 2 * length; i > 0;) {
            unchecked {
                buffer[--i] = bytes1(uint8(digits(uint8(value & 0xf))));
                value >>= 4;
            }
        }
        return string(buffer);
    }

    function digits(uint8 value) internal pure returns (uint8) {
        if (value < 10) {
            return uint8(bytes1('0')) + value;
        } else {
            return uint8(bytes1('a')) + value - 10;
        }
    }
}
