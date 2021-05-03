/**
 *Submitted for verification at Etherscan.io on 2020-11-15
*/

//pragma solidity ^0.5.0;
pragma solidity >=0.5 <0.7.17;

library Address {
    function isContract(address account) internal pure returns (bool) {
        require(account != address(0), "isContract zero address");
        uint256 size;
        return size > 0;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

library EnumerableSet {
    struct Set {
        bytes32[] _values;
        mapping (bytes32 => uint256) _indexes;
    }
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {
        uint256 valueIndex = set._indexes[value];
        if (valueIndex != 0) { // Equivalent to contains(set, value)
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;
            bytes32 lastvalue = set._values[lastIndex];
            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based
            set._values.pop();
            delete set._indexes[value];
            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {return set._indexes[value] != 0;}
    function _length(Set storage set) private view returns (uint256) {return set._values.length;}
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }
    struct AddressSet {Set _inner;}
    function add(AddressSet storage set, address value) internal returns (bool) {return _add(set._inner, bytes32(uint256(value)));}
    function remove(AddressSet storage set, address value) internal returns (bool) {return _remove(set._inner, bytes32(uint256(value)));}
    function contains(AddressSet storage set, address value) internal view returns (bool) {return _contains(set._inner, bytes32(uint256(value)));}
    function length(AddressSet storage set) internal view returns (uint256) {return _length(set._inner);}function at(AddressSet storage set, uint256 index) internal view returns (address) {return address(uint256(_at(set._inner, index)));}
    struct UintSet {Set _inner;}
    function add(UintSet storage set, uint256 value) internal returns (bool) {return _add(set._inner, bytes32(value));}
    function remove(UintSet storage set, uint256 value) internal returns (bool) {return _remove(set._inner, bytes32(value));}
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {return _contains(set._inner, bytes32(value));}
    function length(UintSet storage set) internal view returns (uint256) {return _length(set._inner);}
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {return uint256(_at(set._inner, index));}
}

library Counters {
    using SafeMath for uint256;
    struct Counter {uint256 _value;}
    function current(Counter storage counter) internal view returns (uint256) {return counter._value;}
    function increment(Counter storage counter) internal {counter._value += 1;}
    function decrement(Counter storage counter) internal {counter._value = counter._value.sub(1);}
    
    
    
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface ERC721Metadata{
  function name() external view returns (string memory _name);
  function symbol() external view returns (string memory _symbol);
  function tokenURI(uint256 _tokenId) external view returns (string memory);
}

contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;
    mapping(bytes4 => bool) private _supportedInterfaces;
    constructor () internal {}
    function supportsInterface(bytes4 interfaceId) external view returns (bool) {return _supportedInterfaces[interfaceId];}
    function _registerInterface(bytes4 interfaceId) internal {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}

contract IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed coinowner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed coinowner, address indexed operator, bool approved);
    function balanceOf(address owner) public view returns (uint256 balance);
    //function ownerOf(uint256 tokenId) public view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId) public;
    function transferFrom(address from, address to, uint256 tokenId) public;
    function approve(address to, uint256 tokenId) public;
    function getApproved(uint256 tokenId) public view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) public;
    function isApprovedForAll(address owner, address operator) public view returns (bool);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
} 

contract IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) public returns (bytes4);
}

