// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

// Import SafeMath library
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Main contract for handling crypto loans
contract CryptoLoan {
    address public owner; // Address of the contract owner
    uint256 public constant COLLATERAL_FACTOR = 70; // 70% Loan-to-Value ratio
    uint256 public constant INTEREST_RATE = 12; // 12% Annual Percentage Rate
    uint256 public loanDurationInSeconds = 600; // 10 minutes 

    struct Loan {
        address collateralToken;
        uint256 collateralAmount;
        address loanToken;
        uint256 loanAmount;
        uint256 interestAmount;
        uint256 startTime;
        bool active;
    }

    mapping(address => mapping(uint256 => Loan)) public userLoans;
    mapping(address => uint256) public userLoanCount;
    mapping(address => bool) public isSupportedCollateralToken; // Mapping to track supported collateral tokens
    mapping(address => bool) public isSupportedLoanToken;  //
    mapping(address => uint256) public tokenRates; // Mapping to store previous token rates
    mapping(address => uint256) public latestTokenRates; // Mapping to store latest token rates

    // Events for logging loan requests, loan repayments, and collateral returns
    event LoanRequested(address indexed borrower, uint256 loanId, address indexed collateralToken, uint256 collateralAmount, address indexed loanToken, uint256 loanAmount, uint256 interestAmount);
    event LoanRepaid(address indexed borrower, uint256 loanId, address indexed loanToken, uint256 amountRepaid);
    event CollateralReturned(address indexed borrower, uint256 loanId, address indexed collateralToken, uint256 collateralReturned);
    event SupportedCurrencyUpdated(address indexed currency, bool status);
    event TokenRateUpdated(address indexed token, uint256 rate);
    event CollateralUpdated(address indexed borrower, uint256 loanId, uint256 newCollateralAmount);
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
        // Set token rates
        tokenRates[0xD5DeCf4d8a6Da6e619B9A152b9Fe76721e52d260] = 6; // 1 MLD = 6 USD 
        tokenRates[0x3ADD0D140057303AeaA689C867Ca2eA3A7F844aD] = 5; // 1 TEST Token = 5 USD
        tokenRates[0x0000000000000000000000000000000000001010] = 10; // 1 MAtic = 10 USD
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

    // // Function to update token rates
    // function updateTokenRate(address _token, uint256 _rate) external onlyOwner {
    //     tokenRates[_token] = _rate;
    //     emit TokenRateUpdated(_token, _rate);
    // }

    function updateTokenRate(address _token, uint256 _rate) external onlyOwner {
    tokenRates[_token] = _rate; // Update the token rate
    latestTokenRates[_token] = _rate; // Update the latest token rate as well
    emit TokenRateUpdated(_token, _rate);
}


    // // Function to convert token amount to USD
    function convertToUSD(address _token, uint256 _amount) internal view returns (uint256) {
        uint256 rate = tokenRates[_token];
        require(rate > 0, "Token rate not set");
        return _amount * rate;
    }

    // Function for borrower to update collateral amount after rate decrease
 function updateCollateralAmount(uint256 _loanId, uint256 _updatedCollateralAmount) external {
    Loan storage loan = userLoans[msg.sender][_loanId];
    require(loan.active, "Loan not found or already repaid");

    // Calculate original collateral amount in USD
    uint256 originalCollateralValueUSD = convertToUSD(loan.collateralToken, loan.collateralAmount);

    // Check if the updated collateral amount is greater than the original collateral value
    require(convertToUSD(loan.collateralToken, _updatedCollateralAmount) > originalCollateralValueUSD, "Updated collateral amount should be greater than the original amount");

    // Transfer the updated collateral amount to the contract
    IERC20 collateralToken = IERC20(loan.collateralToken);
    require(collateralToken.transferFrom(msg.sender, address(this), _updatedCollateralAmount), "Failed to transfer updated collateral amount to contract");

    // Update the collateral amount in the loan details
    loan.collateralAmount  +=  _updatedCollateralAmount;
}


    // Function to request a loan in ERC20 or native currency
    function requestLoan(address _collateralToken, uint256 _collateralAmount, address _loanToken, uint256 _loanAmount) external {
        require(_collateralAmount > 0, "Collateral amount must be greater than 0");
        require(_loanAmount > 0, "Loan amount must be greater than 0");
        require(userLoanCount[msg.sender] < 10, "Maximum 10 active loans per user allowed");
        require(isSupportedCollateralToken[_collateralToken], "Collateral token not supported");
        require(isSupportedLoanToken[_loanToken], "Loan token not supported");

        // Convert collateral amount and loan amount to USD
        uint256 collateralAmountUSD = convertToUSD(_collateralToken, _collateralAmount);
        uint256 loanAmountUSD = convertToUSD(_loanToken, _loanAmount);

        // Increment user loan count
        uint256 loanId = userLoanCount[msg.sender] + 1;
        userLoanCount[msg.sender]++;

        // Store loan details
        userLoans[msg.sender][loanId] = Loan({
            collateralToken: _collateralToken,
            collateralAmount: _collateralAmount,
            loanToken: _loanToken,
            loanAmount: _loanAmount,
            interestAmount: (loanAmountUSD * INTEREST_RATE * loanDurationInSeconds) / (365 days),
            startTime: block.timestamp,
            active: true
        });

        uint256 loanLTV = (loanAmountUSD * 100) / collateralAmountUSD;

        // Check if loan-to-value ratio is within allowed limit
        require(loanLTV <= COLLATERAL_FACTOR, "Loan-to-value ratio exceeds allowed limit");

        // Transfer loan amount to borrower
        if (_loanToken == address(0x0000000000000000000000000000000000001010)) {
            // Transfer native currency
            require(payable(msg.sender).send(_loanAmount), "Failed to transfer loan amount to borrower");
        } else {
            // Transfer ERC20 tokens
            IERC20 loanToken = IERC20(_loanToken);
            require(loanToken.transfer(msg.sender, _loanAmount), "Failed to transfer loan amount to borrower");
        }

        // Transfer collateral amount to contract
        IERC20 collateralToken = IERC20(_collateralToken);
        require(collateralToken.transferFrom(msg.sender, address(this), _collateralAmount), "Failed to transfer collateral amount to contract");

        // Emit loan requested event
        emit LoanRequested(msg.sender, loanId, _collateralToken, _collateralAmount, _loanToken, _loanAmount, (loanAmountUSD * INTEREST_RATE * loanDurationInSeconds) / (365 days));
    }

    // Function to repay a loan using ERC20 tokens
    function repayLoan(address loanToken, uint256 _loanId) external {
        Loan storage loan = userLoans[msg.sender][_loanId];
        require(loan.active, "Loan not found or already repaid");
        require(block.timestamp <= loan.startTime + loanDurationInSeconds, "Loan duration expired");

        uint256 totalAmountDue = loan.loanAmount + loan.interestAmount;

         // Calculate collateral amount in USD
    uint256 collateralValueUSD = convertToUSD(loan.collateralToken, loan.collateralAmount);

    // Calculate loan amount in USD
    uint256 loanValueUSD = convertToUSD(loan.loanToken, loan.loanAmount);

          // Check if collateral amount is same or less than loan amount in USD
    require(collateralValueUSD >= loanValueUSD, "Collateral value same or less than loan value so please update the collateral amount");

        
        // Handling ERC20 token repayment
        IERC20 loanToken = IERC20(loan.loanToken);
        require(loanToken.transferFrom(msg.sender, address(this), totalAmountDue), "Failed to transfer loan amount");

        // Transfer collateral tokens back to the borrower
        IERC20 collateralToken = IERC20(loan.collateralToken);
        require(collateralToken.transfer(msg.sender, loan.collateralAmount), "Failed to transfer collateral tokens back to borrower");
        emit CollateralReturned(msg.sender, _loanId, loan.collateralToken, loan.collateralAmount);

        // Mark loan as repaid
        loan.active = false;

        // Emit loan repaid event
        emit LoanRepaid(msg.sender, _loanId, loan.loanToken, totalAmountDue);
    }


    // Function for borrowers to repay a loan using matic
    function repayLoaninnativeCurrency(address loanToken, uint256 _loanId) external payable  {
        Loan storage loan = userLoans[msg.sender][_loanId];
        require(loan.active, "Loan not found or already repaid");
        require(block.timestamp <= loan.startTime + loanDurationInSeconds, "Loan duration expired");

        uint256 totalAmountDue = loan.loanAmount + loan.interestAmount;


         // Calculate collateral amount in USD
    uint256 collateralValueUSD = convertToUSD(loan.collateralToken, loan.collateralAmount);

    // Calculate loan amount in USD
    uint256 loanValueUSD = convertToUSD(loan.loanToken, loan.loanAmount);

          // Check if collateral amount is same or less than loan amount in USD
    require(collateralValueUSD >= loanValueUSD, "Collateral value same or less than loan value so please update the collateral amount");

        // Transfer collateral tokens back to the borrower
        IERC20 collateralToken = IERC20(loan.collateralToken);
        require(collateralToken.transfer(msg.sender, loan.collateralAmount), "Failed to transfer collateral tokens back to borrower");
        emit CollateralReturned(msg.sender, _loanId, loan.collateralToken, loan.collateralAmount);

        // Mark loan as repaid
        loan.active = false;

        // Emit loan repaid event
        emit LoanRepaid(msg.sender, _loanId, loan.loanToken, totalAmountDue);
    }

    // Function to update the contract owner
    function setOwner(address _newOwner) external onlyOwner {
        owner = _newOwner;
    }

    receive() external payable {}


    // Function to withdraw ERC20 collateral tokens, callable only by the owner
   function withdrawCollateral(address _token, uint256 _amount) external onlyOwner {
    require(ERC20(_token).transfer(owner, _amount), "Collateral withdrawal failed");
     }
}