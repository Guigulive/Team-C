/*作业请提交在这个目录下*/

pragma solidity ^0.4.14;

contract Payroll {
    uint salary = 1 ether;
    uint constant payDuration = 10 seconds;
    address boss = 0xca35b7d915458ef540ade6068dfe2f44e8fa733c;
    address staff = 0x14723a09acff6d2a60dcdf7aa4aff308fddc160c;
    uint lastPayday = now;

    function addFund() payable returns (uint) {
        return this.balance;
    }

    function calculateRunway() returns (uint) {
        return this.balance / salary;
    }

    function hasEnoughFund() returns (bool){
        return calculateRunway() > 1;
    }

    function getPaid() returns (uint){
        if(msg.sender != staff){
            revert();
        }

        uint nextPayday = lastPayday + payDuration;
        if(nextPayday > now){
            revert();
        }
        lastPayday=nextPayday;
        staff.transfer(salary);

    }

    function changeAddress (address newAddress){
        if(msg.sender != staff){
            revert();
        }
        staff=newAddress;
    }
    function changeSalary (uint newSalary){
        if(msg.sender != boss){
            revert();
        }
        salary=newSalary * 1 ether;
    }

}

