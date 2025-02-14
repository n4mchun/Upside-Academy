// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../lib/forge-std/src/Test.sol";
import "../src/ERC20.sol";

contract UpsideTokenTest is Test {
    address internal constant alice = address(1);
    address internal constant bob = address(2);

    ERC20 upside_token;

    function setUp() public {
        upside_token = new ERC20("UPSIDE", "UPS");
        upside_token.transfer(alice, 50 ether);
        upside_token.transfer(bob, 50 ether);
    }
    
    // 'testFail' prefix replaced by 'testNo'
    function testNoPauseNotOwner() public {
        vm.prank(alice);
        vm.expectRevert(); // testFail
        upside_token.pause();
    }

    function testNoTransfer() public {
        upside_token.pause();
        vm.prank(alice);
        vm.expectRevert(); // testFail
        upside_token.transfer(bob, 10 ether);
    }

    function testNoTransferFrom() public {
        upside_token.pause();
        vm.prank(alice);
        upside_token.approve(msg.sender, 10 ether);
        vm.expectRevert(); // testFail
        upside_token.transferFrom(alice, bob, 10 ether);
    }
}