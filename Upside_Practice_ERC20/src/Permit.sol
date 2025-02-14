// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Permit {
    address private _owner;
    bytes32 private constant PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 private immutable DOMAIN_SEPARATOR = _buildDomainSeparator();

    mapping(address => uint256) public nonces;

    constructor() {
        _owner = msg.sender;
    }

    function permit(
        address owner, 
        address spender, 
        uint256 amount, 
        uint256 deadline, 
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public 
    virtual {
        require(block.timestamp <= deadline);

        bytes32 structHash = keccak256(abi.encode(
            PERMIT_TYPEHASH,
            owner,
            spender,
            amount,
            nonces[owner]++,
            deadline
        ));

        bytes32 hash = _toTypedDataHash(structHash);
        address signer = ecrecover(hash, v, r, s);

        require(signer == owner, "INVALID_SIGNER");
    }

    function _toTypedDataHash(bytes32 structHash) public view returns (bytes32) {
        return keccak256(abi.encode(
            "\x19\x01",
            DOMAIN_SEPARATOR,
            structHash
        ));
    }

    function _buildDomainSeparator() private view returns (bytes32) {
        return keccak256(
            abi.encode(
                keccak256("CUSTOM DOMAIN"),
                "ethan",
                "v4",
                block.chainid,
                address(this)
            )
        );
    }
}