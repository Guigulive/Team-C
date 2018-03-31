var Payroll = artifacts.require('./Payroll.sol');

const timeTravel = function (time) {
  return new Promise((resolve, reject) => {
    web3.currentProvider.sendAsync({
      jsonrpc: "2.0",
      method: "evm_increaseTime",
      params: [time],
      id: new Date().getTime()
    }, (err, result) => {
	  web3.currentProvider.send({jsonrpc: "2.0", method: "evm_mine", params: [], id: 0});	
      if(err){ return reject(err) }
      return resolve(result)
    });
  });
};

contract('Payroll', function(accounts){

	it('add Employee test....', function(){
		return Payroll.deployed().then(function(instance){
			payrollInstance = instance;

			return payrollInstance.addEmployee(accounts[0], 1, {from: accounts[0]});
		})
		.then(() =>{

            return payrollInstance.employees.call(accounts[0]);
		})
		.then((employee) => {
			// console.log(JSON.stringify(employee));

			assert.equal(employee[1].valueOf(), web3.toWei(1), 'balance should be 1');
		})
	});
	


	var balanceInit;
	it('getPaid test....', function(){
		return Payroll.deployed().then(function(instance){
			payrollInstance = instance;

			return payrollInstance.addFund({from: accounts[0], value: web3.toWei(10, 'ether')});
		})
		.then(() =>{
			return timeTravel(86400 * 31);

		})
		.then(() =>{
			balanceInit = web3.eth.getBalance(accounts[0]).toNumber();

			return payrollInstance.getPaid({from: accounts[0]}); 
		})
		.then(() =>{

			return payrollInstance.employees.call(accounts[0]);
		})
		.then((employee) =>{

			var gas = web3.eth.gasPrice * web3.eth.getBlock(web3.eth.blockNumber).gasUsed;

			assert.isAbove((employee[1].toNumber() - gas), (web3.eth.getBalance(accounts[0]).toNumber() - balanceInit ), 'my salary is wrong');
		})
	});

	it('remove Employee test....', function(){
		return Payroll.deployed().then(function(instance){
			payrollInstance = instance;

			return payrollInstance.removeEmployee(accounts[0], {from: accounts[0]});
		})
		.then(() =>{

            return payrollInstance.employees.call(accounts[0]);
		})
		.then((employee) => {
			// console.log(JSON.stringify(employee));

			assert.equal(employee[0].valueOf(), 0x0, 'address should be 0x0 after remove');
		})
	});


});