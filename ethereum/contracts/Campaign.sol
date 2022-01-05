//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Factory {
    Campaign[] public deployedCampaigns;

    function createCampaign(uint minimum) public {
        Campaign newCampaign = new Campaign(minimum, msg.sender);
        deployedCampaigns.push(newCampaign);
    }

    function getDeployedCampaigns() public view returns (Campaign[] memory){
        return deployedCampaigns;
    }
}

contract Campaign {
    struct Request {
        string description;
        uint value;
        address payable recipient;
        bool complete;
        uint approvalCount;
        mapping(address => bool) approvals;
    }

    uint numRequests;
    mapping (uint => Request) public requests;
    address public manager;
    uint public minimumContribution;
    mapping (address => bool) public approvers;
    uint public approversCount;

    modifier resricted() {
        require(msg.sender == manager);
        _;
    }

    constructor(uint minimum, address creator) {
        manager = creator;
        minimumContribution = minimum;
    }
  
    function contribute() public payable {
        require(msg.value > minimumContribution);

        approvers[msg.sender] = true;
        approversCount++;
    }

    function createRequest(string memory description, uint value, address payable recipient) public resricted {
        Request storage r = requests[numRequests++];
            r.description = description;
            r.value = value;
            r.recipient = recipient;
            r.complete = false;
            r.approvalCount = 0;
    }

    function approveRequest (uint index) public {
        Request storage request = requests[index];

        require(approvers[msg.sender], "Only contributors can approve a specific payment request");

        require(!request.approvals[msg.sender], "You have already voted to approve this request");

        request.approvals[msg.sender] = true;
        request.approvalCount++;
    }

    function finalizeRequest(uint index) public resricted {
        Request storage request = requests[index];

        require(request.approvalCount > (approversCount / 2));
        require(!request.complete);

        request.recipient.transfer(request.value);
        request.complete = true;
    }

    function getSummary()
        public
        view
        returns (
            uint,
            uint,
            uint,
            uint,
            address
        )
    {
        return (
            minimumContribution,
            address(this).balance,
            numRequests,
            approversCount,
            manager
        );
    }

    function getRequestsCount() public view returns (uint) {
        return numRequests;
    }
}