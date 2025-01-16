// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/utils/Strings.sol";

library VotingLib {
    function getEthSignedMessageHash(bytes32 _messageHash) internal pure returns (bytes32) {
        /*
        Signature is produced by signing a keccak256 hash with the following format:
        "\x19Ethereum Signed Message\n" + len(msg) + msg
        */
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }

    function toAsciiString(address x) internal pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint(uint160(x)) / (2 ** (8 * (19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2 * i] = char(hi);
            s[2 * i + 1] = char(lo);
        }
        return string(s);
    }

    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

    function arrayToString(uint256[] calldata arr) internal pure returns (string memory) {
        if (arr.length == 0) return "";
        
        string memory result = Strings.toString(arr[0]);
        for (uint256 i = 1; i < arr.length;) {
            result = string.concat(result, ",", Strings.toString(arr[i]));
            unchecked { i++; }
        }
        return result;
    }

    function messageHash(
        address voter,
        uint256 week,
        uint256[] calldata allocations // ALWAYS in descending order
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(
            "Weekly Hackathon week ",
            Strings.toString(week),
            " voter ",
            toAsciiString(voter),
            " allocations: ",
            arrayToString(allocations)
        ));
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature) internal pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig) internal pure returns (bytes32 r, bytes32 s, uint8 v) {
        require(sig.length == 65, "invalid signature length");

        assembly {
            /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }
    }

    function verifyVote(
        uint256 week,
        address voter,
        uint256[] calldata allocations,
        bytes calldata signature,
        address signer
    ) internal pure returns (bool) {
        bytes32 mh = messageHash(voter, week, allocations);
        bytes32 signatureHash = getEthSignedMessageHash(mh);
        return signer == recoverSigner(signatureHash, signature);
    }
}
