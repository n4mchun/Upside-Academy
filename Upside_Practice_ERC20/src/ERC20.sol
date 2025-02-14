// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Pausable.sol";
import "./Permit.sol";

contract ERC20 is Pausable, Permit {
    address private _owner;

    string private _name;
    string private _symbol;

    mapping(address owner => mapping(address spender => uint256)) private _allowance;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _owner = msg.sender;
    }

    function transfer(address to, uint256 amount) public whenNotPaused {

    }

    function approve(address to, uint256 amount) public {
        _approve(msg.sender, to, amount);
    }

    function transferFrom(address from, address to, uint256 amount) public whenNotPaused {

    }

    function permit(
        address owner, 
        address spender, 
        uint256 amount, 
        uint256 deadline, 
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public override {
        super.permit(owner, spender, amount, deadline, v, r, s);
        _approve(owner, spender, amount);
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowance[owner][spender];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowance[owner][spender] = amount;
    }
}