// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

// Interface for ERC20 token standard

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
}

// Main contract for handling crypto loans
contract CryptoLoan {
    address public owner; // Address of the contract owner
    mapping(address => bool) public isSupportedCollateralToken; // Mapping to track supported collateral tokens
    mapping(address => bool) public isSupportedLoanToken;  // Mapping to track supported loan tokens
    
    // Mapping to track user collateral, loan amounts, interest, loan-to-value ratio, loan duration, and loan status
    mapping(address => mapping(address => uint256)) public userCollateral;
    mapping(address => mapping(address => uint256)) public userLoanAmount;
    mapping(address => mapping(address => uint256)) public userLoanInterest;
    mapping(address => mapping(address => uint256)) public userLoanLTV;
    mapping(address => mapping(address => uint256)) public userLoanDuration;
    mapping(address => mapping(address => bool)) public userHasActiveLoan;
    
    uint256 public constant COLLATERAL_FACTOR = 70; // 70% Loan-to-Value ratio
    uint256 public constant INTEREST_RATE = 5; // 5% Annual Percentage Rate

    // Events for logging loan requests, loan repayments, excess fund returns, collateral returns, and supported currency updates
    event LoanRequested(address indexed borrower, address indexed collateralToken, uint256 collateralAmount, address indexed loanToken, uint256 loanAmount, uint256 interestAmount, uint256 loanDuration);
    event LoanRepaid(address indexed borrower, address indexed loanToken, uint256 amountRepaid);
    event ExcessFundsReturned(address indexed borrower, address indexed loanToken, uint256 amountReturned);
    event CollateralReturned(address indexed borrower, address indexed collateralToken, uint256 collateralReturned);
    event SupportedCurrencyUpdated(address indexed currency, bool status);

    // Modifier to restrict access to only the contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can call this function");
        _;
    }

     // Modifier to check if the address is not zero
    modifier zeroAddressCheck(address _address) {
        require(_address != address(0), "Zero address not allowed");
        _;
    }
    
    // Contract constructor to set the contract owner
    constructor() {
        owner = msg.sender;
    }

      // Function to update the status of supported collateral tokens
    function updateCollateralTokenCurrency(address _collateralToken, bool _status) external onlyOwner zeroAddressCheck(_collateralToken) {
        isSupportedCollateralToken[_collateralToken] = _status;
        emit SupportedCurrencyUpdated(_collateralToken, _status);
    }

    // Function to update the status of supported loan tokens
    function updateLoanTokenCurrency(address _loanToken, bool _status) external onlyOwner zeroAddressCheck(_loanToken) {
        isSupportedLoanToken[_loanToken] = _status;
        emit SupportedCurrencyUpdated(_loanToken, _status);
    }
 // Function for borrowers to request a loan in erc20 or native currency
function requestLoan(address _collateralToken, uint256 _collateralAmount, address _loanToken, uint256 _loanAmount, uint256 _loanDuration) external {
    require(isSupportedCollateralToken[_collateralToken], "Collateral token not supported");
    require(isSupportedLoanToken[_loanToken], "Loan token not supported");
    require(_loanAmount > 0, "Loan amount must be greater than 0");
    require(_collateralAmount > 0, "Collateral amount must be greater than 0");
    require(_loanDuration > 0, "Loan duration must be greater than 0");
    
    // Get instances of collateral token and loan token contracts
    IERC20 collateralToken = IERC20(_collateralToken);
    IERC20 loanToken = IERC20(_loanToken);

   // Check allowance of collateral tokens for spending by the contract
   require(collateralToken.allowance(msg.sender, address(this)) >= _collateralAmount, "Contract not allowed to spend user's collateral tokens");
    
    // Calculate loan interest and loan-to-value ratio
    uint256 loanInterest = (_loanAmount * INTEREST_RATE * _loanDuration) / 100;
    uint256 loanLTV = (_loanAmount * 100) / _collateralAmount;
    
    // Check if loan-to-value ratio is within allowed limit
    require(loanLTV <= COLLATERAL_FACTOR, "Loan-to-value ratio exceeds allowed limit");
    
    // Transfer collateral tokens to the contract
    require(collateralToken.transferFrom(msg.sender, address(this), _collateralAmount), "Failed to transfer collateral tokens to contract");

   // Transfer loan tokens to borrower

    if (_loanToken == address(0x0000000000000000000000000000000000001010)) {
        // Transfer loan amount to the borrower (native currency)
        require(payable(msg.sender).send(_loanAmount), "Failed to transfer loan amount to borrower");
    } else {
        // Transfer loan tokens to borrower (ERC20)
        require(loanToken.transfer(msg.sender, _loanAmount), "Failed to transfer loan amount to borrower");
    }
    
    // Store loan details
    userCollateral[msg.sender][_collateralToken] += _collateralAmount;
    userLoanAmount[msg.sender][_loanToken] = _loanAmount;
    userLoanInterest[msg.sender][_loanToken] = loanInterest;
    userLoanLTV[msg.sender][_loanToken] = loanLTV;
    userLoanDuration[msg.sender][_loanToken] = _loanDuration;
    userHasActiveLoan[msg.sender][_loanToken] = true;
      // Emit loan requested event
    emit LoanRequested(msg.sender, _collateralToken, _collateralAmount, _loanToken, _loanAmount, loanInterest, _loanDuration);
}

    // Function for borrowers to repay a loan using ERC20 tokens
