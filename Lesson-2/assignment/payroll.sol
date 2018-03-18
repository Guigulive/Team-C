pragma solidity ^0.4.14;

/**
 * 0x14723a09acff6d2a60dcdf7aa4aff308fddc160c 28678 + 7406 -> 22361 + 1089
 * 0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db 29459 + 8187 -> 22361 + 1089
 * 0x583031d1113ad414f02576bd6afabfb302140225 30240 + 8968 -> 22361 + 1089
 * 0xdd870fa1b7c4700f2bd7f44238821c26f7392148 31021 + 9749 -> 22361 + 1089
 * 0x51455e74886eac216531b528a5d85e6b9f0205fa 31802 + 10530 -> 22361 + 1089
 * 
 * 0x465d123ee8e0d6aa90c1e4ac61ecb726e0c285f2 32583 + 11311 -> 22361 + 1089
 * 0xc4416529c2c308803a1961f57e7fc6987a1d73f1 33364 + 12092 -> 22361 + 1089
 * 0xff19da88da4557652f4a4053847bd76797a8ead4 34145 + 12873 -> 22361 + 1089
 * 0xed11b75b518da0f8daa62e97beeb120ca8739b3b 34926 + 13654 -> 22361 + 1089
 * 0xd88c3345e2a18e6bb8190f381c52010bfbcf0b29 35707 + 14435 -> 22361 + 1089
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
        salary = salary * 1 ether;
        employees.push(Employee(employeeId, salary, now));
        
        totalSalary += salary;
    }
    
    function removeEmployee(address employeeId) public {
        require(msg.sender == owner);
        int index = _findEmployee(employeeId);
        assert(index > -1);
        
        uint employeeIndex = uint(index);
        _partialPaid(employeeIndex);
        uint salary = employees[employeeIndex].salary;
        delete employees[employeeIndex];
        employees[employeeIndex] = employees[employees.length - 1];
        employees.length -= 1;
        
        totalSalary -= salary;
    }
    
    function updateEmployee(address employeeId, uint salary) public {
        require(msg.sender == owner);
        int index = _findEmployee(employeeId);
        assert(index > -1);
        
        uint employeeIndex = uint(index);
        _partialPaid(employeeIndex);
        
        uint oldSalary = employees[employeeIndex].salary;
        salary = salary * 1 ether;
        employees[employeeIndex].salary = salary;
        employees[employeeIndex].lastPayday = now;
        
        totalSalary += salary - oldSalary;
    }
    
    function addFund() payable public returns (uint) {
        return address(this).balance;
    }
    
    function calculateRunway() public view returns (uint) {
        require(employees.length > 0);
        return address(this).balance / totalSalary;
    }
    
    function hasEnoughFund() public view returns (bool) {
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
    }
}

