### 第二课作业
yours.sol:改进前代码  
yours2.sol：改进后代码

### 改进前gas消耗记录
员工数 | transaction cost | execution cost
-- | ----- | -----
1 | 22966 | 1694
2 | 23747 | 2475
3 | 24528 | 3256
4 | 25309 | 4037
5 | 26090 | 4818
6 | 26871 | 5599
7 | 27652 | 6380
8 | 28433 | 7171
9 | 29214 | 7942
10 | 29995 | 8723

可以看到随着员工数量的增加，for循环的执行次数会增加，因此消耗的gas数量也会增加  
（不过测试的时候实际上每个员工的工资是1wei。。。）

### 改进后
把calculateRunway中的totalSalary变为全局storage变量，并在addEmployee，removeEmpolyee和updateEmployee中相应地更新totalSalary，从而避免重复循环浪费gas  
改进后，calculateRunway固定消耗22124gas的transaction cost和852gas的execution cost

### 思考
如果把Employee改成哈希表
```
strut EmployeeInfo {
    uint salary;
    uint lastPayday;
}
mapping(address => EmployeeInfo) Employee
```
那么_findEmployee中通过循环寻找员工的gas就可以避免
