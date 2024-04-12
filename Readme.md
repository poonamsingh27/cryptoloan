# CryptoLoan Smart Contract

# Overview

The CryptoLoan smart contract is designed to facilitate cryptocurrency loans with collateralization. 
It allows users to request loans by providing collateral in the form of ERC20 tokens or native currency (e.g., Ether). The loan amount is issued in the form of ERC20 tokens. The contract enforces a Loan-to-Value (LTV) 
ratio to ensure the safety of lenders' funds. Additionally, it calculates and charges interest 
on the loan amount.

# Features

* Users can request loans by providing collateral in supported tokens.
* The loan amount is issued in ERC20 tokens or native currency.
* The contract enforces a Loan-to-Value (LTV) ratio to mitigate the risk of default.
* Interest is calculated and charged on the loan amount.
* Users can repay loans using ERC20 tokens or native currency.
* Collateral is returned to borrowers upon loan repayment.
* The contract owner can withdraw ERC20 collateral tokens.

# Function

1. Requesting a Loan:

* Call the requestLoan function with parameters:
* collateralToken: Address of the collateral token.
* _collateralAmount: Amount of collateral.
* _loanToken: Address of the loan token (use address(0x0000000000000000000000000000000000001010) 
for native currency).
* _loanAmount: Amount of loan requested.
* _loanDuration: Duration of the loan in seconds.

2. Repaying a Loan with ERC20 Tokens:

*  Call the repayLoan function with parameters:
* _loanToken: Address of the loan token.
* _loanid: loanid of the borrower.


3. Repaying a Loan with Native Currency:

* Call the repayLoaninnativeCurrency function with parameters:
* _loanToken: Address of the loan token.
* _loanid: loanid of the borrower.
* Send the required amount of native currency along with the transaction.
Withdrawing Collateral.

# Configuration

* Set the contract owner using the setOwner function.
* Update supported collateral tokens using the updateCollateralTokenCurrency function.
* Update supported loan tokens using the updateLoanTokenCurrency function.



