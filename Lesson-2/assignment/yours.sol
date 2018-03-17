// 改进前代码

pragma solidity ^0.4.14;

contract Payroll {
    
    struct Employee {
        address id;
        uint salary;
        uint lastPayday;
    }
    
    uint constant payDuration = 10 seconds;
    
    modifier onlyOnwer {
        require(msg.sender == owner);
        _;
    }

    address owner;
    Employee[] employees;

    function Payroll() {
        owner = msg.sender;
    }
    
    function _partialPaid(Employee _employee) private {
        
        if (_employee.id != 0x0) {
            uint payment = _employee.salary * (now - _employee.lastPayday) / payDuration;
            _employee.id.transfer(payment);
        }
        
    }
    
    function _findEmployee(address _employeeId) private returns (Employee, uint) {
        
        for (uint i = 0; i < employees.length; i++) {
            if (employees[i].id == _employeeId) {
                return (employees[i], i);
            }
        }
        
    }

    function addEmployee(address _employeeId, uint _salary) onlyOnwer {
        
        var (employee, index) = _findEmployee(_employeeId);
        require(employee.id == 0x0);
        employees.push(Employee(_employeeId, _salary, now));

    }
    
    function removeEmployee(address _employeeId) onlyOnwer {
        
        var (employee, index) = _findEmployee(_employeeId);
        require(employee.id != 0x0);
        
        _partialPaid(employee);
        
        delete employees[index];
        employees[index] = employees[employees.length-1];
        employees.length -= 1;
        
    }
    
    function updateEmployee(address _employeeId, uint _salary) onlyOnwer {
        
        var (employee, index) = _findEmployee(_employeeId);
        require(employee.id != 0x0);
        
        _partialPaid(employee);
        
        employees[index].lastPayday = now;
        employees[index].id = _employeeId;
        employees[index].salary = _salary;
        
    }
    
    function addFund() payable returns (uint) {
        return this.balance;
    }
    
    function calculateRunway() returns (uint) {
        uint totalSalary = 0;
        for (uint i = 0; i < employees.length; i++) {
            totalSalary += employees[i].salary;
        }
        return this.balance / totalSalary;
    }
    
    function hasEnoughFund() returns (bool) {
        return calculateRunway() > 0;
    }
    
    function getPaid() {
        
        var (employee, index) = _findEmployee(msg.sender);
        require(employee.id != 0x0);
        uint nextPayDay = employee.lastPayday + payDuration;
        require(nextPayDay < now);
        
        employee.id.transfer(employee.salary);
        employees[index].lastPayday = nextPayDay;
        
    }
}
