// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


contract ProposalContract {

    uint voteLimit; //Reveals owners allowable max votes
    address public owner;
    address[] Voters; //Stores voters address

    struct Proposal {
        string title;
        string description; // Description of the proposal
        uint256 approve; // Number of approve votes
        uint256 reject; // Number of reject votes
        uint256 pass; // Number of pass votes
        uint256 total_vote_to_end; // When the total votes in the proposal reaches this limit, proposal ends
        bool current_state; // This shows the current state of the proposal, meaning whether if passes of fails
        bool is_active; // This shows if others can vote to our contract
        uint currentProposalID;
    
    }

    Proposal proposal;

    mapping(uint256 => Proposal) proposal_history; // Recordings of previous proposals
    mapping(string title => Proposal) findProposalByTitle;
    


    //The rest of this code is the task.
    
    constructor ( uint lastProposalID , uint _voteLimit, string memory _title, string memory _description ) {
        owner = msg.sender;
        proposal.currentProposalID = lastProposalID + 1;
        proposal.is_active = true;
        proposal.title = _title;
        proposal.description = _description;
        voteLimit = _voteLimit;
    }

    //Makes sure voting limit reached before ending vote
    modifier maxVote { 
        require(proposal.total_vote_to_end >= voteLimit, "Maximum votes not yet reached.");
        _;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only owner authorized to call this.");
        _;
    }

    // Prevents double voting
    modifier Voted {
        uint i;  // Declare `i`
        for (i = 0; i < Voters.length; i++) {
            if (msg.sender == Voters[i]) {
                revert("You've already voted pal!");
            }
        }
        Voters.push(msg.sender);  // Add voter to the list
        _;
    }

    //Sets state of proposal to allow votes or not.
    modifier votingAllowed() {
        require(proposal.is_active, "Voting has ended.");
        _;
    }

    //Vote to approve proposal
    function approveVote() public Voted votingAllowed{
        proposal.approve += 1;
        proposal.total_vote_to_end ++;
        
    }

    //Vote to reject proposal
     function rejectVote() public Voted votingAllowed{
        proposal.reject += 1;
        proposal.total_vote_to_end ++;
        
    }

    //Vote to pass vote
     function passVote () public Voted votingAllowed{
        proposal.pass += 1;
        proposal.total_vote_to_end ++;
        
    }

    //For owner to end vote
    function endVote() public onlyOwner maxVote {
        proposal.is_active = false;
    }

    //Reveals vote limit
    function getVoteLimit () public view returns(uint) {
        return voteLimit;
    }

    //Reveals number of approved votes
    function getApprovedVoteCounts() public view returns(uint) {
        return proposal.approve;
    }

    // Reveals number of Passed votes
    function getPassedVoteCounts() public view returns(uint) {
        return proposal.pass;
    }

    //reveals number of rejected votes
    function getRejectedVoteCounts() public view returns(uint) {
        return proposal.reject;
    }

}