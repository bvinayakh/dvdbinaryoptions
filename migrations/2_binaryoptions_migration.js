const BinaryOptions = artifacts.require("BinaryOptions");

module.exports = function (deployer) {
  deployer.deploy(
    BinaryOptions,
    "1623241006",
    "3000",
    "1623241006",
    "0x9326bfa02add2366b30bacb125260af641031331"
  );
};
