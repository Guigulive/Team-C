pragma solidity ^0.4.14;
contract Payroll {
    uint salary = 0;
    address staff = 0x0;
    uint constant payDuration = 30 days;
    uint lastPayday = now;
    address owner;
    
    function Payroll(){
        owner = msg.sender;
    }
    
    function addFun() payable returns (uint){
        return this.balance;
    }
    
    function hasEnoughFund() returns (bool){
        require(salary != 0);
        return this.balance  / salary > 0;
    }
    
    function setStaffAddress(address staffAddress){
        require(msg.sender == owner);
        require(salary != 0);
        
        staff = staffAddress;

        //  清算
        uint money = salary * ((now - lastPayday) / payDuration);
        
        require(money < this.balance);
        lastPayday = now;
        
        if(money > 0){
            staff.transfer(money);
        }
    }
    
    function setStaffPayroll(uint staffPayroll){
        require(msg.sender == owner);
        uint ss = staffPayroll * 1 ether;
        require(ss != 0);
        
        salary = ss;
    }
    
    function getPaid() {
        require(staff == msg.sender);
        require(hasEnoughFund());
        
        uint nextPayDay = lastPayday - payDuration;
        require(nextPayDay < now);
        
        lastPayday = nextPayDay;
        staff.transfer(salary);
    }
}