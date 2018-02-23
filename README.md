# PRM Smart Contract & PRM Token Methods

This repository contains the full PRM Smart Contract as well as an example ERC-20 & ERC-223 Compliant Token Contract that interacts with the PRM Smart Contract.

## Important Note

!> The example Token Contract within the project does not represent final code & should be revised upon agreement to reflect your ICO model correctly as it currently contains placeholder values.

## Contract Analysis & Gas Estimation

Below you can find the estimated gas costs of contract deployments as well as the perspective cost of the contained functions.

### PRM Contract

The PRM contract contains 2 objects, the PRMToken interface & the PRM smart contract.

The PRMToken interface has a minimal gas foot-print & is a stripped-down token interface of the PRM Token for the PRM contract to communicate with in its future deployment. This is purely to generate the function signatures in a human-readable & secure format instead of using `address.call(bytes4(sha3("function_name(types)")), parameters_values)`.

```js
pragma solidity ^0.4.19;

contract PRMToken {
    ...
}
```

The PRM Contract implements the necessary methods for an external web service to interact with the blockchain & the data stored within. It manages the sale/auction of photos as well as their ownership rights.

```js
pragma solidity ^0.4.19;

contract PRMToken {
    ...
}

contract PRM {
  ...
}
```

The total gas estimation for the publishing the contract on the Ethereum blockchain as of 2/23/2018 is `X gas`.

#### setPRMTokenAddress(address)

Sets the address of the PRM Token contract. This address is stored in memory so as to handle the auction e-scrow as well as token transfer for the purchase of photos.

```js
function setPRMTokenAddress(address _PRMTokenAddress) external isAdmin {
    PRMTokenAddress = _PRMTokenAddress;
}
```

The gas estimation of the above function as of 2/23/2018 is `42356 gas`.

#### retrieveAccidentalTransfers(address)

Retrieves ERC-20 compliant tokens that were accidentally sent to the contract address.

```js
function retrieveAccidentalTransfers(address _tokenAddress) external isAdmin {
    require(_tokenAddress != PRMTokenAddress);
    PRMToken tokenObject = PRMToken(_tokenAddress);
    uint256 fullBalance = tokenObject.balanceOf(this);
    tokenObject.transfer(admin, fullBalance);
}
```

The gas estimation of the above function as of 2/23/2018 is `53286 gas`.

#### getPhotoInfo(uint256)

Retrieves the information associated with a photo ID. The `result` variable within a web3 call is an array with the values stored in the same order as they appear on the below function

```js
function getPhotoInfo(uint256 _photoID) external view returns (uint256, uint256, uint256, bool, address, address) {
    //TODO
}
```

There is no gas cost associated with retrieving data from the blockchain.

#### photoUpload(uint256, bool)

Upload photo to the PRM network & emit an event for the server to log the photo ID on its database.

```js
function photoUpload(uint256 _salePrice, bool _isToken) external {
    photoAssets[incrementalID].owner = msg.sender;
    photoSale(_salePrice, incrementalID, _isToken);
    //TODO: Add other types of sales
    PhotoUpload(msg.sender, incrementalID);
    incrementalID++;
}
```

The gas estimation of the above function varies depending on the type of sale, if any, used.

The gas estimation of an empty photo upload with no form of sale as of 2/23/2018 is `64548 gas`.

The gas estimation of subsequent empty photo uploads with no form of sale as of 2/23/2018 is `49548 gas`.

> All metrics have began with an empty photo upload to avoid any confusion regarding the median values.

#### photoSale(uint256, uint256, bool)

Enable the ownership sale of a photo by specifying the amount of Ether or Tokens to price the photo at.

```js
function photoSale(uint256 _salePrice, uint256 _photoID, bool _isToken) public {
    require(msg.sender == photoAssets[_photoID].owner);
    if (_isToken) {
        photoAssets[_photoID].photoTokenPrice = _salePrice;
    } else {
        photoAssets[_photoID].photoPrice = _salePrice;
    }
}
```

The gas estimation of the above function as of 2/23/2018 is `42232 gas`.

The total gas estimation of the `photoUpload(uint256 _salePrice, bool _isToken)` function if this option is specified is `65970 gas` as of 2/23/2018.

#### photoResale(uint256, uint256, bool)

Enable the resale of a photo by specifying the amount of Ether or Tokens to price the photo at.

```js
function photoResale(uint256 _resalePrice, uint256 _photoID, bool _isToken) public {
    //TODO
}
```

