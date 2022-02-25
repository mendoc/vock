const Vock = artifacts.require("Vock");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("Vock", async function ([auteur, compte, electeur, autreElecteur]) {

  const _idElec = Math.floor(Math.random() * 100) + 1;
  const _idCand = 5;
  const nomCandidat = "Candidat 1";

  function getReason(err) {
    //console.log(err)
    return err.data[Object.keys(err.data)[0]].reason;
  }

  it("Interdire la récupération du nombre de votes si l'élection n'existe pas", async function () {
    const vock = await Vock.deployed();
    await vock.getNbreVotesCandidat(_idElec, _idCand).catch((err) => {
      return assert.isTrue(getReason(err) === "Cette election n'est pas en cours");
    });
  });

  it("Ne pas de récupérer de vote si l'élection n'est pas en cours", async function () {
    const vock = await Vock.deployed();
    await vock.getVoteElecteur(_idElec).catch((err) => {
      return assert.isTrue(getReason(err) === "Cette election n'est pas en cours");
    });
  });

  it("Ne pas ajouter de candidat si on n'est pas l'auteur de l'élection", async function () {
    const vock = await Vock.deployed();
    await vock.ajouterCandidat(_idElec, _idCand, nomCandidat, { from: compte }).catch((err) => {
      return assert.isTrue(getReason(err) === "Vous n'etes pas l'auteur de cette election");
    });
  });

  it("Ne pas lancer une élection dont on est pas l'auteur", async function () {
    const vock = await Vock.deployed();
    await vock.lancerElection(_idElec, { from: compte }).catch((err) => {
      return assert.isTrue(getReason(err) === "Vous n'etes pas l'auteur de cette election");
    });
  });

  it("Ne pas voter pour une élection qui n'est pas encore en cours", async function () {
    const vock = await Vock.deployed();
    await vock.voter(_idElec, _idCand, { from: electeur }).catch((err) => {
      return assert.isTrue(getReason(err) === "Cette election n'est pas en cours");
    });
  });

  // Création d'une élection

  it("Ne pas voter pendant la phase d'ajout des candidats", async function () {
    const vock = await Vock.deployed();
    console.log("        | Création de l'élection ...")
    await vock.creerElection(_idElec, { from: auteur });
    await vock.voter(_idElec, _idCand, { from: electeur }).catch((err) => {
      return assert.isTrue(getReason(err) === "Cette election n'est pas en cours");
    });

    console.log("        | Ajout d'un candidat ...")
    await vock.ajouterCandidat(_idElec, _idCand, nomCandidat, { from: auteur });
  });

  it("Ne pas récupérer un vote pendant la phase d'ajout des candidats", async function () {
    const vock = await Vock.deployed();
    await vock.getVoteElecteur(_idElec, { from: electeur }).catch((err) => {
      return assert.isTrue(getReason(err) === "Cette election n'est pas en cours");
    });
  });

  it("Ne pas récupérer le nombre de votes d'un candidat pendant la phase d'ajout des candidats", async function () {
    const vock = await Vock.deployed();
    await vock.getNbreVotesCandidat(_idElec, _idCand, { from: compte }).catch((err) => {
      return assert.isTrue(getReason(err) === "Cette election n'est pas en cours");
    });
  });

  it("Ne pas créer une élection déjà créée", async function () {
    const vock = await Vock.deployed();
    await vock.creerElection(_idElec, { from: compte }).catch((err) => {
      return assert.isTrue(getReason(err) === "Cette election n'est pas disponible pour la creation");
    });
  });

  // Lancement d'une élection

  it("Ne pas créer une élection déjà lancée", async function () {
    const vock = await Vock.deployed();
    console.log("        | Lancement de l'élection ...")
    await vock.lancerElection(_idElec, { from: auteur });

    await vock.creerElection(_idElec, { from: auteur }).catch((err) => {
      return assert.isTrue(getReason(err) === "Cette election n'est pas disponible pour la creation");
    });
  });

  it("Ne pas relancer une élection déjà lancée", async function () {
    const vock = await Vock.deployed();
    await vock.lancerElection(_idElec, { from: auteur }).catch((err) => {
      return assert.isTrue(getReason(err) === "Pas possible de lancer une election qui n'est pas creee");
    });
  });

  it("Ne pas ajouter un candidat après le lancement d'une élection", async function () {
    const vock = await Vock.deployed();
    await vock.ajouterCandidat(_idElec, _idCand, nomCandidat, { from: auteur }).catch((err) => {
      return assert.isTrue(getReason(err) === "Pas possible d'enregistrer un candidat");
    });
  });

  it("Ne pas voter pour un candidat non enregistré", async function () {
    const vock = await Vock.deployed();
    await vock.voter(_idElec, _idCand + 1, { from: electeur }).catch((err) => {
      return assert.isTrue(getReason(err) === "Ce candidat n'est pas enregistre pour cette election");
    });
  });

  it("Ne pas voter plus d'une fois", async function () {
    const vock = await Vock.deployed();
    console.log("        | Voter pour un candidat ...")
    await vock.voter(_idElec, _idCand, { from: electeur });

    await vock.voter(_idElec, _idCand, { from: electeur }).catch((err) => {
      return assert.isTrue(getReason(err) === "Ce compte a deja vote");
    });
  });

  it("Ne pas terminer une élection dont on n'est pas l'auteur", async function () {
    const vock = await Vock.deployed();
    await vock.terminerElection(_idElec, { from: compte }).catch((err) => {
      return assert.isTrue(getReason(err) === "Vous n'etes pas l'auteur de cette election");
    });
  });

  it("Ne pas voter dans une élection déjà terminée", async function () {
    const vock = await Vock.deployed();
    console.log("        | Terminer l'élection ...")
    await vock.terminerElection(_idElec, { from: auteur });

    await vock.voter(_idElec, _idCand, { from: autreElecteur }).catch((err) => {
      return assert.isTrue(getReason(err) === "Cette election n'est pas en cours");
    });
  });

  it("Ne pas relancer une élection déjà terminée", async function () {
    const vock = await Vock.deployed();
    await vock.lancerElection(_idElec, { from: auteur }).catch((err) => {
      return assert.isTrue(getReason(err) === "Pas possible de lancer une election qui n'est pas creee");
    });
  });
});
