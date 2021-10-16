const sell = artifacts.require("Sell");

module.exports = function (deployer) {
  deployer.deploy(sell);
};
