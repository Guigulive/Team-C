/*作业请提交在这个目录下*/
var PayRoll = artifacts.require("./PayRoll.sol");

contract('PayRoll', function(accounts) {

  it("...value should be equal.", function() {
    return PayRoll.deployed().then(function(instance) {
      payrollInstance = instance;

      return payrollInstance.addEmployee('0xf17f52151ebef6c7334fad080c5704d77216b732', 1);
    }).then(function() {
       payrollInstance.removeEmployee('0xf17f52151ebef6c7334fad080c5704d77216b732');
       uint num2 = emplyees.length;
      return num2;
    }).then(function(num2) {
      assert.equal(num2, payrollInstance.emplyees.length, "...value should be equal");
    });
  });

});