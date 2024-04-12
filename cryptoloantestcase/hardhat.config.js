// require("@nomicfoundation/hardhat-toolbox");

// /** @type import('hardhat/config').HardhatUserConfig */
// module.exports = {
//   solidity: "0.8.19",
// };

require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");
require("@openzeppelin/hardhat-upgrades");

// require("@nomicfoundation/hardhat-toolbox");

// Go to https://infura.io, sign up, create a new API key
// in its dashboard, and replace "KEY" with it
const INFURA_API_KEY = "f77800ff05bf49d1b12787b2e7c24b6c";

// Replace this private key with your Sepolia account private key
// To export your private key from Coinbase Wallet, go to
// Settings > Developer Settings > Show private key
// To export your private key from Metamask, open Metamask and
// go to Account Details > Export Private Key
// Beware: NEVER put real Ether into testing accounts
const mumbai_PRIVATE_KEY = "6d926d79abc39487d6a8818da9e0afdd09865c8712dd6e7a75b30c69f90d718c";

module.exports = {
  solidity: "0.8.20",
  networks: {
    Mumbai: {
      url: `https://polygon-mumbai-pokt.nodies.app`,
      accounts: [mumbai_PRIVATE_KEY]
    }
  }
};
