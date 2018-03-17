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
    Employee[] employees;

    function Payroll() {
        owner = msg.sender;
    }
    
    function _partialPaid(Employee employee) private {
        uint payment = employee.salary * (now-employee.lastPayday)/payDuration;
        employee.id.transfer(payment);
    }
    
    function _findEmployee(address employeeId) private returns (Employee, uint) {
        for(uint i=0;i<employees.length;i++){
            if(employees[i].id == employeeId){
                return (employees[i],i);
            }
        }
        
    }

    function addEmployee(address employeeId, uint salary) {
        require(msg.sender == owner);
        //assert before find
        //assert(employeeId == 0x0);
        var(employee,index) = _findEmployee(employeeId);
        assert(employee.id == 0x0);
        
        employees.push(Employee(employeeId,salary * 1 ether,now));
    }
    
    function removeEmployee(address employeeId) {
        require(msg.sender == owner);
        
        for(uint i=0;i<employees.length;i++){
            if(employees[i].id==employeeId){
                delete employees[i];
                employees[i] = employees[employees.length - 1];
                employees.length -=1;
                return;
            }
        }
    }
    
    function updateEmployee(address employeeId, uint salary) {
        require(msg.sender == owner);
        
        var(employee,index) = _findEmployee(employeeId);
        assert(employee.id != 0x0);
        
        _partialPaid(employee);
        employees[index].salary = salary * 1 ether;
        employees[index].lastPayday = now;
        // for(uint i=0;i<employees.length;i++){
        //     if(employeeId == employees[i].id){
        //         _partialPaid(employees[i]);
        //         employees[i].salary=salary;
        //         employees[i].lastPayday=now;
        //         return;
        //     }
        // }
        
        
    }
    
    function addFund() payable returns (uint) {
        return this.balance;
    }
    
    function calculateRunway() returns (uint) {
        uint totalSalary = 0;
       for (uint i = 0; i < employees.length; i++) {
            totalSalary += employees[i].salary;
        }
        return this.balance / totalSalary;
    }
    
    function hasEnoughFund() returns (bool) {
    }
    
    function getPaid() {
        var(employee,index) = _findEmployee(msg.sender);
        assert(employee.id !=0x0);
        
        uint nextPayday = employee.lastPayday + payDuration;
        assert(nextPayday < now);
        
        employees[index].lastPayday = nextPayday;
        employee.id.transfer(employee.salary);
    }
}
////////////////////////////////////////
//十次gas变化
第一个员工(老板自己)address
 transaction cost 	22966 gas 
 execution cost 	1694 gas 
updateEmployee
 transaction cost 	33275 gas 
 execution cost 	10403 gas 
2
 transaction cost 	23747 gas 
 execution cost 	2475 gas 
3
 transaction cost 	24528 gas 
 execution cost 	3256 gas 
 4
  transaction cost 	25309 gas 
 execution cost 	4037 gas
 5
 transaction cost 	26090 gas 
 execution cost 	4818 gas
 6
  transaction cost 	26871 gas 
 execution cost 	5599 gas
 7
 transaction cost 	27652 gas 
 execution cost 	6380 gas
 8
  transaction cost 	28433 gas 
 execution cost 	7161 gas
 9
  transaction cost 	29214 gas 
 execution cost 	7942 gas
 10
 transaction cost 	29995 gas 
 execution cost 	8723 gas
 //////////////////////////////////////////////////
 calculateRunway优化
 是不是把totalSalary提到contract做成员变量 每加一个employee就加一次totalSalary
 然后调此方法时直接用this.balance/totalSalary
 没时间写代码了 
