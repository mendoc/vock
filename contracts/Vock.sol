// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

/** 
 * @title Vock
 * @dev Implémente le mecanisme de vote
 */
contract Vock {

    // Différents statuts d'une élection
    enum Statut {
        Initial,  // L'élection est consiérée comme inexistante
        Cree,     // Quand quelqu'un crée une élection. Enregistrement des candidat
        EnCours,  // Lorsque l'élection est lancée. Il n'est plus possible d'enregistrer des candidats
        Termine   // Lorsque l'émection est terminée. Plus personne ne peut voter.
    }

    // La structure représentant une élection
    struct Election {
        uint totalVotes;                     // Nombre total de vote pour cette élection
        Statut statut;                       // Statut de l'élection. Par défaut c'est Initial
        address auteur;                      // Celui qui a créé l'élection
        mapping(address => uint) votes;      // Tous les votes pour cette élection
        mapping(uint => Candidat) candidats; // Liste des candidats pour cette élection
    }

    // La structure représentant un candidat
    struct Candidat {
        string nom;      // Le nom du candidat
        uint nbreVotes;  // Le nombre de personnes ayant votés pour lui
        bool enregistre; // Pour savoir s'il est enregistré pour l'élection
    }

    // Un modifier pour vérifier si l'élection est en cours
    modifier electionEnCours(uint _idElec) {
        require(elections[_idElec].statut == Statut.EnCours, "Cette election n'est pas en cours");
        _;
    }

    // Un modifier pour vérifier si l'adresse correspond à celle de l'auteur de l'élection
    modifier auteurSeulement(uint _idElec) {
        require(elections[_idElec].auteur == msg.sender, "Vous n'etes pas l'auteur de cette election");
        _;
    }

    // elections : pour stocker les élections
    mapping(uint => Election) private elections;

    /**
     * @dev Enregistre le vote d'un électeur.
     * @param _idElec l'identifiant de l'élection où se trouve le candidat
     * @param _idCand l'identifiant du candidat dans l'élection
     */
    function voter(uint _idElec, uint _idCand) electionEnCours(_idElec) public {
        require(elections[_idElec].votes[msg.sender] == 0, "Ce compte a deja vote");
        require(elections[_idElec].candidats[_idCand].enregistre == true, "Ce candidat n'est pas enregistre pour cette election");
        elections[_idElec].votes[msg.sender] = _idCand;
        elections[_idElec].candidats[_idCand].nbreVotes += 1;
        elections[_idElec].totalVotes += 1;
    }

    /** 
     * @dev Récupérer le vote d'un électeur en fournissant l'identifiant de l'élection
     * @param _idElec l'identifiant de l'élection
     * @return l'identifiant du candidat voté
     */
    function getVoteElecteur(uint _idElec) electionEnCours(_idElec) public view returns (uint)  {
        return elections[_idElec].votes[msg.sender];
    }

    function getNbreVotesCandidat(uint _idElec, uint _idCand) electionEnCours(_idElec) public view returns (uint) {
        require(elections[_idElec].candidats[_idCand].enregistre == false, "Un candidat avec cet identifiant est deja enregitre pour cette election");
        return elections[_idElec].candidats[_idCand].nbreVotes;
    }

    function creerElection(uint _idElec) public {
        require(elections[_idElec].statut == Statut.Initial, "Cette election n'est pas disponible pour la creation");
        elections[_idElec].statut = Statut.Cree;
        elections[_idElec].auteur = msg.sender;
    }

    function ajouterCandidat(uint _idElec, uint _idCand, string memory _nomCand) auteurSeulement(_idElec) public {
        require(elections[_idElec].statut == Statut.Cree, "Pas possible d'enregistrer un candidat");
        require(elections[_idElec].candidats[_idCand].enregistre == false, "Un candidat avec cet identifiant est deja enregitre pour cette election");
        elections[_idElec].candidats[_idCand].nom = _nomCand;
        elections[_idElec].candidats[_idCand].enregistre = true;
        elections[_idElec].candidats[_idCand].nbreVotes = 0;
    }

    function lancerElection(uint _idElec) auteurSeulement(_idElec) public {
        require(elections[_idElec].statut == Statut.Cree, "Pas possible de lancer une election qui n'est pas creee");
        elections[_idElec].statut = Statut.EnCours;
        elections[_idElec].totalVotes = 0;
    }

    function terminerElection(uint _idElec) auteurSeulement(_idElec) public {
        require(elections[_idElec].statut == Statut.EnCours, "Pas possible de terminer une election qui n'est pas en cours");
        elections[_idElec].statut = Statut.Termine;
    }
}
