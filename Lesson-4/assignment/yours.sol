/*作业请提交在这个目录下*/
var Payroll = artifacts.require("./Payroll.sol");

contract('Payroll', function (accounts) {

  it("test add employee from owner", function () {
    return Payroll.deployed().then(function (instance) {
      payrollInstance = instance;
      return payrollInstance.addEmployee(accounts[1], 1, { from: accounts[0] });
    }).then(function () {
      return payrollInstance.employees.call(accounts[1]);
    }).then(function (employee) {
      assert.equal(employee[1].toNumber(), web3.toWei(1), "salary was not saved correctly.");
    });
  });

  it("test add employee not from owner", function () {
    return Payroll.deployed().then(function (instance) {
      payrollInstance = instance;
      return payrollInstance.addEmployee(accounts[2], 1, { from: accounts[3] });
    }).catch(function (error) { 
      assert.include(error.toString(), "Error: VM Exception while processing transaction: revert", "can not add employee if you are not owner") 
    });
  });

  it("test add duplicate employee", function () {
    return Payroll.deployed().then(function (instance) {
      payrollInstance = instance;
      return payrollInstance.addEmployee(accounts[1], 1, { from: accounts[0] });
    }).then(function () {
      assert(false, "can not add duplicate employee");
    }).catch(function (error) { 
      assert.include(error.toString(), "Error: VM Exception while processing transaction: invalid opcode", "can not add employee if you are not owner") 
    });
  });

  it("test remove employee not from owner", function () {
    return Payroll.deployed().then(function (instance) {
      payrollInstance = instance;
      return payrollInstance.removeEmployee(accounts[1], { from: accounts[3] });
    }).catch(function (error) { 
      assert.include(error.toString(), "Error: VM Exception while processing transaction: revert", "can not remove employee if you are not owner") 
    });
  });

  it("test remove employee from owner", function () {
    return Payroll.deployed().then(function (instance) {
      payrollInstance = instance;
      return payrollInstance.removeEmployee(accounts[1], { from: accounts[0] });
    }).then(function () {
      return payrollInstance.employees.call(accounts[1]);
    }).then(function (employee) {
      assert.equal(employee[1].toNumber(), 0, "remove employee from ownner");
    });
  });

  it("test remove non-exist employee from owner", function () {
    return Payroll.deployed().then(function (instance) {
      payrollInstance = instance;
      return payrollInstance.removeEmployee(accounts[1], { from: accounts[0] });
    }).catch(function (error) { 
      assert.include(error.toString(), "Error: VM Exception while processing transaction: invalid opcode", "can not remove non-exist employee") 
    });
  });

});