The gas estimation of the above function as of 2/23/2018 is `X gas`.

The total gas estimation of the `photoUpload(uint256 _salePrice, bool _isToken)` function if this option is specified is `X gas` as of 2/23/2018.

#### photoAuction(uint256, uint256, uint256, bool)

Enable the auction of a photo by specifying the amount of Ether or Tokens to price the photo at as well as the auction's duration in hours.

```js
function photoAuction(uint256 _startingBid, uint256 _auctionDuration, uint256 _photoID, bool _isToken) public {
    //TODO
}
```

The gas estimation of the above function as of 2/23/2018 is `X gas`.

The total gas estimation of the `photoUpload(uint256 _salePrice, bool _isToken)` function if this option is specified is `X gas` as of 2/23/2018.

#### bidOnAuction(uint256, uint256)

Place a bid on an on-going auction either in PRM tokens or Ether.

```js
function bidOnAuction(uint256 _photoID, uint256 _tokenAmount) external payable {
    //TODO
}
```

The gas estimation of the above function as of 2/23/2018 is `X gas` for Ethereum bids.

The gas estimation of the above function as of 2/23/2018 is `X gas` for PRM Token bids.

#### purchaseUsageRight(uint256, uint256)

Purchase usage right of a photo currently offered up for re-sale with either PRM Tokens or Ether.

```js
function purchaseUsageRight(uint256 _photoID, uint256 _tokenAmount) external payable {
    //TODO
}
```

The gas estimation of the above function as of 2/23/2018 is `X gas` for Ethereum purchases.

The gas estimation of the above function as of 2/23/2018 is `X gas` for PRM Token purchases.

#### purchaseOwnershipRight(uint256, uint256)

Purchase ownership right of a photo currently offered up for sale with either PRM Tokens or Ether.

```js
function purchaseOwnershipRight(uint256 _photoID, uint256 _tokenAmount) external payable {
    PhotoAsset storage asset = photoAssets[_photoID];
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
```

The gas estimation of the above function as of 2/23/2018 is `25639 gas` for Ethereum purchases.

The gas estimation of the above function as of 2/23/2018 is `31624 gas` for PRM Token purchases.

#### finalizeAuction(uint256)

Finalize an auction that has expired & reward the owner with the highest bet either in ETH or PRM Tokens.

```js
function finalizeAuction(uint256 _photoID) external {
    //TODO
}
```

The gas estimation of the above function as of 2/23/2018 is `X gas` for Ethereum purchases.

The gas estimation of the above function as of 2/23/2018 is `X gas` for PRM Token purchases.

### PRM Token Contract

The PRM Token contract is an example ERC-223 that also includes the functions used by the PRM address. Gas analysis has been coupled to the PRM Contract since the gas costs are reflected on its function calls.

