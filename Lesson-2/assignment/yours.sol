pragma solidity ^0.4.14;

contract Payroll {
    struct Employee {
        address id;
        uint salary;
        uint lastPayday;
    }
    
    uint constant payDuration = 10 seconds;
    uint totalSalary;

    address owner;
    Employee[] employees;

    function Payroll() {
        owner = msg.sender;
        totalSalary = 0;
    }
    
    function _partialPaid(Employee employee) private {
        uint payment = (now-employee.lastPayday)*employee.salary/payDuration;
        employee.id.transfer(payment);
    }
    
    function _findEmployee(address employeeId) private returns (Employee, uint) {
        for (uint i=0;i<employees.length;i++) {
            if (employeeId == employees[i].id) {
                return (employees[i], i);
            }
        }
    }

    function addEmployee(address employeeId, uint salary) {
        require(msg.sender == owner);
        var (employee, index) = _findEmployee(employeeId);
        assert(employee.id == 0x0);
        employees.push(Employee(employeeId, salary*1 ether, now));
        totalSalary += salary* 1 ether;
    }
    
    function removeEmployee(address employeeId) {
        require(msg.sender == owner);
        var (employee, index) = _findEmployee(employeeId);
        assert(employee.id != 0x0);
        _partialPaid(employee);
        totalSalary -= employee.salary;
        delete employees[index];
        employees[index] = employees[employees.length-1];
        employees.length -= 1;
    }
    
    function updateEmployee(address employeeId, uint salary) {
        require(msg.sender == owner);
        var (employee, index) = _findEmployee(employeeId);
        assert(employee.id != 0x0);
        _partialPaid(employee);
        totalSalary -= employee.salary;
        employees[index] = Employee(employeeId, salary*1 ether, now);
        totalSalary += salary * 1 ether;
    }
    
    function addFund() payable returns (uint) {
        return this.balance;
    }
    
    function calculateRunway() returns (uint) {
        return this.balance / totalSalary;
    }
    
    function hasEnoughFund() returns (bool) {
        return calculateRunway()>0;
    }
    
    function getPaid() {
        var(employee, index) = _findEmployee(msg.sender);
        assert(employee.id != 0x0);
        uint nextPayDay = employee.lastPayday + payDuration;
        assert(nextPayDay < now);
        employee.lastPayday = nextPayDay;
        employee.id.transfer(employee.salary);
    }
}
