// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

/** 
 * @title Vock
 * @dev Implémente le mecanisme de vote
 */
contract Vock {

    // nbreVotes : pour stocker les votes pour un candidat donné 
    mapping(uint => uint) public nbreVotes;

    // totalVotes : pour stocker le nombre de votes pour une élection donnée
    mapping(uint => uint) public totalVotes;

    // votes : pour stocker les votes des électeurs
    mapping(uint => mapping(address => uint)) private votes;

    /**
     * @dev Enregistre le vote d'un électeur.
     * @param _election l'identifiant de l'élection où se trouve le candidat
     * @param _candidat l'identifiant du candat dans l'élection
     */
    function voter(uint _election, uint _candidat) public {
        require(getVote(_election) == 0, "Ce compte a deja vote");
        votes[_election][msg.sender] = _candidat;
        nbreVotes[_candidat] += 1;
        totalVotes[_election] += 1;
    }

    /** 
     * @dev Récupérer le vote d'un électeur en fournissant l'identifiant de l'élection
     * @param _election l'identifiant de l'élection
     * @return l'identifiant du candidat voté
     */
    function getVote(uint _election) public view returns (uint) {
        return votes[_election][msg.sender];
    }
}
