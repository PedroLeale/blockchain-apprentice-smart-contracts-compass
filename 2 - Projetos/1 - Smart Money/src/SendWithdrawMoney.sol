// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract SendWithdrawMoney {

    mapping(address => uint) public balanceReceived;

    function deposit() public payable {
        require(msg.value > 0, "You need to send some Ether");
        balanceReceived[msg.sender] += msg.value;
    }

    function getContractBalance() public view returns(uint) {
        return address(this).balance;
    }

    function getAddressBalance() public view returns(uint) {
        return balanceReceived[msg.sender];
    }

    function withdrawAll() public {
        address payable to = payable(msg.sender);
        to.transfer(balanceReceived[msg.sender]);
        balanceReceived[msg.sender] = 0;
    }

    function withdrawAllToAddress(address payable to) public {
        to.transfer(balanceReceived[msg.sender]);
        balanceReceived[msg.sender] = 0;
    }

    function withdraw(uint amount) public {
        require(amount <= balanceReceived[msg.sender], "Not enough funds");
        balanceReceived[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }

    function withdrawToAddress(uint amount, address payable to) public {
        require(amount <= balanceReceived[msg.sender], "Not enough funds");
        balanceReceived[msg.sender] -= amount;
        to.transfer(amount);
    }
}