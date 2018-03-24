pragma solidity ^0.4.14;


import './SafeMath.sol';
import './Ownable.sol';

contract Payroll is Ownable{
    using SafeMath for uint;
    struct Employee {
        address id;
        uint salary;
        uint lastPayday;
    }
    
    uint constant payDuration = 30 days;
    uint totalSalary = 0;

    mapping(address => Employee) public employees;
    
    modifier employeeExist(address employeeId){
        var employee =  employees[employeeId];
        assert(employee.id != 0x0);
        _;
    }

    modifier partialPaid(address employeeId){
        var employee =  employees[employeeId];
        assert(employee.id != 0x0);
        _partialPaid(employee);
        _;
    }
    
    function _partialPaid(Employee employee) private {
        uint payment = employee.salary
                .mul(now.sub(employee.lastPayday))
                .div(payDuration);
                
        employee.id.transfer(payment);
    }
    
    function addEmployee(address employeeId, uint salary) onlyOwner{
        var employee  =  employees[employeeId];
        assert(employee.id == 0x0);

        totalSalary = totalSalary.add(salary * 1 ether);
        employees[employeeId] = Employee(employeeId, salary * 1 ether, now);
    }
    
    function removeEmployee(address employeeId) onlyOwner employeeExist(employeeId){
        var employee =  employees[employeeId];

        _partialPaid(employee);
        totalSalary = totalSalary.sub(employee.salary);
        delete employees[employeeId];
    }
    
    function updateEmployee(address employeeId, uint salary) onlyOwner employeeExist(employeeId){

        var employee =  employees[employeeId];
        _partialPaid(employee);

        employees[employeeId].salary = salary * 1 ether;
        employees[employeeId].lastPayday = now;

    }
    
    function addFund() payable returns (uint) {
        return this.balance;
    }
    
    function calculateRunway() public returns (uint) {
        return this.balance.div(totalSalary);
    }
    
    function hasEnoughFund() returns (bool) {
        return calculateRunway() > 0;
    }
    
    function getPaid() public employeeExist(msg.sender){
        var employee = employees[msg.sender];

        uint nextPayday = employee.lastPayday.add(payDuration);
        require(nextPayday < now);

        employee.id.transfer(employee.salary);
        employee.lastPayday = nextPayday;
    }
    
    function changePaymentAddress(address employeeId, address newEmployeeId) onlyOwner partialPaid(employeeId){
		var employee =  employees[employeeId];

        employees[newEmployeeId] = Employee(newEmployeeId, employee.salary * 1 ether, now);
        delete employees[employeeId];
    }

}
