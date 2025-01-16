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
    mapping(uint256 => string) public weekURI;

    event MinterUpdated(address indexed previousMinter, address indexed newMinter);
    event WeekURIUpdated(uint256 indexed week, string uri);

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
        address owner = ownerOf(tokenId);
        
        string memory metadata = string(abi.encodePacked(
            '{',
            '"name": "WeeklyHackathon Vote - Week ', Strings.toString(info.week), '",',
            '"description": "Proof of vote for WeeklyHackathon Week ', Strings.toString(info.week), '",',
            '"image": "', weekURI[info.week], '",',
            '"attributes": [',
                '{"trait_type": "owner", "value": "', addressToString(owner), '"},',
                '{"trait_type": "voter", "value": "', addressToString(info.voter), '"},',
                '{"trait_type": "vote_count", "value": ', Strings.toString(info.voteCount), '}',
            ']',
            '}'
        ));

        return string(abi.encodePacked(
            'data:application/json;base64,',
            Base64.encode(bytes(metadata))
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

    /**
     * @dev Sets the URI for a specific week
     * @param week The week number
     * @param uri The URI to set
     */
    function setWeekURI(uint256 week, string calldata uri) external onlyOwner {
        weekURI[week] = uri;
        emit WeekURIUpdated(week, uri);
    }
}
