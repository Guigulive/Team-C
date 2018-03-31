pragma solidity ^0.4.17;

import './SafeMath.sol';
import './Ownable.sol';

contract Payroll is Ownable {

    using SafeMath for uint;

    /**
     * We are using mapping here, the key is already the address.
     */
    struct Employee {
        uint index;
        uint salary;
        uint lastPayday;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier shouldExist(address employeeId) {
        assert(employees[employeeId].lastPayday != 0);
        _;
    }

    modifier shouldNotExist(address employeeId) {
        assert(employees[employeeId].lastPayday == 0);
        _;
    }

    uint constant PAY_DURATION = 10 seconds;
    uint public totalSalary = 0;
    address[] employeeAddressList;

    /**
     * This contract is simple, We update employees by the key directly
     * instead of updating a copy so that we could save some gas.
     */
    mapping(address => Employee) public employees;

    function Payroll() payable public Ownable {
        owner = msg.sender;
    }

    function _partialPaid(address employeeId) private {
        uint payment = employees[employeeId].salary
        .mul(now.sub(employees[employeeId].lastPayday))
        .div(PAY_DURATION);
        employeeId.transfer(payment);
    }

    function addEmployee(address employeeId, uint salary) public onlyOwner shouldNotExist(employeeId) {
        salary = salary.mul(1 ether);

        uint index = employeeAddressList.length;
        employeeAddressList.push(employeeId);
        employees[employeeId] = Employee(index, salary, now);

        totalSalary = totalSalary.add(salary);
    }

    function removeEmployee(address employeeId) public onlyOwner shouldExist(employeeId) {
        _partialPaid(employeeId);

        uint salary = employees[employeeId].salary;
        uint index = employees[employeeId].index;
        totalSalary = totalSalary.sub(salary);

        delete employees[employeeId];

        delete employeeAddressList[index];
        address moveAddress = employeeAddressList[employeeAddressList.length - 1];
        employeeAddressList[index] = moveAddress;

        // update index
        employees[moveAddress].index = index;

        // adjust length
        employeeAddressList.length -= 1;
    }

    function changePaymentAddress(address oldAddress, address newAddress) public onlyOwner shouldExist(oldAddress) shouldNotExist(newAddress) {
        _partialPaid(oldAddress);

        employees[newAddress] = Employee(employees[oldAddress].index, employees[oldAddress].salary, now);
        delete employees[oldAddress];
    }

    function updateEmployee(address employeeId, uint salary) public onlyOwner shouldExist(employeeId) {
        _partialPaid(employeeId);

        uint oldSalary = employees[employeeId].salary;
        salary = salary.mul(1 ether);

        employees[employeeId].salary = salary;
        employees[employeeId].lastPayday = now;
        totalSalary = totalSalary.add(salary).sub(oldSalary);
    }

    function addFund() payable public returns (uint) {
        return address(this).balance;
    }

    function calculateRunway() public view returns (uint) {
        if (totalSalary == 0) {
            return 0;
        }
        return address(this).balance.div(totalSalary);
    }

    function hasEnoughFund() public view returns (bool) {
        return calculateRunway() > 0;
    }

    function getPaid() public shouldExist(msg.sender) {
        address employeeId = msg.sender;

        uint nextPayday = employees[employeeId].lastPayday.add(PAY_DURATION);
        assert(nextPayday < now);

        employees[employeeId].lastPayday = nextPayday;
        employeeId.transfer(employees[employeeId].salary);
    }

    function getEmployerInfo() view public returns (uint balance, uint runway, uint employeeCount) {
        balance = address(this).balance;
        runway = calculateRunway();
        employeeCount = employeeAddressList.length;
    }

    function getEmployeeInfo(uint index) view public returns (address employeeAddress, uint salary, uint lastPayday, uint balance) {
        address id = employeeAddressList[index];
        employeeAddress = id;
        salary = employees[id].salary;
        lastPayday = employees[id].lastPayday;
        balance = address(id).balance;
    }

    function getEmployeeInfoById(address id) view public returns (uint salary, uint lastPayday, uint balance) {
        salary = employees[id].salary;
        lastPayday = employees[id].lastPayday;
        balance = address(id).balance;
    }
}