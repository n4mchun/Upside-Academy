// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

abstract contract Nonces {
    mapping(address account => uint256) private _nonces;

    // ========================== Public Getter Functions ==========================


    /**
     * owner의 nonce값을 반환하는 함수
     */
    function nonces(address owner) public view virtual returns (uint256) {
        return _nonces[owner];
    }

    // ========================== Internal Setter Functions ==========================


    /**
     * permit() 함수에서 호출되며 호출될 때마다 owner의 nonce 값을 1씩 더하는 함수
     */
    function _useNonce(address owner) internal virtual returns (uint256) {
        unchecked {
            return _nonces[owner]++;
        }
    }
}