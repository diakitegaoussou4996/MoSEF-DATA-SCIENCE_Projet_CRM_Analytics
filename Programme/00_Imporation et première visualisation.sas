/********************************************************************************************************************/
/*                                                  IMPORTATION DES DONNEES                                         */
/********************************************************************************************************************/

/*----------------Partie1----------------*/
/*    Cette partie regroupe:             */
/*    1-Importation des tables           */
/*    2-Affichage des valeurs manquantes */
/*---------------------------------------*/



/* Définition des libnames*/
OPTIONS VALIDVARNAME = V7;

LIBNAME INPUT "C:\Users\ekeun\OneDrive\Bureau\Projet SAS\Données";
LIBNAME PGM "C:\Users\ekeun\OneDrive\Bureau\Projet SAS\Programmes";
LIBNAME RESULT "C:\Users\ekeun\OneDrive\Bureau\Projet SAS - Copie\Résultats";


/* Import de la base de données clients*/

FILENAME CLIENTS "C:\Users\ekeun\OneDrive\Bureau\Projet SAS\Données\clients.csv";

DATA RESULT.CLIENTS;
	LENGTH NUM_CLIENT $9. ACTIF 3 DATE_CREATION_COMPTE 8 A_ETE_PARRAINE $3. GENRE $5. DATE_NAISSANCE 8 INSCRIT_NL 3;
	FORMAT NUM_CLIENT $9. ACTIF 3. DATE_CREATION_COMPTE DDMMYY10. A_ETE_PARRAINE $3. GENRE $5. DATE_NAISSANCE DDMMYY10. INSCRIT_NL 3.;
	INFILE CLIENTS DLM=";" DSD MISSOVER FIRSTOBS=2; 
	INFORMAT DATE_CREATION_COMPTE DATE_NAISSANCE DDMMYY10.;
	INPUT NUM_CLIENT $ ACTIF  DATE_CREATION_COMPTE A_ETE_PARRAINE $ GENRE $ DATE_NAISSANCE  INSCRIT_NL ;
	LABEL 
			NUM_CLIENT ="Numéro client"
			ACTIF      ="Client actif"
			DATE_CREATION_COMPTE = "Date de création de compte"
			GENRE = "Genre"
			A_ETE_PARRAINE = "A été parrainé"
			DATE_NAISSANCE = "Date de naissance"
			INSCRIT_NL = "Inscrit Newsletter";
RUN;


/* Import de la base de données commandes*/

FILENAME COM "C:\Users\ekeun\OneDrive\Bureau\Projet SAS\Données\commandes.csv";

DATA RESULT.COMMANDES;
	LENGTH NUM_CLIENT $9. NUMERO_COMMANDE $6.  DATE 8         MONTANT_DES_PRODUITS  REMISE_SUR_PRODUITS  MONTANT_LIVRAISON  REMISE_SUR_LIVRAISON  MONTANT_TOTAL_PAYE 5;
	FORMAT NUM_CLIENT $9. NUMERO_COMMANDE $6.  DATE DDMMYY10. MONTANT_DES_PRODUITS  REMISE_SUR_PRODUITS  MONTANT_LIVRAISON  REMISE_SUR_LIVRAISON  MONTANT_TOTAL_PAYE 5.2;
	INFILE COM DLM=";" DSD MISSOVER FIRSTOBS=2;
	INFORMAT DATE DDMMYY10.;
	INPUT NUM_CLIENT $ NUMERO_COMMANDE DATE MONTANT_DES_PRODUITS REMISE_SUR_PRODUITS  MONTANT_LIVRAISON  REMISE_SUR_LIVRAISON  MONTANT_TOTAL_PAYE;

	LABEL 
		 NUM_CLIENT           = "Numéro client"
		 NUMERO_COMMANDE      = "Numéro de commande"
		 DATE                 = "Date d'achat"
		 MONTANT_DES_PRODUITS = "Montants des achats"
		 REMISE_SUR_PRODUITS  = "Montant des remises sur le montant des achats"
		 MONTANT_LIVRAISON    = "Montant de la livraison"
	     REMISE_SUR_LIVRAISON = "Remise sur la livraison"
         MONTANT_TOTAL_PAYE   = "Montant total payé";

RUN;

                             /* Visualisuation de la table client */


TITLE "Visualisation des caractéristiques de la table CLIENTS";
PROC CONTENTS DATA = RESULT.CLIENTS; RUN; 
TITLE2 "Affichage des 10 premières observations.";
PROC PRINT DATA    = RESULT.CLIENTS(OBS=10); RUN;



                         /* Visualisuation de la table commande */

*Commentaire :  On 11242 observation et 8 variables dans la table Commande. Toutes nos variables sont au bon format;


