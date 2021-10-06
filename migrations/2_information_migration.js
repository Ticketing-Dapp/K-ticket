const Information = artifacts.require("Information");
const TransferTrade = artifacts.require("TransferTrade");

module.exports = async function (deployer) {
  await deployer.deploy(Information);
  await deployer.link(Information, TransferTrade);
  await deployer.deploy(TransferTrade);
};