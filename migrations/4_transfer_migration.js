const TransferTrade = artifacts.require("TransferTrade");

module.exports = function (deployer) {
  deployer.deploy(TransferTrade);
};