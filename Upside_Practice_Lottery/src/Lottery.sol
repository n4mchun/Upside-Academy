// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Lottery {
    uint16 public winningNumber = _getRandomNumber();
    uint256 claimPhase;

    struct LotteryItem {
        address[] buyers;
        uint256 deadline;
    }
    mapping(uint16 => LotteryItem) public lottery;
    mapping(address => uint16) purchasedNumber;

    modifier whenBeforeDeadline(uint16 number) {
        if(lottery[number].deadline != 0) require(block.timestamp < lottery[number].deadline);
        _;
    }

    modifier whenAfterDeadline {
        require(block.timestamp >= lottery[purchasedNumber[msg.sender]].deadline);
        _;
    }

    modifier whenAfterClaimPhase {
        require(block.timestamp >= claimPhase);
        _;
    }

    function buy(uint16 number) public payable whenBeforeDeadline(number) {
        require(msg.value == 0.1 ether);
        require(!_hasPurchased(number, msg.sender));

        lottery[number].buyers.push(msg.sender);
        if (lottery[number].deadline == 0) lottery[number].deadline = block.timestamp + 24 hours;
        purchasedNumber[msg.sender] = number;
    }

    function draw() public whenAfterDeadline whenAfterClaimPhase {
        winningNumber = _getRandomNumber();
        claimPhase = (claimPhase == 0) ? block.timestamp + 24 hours : claimPhase + 24 hours;
    }

    function claim() public whenAfterDeadline {
        uint16 number = purchasedNumber[msg.sender];
        require(_hasPurchased(number, msg.sender));

        if (number == winningNumber) {
            address[] memory winners = lottery[number].buyers;
            uint256 value = address(this).balance / winners.length;

            _removeBuyer(number, msg.sender);
    
            (bool success, ) = payable(msg.sender).call{value: value}("");
            require(success);
        }
    }

    function _removeBuyer(uint16 number, address target) private {
        uint256 length = lottery[number].buyers.length;
        for(uint256 i; i < length; i++) {
            if (lottery[number].buyers[i] == target) {
                lottery[number].buyers[i] = lottery[number].buyers[length - 1];
                lottery[number].buyers.pop();
                break;
            }
        }
    }

    function _hasPurchased(uint16 number, address addr) private view returns (bool) {
        for(uint256 i; i < lottery[number].buyers.length; i++) {
            if (lottery[number].buyers[i] == addr) return true;
        }
        return false;
    }

    function _getRandomNumber() private view returns (uint16) {
        return uint16(
            uint256(keccak256(abi.encode(
                "upsideLotteryService", 
                block.timestamp, 
                winningNumber
            ))) & 0xFFFF
        );
    }

    receive() external payable {}
}