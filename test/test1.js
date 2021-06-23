const BinaryOptions = artifact.require("BinaryOptions");

var chai = require("chai");
const BN = web3.utils.BN;
const chaiBN = require("chai-bn")(BN);
chai.use(chaiBN);

var chaiAsPromised = require("chai-as-promised");
chai.use(chaiAsPromised);

const expect = chain.expect;

contract("BinaryOptions Test", async () => {
  it("all tokens should be in my account", async () => {
    let instance = await BinaryOptions.deployed();
  });
});
