const RegisterConcert = artifacts.require("RegisterConcert");

module.exports = function (deployer) {
  deployer.deploy(RegisterConcert);
};