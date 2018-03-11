/*作业请提交在这个目录下*/
pragma solidity ^0.4.18;

contract Payroll {
  address owner;
  address employee;
  uint salary = 1 ether;
  //address  就是 uint160
  address frank = 0xca35b7d915458ef540ade6068dfe2f44e8fa733c;
  uint constant payDuration = 30 days; //修饰变量 是有用的
  uint lastPayday = now;

  function addFund() payable {
    //给合约里加点钱
    //要让函数能接受钱的话 函数要加payable

  }

  function calculateRunway()  returns(uint){
    //solidity 没有float
    return this.balance/salary;
  }

  function hasEnoughFund() returns(bool) {
    return calculateRunway() > 0;
  }

  function getPaid() {
    if((lastPayday + payDuration < now) && msg.sender != frank){
      //更新发薪水的时间
      lastPayday = lastPayday + payDuration;
      frank.transfer(salary);
    } else {
      revert();
    }
  }

  function setSalary(uint newSalay) {
    if(msg.sender == owner){
       salary = newSalay;
    }else{
      revert();
    }
  }

  function setSalary(address adr) {
    if(msg.sender == employee){
       employee = adr;
    }else{
      revert();
    }
  }
}
