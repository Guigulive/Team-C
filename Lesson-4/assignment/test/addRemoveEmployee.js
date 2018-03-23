var PayRoll = artifacts.require("Payroll");


/**
 *  Unit test to check addEmployee and removeEmployee in PayRoll
 *  Issues:
 *  1 check if the employee is correctly paid when removed by the owner
 *  2 the way to deal with thrown may be improved?
 */
contract('PayRollAddRemoveEmployee', function(accounts) {

    var payroll; // instance of the deployed PayRoll contract

    var employeeId = 1; // the account to be added as an employee by the owner
    var anotherEmpolyee = 5; // another employee associated with many mal behavior
    var salarySet = 1; // 1ether salary
    var wrongOwner = 7; // the account that will try to call functions that should only be called by owner
    var fundToAdd = 20; // amount of ether the owner deposit into the contract

    it("Owner can add an employee", function() {    

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
            assert.equal(salary, salarySet, "Salary is wrongly set.");
            assert.equal(timeStamp, web3.eth.getBlock(web3.eth.blockNumber).timestamp, "lastPayDay is not set to be the current block time!");
        });
    });

    it("Owner cannot add an existing employee", function() {

        var hasThrown = true;

        return payroll.addEmployee(accounts[employeeId], salarySet, {from: accounts[0]})
        .then(function() {
            hasThrown = false;
            assert.fail('should have thrown before');
        }).catch(function(err) {
            assert.equal(hasThrown, true, "Owner can add the same employee twice!"); //may be impoved
        });

    });

    // without this, owner cannot remove an employee because no ether to pay.
    it("Owner can add some fund", function() {
        return payroll.addFund({from:accounts[0], value: web3.toWei(fundToAdd, 'ether')})
        .catch(function (err){
            assert.fail("Owner failed to add some fund!");
        })
    });

    it("Other people cannot add an employee", function() {

        var hasThrown = true;
        
        return payroll.addEmployee(accounts[anotherEmpolyee], salarySet, {from: accounts[wrongOwner]})
        .then(function() {
            hasThrown = false;
            assert.fail('should have thrown before');
        }).catch(function(err) {
            assert.equal(hasThrown, true, "Other people can add an employee!");
        });
    });

    it("Other people cannot remove an employee", function() {

        var hasThrown = true;

        return payroll.removeEmployee(accounts[employeeId], {from: accounts[wrongOwner]})
        .then(function() {
            hasThrown = false;
            assert.fail('should have thrown before');
        }).catch(function(err) {
            assert.equal(hasThrown, true, "Other people can remove an employee!");
        });

    });


    it("Owner cannot remove a no existing employee:", function() {
        
        var hasThrown = true;

        return payroll.removeEmployee(accounts[anotherEmpolyee], {from: accounts[0]})
        .then(function() {
            hasThrown = false;
            assert.fail('should have thrown before');
        }).catch(function(err) {
            assert.equal(hasThrown, true, "Owner removed a no existing employee!");
        });

    });

    it("Owner can remove an existing employee:", function() {
        
        return payroll.removeEmployee(accounts[employeeId], {from: accounts[0]})
        .then(function() {
            return payroll.employees.call(accounts[employeeId]);
        }).then(function(employeeInfo) {
            var salary = employeeInfo[0].toNumber();
            var timeStamp = employeeInfo[1].toNumber();
            salary = web3.fromWei(salary, 'ether');
            assert.equal(salary, 0, "Salary is not cleaned.");
            assert.equal(timeStamp, 0, "lastPayDay is not cleaned");
        });

    });

});
