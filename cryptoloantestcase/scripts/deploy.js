const { ethers, upgrades } = require("hardhat");
require("@openzeppelin/hardhat-upgrades");
async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const main = async () => {
    const CryptoLoan = await ethers.getContractFactory("CryptoLoan");
    const cryptoLoan = await CryptoLoan.deploy();
    await cryptoLoan.deployed();
  
    console.log("CryptoLoan deployed to:", cryptoLoan.address);
  };
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
  }