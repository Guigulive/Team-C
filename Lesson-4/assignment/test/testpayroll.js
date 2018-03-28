var Payroll = artifacts.require("./Payroll.sol");

contract('Payroll', function (accounts) {
    owner = accounts[0];
    // addEmployee
    it("add employee successfully", function () {
        return Payroll.deployed().then(function (instance) {
            wh = instance;
            return wh.addEmployee(accounts[1], 1);
        }).then(function () {
            return wh.employees.call(accounts[1]);
        }).then(function (employee) {
            employee1 = employee[0];
        }).then(function () {
            return wh.addEmployee(accounts[2], 1);
        }).then(function () {
            return wh.employees.call(accounts[2]);
        }).then(function (employee) {
            employee2 = employee[0];
        }).then(function () {
            assert.equal(employee1, accounts[1],"add employee1 not successfully");
            assert.equal(employee2, accounts[2]);
            
        });
    });
    
    // addEmployee by nonowner   
    it("add employee by nonowner failed", function () {
        return Payroll.deployed().then(function (instance) {
            wh = instance;
            exception = false;
            return wh.addEmployee(accounts[3], 1, { from: accounts[1] });
        }).catch(function (error) {
            exception = true;
        }).then(function () {
            assert.equal(exception, true,"error happen");
        });
    });

    it("add exist employee failed", function () {
        return Payroll.deployed().then(function (instance) {
            wh = instance;
            exception = false;
            return wh.addEmployee(accounts[1], 1, { from: accounts[0] });
        }).catch(function (error) {
            exception = true;
        }).then(function () {
            assert.equal(exception, true,"error happen");
        });
    });

    // removeEmployee 
    it("remove employee successfully", function () {
        return Payroll.deployed().then(function (instance) {
            wh = instance;
            amount = web3.toWei(20, "ether");
            return wh.addFund({ from: owner, value: amount });
        }).then(function() {
            console.log("获取contract余额");
            var banlance1=web3.eth.getBalance(wh.address);
            console.log(web3.fromWei(banlance1.toNumber(),'ether'),'ether');
        }).then(function() {
            console.log("获取accounts[0]余额");
            var banlance2=web3.eth.getBalance(accounts[0]);
            console.log(web3.fromWei(banlance2.toNumber(),'ether'),'ether');
        }).then(function () {
            return wh.employees.call(accounts[1]);
        }).then(function (employee) {
            employee1 = employee[0];
        }).then(function () {
            return wh.removeEmployee(accounts[1]);
        }).then(function () {
            return wh.employees.call(accounts[1]);
        }).then(function (employee) {
            employee2 = employee[0];
        }).then(function () {
            assert(employee1, accounts[1]);
            assert(employee2, 0);
        });
    });

    it("test getPaid successfully", function () {
        return Payroll.deployed().then(function (instance) {
            wh = instance;
            console.log("获取before_paid余额");
            e_balance_old = web3.eth.getBalance(accounts[2]);
            amount_old = web3.fromWei(e_balance_old, "ether");
            console.log(web3.fromWei(e_balance_old.toNumber(),'ether'),'ether');
            console.log(amount_old);
         }).then(function () {
            console.log("等待 10 seconds!");
            web3.currentProvider.send({jsonrpc:"2.0",method:"evm_increaseTime",params:[10],id:0});
            return wh.getPaid({from: accounts[2]});
         }).then(function () {
            e_balance_new = web3.eth.getBalance(accounts[2]);
            amount_new = web3.fromWei(e_balance_new, "ether");
            console.log("获取after_paid余额");
            console.log(web3.fromWei(e_balance_new.toNumber(),'ether'),'ether');
            console.log(amount_new);
        });
    });

});
