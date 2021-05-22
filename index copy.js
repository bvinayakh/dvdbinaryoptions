// Source code to interact with smart contract
const Web3 = require("web3");
var web3 = new Web3(
  new Web3.providers.HttpProvider(
    "https://ropsten.infura.io/v3/f8efd6941c7046f1a327d161d0072504"
  )
);

const ethEnabled = async () => {
  if (window.ethereum) {
    await window.ethereum.sendAsync();
    window.web3 = new Web3(window.ethereum);
    return true;
  }
  return false;
};

if (!ethEnabled()) {
  alert("Please install MetaMask to use this dApp!");
}

if (ethEnabled()) {
  // contractAddress and abi are setted after contract deploy
  var contractAddress = "0x930F1d573DCC309AE300cF92606CE8550c162B95";
  var abi = JSON.parse(
    '[{"inputs":[],"stateMutability":"nonpayable","type":"constructor"},{"inputs":[{"internalType":"address","name":"participant","type":"address"}],"name":"voteNegative","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"address","name":"participant","type":"address"}],"name":"votePositive","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[],"name":"announceResult","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getContractBalance","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getNegative","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getPositive","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getTotal","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"}]'
  );

  //contract instance
  contract = new web3.ethererum.Contract(abi, contractAddress);
  // Accounts
  var account;

  web3.eth.getAccounts(function (err, accounts) {
    if (err != null) {
      alert("Error retrieving accounts.");
      return;
    }
    if (accounts.length == 0) {
      alert(
        "No account found! Make sure the Ethereum client is configured properly."
      );
      return;
    }
    account = accounts[0];
    console.log("Account: " + account);
    web3.eth.defaultAccount = account;
  });

  //Smart contract functions
  function registerSetInfo() {
    info = $("#newInfo").val();
    contract.methods
      .setInfo(info)
      .send({ from: account })
      .then(function (tx) {
        console.log("Transaction: ", tx);
      });
    $("#newInfo").val("");
  }

  function registerGetInfo() {
    contract.methods
      .getInfo()
      .call()
      .then(function (info) {
        console.log("info: ", info);
        document.getElementById("lastInfo").innerHTML = info;
      });
  }

  function positive() {
    contract.methods
      .getInfo()
      .call()
      .then(function (info) {
        console.log("info: ", info);
        document.getElementById("lastInfo").innerHTML = info;
      });
  }

  function negative() {
    contract.methods
      .getInfo()
      .call()
      .then(function (info) {
        console.log("info: ", info);
        document.getElementById("lastInfo").innerHTML = info;
      });
  }

  function total() {
    contract.methods
      .getInfo()
      .call()
      .then(function (info) {
        console.log("info: ", info);
        document.getElementById("lastInfo").innerHTML = info;
      });
  }
}
