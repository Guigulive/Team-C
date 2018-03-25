var PayRoll = artifacts.require("Payroll");

/**
 *  Unit test to check getPaid in PayRoll
 *  Issues:
 *  1 In test "Employee can get paid after the next pay date.",
 *    the way to deal with gas price is not beatiful.
 *  2 the way to deal with thrown may be improved?
 */   
contract('PayRollGetPaid', function(accounts) {

    var day = 24*60*60; // day to second

    // !!! this should be manually set the same as in PayRoll (bad code!)
    var payDuration = 30 * day; 

    var payroll; // instance of the deployed PayRoll contract

    var employeeId = 1; // the account to be added as an employee by the owner
    var anotherEmpolyee = 5; // another employee associated with many mal behavior
    var salarySet = 1; // 1ether salary
    var fundToAdd = 20; // amount of ether the owner deposit into the contract
    
    /**
     *  Add one employee and deposit some fund to the contract.
     *  This process should be thoroughly tested in addRemoveEmployee.js
     */
    it("Preparation", function() {    

        return PayRoll.deployed()
        .then(function(instance) {
            payroll = instance;
            return payroll.addEmployee(accounts[employeeId], salarySet, {from: accounts[0]});
        }).then(function() {
            return payroll.employees.call(accounts[employeeId]);
        }).then(function(employeeInfo) {

            var salary = employeeInfo[0].toNumber();
            var timeStamp = employeeInfo[1].toNumber();
            salary = web3.fromWei(salary, 'ether');
            assert.equal(salary, salarySet, "Preparation failed, check 'addRemoveEmployee' test first.");
            assert.equal(timeStamp, web3.eth.getBlock(web3.eth.blockNumber).timestamp, "Preparation failed, check 'addRemoveEmployee' test first.");

            return payroll.addFund({from:accounts[0], value: web3.toWei(fundToAdd, 'ether')
        }).catch(function (err){
            assert.fail("Preparation failed, check 'addRemoveEmployee' test first.");
        })
        });
    });

    it("Employee cannot get paid before the next pay date.", function () {
        
        var hasThrown = true;
        // one day before the next pay day
        web3.currentProvider.send({jsonrpc: "2.0", method: "evm_increaseTime", params: [payDuration-day], id: 0})
        web3.currentProvider.send({jsonrpc: "2.0", method: "evm_mine", params: [], id: 0});

        return payroll.getPaid({from: accounts[employeeId]
        }).then(function() {
            hasThrown = false;
            assert.fail('should have thrown before');
        })
        .catch(function(err) {
            assert.equal(hasThrown, true, "Employee can take his salary before the next pay day!");
        }); 
    });

    it("Other employee cannot get paid even after the next pay date.", function () {
        
        var hasThrown = true;
        // one day after the next pay day
        web3.currentProvider.send({jsonrpc: "2.0", method: "evm_increaseTime", params: [2*day], id: 0})
        web3.currentProvider.send({jsonrpc: "2.0", method: "evm_mine", params: [], id: 0});

        return payroll.getPaid({from: accounts[anotherEmpolyee]
        }).then(function() {
            hasThrown = false;
            assert.fail('should have thrown before');
        })
        .catch(function(err) {
            assert.equal(hasThrown, true, "One employee can take other's salary!");
        }); 
    });


    it("Employee can get paid after the next pay date.", function () {
        
        var balanceBefore = web3.eth.getBalance(accounts[employeeId]).toNumber();
        var balanceAfter;

        return payroll.getPaid({from: accounts[employeeId]
        }).then(function() {
            balanceAfter = web3.eth.getBalance(accounts[employeeId]).toNumber();
            assert.isAbove(balanceAfter, balanceBefore + 0.9*web3.toWei(salarySet, "ether"), "Employee gets insufficient pay!") //ugly!!!
        });
    });

    it("Employee cannot get additional paid.", function () {
        
        var hasThrown = true;
        // one day before the next pay day
        web3.currentProvider.send({jsonrpc: "2.0", method: "evm_increaseTime", params: [payDuration-2*day], id: 0})
        web3.currentProvider.send({jsonrpc: "2.0", method: "evm_mine", params: [], id: 0});

        return payroll.getPaid({from: accounts[employeeId]
        }).then(function() {
            hasThrown = false;
            assert.fail('should have thrown before');
        })
        .catch(function(err) {
            assert.equal(hasThrown, true, "Employee can get additional payment!");
        }); 
    });

});