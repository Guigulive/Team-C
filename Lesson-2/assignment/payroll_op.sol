pragma solidity ^0.4.14;

contract Payroll {
    struct Employee {
    address id;
    uint salary;
    uint lastPayday;
    }
    uint constant payDuration = 10 seconds;
    address owner;
    Employee[] employees;
    uint private totalSalary=0;
    function Payroll() {
        owner = msg.sender;
    }
    //结算工资
    function _partialPaid(Employee employee) private {
        uint payment =employee.salary*(now-employee.lastPayday)/payDuration;
        employee.id.transfer(payment);
    }

    function _findEmployee(address employeeId) private returns (Employee, uint) {
        for(uint i = 0 ;i<employees.length;i++){
            if(employees[i].id == employeeId){
                return (employees[i], i);
            }
        }
    }

    function addEmployee(address employeeId, uint salary) returns(uint) {
        require(msg.sender == owner);
        var (employee , index) = _findEmployee(employeeId);
        assert(employee.id == 0x0);
        salary = salary * 1 ether;
        employees.push(Employee(employee.id, salary*1 ether , now));
        totalSalary += salary;
        return totalSalary;
    }

    function removeEmployee(address employeeId) {
        require(msg.sender == owner);
        var (employee , index) = _findEmployee(employeeId);
        assert(employee.id == 0x0);
        _partialPaid(employee);
        delete employees[index];
        employees[index]=employees[employees.length - 1];
        employees.length-=1;
        totalSalary -= employee.salary;


    }

    function updateEmployee(address employeeId, uint salary) {
        require(msg.sender == owner);
        var (employee , index) = _findEmployee(employeeId);
        assert(employee.id == 0x0);
        _partialPaid(employee);
        employees[index].lastPayday=now;
        newSalary= newSalary * 1 ether;
        employees[index].salary=newSalary;
        totalSalary=totalSalary+newSalary-oldSalary;

    }

    function addFund() payable returns (uint) {
        return this.balance;
    }

    function calculateRunway() returns (uint) {

        return this.balance / totalSalary;
    }

    function hasEnoughFund() returns (bool) {
        return calculateRunway() > 0 ;
    }

    function getPaid() {
        var (employee , index) = _findEmployee(msg.sender);
        assert(employee.id == 0x0);
        uint nextPayday= employee.lastPayday + payDuration;
        assert(nextPayday < now);
        employee.lastPayday = nextPayday;
        employee.id.transfer(employee.salary);
    }
}
