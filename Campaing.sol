pragma solidity ^0.4.17;

contract CampaingFactory {
    address[] public deployedCampaings;
    function createCampaing(uint minimum) public {
        address newCampaing = new Campaing(minimum, msg.sender);
        deployedCampaings.push(newCampaing);
    } 
    function getDeployedCampaings() public view returns (address[]) {
        return deployedCampaings;
    }
}

contract Campaing {
    
    struct Request {
        string description;
        uint value;
        address recipent;
        bool complete;
        uint approvalCount;
        mapping(address => bool) approvals;
    }
    Request[] public requests;
    address public manager;
    uint public minimumContribution;
    uint public approversCount;
    mapping(address => bool) public approvers;
    
    modifier restricted() {
        require(msg.sender == manager);
        _;
    }
    
    function Campaing(uint minimum, address creator) public {
        manager = creator;
        minimumContribution = minimum;
    }
    
    function contribute() public payable {
        require(msg.value>minimumContribution);
        approvers[msg.sender] = true;
        approversCount++;
    }
    
    function createRequest(string desc, uint val, address rec) 
        public restricted {
            Request memory newRequest = Request({
                description : desc,
                value : val,
                recipent : rec,
                complete : false,
                approvalCount : 0
            });
            
            requests.push(newRequest);
    }
    
    function approveRequest(uint index) public {
        
        Request storage request = requests[index];
        
        require(approvers[msg.sender]);
        require(!request.approvals[msg.sender]);
        
        request.approvals[msg.sender] = true;
        request.approvalCount++;
        
    }
    
    function finalizeReqest(uint index) public restricted {
        Request storage req = requests[index];
        
        require(!req.complete);        
        require(req.approvalCount > (approversCount/2)); 
        
        req.recipent.transfer(req.value);
        req.complete = true;
        
        
        
    }
    
    
}
