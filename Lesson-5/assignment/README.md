## 硅谷live以太坊智能合约 第五课作业
这里是同学提交作业的目录


## 作业

1. 为了在金额变化，员工变更后，界面刷新，在合约中引入 event:


```
event AddFund(address indexed from, uint value);
event GetPaid(address indexed employee, uint value);
event AddEmployee(address indexed from, address indexed employee, uint salary);
event UpdateEmployee(address indexed from, address indexed employee, uint salary);
event RemoveEmployee(address indexed from, address indexed removed);
```

在 js 中：


```
componentDidMount() {
  const { payroll, account, web3 } = this.props;
  const updateInfo = (error, result) => {
    if (!error) {
      this.getEmployerInfo();
    }
  }

  this.addFund = payroll.AddFund(updateInfo);
  this.getPaid = payroll.GetPaid(updateInfo);
  this.addEmployee = payroll.AddEmployee(updateInfo);
  this.updateEmployee = payroll.UpdateEmployee(updateInfo);
  this.removeEmployee = payroll.RemoveEmployee(updateInfo);

  this.getEmployerInfo();
}

componentWillUnmount() {
  this.addFund.stopWatching();
  this.getPaid.stopWatching();
  this.addEmployee.stopWatching();
  this.updateEmployee.stopWatching();
  this.removeEmployee.stopWatching();
}
```


2. 为了计算总员工数量，以及遍历所有员工信息，引入 `employeeAddressList` 数组。

为了不在更新和删除员工时查找 `employeeAddressList`，这个操作为 O(n)，将员工地址在数组中的信息放到 `Employee` 结构中。


```
 struct Employee {
     uint index;
     uint salary;
     uint lastPayday;
 }
```

删除和添加时，维护索引：

```
function addEmployee(address employeeId, uint salary) public onlyOwner shouldNotExist(employeeId) {
    salary = salary.mul(1 ether);

    // 新加入， index 为数组长度
    uint index = employeeAddressList.length;
    employeeAddressList.push(employeeId);
    employees[employeeId] = Employee(index, salary, now);

    totalSalary = totalSalary.add(salary);
    AddEmployee(msg.sender, employeeId, salary);
}

function removeEmployee(address employeeId) public onlyOwner shouldExist(employeeId) {
    _partialPaid(employeeId);

    uint salary = employees[employeeId].salary;
    uint index = employees[employeeId].index;
    totalSalary = totalSalary.sub(salary);

    delete employees[employeeId];

    delete employeeAddressList[index];
    // 移动最后一个到当前位置
    address moveAddress = employeeAddressList[employeeAddressList.length - 1];
    employeeAddressList[index] = moveAddress;

    // 更新 index 信息
    employees[moveAddress].index = index;

    // adjust length
    employeeAddressList.length -= 1;
    RemoveEmployee(msg.sender, employeeId);
}
```
