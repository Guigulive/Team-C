var Payroll = artifacts.require("./Payroll.sol");

contract('Payroll', function (accounts) {
  const owner = accounts[0]
  const employee = accounts[1]
  const guest = accounts[3]
  const salary1 = 1;
  const salary2 = 2;

  var payroll;

  it("Only owner can call addEmployee", function () {
        return Payroll.deployed().then(function (instance) {
            payrollinstance = instance;
            return payrollinstance.addEmployee(accounts[1], salary1);
        }).then(function () {
            return payrollinstance.employees.call(accounts[1]);
        }).then(function (employee) {
            employee1 = employee[0];
            employee1Salary = employee[1];
        }).then(function () {
            return payrollinstance.addEmployee(accounts[2], salary2);
        }).then(function () {
            return payrollinstance.employees.call(accounts[2]);
        }).then(function (employee) {
            employee2 = employee[0];
            employee2Salary = employee[1];
        }).then(function () {
            assert.equal(employee1, accounts[1],"the employee1 is not added successfully");
            assert.equal(employee2, accounts[2],"the employee2 is not added successfully");
            assert.equal(web3.fromWei(employee1Salary, 'ether'), salary1,"salary of employee1 is not added successfully");
            assert.equal(web3.fromWei(employee2Salary, 'ether'), salary2,"salary of employee2 is not added successfully");
        });
    });

  it("Guest could not add Employee", function () {
    return Payroll.deployed().then(function (instance) {
      payroll = instance;
      return payroll.addEmployee(employee, salary1, { from: guest });
    }).catch(error => {
      exception = true;
    }).then(function () {
        assert.equal(exception, true);
    });
  });

  it("Duplicate Employee", function () {
    var payroll;
    return Payroll.deployed().then(function (instance) {
      payroll = instance;
      return payroll.addEmployee(employee, salary1, { from: owner });
    }).then(function (){
      return payroll.addEmployee(employee, salary1, { from: owner });
    }).then(function (){
      assert(false, "Duplicate employee should not be ");
    }).catch(error => {
      assert.include(error.toString(), "invalid opcode", "Should not add duplicated employees");
    });
  });


  it("guest cannot remove employee", function () {
    var payroll;
    return Payroll.deployed().then(function (instance) {
      payroll = instance;
      return payroll.addEmployee(employee, salary, { from: owner });
    }).then(() => {
      return payroll.removeEmployee(employee, { from: guest });
    }).then(() => {
      assert(false, "Should not be successful");
    }).catch(error => {
      assert.include(error.toString(), "Error: VM Exception while processing transaction: revert");
    });
  });

  it("cannot remove non-exist employee ", function () {
        return Payroll.deployed().then(function (instance) {
            payroll = instance;
            exception = false;
            return payrollinstance.addEmployee(accounts[1], 1);
        }).then(function () {
            return payrollinstance.removeEmployee(accounts[3]);
        }).catch(function (error) {
            exception = true;
        }).then(function () {
            assert.equal(exception, true);
        });
    });

  it("only owner can remove employee successfully", function () {
      return Payroll.deployed().then(function (instance) {
          payrollinstance = instance;
          amount = web3.toWei(9, "ether")
          return payrollinstance.addFund({ from: owner, value: amount });
      }).then(function () {
          return payrollinstance.addEmployee(accounts[1], 1);
      }).then(function () {
          return payrollinstance.employees.call(accounts[1]);
      }).then(function (employee) {
          employee1 = employee[0];
      }).then(function () {
          return payrollinstance.removeEmployee(accounts[1]);
      }).then(function () {
          return payrollinstance.employees.call(accounts[1]);
      }).then(function (employee) {
          employee2 = employee[0];
      }).then(function () {
          assert(employee1, accounts[1]);
          assert(employee2, 0);
      });
  });
});