contract ERC721 is ERC165, IERC721 {
    using SafeMath for uint256;
    using Address for address;
    using Counters for Counters.Counter;
    using EnumerableSet for EnumerableSet.UintSet;
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;
    mapping (uint256 => address) private _tokenOwner;
    mapping (uint256 => address) private _tokenApprovals;
    mapping (address => mapping (address => bool)) private _operatorApprovals;
    mapping (uint256 => string) private _tokenURIs;
    mapping (address => EnumerableSet.UintSet) private _holderTokens;
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;
    mapping(address => mapping(bytes32 => string)) user_dataList;
    address public owner;
    constructor () public {_registerInterface(_INTERFACE_ID_ERC721);}
    
    struct EaCard {
        string  name;
        uint256 cardprice;
        string stakingto;
    }
    
    mapping(uint256 => EaCard) public Cards_list;
    
    function ownerOf(uint256 tokenId) public view returns (address) {
        address coinowner = _tokenOwner[tokenId];
        require(coinowner != address(0), "ERC721: owner query for nonexistent token");
        return coinowner;
    }
    function approve(address to, uint256 tokenId) public {
        address coinowner = ownerOf(tokenId);
        require(to != coinowner, "ERC721: approval to current owner");
        require(msg.sender == coinowner || isApprovedForAll(owner, msg.sender),
            "ERC721: approve caller is not owner nor approved for all"
        );
        _tokenApprovals[tokenId] = to;
        emit Approval(coinowner, to, tokenId);
    }
    function getApproved(uint256 tokenId) public view returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");
        return _tokenApprovals[tokenId];
    }
    function setApprovalForAll(address to, bool approved) public {
        require(to != msg.sender, "ERC721: approve to caller");
        _operatorApprovals[msg.sender][to] = approved;
        emit ApprovalForAll(msg.sender, to, approved);
    }
    function isApprovedForAll(address coinowner, address operator) public view returns (bool) {
        return _operatorApprovals[coinowner][operator];
    }
    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
    }
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {
        transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }
    
    
    
    function _burn(address coinowner, uint256 tokenId) internal {
        require(ownerOf(tokenId) == coinowner, "ERC721: burn of token that is not own");
        _clearApproval(tokenId);
        _tokenOwner[tokenId] = address(0);
        _holderTokens[coinowner].remove(tokenId);
        emit Transfer(coinowner, address(0), tokenId);
    }
    function _burn(uint256 tokenId) internal {
        _burn(ownerOf(tokenId), tokenId);
    }
    
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data) internal returns (bool){
        if (!to.isContract()) {return true;}
        bytes4 retval = IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    }
    function _clearApproval(uint256 tokenId) private {
        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }
    }
    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {return "0";}
        uint j = _i; uint len;
        while (j != 0) {
		len++;j /= 10;
		}
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
		bstr[k--] = byte(uint8(48 + _i % 10));_i /= 10;
		}
        return string(bstr);
    }
    function concatStrng(string memory _a, string memory _b) internal pure returns (string memory){
        bytes memory bytes_a = bytes(_a);
        bytes memory bytes_b = bytes(_b);
        string memory length_ab = new string(bytes_a.length + bytes_b.length);
        bytes memory bytes_c = bytes(length_ab);
        uint k = 0;
        for (uint256 i = 0; i < bytes_a.length; i++) bytes_c[k++] = bytes_a[i];
        for (uint256 i = 0; i < bytes_b.length; i++) bytes_c[k++] = bytes_b[i];
        return string(bytes_c);
    }
    function _mint(address to, uint256 tokenId) internal {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");
        _tokenOwner[tokenId] = to;
        _holderTokens[to].add(tokenId);
        emit Transfer(address(0), to, tokenId);
    }
    function tokenOfOwnerByIndex(address holder, uint256 index) public view returns (uint256) {
        return _holderTokens[holder].at(index);
    }
    
    function balanceOf(address coinowner) public view returns (uint256) {
        require(coinowner != address(0), "ERC721: balance query for the zero address");
        return _holderTokens[coinowner].length();
    }
    function _gettokenURI(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        string memory _tokenURI = _tokenURIs[tokenId];
        return _tokenURI;
    }
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }
    
    function balanceByAddressAll(address holder) public view returns (string memory) {
        require(holder != address(0), "ERC721: balance query for the zero address");
        uint256 ns = _holderTokens[holder].length();
        string memory _a1 = '[';
        for(uint8 i = 0; i < ns; i++ ){
            uint256 ea = _holderTokens[holder].at(i);
            string memory No = uint2str(ea);
            if( i > 0 ) _a1 = concatStrng(_a1, ',');
            _a1 = concatStrng(_a1, No);
            
        }
        _a1 = concatStrng(_a1, ']');
        return _a1;
    }
    
    function transferFrom(address from, address to, uint256 tokenId) public {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
        _transferFrom(from, to, tokenId);
    }
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address coinowner = ownerOf(tokenId);
        return (spender == owner || spender == coinowner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }
    function _exists(uint256 tokenId) internal view returns (bool) {
        address Coinowner = _tokenOwner[tokenId];
        return Coinowner != address(0);
    }
    function _transferFrom(address from, address to, uint256 tokenId) internal {
        require(ownerOf(tokenId) == from || from == owner , "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");
        _clearApproval(tokenId);
        _tokenOwner[tokenId] = to;
        address ThistokenOwner = ownerOf(tokenId);
        _holderTokens[ThistokenOwner].remove(tokenId);
        _holderTokens[to].add(tokenId);
        emit Transfer(ThistokenOwner, to, tokenId);
    }
    
    
    function getStringData(bytes32 key) public view returns (string memory) {
        return user_dataList[msg.sender][key];
    }
    function setStringData(bytes32 key, string memory value) public {
        user_dataList[msg.sender][key] = value;
    }
}


