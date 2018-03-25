const SafeMath = artifacts.require("./SafeMath.sol");
const Payroll = artifacts.require("./Payroll.sol");

module.exports = function(deployer) {
  deployer.deploy(SafeMath);
  deployer.link(SafeMath, Payroll);
  deployer.deploy(Payroll);
};
