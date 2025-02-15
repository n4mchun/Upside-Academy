// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract EIP712 {
    bytes32 private constant TYPE_HASH = 
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    
    bytes32 private immutable _cachedDomainSeparator;
    uint256 private immutable _cachedChainId;
    address private immutable _cachedThis;

    bytes32 private immutable _hashedName;
    bytes32 private immutable _hashedVersion;

    string private _name;
    string private _version;

    string private _nameFallback;
    string private _versionFallback;


    constructor(string memory name, string memory version) {
        _name = name;
        _version = version;
        _hashedName = keccak256(bytes(name));
        _hashedVersion = keccak256(bytes(version));

        _cachedChainId = block.chainid;
        _cachedDomainSeparator = _buildDomainSeparator();
        _cachedThis = address(this);
    }


    // ========================== Getter Function for Test ==========================


    /**
     * (ERC20-2.t.sol의 테스트 함수에서 _hashTypedDataV4()함수를 '_toTypedDataHash'라는 이름으로 호출한다.)
     */
    function _toTypedDataHash(bytes32 structHash) public view returns (bytes32) {
        return _hashTypedDataV4(structHash);
    }


    // ========================== Private Getter Functions ==========================


    /**
     * 현재 address와 chainid를 캐시 데이터들과 비교하여 동일하면 캐시 domain separator를 반환,
     * 다르다면 새로운 domain separator를 만들어 반환하는 함수
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _cachedThis && block.chainid == _cachedChainId) {
            return _cachedDomainSeparator;
        } else {
            return _buildDomainSeparator();
        }
    }

    /**
     * structHash를 domain separator와 함께 해싱하여 반환하는 함수. 
     * 이 때 \x19\x01은 EIP-712 형식임을 나타내기 위해 사용하며 \x19는 이더리움 서명의 시작을, \x01은 EIP-712의 버전을 나타냄
     */
    function _hashTypedDataV4(bytes32 structHash) internal view returns (bytes32) {
        return keccak256(
            abi.encodePacked(
                "\x19\x01",
                _domainSeparatorV4(), 
                structHash
            )
        );
    }

    /**
     * 현재 address와 chainid에 맞는 domain separator를 반환하는 함수
     */
    function _buildDomainSeparator() private view returns (bytes32) {
        return keccak256(abi.encode(TYPE_HASH, _hashedName, _hashedVersion, block.chainid, address(this)));
    }
}