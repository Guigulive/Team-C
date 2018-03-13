pragma solidity ^0.4.14;
contract Payroll {
    uint salary = 0;
    address staff = 0x0;
    uint constant payDuration = 30 days;
    uint lastPayday = now;
    
    function addFun() payable returns (uint){
        return this.balance;
    }
    
    function hasEnoughFund() returns (bool){
        return this.balance  / salary > 0;
    }
    
    function setStaffAddress(address staffAddress){
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
        uint ss = staffPayroll * 1 ether;
        require(ss != 0);
        
        salary = ss;
    }
    
    function getPaid() {
        require(staff != 0x0);
        require(hasEnoughFund());
        
        uint nextPayDay = lastPayday - payDuration;
        require(nextPayDay < now);
        
        lastPayday = nextPayDay;
        staff.transfer(salary);
    }
}
