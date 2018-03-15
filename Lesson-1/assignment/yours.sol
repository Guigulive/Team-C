/*作业请提交在这个目录下*/
pragma solidity ^0.4.14;

contract Payroll {
    uint constant public payDuration = 10 seconds;

    address public owner;
    uint public salary;
    address public employee;
    uint public lastPayday;

    function Payroll() {
        owner = msg.sender;
    }
    
    // function updateEmployee(address e, uint s) {
    //     require(msg.sender == owner);
        
    //     if (employee != 0x0) {
    //         uint payment = salary * (now - lastPayday) / payDuration;
    //         employee.transfer(payment);
    //     }
        
    //     employee = e;
    //     salary = s * 1 ether;
    //     lastPayday = now;
    // }
    
    function setAddress(address e){
        require(msg.sender == owner);
        
        address oldaddress = employee;
        employee = e;
        
        uint oldlastPayday = lastPayday;
        lastPayday = now;
        
        if (employee != 0x0) {
            uint payment = salary * (now - oldlastPayday) / payDuration;
            oldaddress.transfer(payment);
        }
        
    }
    
    function setSalary(uint s){
        require(msg.sender == owner);

        uint oldsalary = salary;
        salary = s;
        
        uint oldlastPayday = lastPayday;
        lastPayday = now;
        
        if (employee != 0x0) {
            uint payment = oldsalary * (now - oldlastPayday) / payDuration;
            employee.transfer(payment);
        }
        
        salary = s * 1 ether;
        lastPayday = now;        
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
}
