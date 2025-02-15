// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
* ERC20에서 발생되는 이벤트를 정의해둔 인터페이스
*/
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}