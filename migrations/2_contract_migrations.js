const Migrations = artifacts.require("BinaryOptions");

module.exports = function (deployer) {
  deployer.deploy(BinaryOptions);
};
