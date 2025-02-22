// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Pausable} from "./Pausable.sol";
import {Permit} from "./Permit.sol";
import {IERC20} from "./IERC20.sol";

contract ERC20 is IERC20, Pausable, Permit {
    // spender가 owner의 잔액에서 출금할 수 있는 토큰의 양
    mapping(address owner => mapping(address spender => uint256)) private _allowance;
    // account의 잔액
    mapping(address account => uint256) _balances;

    // 토큰의 총 공급량
    uint256 private _totalSupply;

    // 토큰의 이름
    string private _name;
    // 토큰의 심볼 (토큰 이름의 짧은 버전)
    string private _symbol;


    constructor(string memory name_, string memory symbol_) Permit(name_) {
        _name = name_;
        _symbol = symbol_;
        _mint(msg.sender, 1_000_000 * 10 ** decimals());
    }


    // ========================== Public Getter Functions ==========================


    /**
     * 토큰의 이름을 반환해주는 함수
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * 토큰의 심볼을 반환해주는 함수
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * 토큰이 사용하는 소수점 자리수를 반환해주는 함수
     */
    function decimals() public pure returns (uint8) {
        return 18;
    }

    /**
     * 토큰의 총 공급량을 반환해주는 함수
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * account의 잔액을 반환해주는 함수
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * spender가 owner의 잔액에서 출금할 수 있는 토큰의 양을 반환해주는 함수
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowance[owner][spender];
    }

    // ========================== Public Setter Functions ==========================


    /**
     * msg.sender가 to 주소에 value만큼 토큰을 전송하는 함수
     */
    function transfer(address to, uint256 value) public whenNotPaused {
        _transfer(msg.sender, to, value);
    }

    /**
     * msg.sender(spender)가 from에서 to 주소로 value만큼 토큰을 전송하는 함수
     */
    function transferFrom(address from, address to, uint256 value) public whenNotPaused {
        _spendAllowance(from, msg.sender, value);
        _transfer(from, to, value);
    }

    /**
     * msg.sender가 to 주소에게 자신의 토큰을 value만큼 사용할 수 있도록 허용해주는 함수
     */
    function approve(address to, uint256 value) public {
        _approve(msg.sender, to, value);
    }


    // ========================== Private Setter Functions ==========================


    /**
     * ERC20 컨트랙트의 토큰 상태 변수를 통합적으로 변경하는 함수
     * (mint, burn, transfer, transferFrom에서 사용됨)
     */
    function _update(address from, address to, uint256 value) private {
        // from 주소가 0이라면 == mint. 토큰의 공급량을 증가
        if (from == address(0)) {
            _totalSupply += value;
        } else { // 실제 account 주소라면 account의 잔액을 value만큼 차감한다
            uint256 fromBalance = _balances[from];
            // 이 때, from account의 잔액이 value 이상 있는 지 확인
            require(fromBalance >= value);

            unchecked {
                _balances[from] = fromBalance - value;
            }
        }

        // to 주소가 0이라면 == burn. 토큰의 공급량을 제거
        if (to == address(0)) {
            unchecked {
                _totalSupply -= value;
            }
        } else { // to 주소가 실제 주소라면 to 계정의 잔액을 value 만큼 증가
            unchecked {
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }


    /**
     * transfer, transferFrom 함수에서 내부적으로 호출하는 함수.
     */
    function _transfer(address from, address to, uint256 value) private {
        // 사용자의 입력으로부터 Mint, Burn 작업이 수행되는 것을 방지
        require(from != address(0) && to != address(0));
        _update(from, to, value);
    }

    /**
     * spender가 owner에게서 사용할 수 있는 토큰의 양을 value 값으로 저장하는 함수
     */
    function _approve(address owner, address spender, uint256 value) private {
        _allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    /**
     * spender가 owner에게서 사용할 수 있는 토큰의 양을 value만큼 뺀 후 저장하는 함수
     */
    function _spendAllowance(address owner, address spender, uint256 value) private {
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= value);

        unchecked {
            _approve(owner, spender, currentAllowance - value);
        }
    }


    /**
     * 토큰을 발행하는 함수 (토큰의 총 공급량이 증가)
     */
    function _mint(address account, uint256 value) internal {
        require(account != address(0), "Invalid Receiver");
        _update(address(0), account, value);
    }


    /**
     * 토큰의 공급량을 줄이는 함수
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "Invalid Sender");
        _update(account, address(0), value);
    }


    // ========================== Override Functions ==========================


    /**
     * 서명을 통해 spender가 owner에게서 사용할 수 있는 토큰의 양을 설정하는 함수
     */
    function permit(
        address owner, 
        address spender, 
        uint256 value, 
        uint256 deadline, 
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public override {
        super.permit(owner, spender, value, deadline, v, r, s);
        _approve(owner, spender, value);
    }
}
