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
        require(msg.sender == staff);
        //此处需求我理解都是员工老王要换地址，而不是换人，所以之前的账先不结了。到日子nextPayday再发工资，此处只换账号。
        staff=newAddress;
    }
    function changeSalary (uint newSalary){
        require(msg.sender == boss);
        if (employee != 0x0) {
            uint payment = salary * (now - lastPayday) / payDuration;
            employee.transfer(payment);
        }
        salary = newSalary * 1 ether;
        lastPayday = now;
    }

}

