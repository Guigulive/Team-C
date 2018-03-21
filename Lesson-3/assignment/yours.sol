/*作业请提交在这个目录下*/
pragma solidity ^0.4.14;

import './Ownable.sol';
import './SafeMath.sol';
contract payRoll is Ownable{
    using SafeMath for uint;
    struct Employee {
    address id;
    uint salary;
    uint lastPayday;
    }
    uint totalSalary = 0;
    mapping (address => Employee) employees;
    uint constant payDuration = 10 seconds;
    
    function addFund() payable returns(uint){
        return this.balance;
    }

    function calculateRunway() returns (uint) {
        return this.balance / totalSalary;
    }

    function hasEnoughFund() returns (bool) {
        return calculateRunway() > 0;
    }


    modifier hasNoEmployee (address employeeId){
        require(employees[employeeId].id == 0x0);
        _;
    }
    modifier hasEmployee (address employeeId){
        require(employees[employeeId].id != 0x0);
        _;
    }

    function _partialPay(address id){
        var employee = employees[id];
        uint payment = employee.salary.mul(now.sub(employee.lastPayday)).div(payDuration);
        id.transfer(payment);

    }


    // function addEmployee(address employeeId, uint salary) {
    //     require(msg.sender == owner);

    //     var(employee,index) = _findEmployee(employeeId);
    //     assert(employee.id == 0x0);
        
    //     employees.push(Employee(employeeId,salary * 1 ether,now));
    // }
    
    function addEmployee (address id,uint salary) onlyOwner hasNoEmployee(id) {
        var employee =employees[id];
        assert(employee.id==0x0);
        uint _salary = salary.mul(1 ether);
        employees[id]=Employee(id,_salary,now);
        totalSalary+=_salary;

    }
    
    function removeEmployee (address employeeId) onlyOwner hasEmployee(employeeId){
        _partialPay(employeeId);
        delete employees[employeeId];
        totalSalary.sub(employees[employeeId].salary);
    }
    
    function updateEmployee (address id,uint newSalary) onlyOwner hasEmployee(id){
        var employee = employees[id];
        _partialPay(id);

        totalSalary = totalSalary.sub(employee.salary).add(newSalary * 1 ether);

        employee.salary = newSalary * 1 ether;
        employee.lastPayday = now;
    }

    function changePaymentAddress(address oldAddress, address newAddress) onlyOwner hasEmployee(oldAddress) hasNoEmployee(newAddress) {
        Employee employee = employees[oldAddress];
        _partialPay(oldAddress);
        employees[newAddress] = Employee(newAddress, employee.salary, now);
        delete employees[oldAddress];

    }

    function getPaid() hasEmployee(msg.sender) {

        Employee employee = employees[msg.sender];
        uint nextPayDay = employee.lastPayday.add(payDuration);
        assert(nextPayDay < now);

        msg.sender.transfer(employee.salary);
        employee.lastPayday = nextPayDay;

    }

//第三题（加分题）：自学C3 Linearization, 求以下 contract Z 的继承线
//contract O
//contract A is O
//contract B is O
//contract C is O
//contract K1 is A, B
//contract K2 is A, C
//contract Z is K1, K2

}
