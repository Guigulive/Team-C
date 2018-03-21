## 硅谷live以太坊智能合约 第二课作业
这里是同学提交作业的目录

### 第二课：课后作业
完成今天的智能合约添加100ETH到合约中
- 加入十个员工，每个员工的薪水都是1ETH
transaction cost: 22966 gas
execution cost: 1694 gas

transaction cost: 23747 gas
execution cost: 2475 gas

transaction cost: 24528 gas
execution cost: 3256 gas

transaction cost: 25309 gas
execution cost: 4037 gas

transaction cost: 26090 gas
execution cost: 4818 gas 

每次加入一个员工后调用calculateRunway这个函数，并且记录消耗的gas是多少？Gas变化么？如果有 为什么？
发现transaction cost和 execution cost都会变多，而且是线性增多，也就是每次增加的delta是一模一样的
transaction cost和execution cost都是每次增加781
原因是for循环求和的个数会变多一个
所以大约可以算出 this.balance / totalSalary 的cost约为913， 而每次加法的cost约为781.

- 如何优化calculateRunway这个函数来减少gas的消耗？
就是把for循环去掉，每次更新employee时顺带更新totalSalary
提交：智能合约代码，gas变化的记录，calculateRunway函数的优化

