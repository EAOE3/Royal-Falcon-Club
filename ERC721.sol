contract RFC is CF_ERC721 {
    using Strings for uint256;

    bool private _goldMinting = false;//if minting is on or off
    bool private _whiteMinting = false;//if minting is on or off
    bool private _minting = true;//if minting is on or off

    uint256 private _goldPrice = 125000000000000000;
    uint256 private _whitePrice = 150000000000000000;
    uint256 private _publicPrice = 150000000000000000;

    uint256 private _goldMintLimitPerUser = 10;
    uint256 private _whiteMintLimitPerUser = 10;

    mapping(address => bool) private _goldAccess;
    mapping(address => bool) private _whiteAccess;

    mapping(address => uint256) private _userGoldMints;
    mapping(address => uint256) private _userWhiteMints;

    bool private _reveal = false;

    function tokenURI(uint256 tokenId) external view override returns (string memory) {
        if(!_reveal) {return string(abi.encodePacked(uriLink, "secret.json"));}
        return string(abi.encodePacked(uriLink, tokenId.toString(), ".json"));

    }

    function prices() public view returns(uint256 goldPrice, uint256 whitePrice, uint256 publicPrice) {
        goldPrice = _goldPrice;
        whitePrice = _whitePrice;
        publicPrice = _publicPrice;
    }

    function minting() public view returns(bool goldMint, bool whiteMint, bool publicMint) {
        goldMint =_goldMinting;
        whiteMint = _whiteMinting;
        publicMint = _minting;
    }

    function mintLimit() public view returns(uint256 goldMintLimitPerUser, uint256 whiteMintLimitPerUser) {
        goldMintLimitPerUser = _goldMintLimitPerUser;
        whiteMintLimitPerUser = _whiteMintLimitPerUser;
    }

    function userMints(address user) external view returns(uint256 userGoldMints, uint256 userWhiteMints) {
        userGoldMints = _userGoldMints[user];
        userWhiteMints = _userWhiteMints[user];
    }

    function listed(address user) external view returns(bool goldListed, bool whiteListed) {
        goldListed = _goldAccess[user];
        whiteListed = _whiteAccess[user];
    }

    
    //Moderator Functions======================================================================================================================================================

    function setGoldList(address[] calldata goldenUsers) external Owner {
        uint256 size = goldenUsers.length;
        
        for(uint256 t; t < size; ++t) {
            _goldAccess[goldenUsers[t]] = true;
        }
    }

    function setWhiteList(address[] calldata whiteUsers) external Owner {
        uint256 size = whiteUsers.length;
        
        for(uint256 t; t < size; ++t) {
            _whiteAccess[whiteUsers[t]] = true;
        }
    }


    function toggleReveal() external Owner {
        _reveal = !_reveal;
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

    function chnageLimits(uint256 goldMintLimitPerUser, uint256 whiteMintLimitPerUser) external Manager {
        _goldMintLimitPerUser = goldMintLimitPerUser;
        _whiteMintLimitPerUser = whiteMintLimitPerUser;
    }

    //User functions ==================================================================================================================================

    function goldMint(uint256 amount) external payable {
        _userGoldMints[msg.sender] += amount;
        require(_userGoldMints[msg.sender] <= _goldMintLimitPerUser, "RFC: Gold Mint Limit Reached");

        require(_totalSupply + amount < 5050, "RFC: Insufficient Tokens");
        require(_goldMinting, "RFC: Gold Minting Has Not Started Yet"); 
        require(_goldAccess[msg.sender], "RFC: Invalid Access"); 
        require(msg.value == _goldPrice * amount, "RFC: Wrong ETH Value");

        _mint(msg.sender, amount);
    }

    function whiteMint(uint256 amount) external payable {
        _userWhiteMints[msg.sender] += amount;
        require(_userWhiteMints[msg.sender] <= _whiteMintLimitPerUser, "RFC: White Mint Limit Reached");

        require(_totalSupply + amount < 5050, "RFC: Insufficient Tokens");
        require(_whiteMinting, "RFC: Minting Has Not Started Yet"); 
        require(_whiteAccess[msg.sender], "RFC: Invalid Access"); 
        require(msg.value == _whitePrice * amount, "RFC: Wrong ETH Value");

        _mint(msg.sender, amount);
    }

    function mint(uint256 amount) external payable {
        require(_totalSupply + amount < 5050, "RFC: Insufficient Tokens");
        require(_minting, "RFC: Minting Has Not Started Yet"); 
        require(msg.value == _whitePrice * amount, "RFC: Wrong ETH Value");

        _mint(msg.sender, amount);
    }

}
