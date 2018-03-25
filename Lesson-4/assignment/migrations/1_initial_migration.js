var Payroll = artifacts.require("Payroll");

module.exports = function(deployer) {
  deployer.deploy(Payroll);
};
