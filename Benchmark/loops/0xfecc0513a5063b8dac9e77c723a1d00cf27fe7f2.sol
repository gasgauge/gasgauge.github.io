/**
 *Submitted for verification at Etherscan.io on 2019-11-19
*/

//pragma solidity 0.5.11;
pragma solidity >=0.5 <0.7.17;

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

contract Pack {

    enum Type {
        Rare,
        Epic,
        Legendary,
        Shiny
    }

}

contract LegacyICards {

    enum Rarity {
        Common,
        Rare,
        Epic,
        Legendary,
        Mythic
    }

    function getRandomCard(
        Rarity rarity,
        uint16 random
    )
        public
        view
        returns (uint16);

    function createCard(
        address user,
        uint16 proto,
        uint16 purity
    )
        public
        returns (uint);


}

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


/**
 * This file's sole purpose is because in v2 Migrations importing PackFive.sol to use the PackFive 
 * type causes a circular depedency via the import of ICards inside RarityProvider.sol.
 * We can probably get rid of this in the case v2 Migrations aren't needed.
 */

contract IPackFive {

    struct Purchase {
        uint count;
        uint randomness;
        uint[] state;
        Pack.Type packType;
        uint64 commit;
        uint64 lockup;
        bool revoked;
        address user;
    }

    Purchase[] public purchases;

    function getPurchaseState(uint purchaseID) public view returns (uint[] memory state);
    function predictPacks(uint id) external view returns (uint16[] memory protos, uint16[] memory purities);
    function canActivatePurchase(uint id) public view returns (bool);

}


