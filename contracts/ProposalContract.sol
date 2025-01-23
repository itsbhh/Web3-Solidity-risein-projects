// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract ProposalContract {
    address public owner;
    uint256 public proposalCount;

    struct Proposal {
        string title; // Title of the proposal
        string description; // Description of the proposal
        uint256 approve; // Number of approve votes
        uint256 reject; // Number of reject votes
        uint256 pass; // Number of pass votes
        uint256 total_vote_to_end; // When the total votes in the proposal reaches this limit, proposal ends
        bool current_state; // This shows the current state of the proposal, meaning whether it passes or fails
        bool is_active; // This shows if others can vote to our contract
    }

    mapping(uint256 => Proposal) public proposal_history; // Recordings of previous proposals

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can create proposals");
        _;
    }

    modifier onlyActive(uint256 proposalId) {
        require(proposal_history[proposalId].is_active, "Proposal is not active");
        _;
    }

    constructor() {
        owner = msg.sender;
        proposalCount = 0;
    }

    function createProposal(string memory title, string memory description, uint256 voteLimit) external onlyOwner {
        proposal_history[proposalCount] = Proposal({
            title: title,
            description: description,
            approve: 0,
            reject: 0,
            pass: 0,
            total_vote_to_end: voteLimit,
            current_state: false,
            is_active: true
        });
        proposalCount++;
    }

    function voteApprove(uint256 proposalId) external onlyActive(proposalId) {
        proposal_history[proposalId].approve++;
        checkProposalState(proposalId);
    }

    function voteReject(uint256 proposalId) external onlyActive(proposalId) {
        proposal_history[proposalId].reject++;
        checkProposalState(proposalId);
    }

    function votePass(uint256 proposalId) external onlyActive(proposalId) {
        proposal_history[proposalId].pass++;
        checkProposalState(proposalId);
    }

    function checkProposalState(uint256 proposalId) internal {
        Proposal storage proposal = proposal_history[proposalId];
        if (proposal.approve + proposal.reject + proposal.pass >= proposal.total_vote_to_end) {
            proposal.is_active = false;
            proposal.current_state = proposal.approve > proposal.reject; // Passes if approve votes are greater than reject votes
        }
    }

    function getProposal(uint256 proposalId) external view returns (string memory, string memory, uint256, uint256, uint256, bool, bool) {
        Proposal storage proposal = proposal_history[proposalId];
        return (
            proposal.title,
            proposal.description,
            proposal.approve,
            proposal.reject,
            proposal.pass,
            proposal.current_state,
            proposal.is_active
        );
    }
}