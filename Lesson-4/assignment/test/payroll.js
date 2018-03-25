const Payroll = artifacts.require('./Payroll.sol');

contract('Payroll_baseCase', (accounts) => {
  beforeEach(() => {
    var payroll;
    var hasThrown = false;
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
      hasThrown = true;
      assert.isFalse(hasThrown);
    });
  });
});

contract('Payroll_addEmployee', (accounts) => {
  beforeEach(() => {
    var payroll;
    var hasThrown = false;
  });

  it('should revert when not calling from owner', () => {
    return Payroll.deployed()
    .then((instance) => {
      payroll = instance;
      return payroll.addEmployee(accounts[2], 1, {from: accounts[1]});
    })
    .catch((err) => {
      hasThrown = true;
      assert.isTrue(hasThrown);
    });
  });

  it('should add employee with no throw when addEmployee succeeds', () => {
    return Payroll.deployed()
    .then((instance) => {
      payroll = instance;
      return payroll.addEmployee(accounts[2], 1);
    })
    .catch((err) => {
      hasThrown = true;
      assert.isFalse(hasThrown, "shouldn't expect throw, err: " + err);
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
      assert.equal(web3.eth.getBlock(web3.eth.blockNumber).timestamp,
                   employee[2].toNumber());
    })
    .catch((err) => {
      hasThrown = true;
      assert.isFalse(hasThrown, "shouldn't expect throw, err: " + err);
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
      hasThrown = true;
      assert.isFalse(hasThrown, "shouldn't expect throw, err: " + err);
    });
  });

  it('should revert when employee already exists', () => {
    return Payroll.deployed()
    .then((instance) => {
      payroll = instance;
      return payroll.addEmployee(accounts[2], 1);
    })
    .catch((err) => {
      hasThrown = true;
      assert.isTrue(hasThrown);
    });
  });
});

contract('Payroll_removeEmployee', (accounts) => {
  beforeEach(() => {
    var payroll;
    var hasThrown = false;
  });

  it('should revert when not calling from owner', () => {
    return Payroll.deployed()
    .then((instance) => {
      payroll = instance;
      return payroll.removeEmployee(accounts[2], {from: accounts[1]});
    })
    .catch((err) => {
      hasThrown = true;
      assert.isTrue(hasThrown);
    });
  });

  it('should revert when employee not exists', () => {
    return Payroll.deployed()
    .then((instance) => {
      payroll = instance;
      return payroll.removeEmployee(accounts[3]);
    })
    .catch((err) => {
      hasThrown = true;
      assert.isTrue(hasThrown);
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
      hasThrown = true;
      assert.isFalse(hasThrown, "shouldn't expect throw, err: " + err);
    });
  });
});

contract('Payroll_getPaid', (accounts) => {
  const timeToForward = 60 * 60 * 24 * 30; // 30 days in seconds.

  beforeEach(() => {
    var payroll;
    var hasThrown = false;
  });

  it('should increase time for 30 days', () => {
    var t1, t2;
    return Payroll.deployed()
    .then((instance) => {
      payroll = instance;
      t1 = web3.eth.getBlock(web3.eth.blockNumber).timestamp;
      return web3.currentProvider.send({
        jsonrpc: '2.0', 
        method: 'evm_increaseTime', 
        params: [timeToForward], 
        id: 0,
      });
    }).then(() => {
      return web3.currentProvider.send({
        jsonrpc: '2.0', 
        method: 'evm_mine', 
        params: [], 
        id: 0,
      });
    }).then(() => {
      t2 = web3.eth.getBlock(web3.eth.blockNumber).timestamp;
      assert.isAbove(t2 - t1, timeToForward);
    });
  });

  it('should prepare one emoloyee and add fund', () => {
    return Payroll.deployed()
    .then((instance) => {
      payroll = instance;
      return payroll.addEmployee(accounts[2], 1);
    })
    .then(() => {
      return payroll.addFund({
        from: accounts[0],
        value: web3.toWei(1, 'ether'),
      });
    })
    .then(() => {
      const balance = web3.eth.getBalance(payroll.address);
      assert.equal(balance.toNumber(), web3.toWei(1, 'ether'));
      return payroll.totalSalary.call();
    })
    .then((totalSalary) => {
      assert.equal(totalSalary, web3.toWei(1, 'ether'));
      return payroll.calculateRunway.call();
    })
    .then((runway) => {
      assert.equal(runway.toNumber(), 1);
    })
    .catch((err) => {
      hasThrown = true;
      assert.isFalse(hasThrown, "shouldn't expect throw, err: " + err);
    })
  });

  it('should revert when calling from non-employee', () => {
    return Payroll.deployed()
    .then((instance) => {
      payroll = instance;
      return payroll.getPaid.call({from: accounts[3]});
    })
    .catch((err) => {
      hasThrown = true;
      assert.isTrue(hasThrown);
    })
  });

  it('should revert when it is not pay date yet', () => {
    return Payroll.deployed()
    .then((instance) => {
      payroll = instance;
      return payroll.getPaid.call({from: accounts[2]});
    })
    .catch((err) => {
      hasThrown = true;
      assert.isTrue(hasThrown);
    })
  });

  it('should pay employee once if qualified', () => {
    return Payroll.deployed()
    .then((instance) => {
      payroll = instance;
      return web3.currentProvider.send({
        jsonrpc: '2.0', 
        method: 'evm_increaseTime', 
        params: [timeToForward], 
        id: 0,
      });
    })
    .then(() => {
      return web3.currentProvider.send({
        jsonrpc: '2.0', 
        method: 'evm_mine', 
        params: [], 
        id: 0,
      });
    })
    .then(() => {
      return payroll.getPaid({from: accounts[2]});
    })
    .then(() => {
      const balance = web3.eth.getBalance(payroll.address);
      assert.equal(balance.toNumber(), web3.toWei(0, 'ether'));
      return payroll.totalSalary.call();
    })
    .catch((err) => {
      hasThrown = true;
      assert.isFalse(hasThrown);
    })
  });

  it('should revert when there is not enough balance', () => {
    return Payroll.deployed()
    .then((instance) => {
      payroll = instance;
      return web3.currentProvider.send({
        jsonrpc: '2.0', 
        method: 'evm_increaseTime', 
        params: [timeToForward], 
        id: 0,
      });
    })
    .then(() => {
      return web3.currentProvider.send({
        jsonrpc: '2.0', 
        method: 'evm_mine', 
        params: [], 
        id: 0,
      });
    })
    .then(() => {
      return payroll.getPaid({from: accounts[2]});
    })
    .catch((err) => {
      hasThrown = true;
      assert.isTrue(hasThrown);
    })
  });
});
