const Web3 = require('web3');
const privateKey = "5846b01820adebfe404e6a2b3374f34a7c0b92eb7c26bb7655157aceb88ce330"; // Replace with your private key
const web3 = new Web3('https://polygon-mumbai-pokt.nodies.app');
const contractABI = [{"inputs":[],"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"borrower","type":"address"},{"indexed":false,"internalType":"uint256","name":"loanId","type":"uint256"},{"indexed":true,"internalType":"address","name":"collateralToken","type":"address"},{"indexed":false,"internalType":"uint256","name":"collateralReturned","type":"uint256"}],"name":"CollateralReturned","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"borrower","type":"address"},{"indexed":false,"internalType":"uint256","name":"loanId","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"newCollateralAmount","type":"uint256"}],"name":"CollateralUpdated","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"borrower","type":"address"},{"indexed":false,"internalType":"uint256","name":"loanId","type":"uint256"},{"indexed":true,"internalType":"address","name":"loanToken","type":"address"},{"indexed":false,"internalType":"uint256","name":"amountRepaid","type":"uint256"}],"name":"LoanRepaid","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"borrower","type":"address"},{"indexed":false,"internalType":"uint256","name":"loanId","type":"uint256"},{"indexed":true,"internalType":"address","name":"collateralToken","type":"address"},{"indexed":false,"internalType":"uint256","name":"collateralAmount","type":"uint256"},{"indexed":true,"internalType":"address","name":"loanToken","type":"address"},{"indexed":false,"internalType":"uint256","name":"loanAmount","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"interestAmount","type":"uint256"}],"name":"LoanRequested","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"currency","type":"address"},{"indexed":false,"internalType":"bool","name":"status","type":"bool"}],"name":"SupportedCurrencyUpdated","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"token","type":"address"},{"indexed":false,"internalType":"uint256","name":"rate","type":"uint256"}],"name":"TokenRateUpdated","type":"event"},{"inputs":[],"name":"COLLATERAL_FACTOR","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"INTEREST_RATE","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"isSupportedCollateralToken","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"isSupportedLoanToken","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"latestTokenRates","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"loanDurationInSeconds","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"owner","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"loanToken","type":"address"},{"internalType":"uint256","name":"_loanId","type":"uint256"}],"name":"repayLoan","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"loanToken","type":"address"},{"internalType":"uint256","name":"_loanId","type":"uint256"}],"name":"repayLoaninnativeCurrency","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"address","name":"_collateralToken","type":"address"},{"internalType":"uint256","name":"_collateralAmount","type":"uint256"},{"internalType":"address","name":"_loanToken","type":"address"},{"internalType":"uint256","name":"_loanAmount","type":"uint256"}],"name":"requestLoan","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"_newOwner","type":"address"}],"name":"setOwner","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"tokenRates","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"_loanId","type":"uint256"},{"internalType":"uint256","name":"_updatedCollateralAmount","type":"uint256"}],"name":"updateCollateralAmount","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"_collateralToken","type":"address"},{"internalType":"bool","name":"_status","type":"bool"}],"name":"updateCollateralTokenCurrency","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"_loanToken","type":"address"},{"internalType":"bool","name":"_status","type":"bool"}],"name":"updateLoanTokenCurrency","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"_token","type":"address"},{"internalType":"uint256","name":"_rate","type":"uint256"}],"name":"updateTokenRate","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"userLoanCount","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"},{"internalType":"uint256","name":"","type":"uint256"}],"name":"userLoans","outputs":[{"internalType":"address","name":"collateralToken","type":"address"},{"internalType":"uint256","name":"collateralAmount","type":"uint256"},{"internalType":"address","name":"loanToken","type":"address"},{"internalType":"uint256","name":"loanAmount","type":"uint256"},{"internalType":"uint256","name":"interestAmount","type":"uint256"},{"internalType":"uint256","name":"startTime","type":"uint256"},{"internalType":"bool","name":"active","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"_token","type":"address"},{"internalType":"uint256","name":"_amount","type":"uint256"}],"name":"withdrawCollateral","outputs":[],"stateMutability":"nonpayable","type":"function"},{"stateMutability":"payable","type":"receive"}]
const contractAddress = '0x6f30260C6d98F1ae19fC8DD64a7173b54ed8e780'; // Replace with the actual contract address
const cryptoLoanContract = new web3.eth.Contract(contractABI, contractAddress);
const address = "0x5744D3c78034b4A7ab590e6Cc8FCC918994a046f"; // Replace with your address

async function requestLoan(collateralToken, collateralAmount, loanToken, loanAmount) {
    try {
        const txData = cryptoLoanContract.methods.requestLoan(collateralToken, collateralAmount, loanToken, loanAmount).encodeABI();
        const txObject = {
            from: address,
            to: contractAd2dress,
            gas: 3000000,
            data: txData
        };
        const signedTx = await web3.eth.accounts.signTransaction(txObject, privateKey);
        const receipt = await web3.eth.sendSignedTransaction(signedTx.rawTransaction);
        console.log('Transaction receipt:', receipt);
    } catch (error) {
        console.error('Error requesting loan:', error);
    }
}

async function repayLoan(loanToken, loanId) {
    try {
        const txData = cryptoLoanContract.methods.repayLoan(loanToken, loanId).encodeABI();
        const txObject = {
            from: address,
            to: contractAddress,
            gas: 3000000,
            data: txData
        };
        const signedTx = await web3.eth.accounts.signTransaction(txObject, privateKey);
        const receipt = await web3.eth.sendSignedTransaction(signedTx.rawTransaction);
        console.log('Loan repaid:', receipt);
    } catch (error) {
        console.error('Error repaying loan:', error);
    }
}

async function repayLoanInNativeCurrency(loanToken, loanId) {
    try {
        const txData = cryptoLoanContract.methods.repayLoaninnativeCurrency(loanToken, loanId).encodeABI();
        const txObject = {
            from: address,
            to: contractAddress,
            gas: 3000000,
            data: txData,
            value: web3.utils.toWei('LoanAmountInEth', 'ether') // Replace with your loan amount
        };
        const signedTx = await web3.eth.accounts.signTransaction(txObject, privateKey);
        const receipt = await web3.eth.sendSignedTransaction(signedTx.rawTransaction);
        console.log('Loan repaid in native currency:', receipt);
    } catch (error) {
        console.error('Error repaying loan in native currency:', error);
    }
}

// Call the functions
// requestLoan('0xD5DeCf4d8a6Da6e619B9A152b9Fe76721e52d260', '10000000000000000000', '0x3ADD0D140057303AeaA689C867Ca2eA3A7F844aD', '1000000000000000000');
 repayLoan('0x3ADD0D140057303AeaA689C867Ca2eA3A7F844aD', '5');
// repayLoanInNativeCurrency('0xYourLoanTokenAddress', 'LoanId');
