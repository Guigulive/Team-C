pragma solidity ^0.4.14;

/*
    ________________________________________________________
       次数    transaction cost   execution cost      output
    ________________________________________________________
        1          22966               1694           100    
    --------------------------------------------------------
        2          23747               2475           50
    --------------------------------------------------------
        3          24528               3256           33
    --------------------------------------------------------
        4          25309               4037           25
    --------------------------------------------------------
        5          26090               4818           20
    --------------------------------------------------------
        6          26871               5599           16
    --------------------------------------------------------
        7          27652               6380           14
    --------------------------------------------------------
        8          28433               7161           12
    --------------------------------------------------------
        9          29214               7942           11
    --------------------------------------------------------
        10         29995               8723           10
    --------------------------------------------------------


    可以看出，gas消耗越来越多。因为每加入一个员工，执行遍历employees就越多，花费越多。多一次遍历花费781gas。
    把 totalSalary 改为全局变量，增删改员工时相应更新，calculateRunway 直接取值就好。
    改过之后固定销消耗：transaction cost 22124 , execution cost: 852
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
        var(employee, index)  = _findEmployee(employeeId);
        assert(employee.id == 0x0);

        totalSalary += salary * 1 ether;
        employees.push(Employee(employeeId, salary * 1 ether, now));
    }
    
    function removeEmployee(address employeeId) {
        require(msg.sender == owner);

        var(employee, index)  = _findEmployee(employeeId);
        assert(employee.id != 0x0);

        totalSalary -= employee.salary * 1 ether;
        _partialPaid(employee);

        delete employees[index];
        employees[index] = employees[employees.length - 1];
        employees.length -= 1;
    }
    
    function updateEmployee(address employeeId, uint salary) {
        require(msg.sender == owner);

        var(employee, index)  = _findEmployee(employeeId);
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
        // uint totalSalary = 0;
        // for (uint i = 0; i < employees.length; i++) {
        //     totalSalary += employees[i].salary;
        // }
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
