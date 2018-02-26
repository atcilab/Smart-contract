pragma solidity ^0.4.19;

/**
 * @title PRM Token Implementation Smart Contract
 * @author Alex "AL_X" Papageorgiou
 * @dev
 *      The stripped-down token interface of the PRM Token for the PRM contract to communicate with in its future deployment.
 *      This is purely to generate the function signatures in a human-readable & secure format instead of using address.call(bytes4(sha3("function_name(types)")), parameters_values).
 */
contract PRMToken {
    //Implementation of the standard ERC-20 balanceOf method
    function balanceOf(address) public returns (uint256);
    //Implementation of the standard ERC-20 transfer method
    function transfer(address, uint256) public;
    //Implementation of the bidding process PRM Token function
    function refundAndBid(address, uint256, address, uint256) external;
    //Implementation for the sale process PRM Token function
    function saleTransfer(address, uint256, address) external;
    //Implementaiton of the bidding resolution process PRM Token function
    function releaseBid(address, uint256) external;
}


/**
 * @title PRM (Photo Rights Management) Smart Contract
 * @author Alex "AL_X" Papageorgiou
 * @dev The smart contract facilitating the operation of the X platform & handling the sale/auction of photos as well as the ownership.
 */
contract PRM {
    address public PRMTokenAddress;
    address public admin;

    uint256 public incrementalID = 0;

    mapping(uint256 => PhotoAsset) photoAssets;

    /**
     * @dev
     *      All photo details gathered in one place for
     *      easy access and a single mapping reference
     */
    struct PhotoAsset {
        uint256 photoPrice;
        uint256 photoTokenPrice;
        uint256 expiryDate;
        bool saleType;
        address owner;
        address lastBidder;
    }

    event PhotoOwnershipTransfer(address indexed _newOwner, address indexed _previousOwner, uint256 indexed _photoID);
    event PhotoRelease(address indexed _viewer, uint256 indexed _photoID);
    event PhotoBid(uint256 indexed _photoID, uint256 _bidPrice);
    event PhotoUpload(address indexed _uploader, uint256 _photoID);

    /**
	 * @notice Ensures admin is the caller of a function
	 */
    modifier isAdmin() {
        require(msg.sender == admin);
        //Continue executing rest of method body
        _;
    }

    /**
     * @notice PRM Constructor
     */
    function PRM() public {
        admin = msg.sender;
    }

    /**
     * @notice Set the PRM Token Address. Interoperable with PRMToken schema-compliant tokens as well
     * @param _PRMTokenAddress The address of the PRM Token contract
     * @dev
     *      This function is unnecessary in case this contract is deployed
     *      after the token contract has been as the address can be hard-coded.
     */
    function setPRMTokenAddress(address _PRMTokenAddress) external isAdmin {
        PRMTokenAddress = _PRMTokenAddress;
    }

    /**
     * @notice Enables retrieval of ERC-20 compliant tokens
     * @param _tokenAddress The address of the ERC-20 compliant token
     * @dev
     *      Feel free to reach out to us for any accidental loss
     *      of tokens to retrieve them.
     */
    function retrieveAccidentalTransfers(address _tokenAddress) external isAdmin {
        require(_tokenAddress != PRMTokenAddress);
        PRMToken tokenObject = PRMToken(_tokenAddress);
        uint256 fullBalance = tokenObject.balanceOf(this);
        tokenObject.transfer(admin, fullBalance);
    }

    /**
     * @notice Retrieve uploaded photo info based on the photo's ID
     * @param _photoID The ID of the photo whose info we wish to retrieve
     * @returns The photo's contained information as stored within the object's structure
     */
    function getPhotoInfo(uint _photoID) external view returns (uint256, uint256, uint256, bool, address, address) {
        PhotoAsset memory photo = photoAssets[_photoID];
        return (photo.photoPrice, photo.photoTokenPrice, photo.expiryDate, photo.saleType, photo.owner, photo.lastBidder);
    }

    /**
     * @notice Upload photo to the PRM network & set for sale as an opt-in
     * @param _saleType The type of sale should there be one (1 = Single Sale, 2 = Reselling, 2< = Auction Sale & Hour Duration)
     * @param _salePrice The price of the photo should a sale take place
     * @param _isToken Whether tokens should be used for the sale or not
     */
    function photoUpload(uint256 _saleType, uint256 _salePrice, bool _isToken) external {
        photoAssets[incrementalID].owner = msg.sender;
        if (_saleType == 1) {
            photoSale(_salePrice, incrementalID, _isToken);
        } else if (_saleType == 2) {
            photoResale(_salePrice, incrementalID, _isToken);
        } else if (_saleType > 2) {
            photoAuction(_salePrice, _saleType, incrementalID, _isToken);
        }
        PhotoUpload(msg.sender, incrementalID);
        incrementalID++;
    }

    /**
     * @notice Set photo up for sale
     * @param _salePrice The price to sell the photo at
     * @param _photoID The photo's ID
     * @param _isToken Whether tokens should be used for the sale or not
     */
    function photoSale(uint256 _salePrice, uint256 _photoID, bool _isToken) public {
        if (_isToken) {
            photoAssets[_photoID].photoTokenPrice = _salePrice;
        } else {
            photoAssets[_photoID].photoPrice = _salePrice;
        }
    }

    /**
     * @notice Set photo up for resale
     * @param _resalePrice The price to re-sell the photo at
     * @param _photoID The photo's ID
     * @param _isToken Whether tokens should be used for the sale or not
     */
    function photoResale(uint256 _resalePrice, uint256 _photoID, bool _isToken) public {
        PhotoAsset storage asset = photoAssets[_photoID];
        if (_isToken) {
            asset.photoTokenPrice = _resalePrice;
        } else {
            asset.photoPrice = _resalePrice;
        }
        asset.saleType = true;
    }

    /**
     * @notice Set photo up for auction
     * @param _startingBid The minimum bid requirement
     * @param _auctionDuration The duration of the auction in days
     * @param _photoID The photo's ID
     * @param _isToken Whether tokens should be used for the sale or not
     */
    function photoAuction(uint256 _startingBid, uint256 _auctionDuration, uint256 _photoID, bool _isToken) public {
        PhotoAsset storage asset = photoAssets[_photoID];
        if (_isToken) {
            asset.photoTokenPrice = _startingBid;
        } else {
            asset.photoPrice = _startingBid;
        }
        asset.expiryDate = now + (1 hours * _auctionDuration);
    }

    /**
     * @notice Bid on auction of photo
     * @param _photoID The ID of the photo
     * @param _tokenAmount The amount of tokens to use, should the token system be in effect
     */
    function bidOnAuction(uint256 _photoID, uint256 _tokenAmount) external payable {
        PhotoAsset storage asset = photoAssets[_photoID];
        assert(asset.expiryDate > now);
        if (_tokenAmount > asset.photoTokenPrice) {
            PRMToken tokenObject = PRMToken(PRMTokenAddress);
            tokenObject.refundAndBid(asset.lastBidder, asset.photoTokenPrice, msg.sender, _tokenAmount);
            asset.photoTokenPrice = _tokenAmount;
            asset.lastBidder = msg.sender;
            PhotoBid(_photoID, _tokenAmount);
        } else if (msg.value > asset.photoPrice) {
            if (asset.lastBidder != 0x0) {
                asset.lastBidder.transfer(asset.photoPrice);
            }
            asset.photoPrice = msg.value;
            asset.lastBidder = msg.sender;
            PhotoBid(_photoID, msg.value);
        } else {
            revert();
        }
    }

    /**
     * @notice Purchase right to view & use a photo
     * @param _photoID The ID of the photo
     * @param _tokenAmount The amount of tokens to use, should the token system be in effect
     */
    function purchaseUsageRight(uint256 _photoID, uint256 _tokenAmount) external payable {
        PhotoAsset storage asset = photoAssets[_photoID];
        assert(asset.saleType);
        if (_tokenAmount == asset.photoTokenPrice && asset.photoTokenPrice > 0) {
            PRMToken tokenObject = PRMToken(PRMTokenAddress);
            tokenObject.saleTransfer(msg.sender, _tokenAmount, asset.owner);
            PhotoRelease(msg.sender, _photoID);
        } else if (msg.value == asset.photoPrice && asset.photoPrice > 0) {
            asset.owner.transfer(msg.value);
            PhotoRelease(msg.sender, _photoID);
        } else {
            revert();
        }
    }

    /**
     * @notice Purchase complete ownership of photo
     * @param _photoID The ID of the photo
     * @param _tokenAmount The amount of tokens to use, should the token system be in effect
     */
    function purchaseOwnershipRight(uint256 _photoID, uint256 _tokenAmount) external payable {
        PhotoAsset storage asset = photoAssets[_photoID];
        assert(!asset.saleType && asset.expiryDate == 0);
        if (_tokenAmount == asset.photoTokenPrice && asset.photoTokenPrice > 0) {
            PRMToken tokenObject = PRMToken(PRMTokenAddress);
            tokenObject.saleTransfer(msg.sender, _tokenAmount, asset.owner);
            asset.photoTokenPrice = 0;
            PhotoOwnershipTransfer(msg.sender, asset.owner, _photoID);
            asset.owner = msg.sender;
        } else if (msg.value == asset.photoPrice && asset.photoPrice > 0) {
            asset.owner.transfer(msg.value);
            asset.photoPrice = 0;
            PhotoOwnershipTransfer(msg.sender, asset.owner, _photoID);
            asset.owner = msg.sender;
        } else {
            revert();
        }
    }

    /**
     * @notice Resolve auction outcome
     * @param _photoID The ID of the photo
     */
    function finalizeAuction(uint256 _photoID) external {
        PhotoAsset storage asset = photoAssets[_photoID];
        assert(asset.expiryDate < now && (asset.lastBidder == msg.sender || (msg.sender == asset.owner && asset.lastBidder == 0x0)));
        if (asset.photoPrice > 0) {
            if (asset.lastBidder != 0x0) {
              asset.owner.transfer(asset.photoPrice);
              PhotoOwnershipTransfer(asset.lastBidder, asset.owner, _photoID);
              asset.owner = asset.lastBidder;
              asset.lastBidder = 0x0;
            }
            asset.photoPrice = 0;
            asset.expiryDate = 0;
        } else if (asset.photoTokenPrice > 0) {
            if (asset.lastBidder != 0x0) {
              PRMToken tokenObject = PRMToken(PRMTokenAddress);
              tokenObject.releaseBid(asset.owner, asset.photoTokenPrice);
              PhotoOwnershipTransfer(asset.lastBidder, asset.owner, _photoID);
              asset.owner = asset.lastBidder;
              asset.lastBidder = 0x0;
            }
            asset.photoTokenPrice = 0;
            asset.expiryDate = 0;
        }
    }

    /**
     * @notice Reverting fallback to prevent accidental Ethereum transfers
     */
    function() public payable {
        revert();
    }
}
