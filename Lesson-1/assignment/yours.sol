pragma solidity ^0.4.14;

contract Payroll {
    uint public constant payDuration = 1 minutes;

    address public owner;

    uint public salary;
    address public employee;
    uint public lastPayday;
    
    modifier ownerOnly() {require (msg.sender == owner); _;}
    modifier employeeOnly() {require (msg.sender == employee); _;}

    function Payroll(address e, uint s) public {
        owner = msg.sender;
        updateEmployee_(e, s);
    }
    
    function updateEmployee(address e, uint s) public ownerOnly {
        updateEmployee_(e, s);
    }
    
    function updateEmployee_(address e, uint s) private {
        if (employee != 0x0) {
            uint payment = salary * (now - lastPayday) / payDuration;
            employee.transfer(payment);
        }
        
        require (e != 0x0 && s >= 0);
        employee = e;
        salary = s * 1 ether;
        lastPayday = now;
    }
    
    function addFund() public payable returns (uint) {
        address contractAddress = this;
        return contractAddress.balance;
    }
    
    function calculateRunway() public constant returns (uint) {
        address contractAddress = this;
        return contractAddress.balance / salary;
    }
    
    function hasEnoughFund() public constant returns (bool) {
        return calculateRunway() > 0;
    }
    
    function timesToBePaid() public constant returns (uint) {
        return (now - lastPayday) / payDuration;
    }
    
    function totalToBePaid() public constant returns (uint) {
        return salary * timesToBePaid();
    }
    
    function getPaidForOnce() public employeeOnly returns (uint) {
        uint nextPayday = lastPayday + payDuration;
        assert(nextPayday < now);

        lastPayday = nextPayday;
        employee.transfer(salary);
        return employee.balance;
    }
    
    function getRemainingBalance() public constant returns (uint) {
        address contractAddress = this;
        return contractAddress.balance;
    }
    
    function getEmployeeBalance() public constant returns (uint) {
        return employee.balance;
    }
}
