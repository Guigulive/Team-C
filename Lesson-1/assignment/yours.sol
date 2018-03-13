/*作业请提交在这个目录下*/
pragma solidity ^0.4.14;

contract Payroll {
    uint constant payDuration = 10 seconds;

    address owner;
    uint salary = 1 ether;
    address employee = 0xca35b7d915458ef540ade6068dfe2f44e8fa733c;
    uint lastPayday = now;

    function Payroll() {
        owner = msg.sender;
    }

    function updateEmployee(address e) {
      require(msg.sender == owner);

      uint previousPayday = lastPayday;
      address previousEmployee = employee;
      
      employee = e;
      lastPayday = now;
      
      if (previousEmployee != 0x0) {
          uint payment = salary * (now - previousPayday) / payDuration;
          previousEmployee.transfer(payment);
      }
      
    }

    function updateSalary(uint s) {
      require(msg.sender == owner);

      uint previousPayday = lastPayday;
      uint previousSalary = salary;

      salary = s * 1 ether;
      lastPayday = now;
      
      if (employee != 0x0) {
          uint payment = previousSalary * (now - previousPayday) / payDuration;
          employee.transfer(payment);
      }
      
    }
    
    function addFund() payable returns (uint) {
        return this.balance;
    }

    function calculateRunway() returns (uint) {
        return this.balance / salary;
    }

    function hasEnoughFund() returns (bool) {
        return calculateRunway() > 0;
    }

    function getPaid() {
        require(msg.sender == employee);

        uint nextPayday = lastPayday + payDuration;
        assert(nextPayday < now);

        lastPayday = nextPayday;
        employee.transfer(salary);
    }
    
    function getOwner() returns(address){
        return owner;
    }
    
    function getEmployee() returns(address) {
        return employee;   
    }
    
    function getSalary() returns(uint) {
        return salary;
    }
}
