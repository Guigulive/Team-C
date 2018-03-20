## 第三课：课后作业
- 第一题：完成今天所开发的合约产品化内容，使用Remix调用每一个函数，提交函数调用截图
- 第二题：增加 changePaymentAddress 函数，更改员工的薪水支付地址，思考一下能否使用modifier整合某个功能
### 第一第二题
在课程基础上做了小改进（因为哈希表的key已经是员工的address了，所以value里不需要再存address了）  
感觉除了判断雇主以及判断员工是否存在以外，已经没有可以用modifier实现的内容了
1. addfund 打入50eth
![image](https://github.com/Satoshi-Kusumoto/Team-C/raw/master/Lesson-3/assignment/figures/1.png)
2. addEmployee增加一个雇员，工资1eth
![image](https://github.com/Satoshi-Kusumoto/Team-C/raw/master/Lesson-3/assignment/figures/2.png)
3. 查看雇员信息
![image](https://github.com/Satoshi-Kusumoto/Team-C/raw/master/Lesson-3/assignment/figures/3.png)
4. 再增加一个雇员，工资1eth
![image](https://github.com/Satoshi-Kusumoto/Team-C/raw/master/Lesson-3/assignment/figures/4.png)
5. 重复添加已有的雇员会失败
![image](https://github.com/Satoshi-Kusumoto/Team-C/raw/master/Lesson-3/assignment/figures/5.png)
6. calculateRunway
![image](https://github.com/Satoshi-Kusumoto/Team-C/raw/master/Lesson-3/assignment/figures/6.png)
7. hasEnoughFund
![image](https://github.com/Satoshi-Kusumoto/Team-C/raw/master/Lesson-3/assignment/figures/7.png)
8. 员工1调用getPaid得到了1eth
![image](https://github.com/Satoshi-Kusumoto/Team-C/raw/master/Lesson-3/assignment/figures/8.png)
9. 调用updateEmployee把员工1的工资变为2eth，并确认改变
![image](https://github.com/Satoshi-Kusumoto/Team-C/raw/master/Lesson-3/assignment/figures/9.png)
10 .调用chagePaymentAddress可以看到员工信息已经转移到新的地址
![image](https://github.com/Satoshi-Kusumoto/Team-C/raw/master/Lesson-3/assignment/figures/10.png)
11. 调用removeEmployee，可以看到员工已被移除
![image](https://github.com/Satoshi-Kusumoto/Team-C/raw/master/Lesson-3/assignment/figures/11.png)


### 第三题（加分题）：自学C3 Linearization, 求以下 contract Z 的继承线
- contract O
- contract A is O
- contract B is O
- contract C is O
- contract K1 is A, B
- contract K2 is A, C
- contract Z is K1, K2

#### 按照python的C3来计算
```
L(O) = O  
L(A) = A O
L(B) = B O
L(C) = C O
L(K1) = K1 + merge(L(A), L(B), [A B])
      = K1 + merge([A O], [B O], [A B]) //select A
      = K1 A + merge([O], [B O], [B]) //select O failed, select B
      = K1 A B + merge([O], [O])
      = K1 A B O
L(K2) = K2 + merge(L(A), L(C), [A C])
      = K2 + merge([A O], [C O], [A C]) //select A
      = K2 A + merge([O], [C O], [C]) //select O failed, select C
      = K2 A C + merge([O], [O])
      = K2 A C O
L(Z) = Z + merge(L(K1), L(K2), [K1 K2])
     = Z + merge([K1 A B O], [K2 A C O], [K1 K2]) //select K1
     = Z K1 + merge([A B O], [K2 A C O], [K2]) // select A failed, select K2
     = Z K1 K2 + merge([A B O], [A C O]) // select A
     = Z K1 K2 A merge([B O], (C O)])
     = Z K1 K2 A B C O
```
#### 但是
python里的class New(Base1, Base2)看起来和solidity的contract New is Base2, Base1是等价的  
也就是说，需要把所有的顺序反过来
```
L(K1) = K1 B A O
L(K2) = K2 C A O
L(Z) = Z + merge(L(K2), L(K1), [K2 K1])
     = Z + merge([K2 C A O], [K1 B A O], [K2 K1])
     = Z K2 + merge([C A O], [K1 B A O], [K1])
     = Z K2 C + merge([A O], [K1 B A O], [K1])
     = Z K2 C K1 + merge([A O], [B A O])
     = Z K2 C K1 B A O
```
