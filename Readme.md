# CryptoLoan Smart Contract

# Overview

This smart contract facilitates crypto loans by allowing users to deposit collateral and borrow 
funds against it. It supports both ERC20 tokens and native currencies (such as matic) as collateral 
and loan tokens.

# Features

* Users can request loans by providing collateral and specifying the loan amount, duration, and token.
* Supported collateral tokens and loan tokens can be configured by the contract owner.
* Loans can be repaid with interest using ERC20 tokens or native currency.

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
* _borrower: Address of the borrower.
* _loanToken: Address of the loan token.
* _collateralToken: Address of the collateral token.


3. Repaying a Loan with Native Currency:

* Call the repayLoaninnativeCurrency function with parameters:
* _borrower: Address of the borrower.
* _collateralToken: Address of the collateral token.
* _loanToken: Address of the loan token.
* Send the required amount of native currency along with the transaction.
Withdrawing Collateral.

# Configuration

* Set the contract owner using the setOwner function.
* Update supported collateral tokens using the updateCollateralTokenCurrency function.
* Update supported loan tokens using the updateLoanTokenCurrency function.



