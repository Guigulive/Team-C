async function  assertRevert  (promise){
  try {
    await promise;
    assert.fail('Expected revert not received');
  } catch (error) {
    const revertFound = error.message.search('revert') >= 0;
    assert(revertFound, `Expected "revert", got ${error} instead`);
  }
};

var Payroll = artifacts.require("./Payroll.sol");

contract('Payroll', function(accounts) {
  let payroll;
  const owner = accounts[0]
  const employeeId = accounts[1]
  const salray = 1;

  beforeEach(async function () {
    payroll = await Payroll.new();
  });

  it('should revert when  addEmployee by a non-owner', async function () {
    const other = accounts[9];
    await assertRevert(payroll.addEmployee(employeeId,salray, { from: other }));
  });

  it('should add a employee by the owner successfully', async function () {
    const info1 = await payroll.employees(employeeId)
    await payroll.addEmployee(employeeId,salray, { from: owner })
    const info = await payroll.employees(employeeId)
    await assert(employeeId == info[0],'add employee fail');
  });

  it('should revert when adding a existing employee', async function () {
    const employee1 = accounts[9];
    payroll.addEmployee(employee1,salray, { from: owner })
    await assertRevert(payroll.addEmployee(employee1,salray, { from: owner }));
  });
  
  it('should revert when remove a non-existent employee', async function () {
    const employee1 = accounts[6];
    await assertRevert(payroll.removeEmployee(employee1, { from: owner }));
  });
  
  it('should revert when remove a  employee by a non-owner', async function () {
    const other = accounts[9];
    await assertRevert(payroll.removeEmployee(employeeId, { from: other }));
  });

  it('should remove a existing employee successfully by the owner ', async function () {
    const other = accounts[4];
    await payroll.addEmployee(other,salray, { from: owner })
    await payroll.removeEmployee(other, { from: owner });
    const info = await payroll.employees(other)
    let id =web3.toBigNumber(info[0]).toNumber()
    assert(id == 0,'remove a employee fail')
  });
});
