// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract NonProfitDonationTracker {
    address public owner;
    mapping(address => bool) public trustees;
    uint256 public totalDonations;
    uint256 public requiredApprovals;

    struct WithdrawalRequest {
        address recipient;
        uint256 amount;
        uint256 approvals;
        bool executed;
        mapping(address => bool) approvedBy;
    }

    WithdrawalRequest[] public withdrawalRequests;


    constructor(uint256 _requiredApprovals) {
        owner = msg.sender;
        trustees[msg.sender] = true;
        requiredApprovals = _requiredApprovals;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Na Only owner fit do this one na");
        _;
    }

    modifier onlyTrustee() {
        require(trustees[msg.sender], "Na Only Trustee fit do this one na");
        _;
    }

    function addTrustee(address _trusteeAddress) public onlyOwner {
        trustees[_trusteeAddress] = true;
      
    }


    function donate() external payable {
        require(msg.sender != address(0), "Address Zero not allowed");
        require(msg.value > 0, "Donation must be greater than zero");

        totalDonations += msg.value;
      
    }

    function requestWithdrawal(uint256 _requestedAmount) external {
        uint256 amount = _requestedAmount * 1 ether;
        require(amount > 0, "Requested amount must be greater than zero");
        require(amount <= address(this).balance, "Insufficient contract balance");

        WithdrawalRequest storage newRequest = withdrawalRequests.push();
        newRequest.recipient = msg.sender;
        newRequest.amount = amount;
        newRequest.approvals = 0;
        newRequest.executed = false;

     
    }

    function approveWithdrawal(uint256 _requestId) external onlyTrustee {
        WithdrawalRequest storage request = withdrawalRequests[_requestId];
        require(!request.executed, "themem don send am him money na");
        require(!request.approvedBy[msg.sender], "Already approved");

        request.approvals++;
        request.approvedBy[msg.sender] = true;
      
 
        if (request.approvals >= requiredApprovals && !request.executed) {
            executeWithdrawal(_requestId);
        }
        
      
    }

    function executeWithdrawal(uint256 _requestId) internal {
        WithdrawalRequest storage request = withdrawalRequests[_requestId];
        require(!request.executed, "them don send him money na");
        require(request.approvals >= requiredApprovals, "Not enough approvals");

        request.executed = true;
        payable(request.recipient).transfer(request.amount);

    }

    receive() external payable {}
    fallback() external payable {}
}
