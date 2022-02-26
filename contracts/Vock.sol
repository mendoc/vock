// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

/**
 * @title Vock
 * @dev Implémente le mecanisme de vote
 */
contract Vock {
    // Différents statuts d'une élection
    enum Statut {
        Initial, // L'élection est consiérée comme inexistante
        Cree, //    Quand quelqu'un crée une élection. Enregistrement des candidats
        EnCours, // Lorsque l'élection est lancée. Il n'est plus possible d'enregistrer des candidats
        Termine //  Lorsque l'élection est terminée. Plus personne ne peut voter.
    }

    // La structure représentant un candidat
    struct Candidat {
        string nom; //         Le nom du candidat
        uint256 nbreVotes; //  Le nombre de personnes ayant votés pour lui
        bool estEnregistre; // Pour savoir si le candidat est enregistré pour l'élection
    }

    // La structure représentant un électeur
    struct Electeur {
        bool peutVoter; //     Détermine si un électeur peut voter ou pas
        bool estEnregistre; // Pour savoir si l'électeur est enregistré pour l'élection
        uint256 vote; //       L'identifiant du candidat pour lequel il a voté
    }

    // La structure représentant une élection
    struct Election {
        uint256 totalVotes; //                     Nombre total de vote pour cette élection
        Statut statut; //                          Statut de l'élection. Par défaut c'est Initial
        address auteur; //                         Celui qui a créé l'élection
        mapping(address => Electeur) electeurs; // Tous les electeurs pour cette élection
        mapping(uint256 => Candidat) candidats; // Liste des candidats pour cette élection
    }

    // elections : pour stocker les élections
    mapping(uint256 => Election) private elections;

    // Un modifier pour vérifier si l'élection est en cours
    modifier electionEnCours(uint256 _idElec) {
        require(
            elections[_idElec].statut == Statut.EnCours,
            "Cette election n'est pas en cours"
        );
        _;
    }

    // Un modifier pour vérifier si l'élection est créée
    modifier electionCreee(uint256 _idElec) {
        require(
            elections[_idElec].statut == Statut.Cree,
            "Cette election n'est pas creee"
        );
        _;
    }

    // Un modifier pour vérifier si l'adresse correspond à celle de l'auteur de l'élection
    modifier auteurSeulement(uint256 _idElec) {
        require(
            elections[_idElec].auteur == msg.sender,
            "Vous n'etes pas l'auteur de cette election"
        );
        _;
    }

    /**
     * @dev Créer une élection.
     * @param _idElec l'identifiant de l'élection à créer
     */
    function creerElection(uint256 _idElec) public {
        require(
            elections[_idElec].statut == Statut.Initial,
            "Cette election n'est pas disponible pour la creation"
        );
        elections[_idElec].statut = Statut.Cree;
        elections[_idElec].auteur = msg.sender;
    }

    /**
     * @dev Enregistrer un électeur dans une élection.
     * @param _idElec l'identifiant de l'élection
     */
    function enregistrer(uint256 _idElec) electionCreee(_idElec) public {
        require(
            elections[_idElec].electeurs[msg.sender].estEnregistre == false,
            "Electeur deja enregistre"
        );
        elections[_idElec].electeurs[msg.sender].estEnregistre = true;
    }

    /**
     * @dev Autoriser un électeur à voter dans une élection.
     * @param _idElec l'identifiant de l'élection
     * @param _elect l'adresse de l'électeur
     */
    function autoriser(uint256 _idElec, address _elect)
        public
        electionCreee(_idElec)
        auteurSeulement(_idElec)
    {
        require(
            elections[_idElec].electeurs[_elect].estEnregistre == true,
            "Vous devez etre enregistre pour etre autorise"
        );
        require(
            elections[_idElec].electeurs[_elect].peutVoter == false,
            "Ce compte peut deja voter"
        );
        elections[_idElec].electeurs[_elect].peutVoter = true;
    }

    /**
     * @dev Ajouter un candidat sur la liste électorale.
     * @param _idElec l'identifiant de l'élection
     * @param _idCand l'identifiant du candidat
     * @param _nomCand le nom du candidat
     */
    function ajouterCandidat(
        uint256 _idElec,
        uint256 _idCand,
        string memory _nomCand
    ) public electionCreee(_idElec) auteurSeulement(_idElec) {
        require(
            elections[_idElec].candidats[_idCand].estEnregistre == false,
            "Un candidat avec cet identifiant est deja enregitre pour cette election"
        );
        elections[_idElec].candidats[_idCand].nom = _nomCand;
        elections[_idElec].candidats[_idCand].estEnregistre = true;
        elections[_idElec].candidats[_idCand].nbreVotes = 0;
    }

    /**
     * @dev Lancer une élection.
     * @param _idElec l'identifiant de l'élection
     */
    function lancerElection(uint256 _idElec) electionCreee(_idElec) auteurSeulement(_idElec) public{
        elections[_idElec].statut = Statut.EnCours;
        elections[_idElec].totalVotes = 0;
    }

    /**
     * @dev Enregistrer le vote d'un électeur.
     * @param _idElec l'identifiant de l'élection où se trouve le candidat
     * @param _idCand l'identifiant du candidat dans l'élection
     */
    function voter(uint256 _idElec, uint256 _idCand)
        public
        electionEnCours(_idElec)
    {
        require(
            elections[_idElec].electeurs[msg.sender].estEnregistre == true,
            "Vous devez etre enregistre a cette election pour voter"
        );
        require(
            elections[_idElec].electeurs[msg.sender].peutVoter == true,
            "Vous n'avez pas le droit de voter pour cette election"
        );
        require(
            elections[_idElec].electeurs[msg.sender].vote == 0,
            "Ce compte a deja vote"
        );
        require(
            elections[_idElec].candidats[_idCand].estEnregistre == true,
            "Ce candidat n'est pas enregistre pour cette election"
        );
        elections[_idElec].electeurs[msg.sender].vote = _idCand;
        elections[_idElec].candidats[_idCand].nbreVotes += 1;
        elections[_idElec].totalVotes += 1;
    }

    /**
     * @dev Récupérer le vote d'un électeur en fournissant l'identifiant de l'élection
     * @param _idElec l'identifiant de l'élection
     * @return l'identifiant du candidat voté
     */
    function getVoteElecteur(uint256 _idElec) public view returns (uint256) {
        require(
            elections[_idElec].statut == Statut.EnCours ||
                elections[_idElec].statut == Statut.Termine,
            "Vote non disponible"
        );
        return elections[_idElec].electeurs[msg.sender].vote;
    }

    /**
     * @dev Récupérer le nombre de votes d'un candidat
     * @param _idElec l'identifiant de l'élection
     * @param _idCand l'identifiant du candidat
     * @return le nombre de votes du candidat
     */
    function getNbreVotesCandidat(uint256 _idElec, uint256 _idCand)
        public
        view
        returns (uint256)
    {
        require(
            elections[_idElec].statut == Statut.Termine,
            "L'election n'est pas terminee"
        );
        require(
            elections[_idElec].candidats[_idCand].estEnregistre == true,
            "Ce candidat n'est pas enregitre pour cette election"
        );
        return elections[_idElec].candidats[_idCand].nbreVotes;
    }

    /**
     * @dev Terminer une élection.
     * @param _idElec l'identifiant de l'élection
     */
    function terminerElection(uint256 _idElec) public auteurSeulement(_idElec) {
        require(
            elections[_idElec].statut == Statut.EnCours,
            "Pas possible de terminer une election qui n'est pas en cours"
        );
        elections[_idElec].statut = Statut.Termine;
    }
}