contract RarityProvider {

    LegacyICards cards;

    constructor(LegacyICards _cards) public {
        cards = _cards;
    }

    struct RandomnessComponents {
        uint random;
        uint32 rarity;
        uint16 quality;
        uint16 purity;
        uint16 proto;
    }

    // return 'length' bytes of 'num' starting at 'start'
    function extract(uint num, uint length, uint start) internal pure returns (uint) {
        return (((1 << (length * 8)) - 1) & (num >> ((start - 1) * 8)));
    }

    // divides the random seed into components
    function getComponents(
        uint cardIndex, uint rand
    ) internal pure returns (
        RandomnessComponents memory
    ) {
        uint random = uint(keccak256(abi.encodePacked(cardIndex, rand)));
        return RandomnessComponents({
            random: random,
            rarity: uint32(extract(random, 4, 10) % 1000000),
            quality: uint16(extract(random, 2, 4) % 1000),
            purity: uint16(extract(random, 2, 6) % 1000),
            proto: uint16(extract(random, 2, 8) % (2**16-1))
        });
    }

    function getCardDetails(Pack.Type packType, uint cardIndex, uint result) internal view returns (uint16, uint16) {
        if (packType == Pack.Type.Shiny) {
            return _getShinyCardDetails(cardIndex, result);
        } else if (packType == Pack.Type.Legendary) {
            return _getLegendaryCardDetails(cardIndex, result);
        } else if (packType == Pack.Type.Epic) {
            return _getEpicCardDetails(cardIndex, result);
        }
        return _getRareCardDetails(cardIndex, result);
    }

    function _getShinyCardDetails(uint cardIndex, uint result) internal view returns (uint16 proto, uint16 purity) {

        RandomnessComponents memory rc = getComponents(cardIndex, result);

        LegacyICards.Rarity rarity;

        if (cardIndex % 5 == 0) {
            rarity = _getLegendaryPlusRarity(rc.rarity);
            purity = _getShinyPurityBase(rc.quality) + rc.purity;
        } else if (cardIndex % 5 == 1) {
            rarity = _getRarePlusRarity(rc.rarity);
            purity = _getPurityBase(rc.quality) + rc.purity;
        } else {
            rarity = _getCommonPlusRarity(rc.rarity);
            purity = _getPurityBase(rc.quality) + rc.purity;
        }
        proto = cards.getRandomCard(rarity, rc.proto);
        return (proto, purity);
    }

    function _getLegendaryCardDetails(uint cardIndex, uint result) internal view returns (uint16 proto, uint16 purity) {

        RandomnessComponents memory rc = getComponents(cardIndex, result);

        LegacyICards.Rarity rarity;

        if (cardIndex % 5 == 0) {
            rarity = _getLegendaryPlusRarity(rc.rarity);
        } else if (cardIndex % 5 == 1) {
            rarity = _getRarePlusRarity(rc.rarity);
        } else {
            rarity = _getCommonPlusRarity(rc.rarity);
        }

        purity = _getPurityBase(rc.quality) + rc.purity;

        proto = cards.getRandomCard(rarity, rc.proto);

        return (proto, purity);
    }


    function _getEpicCardDetails(uint cardIndex, uint result) internal view returns (uint16 proto, uint16 purity) {

        RandomnessComponents memory rc = getComponents(cardIndex, result);

        LegacyICards.Rarity rarity;

        if (cardIndex % 5 == 0) {
            rarity = _getEpicPlusRarity(rc.rarity);
        } else {
            rarity = _getCommonPlusRarity(rc.rarity);
        }

        purity = _getPurityBase(rc.quality) + rc.purity;

        proto = cards.getRandomCard(rarity, rc.proto);

        return (proto, purity);
    }

    function _getRareCardDetails(uint cardIndex, uint result) internal view returns (uint16 proto, uint16 purity) {

        RandomnessComponents memory rc = getComponents(cardIndex, result);

        LegacyICards.Rarity rarity;

        if (cardIndex % 5 == 0) {
            rarity = _getRarePlusRarity(rc.rarity);
        } else {
            rarity = _getCommonPlusRarity(rc.rarity);
        }

        purity = _getPurityBase(rc.quality) + rc.purity;

        proto = cards.getRandomCard(rarity, rc.proto);
        return (proto, purity);
    }


    function _getCommonPlusRarity(uint32 rand) internal pure returns (LegacyICards.Rarity) {
        if (rand == 999999) {
            return LegacyICards.Rarity.Mythic;
        } else if (rand >= 998345) {
            return LegacyICards.Rarity.Legendary;
        } else if (rand >= 986765) {
            return LegacyICards.Rarity.Epic;
        } else if (rand >= 924890) {
            return LegacyICards.Rarity.Rare;
        } else {
            return LegacyICards.Rarity.Common;
        }
    }

    function _getRarePlusRarity(uint32 rand) internal pure returns (LegacyICards.Rarity) {
        if (rand == 999999) {
            return LegacyICards.Rarity.Mythic;
        } else if (rand >= 981615) {
            return LegacyICards.Rarity.Legendary;
        } else if (rand >= 852940) {
            return LegacyICards.Rarity.Epic;
        } else {
            return LegacyICards.Rarity.Rare;
        }
    }

    function _getEpicPlusRarity(uint32 rand) internal pure returns (LegacyICards.Rarity) {
        if (rand == 999999) {
            return LegacyICards.Rarity.Mythic;
        } else if (rand >= 981615) {
            return LegacyICards.Rarity.Legendary;
        } else {
            return LegacyICards.Rarity.Epic;
        }
    }

    function _getLegendaryPlusRarity(uint32 rand) internal pure returns (LegacyICards.Rarity) {
        if (rand == 999999) {
            return LegacyICards.Rarity.Mythic;
        } else {
            return LegacyICards.Rarity.Legendary;
        }
    }

    // store purity and shine as one number to save users gas
    function _getPurityBase(uint16 randOne) internal pure returns (uint16) {
        if (randOne >= 998) {
            return 3000;
        } else if (randOne >= 988) {
            return 2000;
        } else if (randOne >= 938) {
            return 1000;
        }
        return 0;
    }

    function _getShinyPurityBase(uint16 randOne) internal pure returns (uint16) {
        if (randOne >= 998) {
            return 3000;
        } else if (randOne >= 748) {
            return 2000;
        } else {
            return 1000;
        }
    }

    function getShine(uint16 purity) public pure returns (uint8) {
        return uint8(purity / 1000);
    }

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
     * NFT by either {approve} or {setApprovalForAll}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public;
    /**
     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
     * another (`to`).
     *
     * Requirements:
     * - If the caller is not `from`, it must be approved to move this NFT by
     * either {approve} or {setApprovalForAll}.
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




contract v2Migration is BaseMigration, RarityProvider {

    ICards cards;
    uint16 public limit;

    constructor(
        LegacyICards _legacy,
        ICards _cards,
        address[] memory _packs,
        uint16 _limit
    )
        public RarityProvider(_legacy)
    {
        for (uint i = 0; i < _packs.length; i++) {
            canMigrate[_packs[i]] = true;
        }

        limit = _limit;
        cards = _cards;
    }

    struct StackDepthLimit {
        uint16 proto;
        uint16 purity;
        uint16[] protos;
        uint8[] qualities;
    }

    mapping (address => bool) public canMigrate;
    mapping (address => mapping (uint => uint16)) public v2Migrated;

    event Migrated(
        address indexed user,
        uint id,
        uint start,
        uint end,
        uint startID
    );

    // PackFive = pack factory which creates packs and cards

    function migrate(
        IPackFive pack,
        uint id
    )
        public
    {
        require(
            canMigrate[address(pack)],
            "V2: must be migrating from an approved pack"
        );

        (uint count, uint randomness,Pack.Type packType,,,, address user) = pack.purchases(id);
        uint[] memory state = pack.getPurchaseState(id);

        require(
            noCardsActivated(state),
            "V2: must have no cards activated"
        );

        // Check if randomness set
        require(
            randomness != 0,
            "V2: must have had randomness set"
        );

        uint16 size = uint16(count * 5);
        require(size > count, "check overflow");

        uint16 migrated = v2Migrated[address(pack)][id];

        // If no cards activated, then we just create all of the cards (count * 5)
        require(
            size > migrated,
            "V2: must not have been migrated previously"
        );

        uint16 remaining = size - migrated;

        uint16 len = remaining > limit ? limit : remaining;

        StackDepthLimit memory sdl;

        sdl.protos = new uint16[](len);
        sdl.qualities = new uint8[](len);

        for (uint16 i = 0; i < len; i++) {
            (sdl.proto, sdl.purity) = getCardDetails(packType, migrated+i, randomness);
            sdl.protos[i] = convertProto(sdl.proto);
            sdl.qualities[i] = convertPurity(sdl.purity);
        }

        // Mint cards (details passed as function args)
        uint startID = cards.mintCards(user, sdl.protos, sdl.qualities);

        emit Migrated(user, id, migrated, len, startID);

        v2Migrated[address(pack)][id] += len;

    }

    function noCardsActivated(
        uint[] memory state
    )
        public
        pure
        returns (bool)
    {
        for (uint i = 0; i < state.length; i++) {
            if (state[i] != 0) {
                return false;
            }
        }
        return true;
    }
}
