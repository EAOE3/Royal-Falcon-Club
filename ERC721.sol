/**
 *Submitted for verification at Etherscan.io on 2021-12-17
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;


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

interface IERC721 is IERC165 {
    
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    function balanceOf(address _owner) external view returns (uint256);

    function ownerOf(uint256 _tokenId) external view returns (address);
    
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external;

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external;

    function transferFrom(address _from, address _to, uint256 _tokenId) external;

    function approve(address _approved, uint256 _tokenId) external;

    function setApprovalForAll(address _operator, bool _approved) external;

    function getApproved(uint256 _tokenId) external view returns (address);

    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
    
}

interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

interface IERC721Metadata is IERC721 {

    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);
    
    function totalSupply() external view returns(uint256);
    
    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

library Strings {

    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

}

contract ERC721 is ERC165, IERC721, IERC721Metadata {
    using Strings for uint256;

    address private _owner;

    mapping(address => bool) private _manager;

    string private uriLink = "";
    
    uint256 private _totalSupply = 5050;

    string private _name = "Royal Falcon Club";
    string private _symbol = "RFC";

    mapping(uint256 => address) private _owners;
    mapping(uint256 => string) private _uri;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    uint256 private _minted;

    bool private _goldMinting = false;//if minting is on or off
    bool private _whiteMinting = false;//if minting is on or off
    bool private _minting = false;//if minting is on or off

    uint256 private _goldPrice = 125000000000000000;
    uint256 private _whitePrice = 150000000000000000;
    uint256 private _publicPrice = 150000000000000000;

    mapping(address => bool) private _goldAccess;
    mapping(address => bool) private _whiteAccess;

    bool private _reveal = false;

    modifier Manager() {
      require(_manager[msg.sender]);
      _;  
    }

    modifier Owner() {
        require(msg.sender == _owner);
      _;  
    }

    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;

        _owner = msg.sender;
        _manager[msg.sender] = true;
    } 
    
    //Read Functions======================================================================================================================================================
    function owner() external view returns (address) {
        return _owner;
    }
    
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC721).interfaceId
            || interfaceId == type(IERC721Metadata).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    
    function totalSupply() external view override returns(uint256){return _totalSupply;}

    function tokenURI(uint256 tokenId) external view override returns (string memory) {
        if(!_reveal) {return string(abi.encodePacked(uriLink, "secret.json"));}
        return string(abi.encodePacked(uriLink, tokenId.toString(), ".json"));

    }
    
    function manager(address user) external view returns(bool) {
        return _manager[user];
    }
    
    //Moderator Functions======================================================================================================================================================

    function setNewOwner(address user) external Owner {
        _owner = user;
    }

    function addManager(address user) external Owner {
        _manager[user] = true;
    }

    function removeManager(address user) external Owner {
        _manager[user] = true;
    }

    function setGoldList(address[] calldata goldenUsers) external Owner {
        //unchecked {
            uint256 size = goldenUsers.length;
            
            for(uint256 t; t < size; ++t) {
                _goldAccess[goldenUsers[t]] = true;
            }
        //}
    }

    function setWhiteList(address[] calldata whiteUsers) external Owner {
        //unchecked {
            uint256 size = whiteUsers.length;
            
            for(uint256 t; t < size; ++t) {
                _whiteAccess[whiteUsers[t]] = true;
            }
        //}
    }

    function adminMint(address to, uint256 amount) external Manager {
        _mint(to, amount);
    }

    function toggleReveal() external Owner {
        _reveal = !_reveal;
    }

    function changeURIlink(string calldata newUri) external Manager {
        uriLink = newUri;
    }

    function changeData(uint256 totalSupply, string calldata name, string calldata symbol) external {
        _totalSupply = totalSupply;
        _name = name;
        _symbol = symbol;
    }

    function changePrices(uint256 goldPrice, uint256 whitePrice, uint256 publicPrice) external Manager {
        _goldPrice = goldPrice;
        _whitePrice = whitePrice;
        _publicPrice = publicPrice;
    }

    function setMinting(bool goldMinting, bool whiteMinting, bool publicMinting) external Manager {
        _goldMinting = goldMinting;
        _whiteMinting = whiteMinting;
        _minting = publicMinting;
    }

    function withdraw(address payable to, uint256 value) external Owner {
        to.transfer(value);
    }
 
    
    //User Functions======================================================================================================================================================
    function approve(address to, uint256 tokenId) external override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != msg.sender, "ERC721: approve to caller");

        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) external override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) external override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata _data) external override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function goldMint(uint256 amount) external payable {
        require(_goldMinting, "RFC: Minting Has Not Started Yet"); 
        require(_goldAccess[msg.sender], "RFC: Invalid Access"); 
        require(msg.value == _goldPrice * amount, "RFC: Wrong ETH Value");

        _mint(msg.sender, amount);
    }

    function whiteMint(uint256 amount) external payable {
        require(_whiteMinting, "RFC: Minting Has Not Started Yet"); 
        require(_whiteAccess[msg.sender], "RFC: Invalid Access"); 
        require(msg.value == _whitePrice * amount, "RFC: Wrong ETH Value");

        _mint(msg.sender, amount);
    }

    function mint(uint256 amount) external payable {
        require(_minting, "RFC: Minting Has Not Started Yet"); 
        require(msg.value == _whitePrice * amount, "RFC: Wrong ETH Value");

        _mint(msg.sender, amount);
    }
    
    //Internal Functions======================================================================================================================================================
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {
        _transfer(from, to, tokenId);
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = _owners[tokenId];
        require(spender == owner || _tokenApprovals[tokenId] == spender || isApprovedForAll(owner, spender), "ERC721: Not approved or owner");
        return true;
    }
    
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    function _mint(address user, uint256 amount) internal {
        require(_minted + amount < _totalSupply, "RFC: Insufficient Tokens");
        
        _balances[msg.sender] += amount;
        
        for(uint256 t; t < amount; ++t) {
            uint256 tokenId = _minted++;
            
            _owners[tokenId] = msg.sender;
                
            emit Transfer(address(0), msg.sender, tokenId);
        }

        _totalSupply += amount;
        
    }

}
