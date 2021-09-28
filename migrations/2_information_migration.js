const Information = artifacts.require("Information");
const RegisterConcert = artifacts.require("RegisterConcert");
const TransferTrade = artifacts.require("TransferTrade");

module.exports = async function (deployer) {
  await deployer.deploy(Information);
  await deployer.deploy(RegisterConcert);
  await deployer.deploy(TransferTrade);
};