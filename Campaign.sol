pragma solidity ^0.4.17;

contract Campaign {
    struct Request {
        string description;
        uint value;
        address recipient;
        bool complete;
        uint approvalCount;
        mapping(address=>bool) approvals;
    }
    
    Request[] public requests; 
    address public  manager;
    uint public  minimumContribution;
    mapping (address=>bool) public approvers;
    uint public approversCount;

    modifier restricted() {
        require(msg.sender==manager);
        _;
    }

    function Campaign(uint minimum) public {
        manager=msg.sender;
        minimumContribution= minimum;
        
    }

    function contribute() public payable {
        require(msg.value>=minimumContribution);
        approvers[msg.sender]=true;
        approversCount++;
    }

    function createRequest(string description,uint value, address recipient) public restricted {
        Request memory newRequest=Request({
            description: description,
            value:value,
            recipient:recipient,
            complete:false,
            approvalCount:0
        });

        requests.push(newRequest);

    }
    function approveRequest(uint index) public {
        Request storage request=requests[index];
        //We verify that the sender is an approvers 
        require(approvers[msg.sender]);
        //To verify that the person has not voted on this particular request 
        require(request.approvals[msg.sender]==false);
        request.approvals[msg.sender]=true;
        request.approvalCount++;
    }

    function finalizeRequest(uint index) public restricted {
        Request storage request=requests[index];
        require(request.approvalCount> (approversCount / 2));
        require(!request.complete);
        request.recipient.transfer(request.value);
        request.complete=true;


    }
}