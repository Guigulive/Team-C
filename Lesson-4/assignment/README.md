### 第四课：课后作业（都使用javascript）
####测试文件addRemoveEmployee.js
对以下两个函数的单元测试
- function addEmployee(address employeeId, uint salary) onlyOwner
- function removeEmployee(address employeeId) onlyOwner employeeExist(employeeId)
目测覆盖了所有的测试路径（除了文件里提到的，由于蛋疼的gas费用问题付给员工的工资并没有精确确认）
1. 雇主添加新雇员
2. 雇主重复添加雇员
3. 非雇主添加雇员
4. 非雇主删除雇员
5. 雇主删除不存在的雇员
6. 雇主删除存在的雇员
  
####测试文件getPaid.js
- 对function getPaid() employeeExist(msg.sender)的单元测试
timestamp的话可以叫TestRPC给我们来个时空旅行~
（这招只有js有效。据说solidity测试的话可以使用覆盖now和block.timestamp的方法）
```
contract X {
  struct FakeBlock {
    uint timestamp;
  }

  FakeBlock block;

  uint now;

  function setBlockTime(uint val) {
    now = val;
    block.timestamp = val;
  }
}
```
  
####目前的一些问题
1. TestRPC的账户里默认给100个ether，跑2次测试就得重新开一次TestRPC（潜在的错误源）
2. 一些初始化的参数（有部分重复）直接写到测试文件里了，最好有配置文件
3. getPaid测试文件中，payDuration是硬编码的。如果合约有改动，这里也需要手动改
4. 其他在测试文件描述中提到的
5. （都是ES5语法，老掉牙了）
6. solidity的测试什么时候学习-_-
