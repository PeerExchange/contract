// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract PeerExchange {

    address private _owner;
    mapping(address => bool) _validOrgs;
    mapping(uint256 => address) _allOrgs;
    uint256 _totalOrgs;

    modifier onlyOwner() {
        require(msg.sender == _owner);
        _;
    }

    constructor() {
        _owner = msg.sender;
        _totalOrgs = 0;
    }

    function newOrg(address orgAddress) public onlyOwner {
        _validOrgs[orgAddress] = true;
        _allOrgs[_totalOrgs] = orgAddress;
        _totalOrgs += 1;
    }

    function totalOrgs() public view returns (uint256) {
        return _totalOrgs;
    }

    function getOrg(uint256 index) public view returns (address) {
        return _allOrgs[index];
    }
}