contract KayboMon is ERC721{
    string public _name;
    string public _symbol;
    uint8 public _decimals;
    uint256 public _totalSupply;
    uint256 public prefix;
   
    string private baseImageUrl;
    string private baseMeta;
    
    constructor () public {
        _name ="Kaybo mon";
        _symbol ="KMON";
        _decimals =0;
        _totalSupply = 0;
        prefix = 100000;
        baseImageUrl = "https://kmon.io/datas/";
        baseMeta = "https://kmon.io/kmon/";
        owner = msg.sender; 
    }
    function _setCardPrice( uint256 cardId,uint256 price ) internal {Cards_list[cardId].cardprice = price;}
    function _setCardName( uint256 cardId,string memory cardname ) internal {Cards_list[cardId].name = cardname;}
    function _setbaseImageUrl( string memory change_url ) internal {baseImageUrl = change_url;}
    function setbaseImageUrl(string memory change_url) public {
        require(owner == msg.sender);
        _setbaseImageUrl(change_url);
    }
    function _setbaseMeta( string memory change_url ) internal {baseMeta = change_url;}
    function setbaseMeta(string memory change_url) public {
        require(owner == msg.sender);
        _setbaseMeta(change_url);
    }
    
    function setCardPrice(uint256 cardId,uint256 price ) public {
        require(owner == msg.sender);
        _setCardPrice(cardId,price);
    }
    
    function setCardName(uint256 cardId,string memory newexpress ) public {
        require(owner == msg.sender);
        _setCardName(cardId,newexpress);
    }
    function setCarddescription(uint256 cardId,string memory description ) public {
        require(owner == msg.sender);
        EaCard memory ea = Cards_list[cardId];
        string memory No = uint2str(cardId);
        
        string memory _a1 = '';
        _a1 = concatStrng('{"name": "', ea.name);
        _a1 = concatStrng(_a1, '","image":"');
        _a1 = concatStrng(_a1, baseImageUrl);
        _a1 = concatStrng(_a1, No);
        _a1 = concatStrng(_a1, '.png","description":"');
        _a1 = concatStrng(_a1, description);
        _a1 = concatStrng(_a1, '"}');
        
        _setTokenURI(cardId,_a1);   
    }
    
    function getCardInfo( uint256 tokenId) public view returns (string memory cardname, uint256 cardprice , string memory stakingadr, address _tokenOwner){
        EaCard memory ea = Cards_list[tokenId];
        return (ea.name, ea.cardprice, ea.stakingto, ownerOf(tokenId));
    }
    function getbaseMeta() public view returns (string memory) {return baseMeta;}
    function getbaseImageUrl() public view returns (string memory) {return baseImageUrl;}
    function Contadmin() public view returns (address) {return owner;}
    function totalSupply() public view returns (uint256) {return _totalSupply;}
    function name() public view returns (string memory) {return _name;}
    function symbol() public view returns (string memory) {return _symbol;}
    function GettokenURI( uint256 cardId ) public view returns (string memory){
        return _gettokenURI(cardId);
    }
    
    function mintCard(string memory cardname, address account, uint256 price,string memory carddescription) public {
        require(owner == msg.sender); // Only the Owner can create Items
        uint256 cardId = prefix + _totalSupply; // Unique card ID
        Cards_list[cardId] =EaCard(cardname, price,"" );
        _mint(account, cardId ); // Mint a new card
        
        string memory No = uint2str(cardId);
        string memory _a1 = '';
        if( bytes(cardname).length > 0 ){
             _a1 = concatStrng('{"name":"', cardname);
        }else{
             _a1 = concatStrng('{"name": "MCM #', No);
        }
        _a1 = concatStrng(_a1, '","image":"');
        _a1 = concatStrng(_a1, baseImageUrl);
        _a1 = concatStrng(_a1, No);
        _a1 = concatStrng(_a1, '.png","description":"');
        _a1 = concatStrng(_a1, carddescription);
        _a1 = concatStrng(_a1, '"}');
        _setTokenURI(cardId,_a1);    
        _totalSupply++;
    }
    
    function mintCardTOmain(address account , uint256 _numberOfToken , string memory carddescription, uint256 price ) public {
        require(owner == msg.sender); // Only the Owner can create Items
        for(uint256 i = 0; i < _numberOfToken; i++) {
            uint256 cardId = prefix + _totalSupply; // Unique card ID
            Cards_list[cardId]= EaCard("AutoGen", price, "" );
            _mint(account, cardId); // Mint a new card
            string memory No = uint2str(cardId);
            string memory _a1 = '';
            _a1 = concatStrng('{"name": "MCM #', No);
            _a1 = concatStrng(_a1, '","image":"');
            _a1 = concatStrng(_a1, baseImageUrl);
            _a1 = concatStrng(_a1, No);
            _a1 = concatStrng(_a1, '.png","description":"');
            _a1 = concatStrng(_a1, carddescription);
            _a1 = concatStrng(_a1, '"}');
            
            _setTokenURI(cardId,_a1);    
            _totalSupply++;
        }
    }
}
