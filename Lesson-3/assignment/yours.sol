/*作业请提交在这个目录下*/

pragma solidity ^0.4.14;

contract Payroll {
    struct Employee {
        address id;
        uint salary;
        uint lastPayday;
    }

    uint constant payDuration = 10 seconds;
    address owner;
    uint totalSalary;
    uint balance;
    mapping(address => Employee) public employees;

    function Payroll() payable {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier employeeExist(address employeeId) {
        var employee  =  employees[employeeId];
        assert( employee.id != 0x0);
        _;
    }


    //给工人发币
    function _partialPaid(Employee employee) private {
        uint payment = employee.salary * (now - employee.lastPayday) / payDuration ;
        employee.id.transfer(payment);//具体转账

    }



    function addEmployee(address employeeId, uint salary) payable onlyOwner employeeExist(employeeId) {
        //require(msg.sender == owner);//只有雇主才有权限
        //吧新雇员添加到雇员数组中
        //先在数组中查找有没有改成员
        // employee = employees[employeeId];
        //这是运行中的值
        //assert(employee.id == 0x0);//他的缩影必须为空  表示没有改成员
        //添加
        totalSalary += salary * 1 ether;
        employees[employeeId] =(Employee(employeeId,salary*1 ether,now));


    }

    function removeEmployee(address employeeId) onlyOwner employeeExist(employeeId)  {

        //删除前 先做身份判断
       // require(msg.sender == owner);
        //判断是否存在 存在就删除
        var employee  =  employees[employeeId];
        //assert( employee.id != 0x0);
        //先给人结工资 然后子删除
        _partialPaid(employee);
        //删除
        totalSalary -= employees[employeeId].salary;
        delete employees[employeeId];


    }

    function updateEmployee(address employeeId, uint salary) onlyOwner employeeExist(employeeId) {
        //require(msg.sender == owner);
        var employee = employees[employeeId];
        //assert(employee.id != 0x0);
        _partialPaid(employee);
        totalSalary -= employees[employeeId].salary;
        employees[employeeId].salary = salary*1 ether;
        totalSalary += employees[employeeId].salary;
        employees[employeeId].lastPayday = now;

    }

    function changePaymengAddress(address employeeId,address newaddress) onlyOwner employeeExist(employeeId) {
        //var employee  =  employees[employeeId];
        employees[employeeId].id = newaddress;
        employees[employeeId].lastPayday = now;

    }
    function addFund(uint a) payable returns (uint) {
        return balance += a*1 ether ;
    }

     function getFund()  returns (uint) {
        return balance;
    }

    function calculateRunway() returns (uint) {
        return balance / totalSalary;
    }

    function hasEnoughFund() returns (bool) {
        return calculateRunway() > 0;
    }

    function checkEmployee(address employeeId) returns (uint salary,uint lastPayday) {
        var employee = employees[employeeId];
        salary = employee.salary;
        lastPayday = employee.lastPayday;
    }

    function getPaid() employeeExist(msg.sender){
        var employee = employees[msg.sender];
       // assert(employee.id != 0x0);

        uint nextPayday = employee.lastPayday + payDuration;
        assert(nextPayday < now);

        employee.lastPayday = nextPayday;
        employee.id.transfer(employee.salary);
    }
}
