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
    Employee[] employees;

    function Payroll() payable {
        owner = msg.sender;
    }
    
    //计算当前一共需要多少工资
    function _calTotal() private {
        uint total = 0;
        for (uint i = 0; i < employees.length; i++) {
            totalSalary += employees[i].salary;
        }
        totalSalary = total;
    }
    
    //给工人发币
    function _partialPaid(Employee employee) private {
        uint payment = employee.salary * (now - employee.lastPayday) / payDuration ;
        employee.id.transfer(payment);//具体转账

    }
    
    function _findEmployee(address employeeId) private returns (Employee, uint) {
        for(uint i = 0; i < employees.length; i++) {
            if (employees[i].id == employeeId) {
                return (employees[i], i);
            }
        }
        revert();//否则没找到成员 抛出异常
    }

    function addEmployee(address employeeId, uint salary) payable {
        require(msg.sender == owner);//只有雇主才有权限
        //吧新雇员添加到雇员数组中
        //先在数组中查找有没有改成员
        var (employee,i) = _findEmployee(employeeId);
        //这是运行中的值 
        assert(employee.id == 0x0);//他的缩影必须为空  表示没有改成员
        //添加  push
        employees.push(Employee(employeeId,salary*1 ether,now));
        _calTotal();


    }
    
    function removeEmployee(address employeeId) {
        
        //删除前 先做身份判断
        require(msg.sender == owner);
        //判断是否存在 存在就删除
        var (employee,i)  =  _findEmployee(employeeId);
        assert( employee.id != 0x0);
        //先给人结工资 然后子删除
        _partialPaid(employees[i]);
        //删除
        delete employees[i];
        //吧最后一个元素用来填充
        employees[i] = employees[employees.length - 1];
        employees.length--;
        _calTotal();


    }
    
    function updateEmployee(address employee, uint salary) {
        require(msg.sender == owner);
        for(uint i = 0; i < employees.length; i++){
            if( employees[i].id == employee ) {
                _partialPaid(employees[i]);
                employees[i].salary = salary;
                employees[i].lastPayday = now;
            }
        }
        _calTotal();

    }
    
    function addFund() payable returns (uint) {
        return this.balance;
    }
    
     function getFund(uint a) payable returns (uint) {
        return this.balance;
    }
    
    function calculateRunway() returns (uint) {
        return this.balance / totalSalary;
    }
    
    function hasEnoughFund() returns (bool) {
        return calculateRunway() > 0;
    }
    
    function getPaid() {
        var (employee,i) = _findEmployee(msg.sender);
        assert(employee.id != 0x0);

        uint nextPayday = employee.lastPayday + payDuration;
        assert(nextPayday < now);

        employees[i].lastPayday = nextPayday;
        employee.id.transfer(employee.salary);
    }
}
