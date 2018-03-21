pragma solidity ^0.4.14;

import './SafeMath.sol';

contract Payroll {
  using SafeMath for uint;
  struct Employee {
    address id;
    uint salary;
    uint lastPayday;
  }

  modifier ownerOnly {
    require (msg.sender == owner);
    _;
  }

  modifier employeeExists(address addr) {
    var employee = employees[addr];
    require(employee.id != 0x0);
    _;
  }

  modifier employeeNotExists(address addr) {
    var employee = employees[addr];
    require(employee.id == 0x0);
    _;
  }
  
  uint constant payDuration = 10 seconds;

  address owner;
  mapping(address => Employee) public employees;
  uint public totalSalary_;

  function Payroll() {
    owner = msg.sender;
  }
  
  function _safelySendPayment(address addr, uint amount) private {
    if (addr != 0x0 && amount > 0) {
      addr.transfer(amount);
    }
  }
  
  function _calculatePayment(Employee e) private returns (uint) {
    return e.salary.mul((now.sub(e.lastPayday))).div(payDuration);
  }

  function addEmployee(address employeeId, uint salary) 
      ownerOnly employeeNotExists(employeeId) {        
    employees[employeeId] = Employee(employeeId, salary.mul(1 ether), now);
    totalSalary_ = totalSalary_.add(salary.mul(1 ether));
  }
  
  function removeEmployee(address employeeId) 
      ownerOnly employeeExists(employeeId) {        
    uint payment = _calculatePayment(employees[employeeId]);
    totalSalary_ = totalSalary_.sub(employees[employeeId].salary);
    delete employees[employeeId];
    
    _safelySendPayment(employeeId, payment);
  }
  
  function updateEmployee(address employeeId, uint salary) 
      ownerOnly employeeExists(employeeId) {        
    uint payment = _calculatePayment(employees[employeeId]);
    totalSalary_ = totalSalary_.add(salary.mul(1 ether));
    totalSalary_ = totalSalary_.sub(employees[employeeId].salary);
    // totalSalary_ = totalSalary_ + salary * 1 ether - employees[employeeId].salary;
    employees[employeeId].salary = salary.mul(1 ether);
    employees[employeeId].lastPayday = now;

    _safelySendPayment(employeeId, payment);
  }

  function changePaymentAddress(address employeeId, address newAddress)
      ownerOnly employeeExists(employeeId) employeeNotExists(newAddress){
    employees[newAddress] = 
        Employee(newAddress, 
                 employees[employeeId].salary,
                 employees[employeeId].lastPayday);
    delete employees[employeeId];
  }
  
  function addFund() payable returns (uint) {
    return this.balance;
  }
  
  function calculateRunway() returns (uint) {
    return this.balance.div(totalSalary_);
  }
  
  function hasEnoughFund() returns (bool) {
    return calculateRunway() > 0;
  }
  
  function getPaid() employeeExists(msg.sender) {       
    uint nextPayDay = employees[msg.sender].lastPayday.add(payDuration);
    require(nextPayDay < now);
    
    employees[msg.sender].lastPayday = nextPayDay;
    _safelySendPayment(msg.sender, employees[msg.sender].salary);
  }
}
