/**
 *Submitted for verification at Etherscan.io on 2019-11-02
*/

//pragma solidity 0.5.11;
pragma solidity >=0.5 <0.7.17;

contract IPackFour {

    struct Purchase {
        uint16 current;
        uint16 count;
        address user;
        uint randomness;
        uint64 commit;
    }

    function purchases(uint p) public view returns (
        uint16 current,
        uint16 count,
        address user,
        uint256 randomness,
        uint64 commit
    );

    function predictPacks(uint id) public view returns (uint16[] memory protos, uint16[] memory purities);

}

contract BaseMigration {

    function convertPurity(uint16 purity)
        public
        pure
        returns (uint8)
    {
        return uint8(4 - (purity / 1000));
    }

    function convertProto(uint16 proto)
        public
        view
        returns (uint16)
    {
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
        require(false, "BM: unrecognised proto");
    }

    uint16[] internal ebs = [
        400,
        413,
        414,
        421,
        427,
        428,
        389,
        415,
        416,
        422,
        424,
        425,
        426,
        382,
        420,
        417
    ];

    function getEtherbotsIndex(uint16 proto)
        public
        view
        returns (bool, uint16)
    {
        for (uint16 i = 0; i < ebs.length; i++) {
            if (ebs[i] == proto) {
                return (true, i);
            }
        }
        return (false, 0);
    }

}

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


contract ICards is IERC721 {

    struct Batch {
        uint48 userID;
        uint16 size;
    }

    function batches(uint index) public view returns (uint48 userID, uint16 size);

    function userIDToAddress(uint48 id) public view returns (address);

    function getDetails(
        uint tokenId
    )
        public
        view
        returns (
        uint16 proto,
        uint8 quality
    );

    function setQuality(
        uint tokenId,
        uint8 quality
    ) public;

    function mintCards(
        address to,
        uint16[] memory _protos,
        uint8[] memory _qualities
    )
        public
        returns (uint);

    function mintCard(
        address to,
        uint16 _proto,
        uint8 _quality
    )
        public
        returns (uint);

    function burn(uint tokenId) public;

    function batchSize()
        public
        view
        returns (uint);
}


contract v1Migration is BaseMigration {

    ICards cards;
    uint public limit;

    constructor(
        ICards _cards,
        address[] memory _packs,
        uint _limit
    ) public {

        for (uint i = 0; i < _packs.length; i++) {
            canMigrate[_packs[i]] = true;
        }

        cards = _cards;
        limit = _limit;
    }

    mapping (address => bool) public canMigrate;

    mapping (address => mapping (uint => bool)) public v1Migrated;

    event Migrated(
        address indexed user,
        address indexed pack,
        uint indexed id,
        uint start,
        uint end,
        uint startID
    );

    struct StackDepthLimit {
        uint16[] oldProtos;
        uint16[] purities;
        uint8[] qualities;
        uint16[] protos;
    }

    function migrate(
        IPackFour pack,
        uint id
    )
        public
    {

        require(
            canMigrate[address(pack)],
            "V1: must be migrating from an approved pack"
        );

        require(
            !v1Migrated[address(pack)][id],
            "V1: must not have been already migrated"
        );

        (
            uint16 current,
            uint16 count,
            address user,
            uint256 randomness,
        ) = pack.purchases(id);

        // Check if randomness set
        require(
            randomness != 0,
            "V1: must have had randomness set"
        );

        // removed variable due to stack limit
        uint remaining = ((count - current) * 5);

        require(
            remaining > 0,
            "V1: no more cards to migrate"
        );

        require(limit >= remaining, "too many cards remaining");

        StackDepthLimit memory sdl;

        sdl.protos = new uint16[](remaining);
        sdl.qualities = new uint8[](remaining);

        // TODO: Do these need to be converted as well?
        (sdl.oldProtos, sdl.purities) = pack.predictPacks(id);

        // Run loop which starts at local counter start of v1Migrated
        uint loopStart = (current * 5);

        // For each element, get the old card and make the
        // appropriate conversion + check not activated
        for (uint i = 0; i < remaining; i++) {
            uint x = loopStart+i;
            sdl.protos[i] = convertProto(sdl.oldProtos[x]);
            sdl.qualities[i] = convertPurity(sdl.purities[x]);
        }

        // Batch Mint cards (details passed as function args)
        uint startID = cards.mintCards(user, sdl.protos, sdl.qualities);

        v1Migrated[address(pack)][id] = true;

        uint loopEnd = loopStart + remaining;

        emit Migrated(user, address(pack), id, loopStart, loopEnd, startID);
    }

}