TITLE "Visualisation des caractéristiques de la table COMMANDES";
PROC CONTENTS DATA = RESULT.COMMANDES; RUN; 
TITLE2 "Affichage des 10 premières observations.";
PROC PRINT DATA    = RESULT.COMMANDES(OBS=10); RUN;

TITLE;


           /* Affichage de valeurs manquantes en nombre et en pourcentage dans la table client */


PROC SQL;
  TITLE "Nombre de valeurs manquantes pour chaque variable de table CLIENTS";
  SELECT COUNT(*) AS n_obs,
         SUM(NUM_CLIENT = " ")         AS nmiss_NUM_CLIENT,
         SUM(ACTIF = .)                AS nmiss_ACTIF,
         SUM(DATE_CREATION_COMPTE = .) AS nmiss_DATE_CREATION_COMPTE,
         SUM(GENRE = " ")              AS nmiss_GENRE,
		 SUM(A_ETE_PARRAINE = " ")     AS nmiss_A_ETE_PARRAINE,
		 SUM(DATE_NAISSANCE = .)       AS nmiss_DATE_NAISSANCE,
		 SUM(INSCRIT_NL = .)           AS nmiss_INSCRIT_NL
  FROM RESULT.CLIENTS;
QUIT;


PROC SQL;
  TITLE "Pourcentage de valeurs manquantes pour chaque variable de table CLIENTS";
  SELECT COUNT(*) AS n_obs,
         SUM(NUM_CLIENT = " ")/COUNT(*)*100            AS nmiss_NUM_CLIENT,
         SUM(ACTIF = .)/COUNT(*)*100                   AS nmiss_ACTIF,
         SUM(DATE_CREATION_COMPTE = .)/COUNT(*)*100    AS nmiss_DATE_CREATION_COMPTE,
         SUM(GENRE = " ")/COUNT(*)*100                 AS nmiss_GENRE,
		 SUM(A_ETE_PARRAINE = " ")/COUNT(*)*100        AS nmiss_A_ETE_PARRAINE,
		 SUM(DATE_NAISSANCE = .)/COUNT(*)*100          AS nmiss_DATE_NAISSANCE,
		 SUM(INSCRIT_NL = .)/COUNT(*)*100              AS nmiss_INSCRIT_NL
  FROM RESULT.CLIENTS;
QUIT;

           /* Affichage de valeurs manquantes en nombre et en pourcentage dans la table Commande */



PROC SQL;
  TITLE "Nombre de valeurs manquantes pour chaque variable de table COMMANDES";
  SELECT COUNT(*) AS n_obs,
         SUM(NUM_CLIENT = " ")         	  AS nmiss_NUM_CLIENT,
         SUM(NUMERO_COMMANDE = "")         AS nmiss_NUMERO_COMMANDE,
         SUM(DATE = .) 					  AS nmiss_DATE,
         SUM(MONTANT_DES_PRODUITS = .)    AS nmiss_MONTANT_DES_PRODUITS,
         SUM(REMISE_SUR_PRODUITS = .)    AS nmiss_REMISE_SUR_PRODUITS,
		 SUM(MONTANT_LIVRAISON = .)       AS nmiss_MONTANT_LIVRAISON,
		 SUM(REMISE_SUR_LIVRAISON = .)    AS nmiss_REMISE_SUR_LIVRAISON,
		 SUM(MONTANT_TOTAL_PAYE = .)      AS nmiss_MONTANT_TOTAL_PAYE
  FROM RESULT.COMMANDES;
QUIT;




PROC SQL;
  TITLE "Pourcentage de valeurs manquantes pour chaque variable de table COMMANDES";
  SELECT COUNT(*) AS n_obs,
         SUM(NUM_CLIENT = " ")/COUNT(*)*100                AS nmiss_NUM_CLIENT,
         SUM(NUMERO_COMMANDE = "")/COUNT(*)*100            AS nmiss_NUMERO_COMMANDE,
         SUM(DATE = .)/COUNT(*)*100 				       AS nmiss_DATE,
         SUM(MONTANT_DES_PRODUITS = .)/COUNT(*)*100        AS nmiss_MONTANT_DES_PRODUITS,
		 SUM(MONTANT_LIVRAISON = .)/COUNT(*)*100           AS nmiss_MONTANT_LIVRAISON,
		 SUM(REMISE_SUR_LIVRAISON = .)/COUNT(*)*100        AS nmiss_REMISE_SUR_LIVRAISON,
		 SUM(MONTANT_TOTAL_PAYE = .)/COUNT(*)*100          AS nmiss_MONTANT_TOTAL_PAYE
  FROM RESULT.COMMANDES;
QUIT;
