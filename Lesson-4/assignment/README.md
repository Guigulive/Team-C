## 硅谷live以太坊智能合约 第四课作业
这里是同学提交作业的目录

### 第四课：课后作业
- 将第三课完成的payroll.sol程序导入truffle工程
- 在test文件夹中，写出对如下两个函数的单元测试：
- function addEmployee(address employeeId, uint salary) onlyOwner
- function removeEmployee(address employeeId) onlyOwner employeeExist(employeeId)
- 思考一下我们如何能覆盖所有的测试路径，包括函数异常的捕捉
- (加分题,选作）
- 写出对以下函数的基于solidity或javascript的单元测试 function getPaid() employeeExist(msg.sender)
- Hint：思考如何对timestamp进行修改，是否需要对所测试的合约进行修改来达到测试的目的？


### 作业

1. `addEmployee()` 的测试用例为： `payroll-test-add-employee.js`
2. `removeEmployee()` 的测试用例为： `payroll-test-remove-employee.js`
3. `getPaid()` 的测试用例为： `payroll-test-get-paid.js`
4. 调用 `evm_increaseTime`，可修改 evm 时间。

测试结果如下:

```
root@cube-box@huqiu:/opt/src/payroll# truffle test
Using network 'development'.

Compiling ./contracts/Ownable.sol...
Compiling ./contracts/Payroll.sol...
Compiling ./contracts/SafeMath.sol...


  Contract: Payroll
    ✓ Test call addEmployee() by owner (68ms)
    ✓ Test addEmployee() duplicated
    ✓ Test addEmployee() by guest

  Contract: Payroll
    ✓ Test getPaid() (234ms)
    ✓ Test getPaid() before duration
    ✓ Test getPaid() by a non-employee

  Contract: Payroll
    ✓ Test call addEmployee() and removeEmployee by owner (66ms)
    ✓ Test remove a non-existent employee
    ✓ Test removeEmployee() by guest (67ms)


  9 passing (697ms)
  ```
