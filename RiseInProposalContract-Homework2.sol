// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


contract ProposalContract {

    uint voteLimit; //Reveals owners allowable max votes
    address public owner;
    address[] Voters; //Stores voters address
    uint256 totalVotes;


    struct Proposal {
        string title;
        string description; // Description of the proposal
        uint256 approve; // Number of approve votes
        uint256 reject; // Number of reject votes
        uint256 total_vote_to_end; // When the total votes in the proposal reaches this limit, proposal ends
        bool is_active; // This shows if others can vote to our contract
    
    }

    Proposal proposal;


    //The rest of this code is the task.
    
    constructor ( uint _voteLimit, string memory _title, string memory _description ) {
        owner = msg.sender;
        Voters.push(msg.sender); //Prevents owner to vote. (Unless they trasnfer ownership)
        proposal.is_active = true;
        proposal.title = _title;
        proposal.description = _description;
        voteLimit = _voteLimit;
    }


    //Makes sure voting limit reached before ending vote
    modifier maxVote { 
        require(proposal.total_vote_to_end == voteLimit, "Maximum votes not yet reached.");
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
                revert("Already voted pal.");
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
    function approveVote() public Voted votingAllowed {
        proposal.approve += 1;
        proposal.total_vote_to_end ++;

           if (proposal.total_vote_to_end == voteLimit) {
            endVote(); // Automatically end vote if limit reached
        }
        
    }


    //Vote to reject proposal
     function rejectVote() public Voted votingAllowed{
        proposal.reject += 1;
        proposal.total_vote_to_end ++;

        if (proposal.total_vote_to_end == voteLimit) {
            endVote(); // Automatically end vote if limit reached
        }
        
    }


    /*
    Automatically ends vote when
    proposal.total_vote_to_end == voteLimit
    callable by approve and reject vote functions
    */
    function endVote() private  {
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


    //reveals number of rejected votes
    function getRejectedVoteCounts() public view returns(uint) {
        return proposal.reject;
    }


    // Added this to get total number of voters / votes.
    function getTotalVotes() external view returns (uint) {
        uint256 total_vote = proposal.approve + proposal.reject;
        return total_vote;
    }

    /* Will retrieve whether a given address has voted or not.
    Owner will return true since they were pushed to Voters[].
    Drwback: Owner must watch close so total don't
    */
    function votedOrNot (address _address) public view returns (bool) {
        for (uint i = 0; i < Voters.length; i++) {
            if (Voters[i] == _address) {
                return true;
            }
        }
        return false;
    }

    /// true = approve votes > reject votes
    function voteOutcome() external view returns(bool) {
        if (proposal.approve > proposal.reject) {
            return true;
        } else {
            return false;
        }
    }


    /* Function to transfer ownership of contract
    The Voted modifier is to check if the address has voted already.
    If yes, transfer of ownership not possible.
    If no, address is added to Voters[] to prevent theri voting.
    */ 
    function transferOwnership(address _newOwner) external onlyOwner {
        owner = _newOwner;
        uint i;  // Declare `i`
        for (i = 0; i < Voters.length; i++) {
            if (msg.sender == Voters[i]) {
                delete Voters[i]; // Remove msg.sender directly;
            }
            if (owner == Voters[i]) {
                revert("Voters cannot own this proposal.");
            }
        }
        Voters.push(owner);  // Add owner to the list
        
    }

    
}


