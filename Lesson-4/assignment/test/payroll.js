const Payroll = artifacts.require('./Payroll.sol');

contract('Payroll_baseCase', (accounts) => {
  beforeEach(() => {
    var payroll;
    var has_thrown = false;
  });

  it('should return owner', () => {
    return Payroll.deployed().then((instance) => {
      payroll = instance;
      return payroll.owner.call();
    })
    .then((owner) => {
      assert.equal(owner, accounts[0]);
    })
    .catch((err) => {
      has_thrown = true;
      assert.isFalse(has_thrown);
    });
  });
});

contract('Payroll_addEmployee', (accounts) => {
  beforeEach(() => {
    var payroll;
    var has_thrown = false;
  });

  it('should revert when not calling from owner', () => {
    return Payroll.deployed()
    .then((instance) => {
      payroll = instance;
      return payroll.addEmployee(accounts[2], 1, {from: accounts[1]});
    })
    .catch((err) => {
      has_thrown = true;
      assert.isTrue(has_thrown);
    });
  });

  it('should add employee with no throw when addEmployee succeeds', () => {
    return Payroll.deployed()
    .then((instance) => {
      payroll = instance;
      return payroll.addEmployee(accounts[2], 1);
    })
    .catch((err) => {
      has_thrown = true;
      assert.isFalse(has_thrown, "shouldn't expect throw, err: " + err);
    });
  });

  it('should find new employee when addEmployee succeeds', () => {
    return Payroll.deployed()
    .then((instance) => {
      payroll = instance;
      return employee = payroll.employees.call(accounts[2]);
    })
    .then((employee) => {
      assert.isDefined(employee);
      assert.equal(accounts[2], employee[0]);
      assert.equal(web3.toWei(1, 'ether'), employee[1].toNumber());
      assert.isAbove(employee[2].toNumber(), 0);
    })
    .catch((err) => {
      has_thrown = true;
      assert.isFalse(has_thrown, "shouldn't expect throw, err: " + err);
    });
  });

  it('should increase totalSalary when addEmployee succeeds', () => {
    return Payroll.deployed().then((instance) => {
      payroll = instance;
      return payroll.totalSalary.call();
    })
    .then((totalSalary) => {
      assert.equal(web3.toWei(1, 'ether'), totalSalary.toNumber());
    })
    .catch((err) => {
      has_thrown = true;
      assert.isFalse(has_thrown, "shouldn't expect throw, err: " + err);
    });
  });

  it('should revert when employee already exists', () => {
    return Payroll.deployed()
    .then((instance) => {
      payroll = instance;
      return payroll.addEmployee(accounts[2], 1);
    })
    .catch((err) => {
      has_thrown = true;
      assert.isTrue(has_thrown);
    });
  });
});

contract('Payroll_removeEmployee', (accounts) => {
  beforeEach(() => {
    var payroll;
    var has_thrown = false;
  });

  it('should revert when not calling from owner', () => {
    return Payroll.deployed()
    .then((instance) => {
      payroll = instance;
      return payroll.removeEmployee(accounts[2], {from: accounts[1]});
    })
    .catch((err) => {
      has_thrown = true;
      assert.isTrue(has_thrown);
    });
  });

  it('should revert when employee not exists', () => {
    return Payroll.deployed()
    .then((instance) => {
      payroll = instance;
      return payroll.removeEmployee(accounts[3]);
    })
    .catch((err) => {
      has_thrown = true;
      assert.isTrue(has_thrown);
    });
  });

  it('should descrease totalBalance when removeEmployee succeeds', () => {
    return Payroll.deployed()
    .then((instance) => {
      // Add employee first.
      payroll = instance;
      return payroll.addEmployee(accounts[2], 1);
    })
    .then(() => {
      // Remove employee.
      return payroll.removeEmployee(accounts[2]);
    })
    .then(() => {
      return payroll.totalSalary.call();
    })
    .then((totalSalary) => {
      // assert that total balance has decreased.
      assert.equal(web3.toWei(0, 'ether'), totalSalary.toNumber());
    })
    .then(() => {
      return employee = payroll.employees.call(accounts[2]);
    })
    .then((employee) => {
      // assert that employee has been deleted.
      assert.equal(0, Number(employee[0]));
    })
    .catch((err) => {
      has_thrown = true;
      assert.isFalse(has_thrown, "shouldn't expect throw, err: " + err);
    });
  });
});
