// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS
    }


    // ========================== Errors ==========================


    // 서명 시그니처가 잘못된 경우 에러 처리
    error ECDSAInvalidSignature();

    // 서명 시그니처의 길이가 올바르지 않을 경우 에러 처리
    error ECDSAInvalidSignatureLength(uint256 length);

    // 서명 값 중 s가 잘못된 경우 에러 처리
    error ECDSAInvalidSignatureS(bytes32 s);


    // ========================== Internal Functions ==========================


    /**
     * 서명자 복구를 하는 함수이며 _throwError() 함수를 호출하여 반환받은 에러를 처리한다. 
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, v, r, s);
        _throwError(error, errorArg);
        return recovered;
    }


    /**
     * solidity의 내장함수인 ecrecover() 함수를 호출하여 서명자를 복구하는 함수
     */
    function tryRecover(
        bytes32 hash, 
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) internal pure returns (address recovered, RecoverError err, bytes32 errArg) {
        // s값이 잘못되었는지 확인. 만약 s가 n/2보다 큰 값이라면 InvalidSignatureS를 에러로 반환
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS, s);
        }

        address signer = ecrecover(hash, v, r, s);
        // ecrecover() 함수에서 서명값이 잘못되었다면 0을 반환한다. 따라서 signer가 0이라면 InvalidSignature를 에러로 반환
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature, bytes32(0));
        }

        // 서명이 올바르다면 에러 없이 반환한다.
        return (signer, RecoverError.NoError, bytes32(0));
    }


    /**
     * 전달받은 값에 맞는 에러와 함께 revert하는 함수
     */
    function _throwError(RecoverError error, bytes32 errorArg) private pure {
        // NoError인 경우 아무것도 하지 않음
        if (error == RecoverError.NoError) {
            return;
        } else if (error == RecoverError.InvalidSignature) {
            revert ECDSAInvalidSignature();
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert ECDSAInvalidSignatureLength(uint256(errorArg));
        } else if (error == RecoverError.InvalidSignatureS) {
            revert ECDSAInvalidSignatureS(errorArg);
        }
    }
}