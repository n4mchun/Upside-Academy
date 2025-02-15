// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Nonces} from "./Nonces.sol";
import {EIP712} from "./EIP712.sol";
import {ECDSA} from "./ECDSA.sol";

abstract contract Permit is EIP712, Nonces {
    // EIP-712 표준에서 서명된 메시지를 검증하는 데 사용하는 상수 해시값
    bytes32 private constant PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");


    constructor(string memory name) EIP712(name, "1") {}


    // ========================== Public Getter Functions ==========================

    /**
     * owner의 nonce를 반환하는 함수
     */
    function nonces(address owner) public view override returns (uint256) {
        return super.nonces(owner);
    }

    /**
     * domain separator의 값을 반환하는 함수
     */
    function DOMAIN_SEPARATOR() external view returns (bytes32) {
        return _domainSeparatorV4();
    }


    // ========================== Public Setter Functions ==========================


    /**
     * 서명을 통해 spender가 owner에게서 사용할 수 있는 토큰의 양을 설정하는 함수
     */
    function permit(
        address owner, 
        address spender, 
        uint256 amount, 
        uint256 deadline, 
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        // 서명의 데드라인이 지났는 지 확인
        require(block.timestamp <= deadline);

        // 서명에 필요한 값들을 모아 해시한다. 이 때 nonce의 값은 1 증가한다.
        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, amount, _useNonce(owner), deadline));

        // 서명 검증에 사용되는 형태로 해시를 변환한다.
        bytes32 hash = _hashTypedDataV4(structHash);

        // ECDSA의 서명자 복구 함수를 호출해 서명자를 반환받는다.
        address signer = ECDSA.recover(hash, v, r, s);

        // 서명자와 owner가 다를 경우 revert
        require(signer == owner, "INVALID_SIGNER");
    }
}