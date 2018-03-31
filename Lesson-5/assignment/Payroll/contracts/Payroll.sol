pragma solidity ^0.4.14;

import './SafeMath.sol';
import './Ownable.sol';

contract Payroll is Ownable {
    using SafeMath for uint;
    struct Employee {
        address id;
        uint salary;
        uint lastPayday;
    }

    uint constant payDuration = 10 seconds;

    uint totalSalary;
    uint totalEmployee;
    address[] employeeList;
    mapping(address => Employee) public employees;

    modifier hasNoEmployee (address employeeId){
        require(employees[employeeId].id == 0x0);
        _;
    }
    modifier hasEmployee (address employeeId){
        require(employees[employeeId].id != 0x0);
        _;
    }

    function partialPay(address id){
        var employee = employees[id];
        uint payment = employee.salary.mul(now.sub(employee.lastPayday)).div(payDuration);
        id.transfer(payment);
    }

    function addEmployee(address employeeId, uint salary) onlyOwner hasNoEmployee(employeeId){
        employees[employeeId] = Employee(employeeId, salary.mul(1 ether), now);
        totalSalary = totalSalary.add(employees[employeeId].salary);
        totalEmployee = totalEmployee.add(1);
        employeeList.push(employeeId);
    }

    function removeEmployee(address employeeId) onlyOwner hasEmployee(employeeId) {
        var employee = employees[employeeId];
        partialPay(employeeId);
        totalSalary = totalSalary.sub(employee.salary);
        delete employees[employeeId];
        totalEmployee = totalEmployee.sub(1);
    }

    function updateEmployee(address employeeId, uint salary) onlyOwner hasEmployee(employeeId) {
        var employee = employees[employeeId];
        partialPay(employeeId);
        totalSalary = totalSalary.sub(employee.salary);
        employee.salary = salary.mul(1 ether);
        employee.lastPayday = now;
        totalSalary = totalSalary.add(employee.salary);
    }

    function addFund() payable returns (uint) {
        return this.balance;
    }

    function calculateRunway() returns (uint) {
        return this.balance.div(totalSalary);
    }

    function hasEnoughFund() returns (bool) {
        return calculateRunway() > 0;
    }

    function getPaid() hasEmployee(msg.sender) {
        var employee = employees[msg.sender];
        uint nextPayday = employee.lastPayday.add(payDuration);
        assert(nextPayday < now);
        employee.lastPayday = nextPayday;
        employee.id.transfer(employee.salary);
    }

    function checkEmployee(uint index) returns (address employeeId, uint salary, uint lastPayday) {
        employeeId = employeeList[index];
        var employee = employees[employeeId];
        salary = employee.salary;
        lastPayday = employee.lastPayday;
    }
	
    function checkInfo() returns (uint balance, uint runway, uint employeeCount) {
        balance = this.balance;
        employeeCount = totalEmployee;
        if (totalSalary > 0) {
            runway = calculateRunway();
        }
    }
}