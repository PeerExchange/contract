// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract PeerOrg {

    address private _owner;
    mapping(address => uint256) private _balances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    uint256 voteId;
    mapping(uint256 => Vote) private allVotes;
    mapping(uint256 => mapping(address => bool)) private voters;
    struct Vote {
        string option1;
        string option2;
        uint256 option1Count;
        uint256 option2Count;
        bool over;
    }

    bool transferrable;

    event NewUser(uint256 time, address user);
    event Withdraw(uint256 amount, string message);

    modifier onlyOwner() {
        require(msg.sender == _owner);
        _;
    }

    constructor(string memory name_, string memory symbol_, address owner_, bool transferrable_) {
        _owner = owner_;
        _name = name_;
        _symbol = symbol_;
        voteId = 0;
        transferrable = transferrable_;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    function isAdmin(address account) public view virtual returns (bool) {
        return _owner == account;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        require(transferrable);             //only if admin allows for transfers
        require(to != address(0));
        
        address from = msg.sender;
        require(_balances[from] >= amount);
        _balances[from] -= amount;
        _balances[to] += amount;
        return true;
    }

    function adminMint(address account, uint256 amount) public {
        _balances[account] += amount;
        _totalSupply += amount;                 //admin can give users tokens (volunteer work)
    }

    function userMint() public payable {
        require(msg.value > 0);
        if (_balances[msg.sender] == 0) {
            emit NewUser(block.timestamp, msg.sender);
        }
        _balances[msg.sender] += msg.value * 100;     //user gets the same number of tokens as they deposited in ETH * 100
        _totalSupply += msg.value * 100;
    }

    function adminWithdraw(address account, uint256 amount, string memory message) public {
        require(address(this).balance >= amount);
        payable(account).transfer(amount);
        emit Withdraw(amount, message);     //withdraw event can be tracked and then displayed to show every withdrawal
    }

    function getAddress() public view virtual returns (address) {
        return address(this);
    }

    function newVote(string memory option1_, string memory option2_) public {
        allVotes[voteId] = Vote(option1_, option2_, 0, 0, false);      //stores vote prospect
        voteId += 1;
    }

    function getVote(uint256 id_) public view virtual returns(Vote memory) {
        return allVotes[id_];
    }

    function vote(uint256 id_, bool option_) public {
        require(!voters[id_][msg.sender]);  //makes sure the user hasn't voted yet
        require(_balances[msg.sender] > 0); //makes sure the user can vote
        require(!allVotes[id_].over);       //makes sure user hasn't ended vote

        if (option_) {
            allVotes[id_].option1Count += _balances[msg.sender];    //true is in favor of option1
        } else {
            allVotes[id_].option2Count += _balances[msg.sender];    //false is in favor of option2
        }
        
        voters[id_][msg.sender] = true;     //prevents user from voting again
    }

    function getVoteId() public view virtual returns (uint256) {
        return voteId;
    }

    function endVote(uint256 id_) public {
        allVotes[id_].over = true;
    }
}