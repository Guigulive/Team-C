/*作业请提交在这个目录下*/
pragma solidity ^0.4.14;

/*
优化前gas变化的记录如下：
员工数 | transaction cost | execution cost
1  | 22966 | 1694
2  | 23747 | 2475
3  | 24528 | 3256
4  | 25309 | 4037
5  | 26090 | 4818
6  | 26871 | 5599
7  | 27652 | 6380
8  | 28433 | 7171
9  | 29214 | 7942
10 | 29995 | 8723

分析：
员工越多，遍历越多，花费越多

优化：
设置totalSalary 为storage变量，在增、删、改操作中直接更新，避免重复循环

结果：
每次消耗固定如下
transaction cost 22124 , execution cost: 852
*/

contract Payroll {
    struct Employee {
        address id;
        uint salary;
        uint lastPayday;
    }
    
    uint constant payDuration = 10 seconds;
    uint totalSalary = 0;
    address owner;
    Employee[] employees;

    function Payroll() {
        owner = msg.sender;
    }
    
    function _partialPaid(Employee employee) private {
        uint payment = employee.salary * (now - employee.lastPayday) / payDuration;
        employee.id.transfer(payment);
    }
    
    function _findEmployee(address employeeId) private returns (Employee, uint) {
       for (uint i = 0; i < employees.length; i++) {
            if(employees[i].id == employeeId){
                return (employees[i], i);
            }
        }
    }

    function addEmployee(address employeeId, uint salary) {
        require(msg.sender == owner);
        
        var(employee, index) = _findEmployee(employeeId);
        assert(employee.id == 0x0);

        totalSalary += salary * 1 ether;
        employees.push(Employee(employeeId, salary * 1 ether, now));
    }
    
    function removeEmployee(address employeeId) {
        require(msg.sender == owner);

        var(employee, index) = _findEmployee(employeeId);
        assert(employee.id != 0x0);

        totalSalary -= employee.salary * 1 ether;
        _partialPaid(employee);

        delete employees[index];
        employees[index] = employees[employees.length - 1];
        employees.length -= 1;
    }
    
    function updateEmployee(address employeeId, uint salary) {
        require(msg.sender == owner);

        var(employee, index) = _findEmployee(employeeId);
        assert(employee.id != 0x0);

        totalSalary -= employee.salary * 1 ether;
        _partialPaid(employee);

        employees[index].salary = salary * 1 ether;
        totalSalary += salary * 1 ether;

        employees[index].lastPayday = now;
    }
    
    function addFund() payable returns (uint) {
        return this.balance;
    }
    
    function calculateRunway() returns (uint) {
        return this.balance / totalSalary;
    }
    
    function hasEnoughFund() returns (bool) {
        return calculateRunway() > 0;
    }
    
    function getPaid() {
        var(employee, index) = _findEmployee(msg.sender);
        assert(employee.id != 0x0);

        uint nextPayday = employee.lastPayday + payDuration;
        assert(nextPayday < now);

        employees[index].lastPayday = nextPayday;
        employee.id.transfer(employee.salary);
    }
}