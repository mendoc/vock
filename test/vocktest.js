const Vock = artifacts.require("Vock");
require('chai')
.use(require('chai-as-promised'))
.should();


contract ('Testons notre contrat ELECTION', (accounts)=>{

    let vock,election1,election2,election3;

    beforeEach(async()=>{
        vock= await Vock.new();
        console.log("============ ADRESSE DU CONTRAT ======================")  
        const contratElection= vock.address;
        console.log('ADRESSE DU CONTRAT :',contratElection)
        console.log("======================================================")  
        
        election1= await vock.creerElection('1',{from:accounts[0]});
        election2= await vock.creerElection('2',{from:accounts[0]});
        election3= await vock.creerElection('3',{from:accounts[0]});
    })

    it ('adresse du contract',async()=>{
        
        // evenement après avoir crée la prémiere élection
        const resultat1= election1.logs[0];
        resultat1.event.should.eq('CreerElection');
        const event1= resultat1.args;
       
        event1.admin.should.equal(accounts[0]);
        event1.idElection.toString().should.equal('1');

        // evenement après avoir crée la 2nde élection
        const resultat2= election2.logs[0];
        resultat2.event.should.eq('CreerElection');
        const event2= resultat2.args;
       
        event2.admin.should.equal(accounts[0]);
        event2.idElection.toString().should.equal('2');

        // evenement après avoir crée la 3ième élection
        const resultat3= election3.logs[0];
        resultat3.event.should.eq('CreerElection');
        const event3= resultat3.args;
       
        event3.admin.should.equal(accounts[0]);
        event3.idElection.toString().should.equal('3');
       
    })
   it('enregistrer les electeurs',async()=>{

     const electeur1= await vock.enregistrer('1',{from:accounts[1]})
      await vock.enregistrer('1',{from:accounts[2]})
      await vock.enregistrer('1',{from:accounts[3]})
      await vock.enregistrer('1',{from:accounts[4]})
      await vock.enregistrer('2',{from:accounts[5]})
     const electeur6= await vock.enregistrer('2',{from:accounts[6]})
      await vock.enregistrer('2',{from:accounts[7]})
      await vock.enregistrer('3',{from:accounts[8]})
      await vock.enregistrer('3',{from:accounts[9]})

      const resultat1= electeur1.logs[0];
      resultat1.event.should.eq('Enregistrer');
      const event1=resultat1.args;
      event1.electeur.should.equal(accounts[1]);
      event1.idElection.toString().should.equal('1')

      const resultat6= electeur6.logs[0];
      resultat6.event.should.eq('Enregistrer');
      const event6=resultat6.args;
      event6.electeur.should.equal(accounts[6]);
      event6.idElection.toString().should.equal('2')

      const autorization1=await vock.autoriser('1', accounts[1],{from:accounts[0]});
      await vock.autoriser('1', accounts[2],{from:accounts[0]});
      await vock.autoriser('1', accounts[3],{from:accounts[0]});
      const autorization6= await vock.autoriser('2', accounts[6],{from:accounts[0]});
      await vock.autoriser('2', accounts[7],{from:accounts[0]});
      await vock.autoriser('2', accounts[5],{from:accounts[0]});

      const autoEvent1= autorization1.logs[0];
      autoEvent1.event.should.eq('Autoriser');
      const evAuto1=autoEvent1.args;
      evAuto1.admin.should.equal(accounts[0]);
      evAuto1.electeur.should.equal(accounts[1]);
      evAuto1.idElection.toString().should.equal('1');

      const autoEvent6= autorization6.logs[0];
      autoEvent6.event.should.eq('Autoriser');
      const evAuto6=autoEvent6.args;
      evAuto6.admin.should.equal(accounts[0]);
      evAuto6.electeur.should.equal(accounts[6]);
      evAuto6.idElection.toString().should.equal('2');

      const candidat1a=await vock.ajouterCandidat('1','1',"ENOCK",{from:accounts[0]})
      await vock.ajouterCandidat('1','2',"DIMITRI",{from:accounts[0]})
      await vock.ajouterCandidat('2','1',"JOSEPH",{from:accounts[0]})
      const candidat2b=await vock.ajouterCandidat('2','2',"JESSICA",{from:accounts[0]})

      const ajouter1= candidat1a.logs[0];
      ajouter1.event.should.eq('AjouterCandidat');
      const evAjout1=ajouter1.args;
      evAjout1.admin.should.equal(accounts[0]);
      evAjout1.idElec.toString().should.equal('1');
      evAjout1.idCand.toString().should.equal('1');
      evAjout1.candidat.should.equal("ENOCK");

      const ajouter2b= candidat2b.logs[0];
      ajouter2b.event.should.eq('AjouterCandidat');
      const evAjout2b=ajouter2b.args;
      evAjout2b.admin.should.equal(accounts[0]);
      evAjout2b.idElec.toString().should.equal('2');
      evAjout2b.idCand.toString().should.equal('2');
      evAjout2b.candidat.should.equal("JESSICA");

      const lancer= await vock.lancerElection('1',{from:accounts[0]});
      const elec1= lancer.logs[0];
      elec1.event.should.eq('Lancer');
      const evLance= elec1.args;
     
      evLance.admin.should.equal(accounts[0]);
      evLance.idElection.toString().should.equal('1');

     await vock.voter('1', '2',{from:accounts[1]})
     await vock.voter('1', '2',{from:accounts[2]})
     await vock.voter('1', '1',{from:accounts[3]})
     await vock.voter('1', '2',{from:accounts[4]}).should.be.rejectedWith("Vous n'avez pas le droit de voter pour cette election")
     await vock.voter('1', '1',{from:accounts[3]}).should.be.rejectedWith("Ce compte a deja vote")

     await vock.terminerElection('1',{from:accounts[1]}).should.be.rejectedWith("Vous n'etes pas l'auteur de cette election")
     await vock.terminerElection('1',{from:accounts[0]});

    //  const compte1=await vock.getVoteElecteur('1',accounts[1]);
    //  compte1.toString().should.equal('2');
    //  const compte2=await vock.getVoteElecteur('1',accounts[2]);
    //  compte2.toString().should.equal('2');
    //  const compte3=await vock.getVoteElecteur('1',accounts[3]);
    //  compte3.toString().should.equal('1');


     const nbVoix1= await vock.getNbreVotesCandidat('1', '1');
     nbVoix1.toString().should.equal('1');

     const nbVoix2= await vock.getNbreVotesCandidat('1', '2');
     nbVoix2.toString().should.equal('2');
     


   })





})