pragma solidity ^0.4.15;

import './SafeMath.sol';
import './Ownable.sol';

contract Payroll is Ownable {
    
    using SafeMath for uint;
    
    // address is not needed because it is already the key
    struct EmployeeInfo {
        uint salary;
        uint lastPayday;
    }
    
    mapping (address=>EmployeeInfo) public employees;
    
    uint constant payDuration = 30 days;
    uint totalSalary = 0;
    
    modifier employeeExists(address _address) {
        require(employees[_address].lastPayday != 0);
        _;
    }
    
    function _partialPaid(address _address) private {
        var _employee = employees[_address];
        uint payment = _employee.salary.mul(now.sub(_employee.lastPayday)).div(payDuration);
        _address.transfer(payment);
        
    }

    function addEmployee(address _employeeId, uint _salary) external onlyOwner {
        
        var _employee = employees[_employeeId];
        require(_employee.lastPayday == 0); // employee not exists
        totalSalary += _salary * 1 ether;
        employees[_employeeId] = EmployeeInfo(_salary * 1 ether, now);

    }
    
    function removeEmployee(address _employeeId) onlyOwner employeeExists(_employeeId) {
        
        var _employee = employees[_employeeId];
        
        _partialPaid(_employeeId);
        
        totalSalary = totalSalary.sub(_employee.salary);
        
        delete employees[_employeeId];
        
    }
    
    /// @dev change the salary of an employee
    function updateEmployee(address _employeeId, uint _salary) onlyOwner employeeExists(_employeeId){
        
        var _employee = employees[_employeeId];
        
        _partialPaid(_employeeId);
        
        totalSalary = totalSalary.sub(_employee.salary).add(_salary * 1 ether);
        
        _employee.salary = _salary * 1 ether;
        _employee.lastPayday = now;
        
    }
    
    /// @dev change the address of an employee
    function changePaymentAddress(address _oldAddress, address _newAddress) onlyOwner employeeExists(_oldAddress) {
        
        require(employees[_newAddress].lastPayday == 0); // the newAddress should not already be an employee
        
        var _employee = employees[_oldAddress];
        _partialPaid(_oldAddress);
        
        employees[_newAddress] = EmployeeInfo(_employee.salary, now);
        delete employees[_oldAddress];
        
    }
    
    function addFund() payable returns (uint) {
        return this.balance;
    }
    
    function calculateRunway() returns (uint) {
        return this.balance / totalSalary;
    }
    
    function hasEnoughFund() returns (bool) {
        return calculateRunway() > 0;
    }
    
    function getPaid() employeeExists(msg.sender) {
        
        var _employee = employees[msg.sender];
        uint nextPayDay = _employee.lastPayday.add(payDuration);
        require(nextPayDay < now);
        
        msg.sender.transfer(_employee.salary);
        _employee.lastPayday = nextPayDay;
        
    }
}