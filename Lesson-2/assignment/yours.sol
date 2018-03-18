pragma solidity ^0.4.14;

contract Payroll {
    struct Employee {
        address id;
        uint salary;
        uint lastPayday;
    }
    
    uint constant payDuration = 10 seconds;

    address owner;
    Employee[] employees;
    uint totalSalary_;

    function Payroll() {
        owner = msg.sender;
    }
    
    function _safelySendPayment(address addr, uint amount) private {
        if (addr != 0x0 && amount > 0) {
            addr.transfer(amount);
        }
    }
    
    function _calculatePayment(Employee e) private returns (uint){
        return e.salary * (now - e.lastPayday) / payDuration;
    }
    
    function _findEmployee(address employeeId) private 
    returns (Employee, uint) {
        for (uint i = 0; i < employees.length; i++) {
              if (employees[i].id == employeeId) {
                  return (employees[i], i);
              }
        }
        return (Employee(0x0, 0, 0), 0);
    }

    function addEmployee(address employeeId, uint salary) {
        require (msg.sender == owner);
        var (employee, index) = _findEmployee(employeeId);
        require(employee.id == 0x0);
        
        employees.push(Employee(employeeId, salary * 1 ether, now));
        totalSalary_ += salary * 1 ether;
    }
    
    function removeEmployee(address employeeId) {
        require (msg.sender == owner);
        var (employee, index) = _findEmployee(employeeId);
        require(employee.id != 0x0);
        
        uint payment = _calculatePayment(employee);
        totalSalary_ -= employee.salary;
        delete employees[index];
        employees[index] = employees[employees.length - 1];
        employees.length -= 1;
        
        _safelySendPayment(employees[index].id, payment);
    }
    
    function updateEmployee(address employeeId, uint salary) {
        require (msg.sender == owner);
        var (employee, index) = _findEmployee(employeeId);
        require(employees[index].id != 0x0); 
        
        uint payment = _calculatePayment(employees[index]);
        employees[index].salary = salary;
        employees[index].lastPayday = now;
        
        _safelySendPayment(employees[index].id, payment);
    }
    
    function addFund() payable returns (uint) {
        return this.balance;
    }
    
    function calculateRunway() returns (uint) {
        uint totalSalary = 0;
       for (uint i = 0; i < employees.length; i++) {
            totalSalary += employees[i].salary;
        }
        require(totalSalary > 0);
        return this.balance / totalSalary;
    }
    
    function calculateRunwayOptimized() returns (uint) {
        require (totalSalary_ > 0);
        return this.balance / totalSalary_;
    }
    
    function hasEnoughFund() returns (bool) {
        return calculateRunway() > 0;
    }
    
    function getPaid() {
        var (employee, index) = _findEmployee(msg.sender);
        require (employees[index].id != 0x0); 
        
        uint nextPayDay = employee.lastPayday + payDuration;
        require(nextPayDay < now);
        
        employees[index].lastPayday = nextPayDay;
        _safelySendPayment(employee.id, employee.salary);
    }
}