function repayLoan(address _borrower, address _loanToken,address _collateralToken) external {
         require(isSupportedCollateralToken[_collateralToken], "Collateral token not supported");
         require(isSupportedLoanToken[_loanToken], "Loan token not supported");
        require(userHasActiveLoan[_borrower][_loanToken], "No active loan found for the user");
        uint256 totalAmountDue = userLoanAmount[_borrower][_loanToken] + userLoanInterest[_borrower][_loanToken];
        
        // Handling ERC20 token repayment
        IERC20 loanToken = IERC20(_loanToken);
        require(loanToken.transferFrom(msg.sender, address(this), totalAmountDue), "Failed to transfer loan amount");

        // // Transfer collateral tokens back to the borrower
         IERC20 collateralToken = IERC20(_collateralToken);
        uint256 collateralAmount = userCollateral[_borrower][address(collateralToken)];
        require(collateralToken.transfer(_borrower, collateralAmount), "Failed to transfer collateral tokens back to borrower");
        emit CollateralReturned(_borrower, address(collateralToken), collateralAmount);

        // Clear user loan details
        userLoanAmount[_borrower][_loanToken] = 0;
        userLoanInterest[_borrower][_loanToken] = 0;
        userLoanLTV[_borrower][_loanToken] = 0;
        userLoanDuration[_borrower][_loanToken] = 0;
        userHasActiveLoan[_borrower][_loanToken] = false;

        emit LoanRepaid(_borrower, _loanToken, totalAmountDue);
    }

// Function for borrowers to repay a loan using matic

  function repayLoaninnativeCurrency(address _borrower,address _collateralToken, address _loanToken) external payable  {
     require(userHasActiveLoan[_borrower][_loanToken], "No active loan found for the user");
      uint256 totalAmountDue = userLoanAmount[_borrower][_loanToken] + userLoanInterest[_borrower][_loanToken];
      require(msg.value == totalAmountDue, "Insufficient funds to repay the loan");
    // Transfer collateral tokens back to the borrower
    IERC20 collateralToken = IERC20(_collateralToken); // Replace with the address of the collateral token contract
    uint256 collateralAmount = userCollateral[_borrower][address(collateralToken)];
    require(collateralToken.transfer(_borrower, collateralAmount), "Failed to transfer collateral tokens back to borrower");
    emit CollateralReturned(_borrower, address(collateralToken), collateralAmount);

    // Clear user loan details
        userLoanAmount[_borrower][_loanToken] = 0;
        userLoanInterest[_borrower][_loanToken] = 0;
        userLoanLTV[_borrower][_loanToken] = 0;
        userLoanDuration[_borrower][_loanToken] = 0;
        userHasActiveLoan[_borrower][_loanToken] = false;

        emit LoanRepaid(_borrower, _loanToken, totalAmountDue);
  }
    
    function setOwner(address _newOwner) external onlyOwner {
        owner = _newOwner;
    }
    receive() external payable {}
}
