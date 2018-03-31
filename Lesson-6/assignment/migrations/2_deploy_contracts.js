var Ownable = artifacts.require("Ownable");
var SafeMath = artifacts.require("SafeMath");
var Payroll = artifacts.require("Payroll");

module.exports = function(deployer) {
  deployer.deploy(Ownable);
  deployer.deploy(SafeMath);

  deployer.link(Ownable, Payroll);
  deployer.link(SafeMath, Payroll);
  deployer.deploy(Payroll);
};
