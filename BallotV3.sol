pragma solidity =0.6.0;
contract BallotV3{
  
  struct Voter{
    uint weight;
    bool voted;
    uint vote;
  }
  struct Proposal{
    uint voteCount;
  }
  
  address chairperson;
  mapping(address => Voter) voters;
  Proposal[] proposals;
  
  enum Phase {Init, Regs, Vote, Done}
  
  Phase public state = Phase.Init;
  
  //수정자
  modifier validPhase(Phase reqPhase){
    require(state == reqPhase); //검증
    _;
  }
  
  constructor (uint numProposals) public{
    chairperson = msg.sender;
    voters[chairperson].weight = 2;
    for (uint prop = 0; prop < numProposals; prop++){
      proposals.push(Proposal(0));
    }
    state = Phase.Regs;//Regs로 변경
   
  }
  
  function changeState(Phase x) public {
    if (msg.sender!= chairperson) revert();
    if (x < state) revert();
    state = x;
  }
  
  function register(address voter) public validPhase(Phase.Regs){
    if(msg.sender != chairperson || voters[voter].voted) revert();
    voters[voter].weight=1;
    voters[voter].voted=false;
  }
  
  function vote(uint toProposal) public validPhase(Phase.Vote) {
  
    Voter memory sender = voters[msg.sender];
    if(sender.voted ||toProposal >= proposals.length) revert();
    sender.voted = true;
    sender.vote = toProposal;
    proposals[toProposal].voteCount += sender.weight;
  }
  
  function reqWinner() public validPhase(Phase.Done) view returns (uint winningProposal){
  
    uint winningVoteCount = 0;
      for (uint prop = 0; prop < proposals.length; prop++){
        if (proposals[prop].voteCount > winningVoteCount){
          winningVoteCount = proposals[prop].voteCount;
          winningProposal = prop;
        }
  }
  
}
