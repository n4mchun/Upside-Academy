// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Pausable {
    address private _owner;
    bool private _paused;

    constructor() {
        _owner = msg.sender;
    }


    // ========================== Modifiers ==========================


    modifier onlyOwner {
        require(msg.sender == _owner, "Caller is not the owner");
        _;
    }

    modifier whenNotPaused {
        require(!_paused, "Contract is already paused");
        _;
    }


    // ========================== Public Getter Functions ==========================


    function paused() public view virtual returns (bool) {
        return _paused;
    }

    // ========================== Public Setter Functions ==========================

    
    function pause() public onlyOwner whenNotPaused {
        _paused = true;
    }
}