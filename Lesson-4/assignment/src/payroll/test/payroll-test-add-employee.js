var Payroll = artifacts.require("./Payroll.sol");

contract('Payroll', function (accounts) {
  const owner = accounts[0]
  const employee = accounts[1]
  const guest = accounts[5]
  const salray = 1;

  it("Test call addEmployee() by owner", function () {
    var payroll;
    return Payroll.deployed().then(instance => {
      payroll = instance;
      return payroll.addEmployee(employee, salray, { from: owner });
    }).then(() => {
      return payroll.employees(employee);
    }).then(employeeInfo => {
      assert.equal(employeeInfo[0].toNumber(), web3.toWei(salray, 'ether'), "Try addEmployee() fail");
    });
  });

  it("Test addEmployee() duplicated", function () {
    var payroll;
    return Payroll.deployed().then(function (instance) {
      payroll = instance;
      return payroll.addEmployee(employee, salray, { from: owner });
    }).then(() => {
      return payroll.addEmployee(employee, salray, { from: owner });
    }).then(() => {
      assert(false, "Should not be successful");
    }).catch(error => {
      assert.include(error.toString(), "invalid opcode", "Should not add duplicated employees");
    });
  });

  it("Test addEmployee() by guest", function () {
    var payroll;
    return Payroll.deployed().then(function (instance) {
      payroll = instance;
      return payroll.addEmployee(employee, salray, { from: guest });
    }).then(() => {
      assert(false, "Should not be successful");
    }).catch(error => {
      assert.include(error.toString(), "Error: VM Exception while processing transaction: revert", "Can not call addEmployee() by who is not owner");
    });
  });
});
