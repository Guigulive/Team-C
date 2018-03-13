pragma solidity ^0.4.14;

contract Payroll {
    uint constant payDuration = 30 days;

    address owner;
    uint salary = 1 ether;
    address employee;
    uint lastPayday;

    function Payroll() payable public {
        owner = msg.sender;
        lastPayday = now;
    }
    
    function doUpdateEmployee(address newAddress, uint newSalary) internal { 
        if (employee != 0x0) {
            uint payment = salary * (now - lastPayday) / payDuration;
            employee.transfer(payment);
        }
        
        employee = newAddress;
        salary = newSalary;
        lastPayday = now;
    }
    
    function updateEmployeeAddress(address newAddress) public {
        require(msg.sender == owner);
        require(newAddress != employee);
        
        doUpdateEmployee(newAddress, salary);
    }

    function updateEmployeeSalary(uint newSalary) public {
        require(msg.sender == owner);
        require(newSalary > 0);
        newSalary = newSalary * 1 ether;
        require(newSalary != salary);

        doUpdateEmployee(employee, newSalary);
    }
    
    function getEmployee() view public returns (address) {
        return employee;
    }
    
    function addFund() payable public returns (uint) {
        return address(this).balance;
    }
    
    function calculateRunway() view public returns (uint) {
        return address(this).balance / salary;
    }
    
    function getSalary() view public returns (uint) {
        return salary;
    }
    
    function hasEnoughFund() view public returns (bool) {
        return calculateRunway() > 0;
    }
    
    function isMe() view public returns (bool) {
        return msg.sender == employee;
    }
    
    function getPaid() public {
        require(msg.sender == employee);
        
        uint nextPayday = lastPayday + payDuration;
        assert(nextPayday < now);

        lastPayday = nextPayday;
        employee.transfer(salary);
    }
}
