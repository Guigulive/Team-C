var Payroll = artifacts.require("./Payroll.sol");

contract('Payroll', function (accounts) {
  const owner = accounts[0]
  const employee = accounts[1]
  const guest = accounts[5]
  const salray = 1;

  it("Test call addEmployee() and removeEmployee by owner", function () {
    var payroll;
    return Payroll.deployed().then(instance => {
      payroll = instance;
      return payroll.addEmployee(employee, salray, { from: owner });
    }).then(() => {
      return payroll.removeEmployee(employee);
    }).then(() => {
      return payroll.employees(employee);
    }).then(employeeInfo => {
      assert.equal(employeeInfo[0].toNumber(), 0, "Fail to call addEmployee() and removeEmployee()");
    });
  });

  it("Test remove a non-existent employee", function () {
    var payroll;
    return Payroll.deployed().then(function (instance) {
      payroll = instance;
      return payroll.removeEmployee(employee);
    }).then(() => {
      assert(false, "Should not be successful");
    }).catch(error => {
      assert.include(error.toString(), "invalid opcode", "Can not remove a non-existent employee");
    });
  });

  it("Test removeEmployee() by guest", function () {
    var payroll;
    return Payroll.deployed().then(function (instance) {
      payroll = instance;
      return payroll.addEmployee(employee, salray, { from: owner });
    }).then(() => {
      return payroll.removeEmployee(employee, { from: guest });
    }).then(() => {
      assert(false, "Should not be successful");
    }).catch(error => {
      assert.include(error.toString(), "Error: VM Exception while processing transaction: revert", "Can not call removeEmployee() by who is not the owner");
    });
  });
});
