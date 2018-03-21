/*作业请提交在这个目录下*/
pragma solidity ^0.4.14;

import './Ownable.sol';
import './SafeMath.sol';

contract Payroll is Ownable{
    using SafeMath for uint;
    struct Employee {
        address id;
        uint salary;
        uint lastPayday;
    }
    
    uint constant payDuration = 10 seconds;
    uint totalSalary;

    address owner;
    mapping(address => Employee) public employees;

    function Payroll() {
        owner = msg.sender;
    }
    
    modifier employeeExist(address employeeId) {
        Employee employee = employees[employeeId];
        assert(employee.id != 0x0);
        _;
    }
    
    function _partialPaid(Employee employee) private {
        uint payment = (now-employee.lastPayday)*employee.salary/payDuration;
        employee.id.transfer(payment);
    }
    
    function changePaymentAddress(address oldEmployeeId, address newEmployeeId) onlyOwner employeeExist(oldEmployeeId) {
        Employee employee = employees[oldEmployeeId];
        _partialPaid(employee);
        delete employees[oldEmployeeId];
        employees[newEmployeeId] = Employee(newEmployeeId, employee.salary, now);
    }

    function addEmployee(address employeeId, uint salary) onlyOwner {
        Employee employee = employees[employeeId];
        assert(employee.id == 0x0);
        employees[employeeId] = Employee(employeeId, salary*1 ether, now);
        totalSalary += salary* 1 ether;
    }
    
    function removeEmployee(address employeeId) onlyOwner employeeExist(employeeId) {
        Employee employee = employees[employeeId];
        _partialPaid(employee);
        totalSalary -= employee.salary;
        delete employees[employeeId];
    }
    
    function updateEmployee(address employeeId, uint salary) onlyOwner employeeExist(employeeId) {
        Employee employee = employees[employeeId];
        _partialPaid(employee);
        totalSalary -= employee.salary;
        employees[employeeId] = Employee(employeeId, salary*1 ether, now);
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
        Employee employee = employees[msg.sender];
        assert(employee.id != 0x0);
        uint nextPayDay = employee.lastPayday + payDuration;
        assert(nextPayDay < now);
        employee.lastPayday = nextPayDay;
        employee.id.transfer(employee.salary);
    }
}
