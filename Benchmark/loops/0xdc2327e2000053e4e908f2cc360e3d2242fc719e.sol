/**
 *Submitted for verification at Etherscan.io on 2019-10-27
*/

//pragma solidity ^0.5.11;
pragma solidity >=0.5 <0.7.17;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * [EIP](https://eips.ethereum.org/EIPS/eip-165).
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others (`ERC165Checker`).
 *
 * For an implementation, see `ERC165`.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * [EIP section](https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified)
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


/**
 * @dev Required interface of an ERC721 compliant contract.
 */
contract IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of NFTs in `owner`'s account.
     */
    function balanceOf(address owner) public view returns (uint256 balance);

    /**
     * @dev Returns the owner of the NFT specified by `tokenId`.
     */
    function ownerOf(uint256 tokenId) public view returns (address owner);

    /**
     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
     * another (`to`).
     *
     * 
     *
     * Requirements:
     * - `from`, `to` cannot be zero.
     * - `tokenId` must be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this
     * NFT by either `approve` or `setApproveForAll`.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public;
    /**
     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
     * another (`to`).
     *
     * Requirements:
     * - If the caller is not `from`, it must be approved to move this NFT by
     * either `approve` or `setApproveForAll`.
     */
    function transferFrom(address from, address to, uint256 tokenId) public;
    function approve(address to, uint256 tokenId) public;
    function getApproved(uint256 tokenId) public view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) public;
    function isApprovedForAll(address owner, address operator) public view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
}


contract OldToken is IERC721 {

    function getCard(uint id) public view returns (uint16, uint16);
    function totalSupply() public view returns (uint);

}

contract ICards is IERC721 {

    function getDetails(uint tokenId) public view returns (uint16 proto, uint8 quality);
    function setQuality(uint tokenId, uint8 quality) public;
    function burn(uint tokenId) public;
    function batchMintCards(address to, uint16[] memory _protos, uint8[] memory _qualities) public returns (uint);
    function mintCards(address to, uint16[] memory _protos, uint8[] memory _qualities) public returns (uint);
    function mintCard(address to, uint16 _proto, uint8 _quality) public returns (uint);
    function batchSize() public view returns (uint);
}



contract DirectMigration {

    uint threshold;
    OldToken old;
    ICards cards;
    uint limit;

    event Migrated(address indexed user, uint oldStart, uint oldEnd, uint newStart);
    event NonGenesisMigrated(address indexed user, uint oldID, uint newID);

    constructor(OldToken _old, ICards _cards, uint _threshold, uint _limit) public {
        old = _old;
        cards = _cards;
        threshold = _threshold;
        limit = _limit;
    }

    struct IM {
        uint16 proto;
        uint16 purity;

        uint16 p;
        uint8 q;
        uint id;
    }

    uint public migrated;

    function multiMigrate() public {
        while (gasleft() > 3000000) {
            activatedMigration();
        }
    }

    function activatedMigration() public returns (uint current) {
        uint start = migrated;
        address first = old.ownerOf(start);
        current = start;
        address owner = first;
        uint last = old.totalSupply();

        while (owner == first && current < start + limit) {
            current++;
            if (current >= last) {
                break;
            }
            owner = old.ownerOf(current);
        }

        uint size = current - start;

        require(size > 0, "size is zero");

        uint16[] memory protos = new uint16[](size);
        uint8[] memory qualities = new uint8[](size);

        // dodge the stack variable limit
        IM memory im;
        uint count = 0;

        for (uint i = 0; i < size; i++) {
            (im.proto, im.purity) = old.getCard(start+i);
            im.p = convertProto(im.proto);
            im.q = convertPurity(im.purity);
            if (im.p > 377) {
                im.id = cards.mintCard(first, im.p, im.q);
                emit NonGenesisMigrated(first, start + i, im.id);
            } else {
                protos[count] = im.p;
                qualities[count] = im.q;
                count++;
            }
        }

        // change lengths back to count
        assembly{mstore(protos, count)}
        assembly{mstore(qualities, count)}

        uint newStart;
        if (count <= threshold) {
            newStart = cards.mintCards(first, protos, qualities);
        } else {
            newStart = cards.batchMintCards(first, protos, qualities);
        }

        migrated = current;

        emit Migrated(first, start, current, newStart);

        return current;
    }


    function convertPurity(uint16 purity) public pure returns (uint8) {
        return uint8((purity / 1000) + 2);
    }

    function convertProto(uint16 proto) public view returns (uint16) {
        if (proto >= 1 && proto <= 377) {
            return proto;
        }
        // first phoenix
        if (proto == 380) {
            return 400;
        }
        // light's bidding
        if (proto == 381) {
            return 401;
        }
        // chimera
        if (proto == 394) {
            return 402;
        }
        // etherbots
        (bool found, uint index) = getEtherbotsIndex(proto);
        if (found) {
            return uint16(380 + index);
        }
        // hyperion
        if (proto == 378) {
            return 65000;
        }
        // prometheus
        if (proto == 379) {
            return 65001;
        }
        // atlas
        if (proto == 383) {
            return 65002;
        }
        // tethys
        if (proto == 384) {
            return 65003;
        }
        require(false, "unrecognised proto");
    }

    uint16[] internal ebs = [400, 413, 414, 421, 427, 428, 389, 415, 416, 422, 424, 425, 426, 382, 420, 417];

    function getEtherbotsIndex(uint16 proto) public view returns (bool, uint16) {
        for (uint16 i = 0; i < ebs.length; i++) {
            if (ebs[i] == proto) {
                return (true, i);
            }
        }
        return (false, 0);
    }

}
