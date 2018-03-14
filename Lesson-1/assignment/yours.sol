pragma solidity ^0.4.14;

contract Payroll {
    event UpdateEmployee(address addressToPay, uint balance);
    event UpdateSalary(address addressToPay, uint balance);
    
    uint public constant payDuration = 10 seconds;
    address public owner;
    uint public salary;
    address public employee;
    uint public lastPayday;
    
    modifier ownerOnly() {require (msg.sender == owner); _;}
    modifier employeeOnly() {require (msg.sender == employee); _;}

    function Payroll(address e, uint s) public {
        require(e != 0x0 && s > 0);
        owner = msg.sender;
        employee = e;
        salary = s * 1 ether;
        lastPayday = now;
    }
    
    function updateEmployee(address e) public ownerOnly {
        require(e != 0x0);
        uint outStandingBalance = salary * (now - lastPayday) / payDuration;
        address addressToPay = employee;
        employee = e;
        lastPayday = now;
        safelyPayTheOutstandingBalance_(addressToPay, outStandingBalance);
        emit UpdateEmployee(addressToPay, outStandingBalance);
    }
    
    function updateSalary(uint s) public ownerOnly {
        require (s >= 0);
        uint outStandingBalance = salary * (now - lastPayday) / payDuration;
        address addressToPay = employee;
        salary = s * 1 ether;
        lastPayday = now;
        safelyPayTheOutstandingBalance_(addressToPay, outStandingBalance);
        emit UpdateSalary(addressToPay, outStandingBalance);
    }
    
    function safelyPayTheOutstandingBalance_(address add, uint amount) private {
        if (add != 0x0 && amount > 0) {
            add.transfer(amount);
        }
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
    
    /** The employee calls this method to get his payment *FOR ONCE*. This
     * method can be called multiple times if timesToBePaid() > 0.
     */
    function getPaid() public employeeOnly returns (uint) {
        require (nextPayday < now);
        if (employee != 0x0 && salary > 0) {
            uint nextPayday = lastPayday + payDuration;
            lastPayday = nextPayday;
            employee.transfer(salary);
            return employee.balance;
        }
        return 0;
    }
    
    // =========================================================================
    // Helper functions for debugging purpose
    // =========================================================================
    /*
    function timesToBePaid() public constant returns (uint) {
        return (now - lastPayday) / payDuration;
    }
    
    function totalToBePaid() public constant returns (uint) {
        return salary * timesToBePaid();
    }
    */
}
