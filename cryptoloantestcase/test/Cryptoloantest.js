//const { expect } = require("chai");
const { ethers } = require("hardhat");
const { BigNumber } = require('ethers')
const { expect, use } = require("chai");
const chaiAsPromised = require("chai-as-promised");
use(chaiAsPromised);



describe("CryptoLoan Contract", function () {

  let CryptoLoan = "0x6f30260C6d98F1ae19fC8DD64a7173b54ed8e780";
  let cryptoLoan;
  let owner = "0xdCe867155ec431Dba1Caa9c21f8567dBbe0472d4";
  let borrower = "0x5744D3c78034b4A7ab590e6Cc8FCC918994a046f";
  let BigNumber; // Declare BigNumber variable

  
  beforeEach(async function () {
    [owner, user] = await ethers.getSigners();

    // Deploy the Floxyswap contract
    CryptoLoan = await ethers.getContractFactory("CryptoLoan");
    cryptoLoan = await CryptoLoan.deploy();
  });

   it("should initialize contract correctly", async function () {
  //   // Check owner
     expect(await cryptoLoan.owner()).to.equal(owner.address);

  //   // Check initial loan duration
      expect(await cryptoLoan.loanDurationInSeconds()).to.equal(600n); // 10 minutes

  //   // Check initial collateral factor
      expect(await cryptoLoan.COLLATERAL_FACTOR()).to.equal(70n); // 70% Loan-to-Value ratio

  // //   // Check initial interest rate
      expect(await cryptoLoan.INTEREST_RATE()).to.equal(12n); // 12% Annual Percentage Rate
  });

  it("should update collateral token currency", async function () {
    // Update supported collateral token
    await cryptoLoan.updateCollateralTokenCurrency("0xD5DeCf4d8a6Da6e619B9A152b9Fe76721e52d260", true);
    const isSupported = await cryptoLoan.isSupportedCollateralToken("0xD5DeCf4d8a6Da6e619B9A152b9Fe76721e52d260");
    expect(isSupported).to.be.true;
  });

  it("should update loan token currency", async function () {
    // Update supported loan token
    await cryptoLoan.updateLoanTokenCurrency("0x3ADD0D140057303AeaA689C867Ca2eA3A7F844aD", true);
    const isSupported = await cryptoLoan.isSupportedLoanToken("0x3ADD0D140057303AeaA689C867Ca2eA3A7F844aD");
    expect(isSupported).to.be.true;
  });

  it("should update token rate", async function () {
    // Update token rate
    const rateToUpdate = "6";
    await cryptoLoan.updateTokenRate("0xD5DeCf4d8a6Da6e619B9A152b9Fe76721e52d260", rateToUpdate);
    
    // Get the updated rate
    const rate = await cryptoLoan.tokenRates("0xD5DeCf4d8a6Da6e619B9A152b9Fe76721e52d260");
    
     // Assert that the rate is updated correctly
     expect(rate.toString()).to.equal(rateToUpdate);
  });
  it("should request a loan", async function () {
    // Ensure the collateral and loan tokens are supported
    await cryptoLoan.updateCollateralTokenCurrency("0xD5DeCf4d8a6Da6e619B9A152b9Fe76721e52d260", true);
    await cryptoLoan.updateLoanTokenCurrency("0x3ADD0D140057303AeaA689C867Ca2eA3A7F844aD", true);
    await cryptoLoan.updateTokenRate("0xD5DeCf4d8a6Da6e619B9A152b9Fe76721e52d260", "6");
    await cryptoLoan.updateTokenRate("0xD5DeCf4d8a6Da6e619B9A152b9Fe76721e52d260", "5");

    // Request a loan
    const collateralToken = "0xD5DeCf4d8a6Da6e619B9A152b9Fe76721e52d260";
    const collateralAmount = "10000000000000000000"; // 10 ETH worth of collateral
    const loanToken = "0x3ADD0D140057303AeaA689C867Ca2eA3A7F844aD";
    const loanAmount = "1000000000000000000"; // 1 ERC20 token as loan

    // Use await with expect
    await expect(cryptoLoan.requestLoan(collateralToken, collateralAmount, loanToken, loanAmount)).to.eventually.be.fulfilled;;

    // Check the loan details
    const loan = await cryptoLoan.userLoans(borrower.address, 1);

    expect(loan.collateralToken).to.equal(collateralToken);
    expect(loan.collateralAmount.toString()).to.equal(collateralAmount.toString());
    expect(loan.loanToken).to.equal(loanToken);
    expect(loan.loanAmount.toString()).to.equal(loanAmount.toString());
    expect(loan.active).to.be.true;
});


  it("should repay a loan", async function () {
    // Request a loan
    const collateralToken = "0xD5DeCf4d8a6Da6e619B9A152b9Fe76721e52d260";
    const collateralAmount = "10000000000000000000"; // 10 ETH worth of collateral
    const loanToken = "0x3ADD0D140057303AeaA689C867Ca2eA3A7F844aD";
    const loanAmount = "1000000000000000000"; // 1 ERC20 token as loan

    // Use await with expect
    await expect(cryptoLoan.requestLoan(collateralToken, collateralAmount, loanToken, loanAmount)).to.eventually.be.fulfilled;;

    // Repay the loan
    await cryptoLoan.repayLoan("0x3ADD0D140057303AeaA689C867Ca2eA3A7F844aD", 1);
    
    // Check if the loan is marked as repaid
    const loan = await cryptoLoan.userLoans(borrower.address, 1);
    expect(loan.active).to.be.false;
  });
});