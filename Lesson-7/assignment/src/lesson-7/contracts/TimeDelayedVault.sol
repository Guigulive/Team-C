pragma solidity ^0.4.17;

import './GamerVerifier.sol';
import './CommonWalletLibrary.sol';

contract TimeDelayedVault is CommonWalletLibrary {
    uint  public nextWithdrawTime;
    uint  public withdrawCoolDownTime;
    address[] public authorizedUsers;
    address public withdrawObserver;
    address public additionalAuthorizedContract;
    address public proposedAAA;
    uint public lastUpdated;
    bool[] public votes;
    address [] public observerHistory;
    GamerVerifier public g = GamerVerifier(0x0);
    address owner;
    address walletLibrary;

    function TimeDelayedVault(address libAddress) recordAction {
        nextWithdrawTime = now;
        withdrawCoolDownTime = 30 minutes;
        walletLibrary = libAddress;
        address(this).call(bytes4(sha3("initializeVault()")));
        // Please note, the following code chunk is different for each group, all group members are added to authorizedUsers array
        // authorizedUsers.push(xxxxxxxxxx);
        for (uint i = 0; i < authorizedUsers.length; i++) {
            votes.push(false);
        }
    }

    modifier onlyAuthorized() {
        bool pass = false;
        if (additionalAuthorizedContract == msg.sender) {
            pass = true;
        }

        for (uint i = 0; i < authorizedUsers.length; i++) {
            if (authorizedUsers [i] == msg.sender) {
                pass = true;
                break;
            }
        }
        require(pass);
        _;
    }

    modifier onlyOnce() {
        require(owner == 0x0);
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier recordAction() {
        lastUpdated = now;
        _;
    }

    function setObserver(address ob) {
        bool duplicate = false;
        for (uint i = 0; i < observerHistory.length; i++) {
            if (observerHistory[i] == ob) {
                duplicate = true;
            }
        }

        if (!duplicate) {
            withdrawObserver = ob;
            observerHistory.push(ob);
        }
    }

    function addToReserve() payable recordAction external returns (uint) {
        require(g.isValidGamer(msg.sender));
        assert(msg.value > 0.01 ether);
        return this.balance;
    }


    function withdrawFund() onlyAuthorized external returns (bool) {
        require(now > nextWithdrawTime);
        assert(withdrawObserver.call(bytes4(sha3("observe()"))));
        walletLibrary.delegatecall(bytes4(sha3("basicWithdraw()")));
        nextWithdrawTime = nextWithdrawTime + withdrawCoolDownTime;
        return true;
    }

    function checkAllVote() private returns (bool) {
        for (uint i = 0; i < votes.length; i++) {
            if (!votes[i]) {
                return false;
            }
        }

        return true;
    }

    function clearVote() private {
        for (uint i = 0; i < votes.length; i++) {
            votes[i] = false;
        }
    }

    function addAuthorizedAccount(uint votePosition, address proposal) onlyAuthorized external {
        require(votePosition < authorizedUsers.length);
        require(msg.sender == authorizedUsers[votePosition]);
        if (proposal != proposedAAA) {
            clearVote();
            proposedAAA = proposal;
        }

        votes[votePosition] = true;
        if (checkAllVote()) {
            additionalAuthorizedContract = proposedAAA;
            clearVote();
        }
    }

    function resolve() onlyOwner {
        walletLibrary.delegatecall(bytes4(sha3("resolve()")));
    }

    function initilizeVault() onlyOnce {
        lastUpdated = now;
        owner = msg.sender;
    }
}