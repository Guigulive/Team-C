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

    function addEmployee(address employeeId, uint salary) {
        require(msg.sender == owner);
        var (employee , index) = _findEmployee(employeeId);
        assert(employee.id == 0x0);
        salary = salary * 1 ether;
        employees.push(Employee(employee.id, salary*1 ether , now));
    }

    function removeEmployee(address employeeId) {
        require(msg.sender == owner);
        var (employee , index) = _findEmployee(employeeId);
        assert(employee.id != 0x0);
        _partialPaid(employee);
        delete employees[index];
        employees[index]=employees[employees.length - 1];
        employees.length-=1;


    }

    function updateEmployee(address employeeId, uint salary) {
        require(msg.sender == owner);
        var (employee , index) = _findEmployee(employeeId);
        assert(employee.id != 0x0);
        _partialPaid(employee);
        employees[index].lastPayday=now;
        employees[index].salary=salary;

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
        return calculateRunway() > 0 ;
    }

    function getPaid() {
        var (employee , index) = _findEmployee(msg.sender);
        assert(employee.id != 0x0);
        uint nextPayday= employee.lastPayday + payDuration;
        assert(nextPayday < now);
        employees[index].lastPayday = nextPayday;
        employees[index].id.transfer(employee.salary);
    }
}

/*记录*/
// "0x14723a09acff6d2a60dcdf7aa4aff308fddc160c",1   gas:22966+1694
// '0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db',1   gas:23747+2475
// '0x583031d1113ad414f02576bd6afabfb302140225',1   gas:24528+3256
// '0xdd870fa1b7c4700f2bd7f44238821c26f7392148',1   gas:25309+4037
// '0x8caabc77dc0303c8dc4b83d94d1116795bee861b',1   gas:26090+4818
// '0xf316549251ebd4340dcc9d6827aee5b60c811b77',1   gas:26871+5599
// '0xacad004917714ae77827854a6fc117f3d650ea3e',1   gas:27652+6380
// '0x301ca0bb5223c518fafe6c93385c2ad5bd7ca198',1   gas:28433+7161
// '0x8739e73b14e2d588106ce71380a5b11b2f1ed05b',1   gas:29214+7942
// '0x04a4dad7290ca7f775498f27bd1add29c208c73d',1   gas:29995+8723


//gas随计算量的增加而增加

/*calculateRunway 优化*/
// 代码详见 payroll_op.sol

//优化后gas ：22124+852
