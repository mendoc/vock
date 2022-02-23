// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Vock {

    struct Vote {
        address electeur;
        uint candidat;
        uint election;
    }

    Vote[] private votes;

    function voter(uint _election, uint _candidat) public {
        require(getVote(_election) == 0, "Ce compte a deja vote");
        votes.push(Vote({
            electeur: msg.sender,
            candidat: _candidat,
            election: _election
        }));
    }

    function totalVotes(uint _election) public view returns (uint nbre) {
        for (uint i = 0; i < votes.length; i++) {
            if (votes[i].election == _election) 
                nbre++;
        }
    }

    function getVote(uint _election) public view returns (uint) {
        for (uint i = 0; i < votes.length; i++) {
            if (votes[i].election == _election && votes[i].electeur == msg.sender) 
                return votes[i].candidat;
        }
        return 0;
    }

    function nbreVotes(uint _election, uint _candidat) public view returns (uint nbre) {
        for (uint i = 0; i < votes.length; i++) {
            if (votes[i].election == _election && votes[i].candidat == _candidat) 
                nbre++;
        }
    }
}