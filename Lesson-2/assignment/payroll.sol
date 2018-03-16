pragma solidity ^0.4.14;

contract Payroll {
    
    struct Employee {
        address id;
        uint salary;
        uint lastPayday;
    }
    
    uint constant payDuration = 10 seconds;
    int totalSalary = -1;

    address owner;
    Employee[] employees;

    function Payroll() payable public {
        owner = msg.sender;
    }
    
    function _partialPaid(uint employeeIndex) private {
        uint payment = employees[employeeIndex].salary * (now - employees[employeeIndex].lastPayday) / payDuration;
        employees[employeeIndex].id.transfer(payment);
    }
    
    function _findEmployee(address employeeId) private view returns (int) {
        for (uint i = 0; i < employees.length; i++) {
            if (employees[i].id == employeeId) {
                return int(i);
            }
        }
        return -1;
    }
    
    function _caculateTotalSalary() private view returns (uint) {
        uint total = 0;
        for (uint i = 0; i < employees.length; i++) {
            total += employees[i].salary;
        }
        return total;
    }

    function addEmployee(address employeeId, uint salary) public {
        require(msg.sender == owner);
        int index = _findEmployee(employeeId);
        assert(index == -1);
        employees.push(Employee(employeeId, salary * 1 ether, now));
        
        totalSalary = -1;
    }
    
    function removeEmployee(address employeeId) public {
        require(msg.sender == owner);
        int index = _findEmployee(employeeId);
        assert(index > -1);
        
        uint employeeIndex = uint(index);
        _partialPaid(employeeIndex);
        delete employees[employeeIndex];
        employees[employeeIndex] = employees[employees.length - 1];
        employees.length -= 1;
        
        totalSalary = -1;
    }
    
    function updateEmployee(address employeeId, uint salary) public {
        require(msg.sender == owner);
        int index = _findEmployee(employeeId);
        assert(index > -1);
        
        uint employeeIndex = uint(index);
        _partialPaid(employeeIndex);
        employees[employeeIndex].salary = salary * 1 ether;
        employees[employeeIndex].lastPayday = now;
        
        totalSalary = -1;
    }
    
    function addFund() payable public returns (uint) {
        totalSalary = -1;
        return address(this).balance;
    }
    
    function calculateRunway() public returns (uint) {
        require(employees.length > 0);
        if (totalSalary == -1) {
            totalSalary = int(_caculateTotalSalary());
        }
        return address(this).balance / uint(totalSalary);
    }
    
    function hasEnoughFund() public returns (bool) {
        return calculateRunway() > 0;
    }
    
    function getPaid() public {
        int index = _findEmployee(msg.sender);
        assert(index > -1);
        
        uint employeeIndex = uint(index);
        uint nextPayday = employees[employeeIndex].lastPayday + payDuration;
        assert(nextPayday < now);
        
        employees[employeeIndex].lastPayday = nextPayday;
        employees[employeeIndex].id.transfer(employees[employeeIndex].salary);
        totalSalary = -1;
    }
}