> Only unique functions will be included in this analysis (Meaning ERC-20 functions such as transfer() won't be analyzed).

```js
pragma solidity ^0.4.19;

contract PRMToken {
    ...
}
```

The total gas estimation for the publishing the contract on the Ethereum blockchain as of 2/23/2018 is `1313625 gas`.

#### setPRMAddress(address)

Sets the address of the PRM contract. This address is stored in memory so as to allow the contract to transfer tokens between users & be used as e-scrow.

```js
function setPRMAddress(address _PRMAddress) external isAdmin {
    PRMAddress = _PRMAddress;
}
```

The gas estimation of the above function as of 2/23/2018 is `29012 gas`.

#### refundAndBid(address, uint256, address, uint256)

Refunds the latest PRM bid on an auction & e-scrows the new bid amount.

```js
function refundAndBid(address _previousBidder, uint256 _previousBid, address _newBidder, uint256 _newBid) external isPRM {
    if (_previousBidder == 0x0) {
        balances[msg.sender] += _newBid;
    } else {
        balances[msg.sender] += (_newBid - _previousBid);
    }
    balances[_previousBidder] += _previousBid;
    balances[_newBidder] = safeSub(balances[_newBidder], _newBid);
}
```

> This function is called within the PRMContract & as such, its gas expenditure can only be calculated within the functions it is called as a whole.

#### saleTransfer(address, uint256, address)

Transfer the required PRM tokens from one account to the other to complete a sale.

```js
function saleTransfer(address _buyer, uint256 _amount, address _owner) external isPRM {
    balances[_owner] += _amount;
    balances[_buyer] = safeSub(balances[_buyer], _amount);
}
```

> This function is called within the PRMContract & as such, its gas expenditure can only be calculated within the functions it is called as a whole.

#### releaseBid(address, uint256)

Release the PRM tokens held in e-scrow to the owner of the auctioned photo.

```js
function releaseBid(address _owner, uint256 _bid) external isPRM {
    balances[_owner] += _bid;
    //Underflow impossible to occur due to Smart Contract workflow
    balances[msg.sender] -= _bid;
}
```

> This function is called within the PRMContract & as such, its gas expenditure can only be calculated within the functions it is called as a whole.

## Web3 Module Snippets

Below one can find web3 code snippets for the various functions required to complete the photo upload workflow & photo purchase workflow.

> For the purposes of the following snippets the web3 version 0.20.4.

### Initial Web3 Setup

Properly operating with the Metamask extension means that one should take care of certain cases & initialize the contract correctly. These cases include a the absence of the plugin, locked-by-passphrase account & an invalid network id.

#### Absence of Metamask

In order to set-up our local web3 instance we require the web3 object to be defined & an Ethereum node to operate with. Both are provided by the in-page web3 Metamask module in addition to the web3 object. Since we want consistency across our deployments initializing a local web3 instance is better for version control.

The below code snippet detects the existance of Metamask (Or any service provider injecting the web3 module such as the Parity browser) & initializes a local web3 instance via the browserified module I have provided. Should the web3 module be absent, the user is alerted of the error & redirected to Metamask's main page.

```js
let localWeb3;

if (typeof window.web3 === 'undefined' || typeof window.web3.currentProvider === 'undefined') {
	alert("No Web3 Detected. Consider installing Metamask!");
	setTimeout(function(){
		window.location = "https://metamask.io/";
	},4000);
} else {
	localWeb3 = new Web3(window.web3.currentProvider);
}
```

#### Contract Object

In order to interact with smart contracts deployed on the Ethereum blockchain one should first create an instance of the contract's interface. In order to do this, the two things required are the contract ABI in `JSON` format & the contract `address`. A snippet can be found below.

```js
let localWeb3;
let contractInstance;

if (typeof window.web3 === 'undefined' || typeof window.web3.currentProvider === 'undefined') {
	...;
} else {
	localWeb3 = new Web3(window.web3.currentProvider);

  let contractAddress = "0x8cc5da3bae2f7222888c11fca0459c7ea4c848c5";

  let contractABI = [{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"_name","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_spender","type":"address"},{"name":"_value","type":"uint256"}],"name":"approve","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"_totalSupply","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_referrer","type":"address"}],"name":"refer","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_nickname","type":"bytes32"}],"name":"referByRNS","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transferFrom","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"_decimals","type":"uint8"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"referralReward","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_nickname","type":"bytes32"}],"name":"reserveRNS","outputs":[],"payable":true,"stateMutability":"payable","type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"}],"name":"balanceOf","outputs":[{"name":"balance","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"_symbol","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transfer","outputs":[{"name":"success","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_value","type":"uint256"},{"name":"_data","type":"bytes"}],"name":"transfer","outputs":[{"name":"success","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_sender","type":"address"},{"name":"_value","type":"uint256"},{"name":"_data","type":"bytes"}],"name":"tokenFallback","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"retrieveInfo","outputs":[{"name":"_totalSupply","type":"uint256"},{"name":"_referralReward","type":"uint256"},{"name":"referrals","type":"uint256"},{"name":"balance","type":"uint256"},{"name":"nickname","type":"bytes32"},{"name":"isReferred","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"},{"name":"_spender","type":"address"}],"name":"allowance","outputs":[{"name":"remaining","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_token","type":"address"}],"name":"claimTokens","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"admin","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"inputs":[],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_from","type":"address"},{"indexed":true,"name":"_to","type":"address"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"Transfer","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_owner","type":"address"},{"indexed":true,"name":"_spender","type":"address"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"Approval","type":"event"}];

	contractInstance = localWeb3.eth.contract(contractABI).at(contractAddress);
}
```

The ABI can be acquired via an external resource stored on the server & parsed via the JSON.parse() method to avoid ugly hard-coded code.

#### Locked Account

A locked account can prevent you from accessing the Metamask's public address & disable the ability to sign transactions, resulting in numerous errors within your JS code. In order to avoid that, one should first alert the user to unlock his account & then create a `watcher` that disables itself once the account has been unlocked. If the account is unlocked, updating your local instance's defaultAccount variable will ensure synchronous signature request instead of asynchronous. A snippet can be found below.

```js
let localWeb3;

if (typeof window.web3 === 'undefined' || typeof window.web3.currentProvider === 'undefined') {
	...;
} else {
	localWeb3 = new Web3(window.web3.currentProvider);
  ...;
  window.web3.eth.getAccounts(function (err, accounts) {
		if (!accounts[0]) {
			alert("Please unlock your Metamask wallet");
			watchAccountUnlock();
		} else {
			localWeb3.eth.defaultAccount = accounts[0];
		}
	});
}

function watchAccountUnlock() {
	let toClear = setInterval(function() {
		window.web3.eth.getAccounts(function (err, accounts) {
			if (accounts[0] != localWeb3.eth.defaultAccount) {
				localWeb3.eth.defaultAccount = accounts[0];
				clearInterval(toClear);
			}
		});
	},500);
}
```

#### Invalid Network ID

Since the Metamask & any user-reliant web3 injected module can connect to any Ethereum node the user wishes, a malicious party could connect the user to a different network (Such as Ethereum Classic) in an attempt to deceive or steal funds. Or a user may attempt to fool the server by connecting to a testnet which will result in a failure anyhow. For completeness' sake, a snippet has been included to detect the network the user is connected to & inform him.

```js
let localWeb3;
let contractInstance;

if (typeof window.web3 === 'undefined' || typeof window.web3.currentProvider === 'undefined') {
	...;
} else {
	localWeb3 = new Web3(window.web3.currentProvider);
  ...;
  localWeb3.version.getNetwork((err, netId) => {
    if (netId != 1) {
      alert("Please switch to the main-net");
      watchNetChange();
    } else {
      ...;
    }
  });
}

function watchNetChange() {
	let toClear = setInterval(function() {
		localWeb3.version.getNetwork((err, netId) => {
			if (netId == 1) {
				clearInterval(toClear);
			}
		});
	},500);
}
```

#### Complete Workflow

All the above checks, with the addition of a getBlockchainData() function called when all checks have been passed, can be found implemented on the snippet below.

```js
let localWeb3;
let contractInstance;

if (typeof window.web3 === 'undefined' || typeof window.web3.currentProvider === 'undefined') {
	alert("No Web3 Detected. Consider installing Metamask!");
	setTimeout(function(){
		window.location = "https://metamask.io/";
	},4000);
} else {
	localWeb3 = new Web3(window.web3.currentProvider);

	let contractAddress = "CONTRACT_ETHEREUM_ADDRESS_HERE";
	let contractABI = "PARSED_CONTRACT_ABI_HERE";
	contractInstance = localWeb3.eth.contract(contractABI).at(contractAddress);

	window.web3.eth.getAccounts(function (err, accounts) {
		if (!accounts[0]) {
			alert("Please unlock your Metamask wallet");
			watchAccountUnlock();
		} else {
			localWeb3.eth.defaultAccount = accounts[0];
			localWeb3.version.getNetwork((err, netId) => {
				if (netId != 1) {
					alert("Please switch to the main-net");
					watchNetChange();
				} else {
					getBlockchainData();
				}
			});
		}
	});
}

function watchAccountUnlock() {
	let toClear = setInterval(function() {
		window.web3.eth.getAccounts(function (err, accounts) {
			if (accounts[0] != localWeb3.eth.defaultAccount) {
				localWeb3.eth.defaultAccount = accounts[0];
				localWeb3.version.getNetwork((err, netId) => {
					if (netId != 1) {
						alert("Please switch to the main-net");
						watchNetChange();
					} else {
						getBlockchainData();
					}
				});
				clearInterval(toClear);
			}
		});
	},500);
}

function watchNetChange() {
	let toClear = setInterval(function() {
		localWeb3.version.getNetwork((err, netId) => {
			if (netId == 1) {
				getBlockchainData();
				clearInterval(toClear);
			}
		});
	},500);
}

function getBlockchainData() {
  ...;
}
```

### Uploading a photo

`TODO`

### Buyer Interactions

`TODO`

## Built With

* [Remix IDE](https://remix.ethereum.org/#optimize=true&version=soljson-v0.4.20+commit.3155dd80.js) - The IDE used for smart contract development
* [Ganache](http://truffleframework.com/ganache/) - Local blockchain used for gas estimations & debugging
* [web3.js](https://github.com/ethereum/web3.js/) - The library used for communicating with the blockchain
* [Atom](https://atom.io/) - Used for creating the back-end snippets

## Authors

* **Alexander Papageorgiou** - *Complete Project Development* - [alex-ppg](https://github.com/alex-ppg)
