// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Pausable {
    address private _owner;
    bool private _paused;

    constructor() {
        _owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == _owner, "Caller is not the owner");
        _;
    }

    modifier whenNotPaused {
        require(!_paused, "Contract is already paused");
        _;
    }

    
    function pause() public onlyOwner whenNotPaused {
        _paused = true;
    }
}