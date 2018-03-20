pragma solidity ^0.4.14;

/**

	L[O] := O
	L(A) := [A, O]
	L(B) := [B, O]
	L(C) := [C, O]
	L[K1] := [K1] + merge(L[A], L[B], [A,B])
		= [K1] + merge([A, O], [B, O], [A, B]) 
		= [K1, A] + merge([O], [B, O], [B]) 
		= [K1, A, B] + merge([O], [O]) 
		= [K1, A, B, O]

	L[K2] := [K2] + merge(L[A], L[C], [A,C])
		= [K2] + merge([A, O], [C, O], [A, C]) 
		= [K2, A] + merge([O], [C, O], [C]) 
		= [K2, A, C] + merge([O], [O]) 
		= [K2, A, C, O]

	L[Z] := [Z] + merge(L[K1], L[K2], [K1, K2])
		= [Z] + merge([K1, A, B, O], [K2, A, C, O], [K1, K2])
		= [Z, K1] + merge([A, B ,O], [K2, A, C, O], [K2])
		= [Z, K1, K2] + merge([A, B ,O], [A, C, O])
		= [Z, K1, K2, A] + merge([B ,O], [C, O])
		= [Z, K1, K2, A, B] + merge([O], [C, O])
		= [Z, K1, K2, A, B, C] + merge([O], [O])
		= [Z, K1, K2, A, B, C, O]


**/

import './SafeMath.sol';
import './Ownable.sol';

contract Payroll is Ownable{
    using SafeMath for uint;
    struct Employee {
        address id;
        uint salary;
        uint lastPayday;
    }
    
    uint constant payDuration = 10 seconds;
    uint totalSalary = 0;

    mapping(address => Employee) employees;
    
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
    
    function calculateRunway() returns (uint) {
        return this.balance.div(totalSalary);
    }
    
    function hasEnoughFund() returns (bool) {
        return calculateRunway() > 0;
    }
    
    function getPaid() employeeExist(msg.sender){
        var employee = employees[msg.sender];

        uint nextPayday = employee.lastPayday.add(payDuration);
        assert(nextPayday < now);

        employee.lastPayday = nextPayday;
        employee.id.transfer(employee.salary);
    }
    
    function changePaymentAddress(address employeeId, address newEmployeeId) onlyOwner partialPaid(employeeId){
		var employee =  employees[employeeId];

        employees[newEmployeeId] = Employee(newEmployeeId, employee.salary * 1 ether, now);
        delete employees[employeeId];
    }
}
