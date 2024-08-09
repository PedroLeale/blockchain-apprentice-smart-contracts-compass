// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/SendWithdrawMoney.sol";

contract SendWithdrawMoneyTest is Test {
    SendWithdrawMoney contractInstance;
    address[3] addresses = [address(0x2), address(0x3), address(0x4)];

    function setUp() public {
        contractInstance = new SendWithdrawMoney();
        for (uint i = 0; i < 3; i++) {
            vm.deal(addresses[i], 100 ether);
        }
    }

    function testDeposit() public {
        vm.prank(addresses[0]);
        contractInstance.deposit{value: 5 ether}();
        assertEq(contractInstance.getContractBalance(), uint(5 ether));

        vm.prank(addresses[1]);
        contractInstance.deposit{value: 10 ether}();
        assertEq(contractInstance.getContractBalance(), uint(15 ether));

        vm.startPrank(addresses[2]);
        contractInstance.deposit{value: 20 ether}();
        assertEq(contractInstance.getContractBalance(), uint(35 ether));
        assertEq(contractInstance.getAddressBalance(), uint(20 ether));
        vm.expectRevert("You need to send some Ether");
        contractInstance.deposit{value: 0}();
        vm.stopPrank();
    }

    function testWithdrawAll() public {
        vm.prank(addresses[0]);
        contractInstance.deposit{value: 5 ether}();
        vm.prank(addresses[1]);
        contractInstance.deposit{value: 10 ether}();
        vm.prank(addresses[2]);
        contractInstance.deposit{value: 20 ether}();

        assertEq(contractInstance.getContractBalance(), uint(35 ether));

        vm.prank(addresses[0]);
        contractInstance.withdrawAll();

        assertEq(contractInstance.getContractBalance(), uint(30 ether));
    }

    function testwithdrawAllToAddress() public {
        vm.prank(addresses[0]);
        contractInstance.deposit{value: 10 ether}();
        assertEq(contractInstance.getContractBalance(), uint(10 ether));

        vm.startPrank(addresses[1]);
        contractInstance.deposit{value: 5 ether}();
        contractInstance.withdrawAllToAddress(payable(addresses[2]));
        vm.stopPrank();

        assertEq(contractInstance.getContractBalance(), uint(10 ether));
        assertEq(addresses[2].balance, uint(105 ether));
    }

    function testWithdraw() public {
        vm.startPrank(addresses[0]);
        contractInstance.deposit{value: 10 ether}();
        assertEq(contractInstance.getAddressBalance(), uint(10 ether));
        vm.expectRevert("Not enough funds");
        contractInstance.withdraw(20 ether);
        vm.stopPrank();

        vm.startPrank(addresses[1]);
        contractInstance.deposit{value: 5 ether}();
        contractInstance.withdraw(3 ether);
        assertEq(contractInstance.getAddressBalance(), uint(2 ether));
        vm.stopPrank();
    }

    function testWithdrawToAddress() public {
        vm.startPrank(addresses[0]);
        contractInstance.deposit{value: 10 ether}();
        assertEq(contractInstance.getAddressBalance(), uint(10 ether));
        vm.expectRevert("Not enough funds");
        contractInstance.withdrawToAddress(20 ether, payable(addresses[1]));
        vm.stopPrank();

        vm.startPrank(addresses[1]);
        contractInstance.deposit{value: 5 ether}();
        contractInstance.withdrawToAddress(3 ether, payable(addresses[2]));
        assertEq(contractInstance.getAddressBalance(), uint(2 ether));
        assertEq(addresses[2].balance, uint(103 ether));
        vm.stopPrank();
    }

}
