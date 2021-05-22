const Web3 = require("web3");
const abiJSON =
  '[{"inputs":[],"name":"announceResult","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"bytes32","name":"_requestId","type":"bytes32"},{"internalType":"uint256","name":"_payment","type":"uint256"},{"internalType":"bytes4","name":"_callbackFunctionId","type":"bytes4"},{"internalType":"uint256","name":"_expiration","type":"uint256"}],"name":"cancelRequest","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"bytes32","name":"id","type":"bytes32"}],"name":"ChainlinkCancelled","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"bytes32","name":"id","type":"bytes32"}],"name":"ChainlinkFulfilled","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"bytes32","name":"id","type":"bytes32"}],"name":"ChainlinkRequested","type":"event"},{"inputs":[{"internalType":"bytes32","name":"_requestId","type":"bytes32"},{"internalType":"uint256","name":"_price","type":"uint256"}],"name":"fulfill","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"getAPIResult","outputs":[{"internalType":"bytes32","name":"requestId","type":"bytes32"}],"stateMutability":"nonpayable","type":"function"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"string","name":"status","type":"string"}],"name":"log","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"string","name":"message","type":"string"}],"name":"logString","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"uint256","name":"value","type":"uint256"}],"name":"logUint","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"bool","name":"status","type":"bool"}],"name":"logging","type":"event"},{"inputs":[{"internalType":"uint256","name":"_criteria","type":"uint256"}],"name":"setCriteria","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"bool","name":"_paused","type":"bool"}],"name":"setPaused","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"participant","type":"address"}],"name":"voteNegative","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"address","name":"participant","type":"address"}],"name":"votePositive","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[],"name":"withdrawLink","outputs":[],"stateMutability":"nonpayable","type":"function"},{"stateMutability":"payable","type":"receive"},{"inputs":[],"name":"criteria","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"currentPrice","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getContractBalance","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getNegative","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getPositive","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getTotal","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"isPaused","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"latestPausedTime","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"tokenName","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"tokenSymbol","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"}]';

const abi = JSON.parse(abiJSON);

document.addEventListener("DOMContentLoaded", onDocumentLoad);
function onDocumentLoad() {
  DApp.init();
}

const contractAddress = "0xC75dDD8fc504C2d78CF56d2Da71E765b54C4E495";

const DApp = {
  web3: null,
  contracts: {},
  accounts: [],

  init: function () {
    return DApp.initWeb3();
  },

  initWeb3: async function () {
    if (typeof window.ethereum !== "undefined") {
      // New web3 provider
      // As per EIP1102 and EIP1193
      // Ref: https://eips.ethereum.org/EIPS/eip-1102
      // Ref: https://eips.ethereum.org/EIPS/eip-1193
      try {
        // Request account access if needed
        const accounts = await window.ethereum.request({
          method: "eth_requestAccounts",
        });
        // Accounts now exposed, use them
        DApp.updateAccounts(accounts);

        // Opt out of refresh page on network change
        // Ref: https://docs.metamask.io/guide/ethereum-provider.html#properties
        ethereum.autoRefreshOnNetworkChange = false;

        // When user changes to another account,
        // trigger necessary updates within DApp
        window.ethereum.on("accountsChanged", DApp.updateAccounts);
      } catch (error) {
        // User denied account access
        console.error("User denied web3 access");
        return;
      }
      DApp.web3 = new Web3(window.ethereum);
    } else if (window.web3) {
      // Deprecated web3 provider
      DApp.web3 = new Web3(web3.currentProvider);
      // no need to ask for permission
    }
    // No web3 provider
    else {
      console.error("No web3 provider detected");
      return;
    }
    return DApp.initContract();
  },

  updateAccounts: async function (accounts) {
    const firstUpdate = !(DApp.accounts && DApp.accounts[0]);
    DApp.accounts = accounts || (await DApp.web3.eth.getAccounts());
    console.log("updateAccounts", accounts[0]);
    if (!firstUpdate) {
      DApp.render();
    }
  },

  initContract: async function () {
    let networkId = await DApp.web3.eth.net.getId();
    console.log("networkId", networkId);

    // let deployedNetwork = mySmartContractArtefact.networks[networkId];
    // if (!deployedNetwork) {
    //   console.error(
    //     "No contract deployed on the network that you are connected. Please switch networks."
    //   );
    //   return;
    // }
    // console.log("deployedNetwork", deployedNetwork);

    // DApp.contracts.MySmartContract = new DApp.web3.eth.Contract(
    //   '[{"inputs":[],"stateMutability":"nonpayable","type":"constructor"},{"inputs":[{"internalType":"address","name":"participant","type":"address"}],"name":"voteNegative","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"address","name":"participant","type":"address"}],"name":"votePositive","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[],"name":"announceResult","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getContractBalance","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getNegative","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getPositive","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getTotal","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"}]',
    //   deployedNetwork.address
    // );

    DApp.contracts.mycontract = new DApp.web3.eth.Contract(
      abi,
      contractAddress
    );
    return DApp.render();
  },

  render: async function () {
    // show spinner before loading data from smart contract
    // TODO
    // set or refresh any event listeners
    // update DOM to render account address where relevant
    // TODO using DApp.accounts[0]
    // retrieve data from smart contract and render it
    // TODO using DApp.contracts.MySmartContract
    // Hide spinner after loading and rendering data from smart contract
    //this.positive();
    this.total();
  },

  positive: function (addr) {
    DApp.contracts.mycontract.methods
      .votePositive(addr)
      .call()
      .then(function (info) {
        console.log("info: ", info);
        document.getElementById("lastInfo").innerHTML = info;
      });
  },

  negative: function (addr) {
    DApp.contracts.mycontract.methods
      .voteNegative(addr)
      .call()
      .then(function (info) {
        console.log("info: ", info);
        document.getElementById("lastInfo").innerHTML = info;
      });
  },

  total: function () {
    DApp.contracts.mycontract.methods
      .getTotal()
      .call()
      .then(function (info) {
        console.log("total: ", info);
        document.getElementById("totalparticipants").innerHTML = info;
      });
  },
};
