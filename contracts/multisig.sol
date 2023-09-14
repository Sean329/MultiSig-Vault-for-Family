// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/*
This is a Goerli copy of a simple but practical version of a Multi-Sig vault that my family (myWife and mySelf)
are using to send outgoing payments on Mainnet. Both people must sign to execute transactions so neigher of us can move the
money without the other's consent. We both are Smart Contract advocators so we CODIFY our daily decision making processes.

This Goerli copy is for the demo purposes for any Web3 job application if a demo is required.
*/

/* 
This Multi-Sig vault works with both ETH and ERC20 payments, coded with DeFi security practice (prevent reentry) as well as gas optimization tricks.

I also added a Dead Man's Switch functionality to the contract so that in the situation of:
    1. One of us is dead or doesn't care about this vault no more ------ the other one can withdraw the money after
        a 52 weeks cool down period
    2. Both of us are dead for over a year ------ the kid who inherited our PKs can withdraw the money

That being said, LONG LIVE myWife and mySelf plz!!
*/

contract MultiSig {
    address[] public owners;
    uint public required;
    uint public transactionCount;
    uint lastPing;


    struct Transaction {
        address destination;
        uint valueInWei;
        bool executed;
        bytes data;
    }

    mapping (uint => Transaction) public transactions;
    mapping (uint => mapping(address => bool)) public confirmations;

    constructor(address[] memory _owners, uint _required){
        require(_owners.length>0 && _required>0 && _required<=_owners.length);
        owners = _owners;
        required = _required;
        lastPing = block.timestamp;
    }

//  @dev Ping the contract to reset the Dead Man's Switch clock, do nothing else
    function ping() external {
        require(isOwner(msg.sender));
        lastPing = block.timestamp;
    }

    function addTransaction(address _destination, uint _valueInWei, bytes calldata _data) internal returns(uint) {
        transactions[transactionCount] = Transaction(_destination, _valueInWei, false, _data);
        
        return transactionCount++;
    }

    function isOwner(address _address) public view returns(bool){
        uint length = owners.length;

        for(uint i; i<length;) {
            if(owners[i] == _address){return true;}
            unchecked{++i;}
        }
        return false;
    }

//  @dev Has pinging effect
    function confirmTransaction(uint _id) public {
        require(isOwner(msg.sender));
        confirmations[_id][msg.sender] = true;

        if(isConfirmed(_id)) {
            executeTransaction(_id);
        }
        lastPing = block.timestamp;
    }

    function getConfirmationsCount(uint _id) public view returns(uint counter){
        uint length = owners.length;

        for(uint i; i<length;) {
            if(confirmations[_id][owners[i]] == true){
                ++counter;
            }
            unchecked{++i;}
        }
    }

     function isConfirmed(uint _id) public view returns(bool){
        return getConfirmationsCount(_id) >= required;
    }

//  @dev Has pinging effect
//       The _destination is the address of recipient of paying ETH; 
//       but is the ERC20 contract address when paying ERC20 and the actual recipient address is encoded into the _data
    function submitTransaction(address _destination, uint _valueInWei, bytes calldata _data) external {
        confirmTransaction(addTransaction(_destination, _valueInWei, _data));
    }

    function executeTransaction(uint _id) internal {
        require(isConfirmed(_id));

        require(transactions[_id].executed == false);

        transactions[_id].executed = true;
        (bool success, ) = transactions[_id].destination.call{value: transactions[_id].valueInWei}(transactions[_id].data);
        require(success);
    }

//  @dev Dead Man's Switch is on, can withdraw ETH, or ERC20 repeatly
//       The _destination is the address of recipient of paying ETH; 
//       but is the ERC20 contract address when paying ERC20 and the actual recipient address is encoded into the _data
    function withdraw(address _destination, uint _valueInWei, bytes calldata _data) external {
        require(isOwner(msg.sender));
        require(block.timestamp > lastPing + 52 weeks);

        (bool success, ) = _destination.call{value: _valueInWei}(_data);
        require(success);
    }

    fallback() external payable {}
    receive() external payable {}
}
