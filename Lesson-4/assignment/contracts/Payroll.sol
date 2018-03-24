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
    mapping (address => Employee) public employees;
    uint constant payDuration = 10 seconds;
    // 充值
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

    function partialPay(address id){
        var employee = employees[id];
        uint payment = employee.salary.mul(now.sub(employee.lastPayday)).div(payDuration);
        id.transfer(payment);

    }


    //
    function addEmployee (address id,uint salary) onlyOwner hasNoEmployee(id) {
        var employee =employees[id];
        assert(employee.id==0x0);
        uint _salary = salary.mul(1 ether);
        employees[id]=Employee(id,_salary,now);
        totalSalary+=_salary;


    }
    function removeEmployee (address employeeId) onlyOwner hasEmployee(employeeId){

        
        partialPay(employeeId);
        delete employees[employeeId];
        totalSalary.sub(employees[employeeId].salary);

    }
    function updateEmployee (address id,uint newSalary) onlyOwner hasEmployee(id){
        var employee = employees[id];

        partialPay(id);

        totalSalary = totalSalary.sub(employee.salary).add(newSalary * 1 ether);

        employee.salary = newSalary * 1 ether;
        employee.lastPayday = now;
    }

    function changePaymentAddress(address oldAddress, address newAddress) onlyOwner hasEmployee(oldAddress) hasNoEmployee(newAddress) {

        Employee employee = employees[oldAddress];
        partialPay(oldAddress);
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



}