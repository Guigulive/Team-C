## 硅谷live以太坊智能合约 第二课作业
这里是同学提交作业的目录

### 第二课：课后作业
完成今天的智能合约添加100ETH到合约中
- 加入十个员工，每个员工的薪水都是1ETH
每次加入一个员工后调用calculateRunway这个函数，并且记录消耗的gas是多少？Gas变化么？如果有 为什么？
- 如何优化calculateRunway这个函数来减少gas的消耗？
提交：智能合约代码，gas变化的记录，calculateRunway函数的优化




#### Gas 变化

| address | before optimization | after optimization |
| --- | --- | --- |
| 0x14723a09acff6d2a60dcdf7aa4aff308fddc160c | 28678 + 7406   | 22587 + 1315 |  
| 0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db | 29459 + 8187   | 22587 + 1315 | 
| 0x583031d1113ad414f02576bd6afabfb302140225 | 30240 + 8968   | 22587 + 1315 | 
| 0xdd870fa1b7c4700f2bd7f44238821c26f7392148 | 31021 + 9749   | 22587 + 1315 | 
| 0x51455e74886eac216531b528a5d85e6b9f0205fa | 31802 + 10530  | 22587 + 1315 | 
| 0x465d123ee8e0d6aa90c1e4ac61ecb726e0c285f2 | 32583 + 11311  | 22587 + 1315 | 
| 0xc4416529c2c308803a1961f57e7fc6987a1d73f1 | 33364 + 12092  | 22587 + 1315 | 
| 0xff19da88da4557652f4a4053847bd76797a8ead4 | 34145 + 12873  | 22587 + 1315 | 
| 0xed11b75b518da0f8daa62e97beeb120ca8739b3b | 34926 + 13654  | 22587 + 1315 | 
| 0xd88c3345e2a18e6bb8190f381c52010bfbcf0b29 | 35707 + 14435  | 22587 + 1315 | 

#### 原因

`calculateRunway()` 时间复杂度为 `O(n)`，和 `employees` 数组规模线性相关。


#### 优化

方案 1: 空间换时间。加入 `totalSalary` 做缓存，第二次调用可节约 gas
方案 2: 提前计算。员工数变化，balance 变化后，计算 `totalSalary` ，`calculateRunway()` 中直接使用 `totalSalary` 做计算。
