/**
 *  This is not a part of the unit test for PayRoll.
 *  Just test the time travel feature of TestRPC
 */
contract('TestTimeStamp', function(accounts) {

    var currentTime;
    
    var day = 24*60*60;
    var payDuration = 30 * day;
    

    it("Simulate time pass", function() {
        
        console.log("Initial time stamp: " + web3.eth.getBlock(web3.eth.blockNumber).timestamp);

        web3.currentProvider.send({jsonrpc: "2.0", method: "evm_increaseTime", params: [payDuration], id: 0})

        web3.currentProvider.send({jsonrpc: "2.0", method: "evm_mine", params: [], id: 0});
        console.log("After 30 days: " + web3.eth.getBlock(web3.eth.blockNumber).timestamp);

        web3.currentProvider.send({jsonrpc: "2.0", method: "evm_increaseTime", params: [payDuration], id: 0})

        web3.currentProvider.send({jsonrpc: "2.0", method: "evm_mine", params: [], id: 0});
        console.log("After another 30 days: " + web3.eth.getBlock(web3.eth.blockNumber).timestamp);

    });

});