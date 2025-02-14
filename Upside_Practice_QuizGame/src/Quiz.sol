// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Quiz{
    struct Quiz_item {
        uint id;
        string question;
        string answer;
        uint min_bet;
        uint max_bet;
    }
    
    mapping(address => uint256)[] public bets;
    uint public vault_balance;

    mapping(uint => address) public winners;
    mapping(uint => Quiz_item) public quiz;
    uint public quizNum;

    constructor () {
        Quiz_item memory q;
        q.id = 1;
        q.question = "1+1=?";
        q.answer = "2";
        q.min_bet = 1 ether;
        q.max_bet = 2 ether;
        addQuiz(q);
    }

    function addQuiz(Quiz_item memory q) public {
        require(msg.sender != address(1), "address(1) is not allowed");

        quiz[quizNum++] = Quiz_item({
            id: q.id,
            question: q.question,
            answer: q.answer,
            min_bet: q.min_bet,
            max_bet: q.max_bet
        });

        bets.push();
    }

    function getAnswer(uint quizId) public view returns (string memory) {
        return quiz[quizId - 1].answer;
    }

    function getQuiz(uint quizId) public view returns (Quiz_item memory) {
        Quiz_item memory q = quiz[quizId - 1];
        q.answer = "";
        return q;
    }

    function getQuizNum() public view returns (uint) {
        return quizNum;
    }
    
    function betToPlay(uint quizId) public payable {
        Quiz_item memory q = quiz[quizId - 1];

        require(msg.value >= q.min_bet && msg.value <= q.max_bet);

        bets[quizId - 1][msg.sender] += msg.value;
    }

    function solveQuiz(uint quizId, string memory ans) public returns (bool) {
        require(winners[quizId - 1] == address(0));

        Quiz_item memory q = quiz[quizId - 1];

        vault_balance += bets[quizId - 1][msg.sender];
        bets[quizId - 1][msg.sender] = 0;

        if (keccak256(abi.encodePacked(q.answer)) == keccak256(abi.encodePacked(ans))) {
            winners[quizId - 1] = msg.sender;
            return true;
        }
        return false;
    }

    function claim() public {
        require(msg.sender == winners[quizNum - 1]);

        uint amount = quiz[quizNum - 1].min_bet * 2;
        vault_balance -= amount;

        (bool result, ) = payable(msg.sender).call{value: amount}("");
        require(result);
    }

    receive() external payable {
        vault_balance += msg.value;
    }
}