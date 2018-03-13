pragma solidity ^0.4.14;

/// @dev 1st home work
/// @dev added two function setEmployee and setSalary
/// @dev these functions allower employer change the employee and salary to pay
/// @dev however, the unpaid salary is forced to pay to the former employee by the former rate
contract payroll {
    
    uint constant payDuration = 10 seconds;
    
    uint lastPayDay = now;
    address owner;
    address employee;
    uint salary;
    
    modifier onlyOnwer {
        require(msg.sender == owner);
        _;
    }
    
    function payroll(address _employee, uint _salary) {
        owner = msg.sender;
        employee = _employee;
        salary = _salary * 1 ether;
    }
    
    function getPaid() {
        require(msg.sender == employee);
        
        uint nextPayday = lastPayDay + payDuration;
        require(nextPayday < now);

        lastPayDay = nextPayday;
        employee.transfer(salary);
    }
    
    /// @dev home work function 1
    function setEmployee(address newEmployee) onlyOnwer {
        
        address _employee = employee;
        employee = newEmployee;
        
        uint _lastPayDay = lastPayDay;
        lastPayDay = now;
        
        if (_employee!= 0x0) {
            uint payment = salary * (now - _lastPayDay) / payDuration;
            _employee.transfer(payment);
        }
        
    }
    
    /// @dev home work function 2
    function setSalary(uint newSalary) onlyOnwer {
        
        uint _lastPayDay = lastPayDay;
        lastPayDay = now;
        
        uint _salary =salary;
        salary = newSalary * 1 ether;
        
        if (employee != 0x0) {
            uint payment = _salary * (now - _lastPayDay) / payDuration;
            employee.transfer(payment);
        }
        
    }
    
    function addFund() payable returns (uint) {
        return this.balance;
    }
    
    function calculateRunway() constant returns (uint) {
        return this.balance / salary;
    }
    
    function hasEnoughFund() constant returns (bool) {
        return calculateRunway() > 0;
    }
    
}

