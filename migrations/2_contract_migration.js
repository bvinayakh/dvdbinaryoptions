const BinaryOptions = artifacts.require("BinaryOptions");

module.exports = function (deployer) {
  deployer.deploy(BinaryOptions, "1623241006", "3000", "1623241006");
};
