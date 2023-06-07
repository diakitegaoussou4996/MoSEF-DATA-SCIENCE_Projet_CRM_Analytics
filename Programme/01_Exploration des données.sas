
/********************************************************************************************************************/
/*                                                  EXPLORATION DES DONNEES                                         */
/********************************************************************************************************************/

/*---------------------------------------------Partie2------------------------------------*/
/*    Cette partie regroupe:                                                              */
/*                                                                                        */
/*    1 - Visualisation de la modalité des variables de la base de donnée client          */
/*    2 - Recodage des modalités de la variable parrainage                                */
/*    3 - Audit de la base de données client                                              */
/*    4 - Audit de la base de données commande                                            */
/*----------------------------------------------------------------------------------------*/



/* Définition des libnames*/

LIBNAME INPUT "C:\Users\ekeun\OneDrive\Bureau\Projet SAS\Données";
LIBNAME PGM "C:\Users\ekeun\OneDrive\Bureau\Projet SAS\Programmes";
LIBNAME RESULT "C:\Users\ekeun\OneDrive\Bureau\Projet SAS - Copie\Résultats";


/* Base de données clients */
PROC FREQ DATA=RESULT.CLIENTS;
	TABLE A_ETE_PARRAINE;
	TABLE GENRE;
	TABLE ACTIF;
	TABLE INSCRIT_NL;
RUN;


                

/* Recodage de la parrainage */

DATA RESULT.CLIENTS;
	SET RESULT.CLIENTS;
	IF A_ETE_PARRAINE NOT IN ("OUI", "NON") THEN A_ETE_PARRAINE = "INC";
RUN;


/*  Audit de la base de données client */

PROC SQL;
  TITLE "Audit de la base de données des CLIENTS";
  CREATE TABLE RESULT.AUDIT_CLIENTS AS
  SELECT 
  		 /* Le nombre de clients */
         COUNT(DISTINCT(NUM_CLIENT))   AS NB_CLIENT,

		 /* Le nombre de clients actifs */
         SUM(ACTIF)         AS NB_ACTIF,

		 /* Le nombre d'inscrits à la newsletter */
         SUM(INSCRIT_NL) 	AS NB_INSCRIT_NL,

		 /* Le nombre de clients parrainés */
         SUM(A_ETE_PARRAINE = "OUI")    AS NB_PARRAINAGE,

		 /* Le nombre de clients non parrainés */
		 SUM(A_ETE_PARRAINE = "NON")    AS NB_NON_PARRAINAGE,

		 /* Le nombre de clients inc parrainés */
		 SUM(A_ETE_PARRAINE = "INC")    AS NB_INC_PARRAINAGE,

		 /* Le nombre de femmes */
		 SUM(GENRE = "Femme")    AS NB_FEMME,

		 /* Le nombre d'hommes */
		 SUM(GENRE = "Homme")    AS NB_HOMME,

		 /* Le nombre d'hommes */
		 MIN(DATE_CREATION_COMPTE)       AS MIN_DATE_CREATION_COMPTE FORMAT DDMMYY10.,

		 /* Le nombre d'hommes */
		 MAX(DATE_CREATION_COMPTE)       AS MAX_DATE_CREATION_COMPTE FORMAT DDMMYY10.,

		 /* Le nombre d'hommes */
		 MIN(DATE_NAISSANCE)             AS MIN_DATE_NAISSANCE       FORMAT DDMMYY10.,

		 /* Le nombre d'hommes */
		 MAX(DATE_NAISSANCE)             AS MAX_DATE_NAISSANCE       FORMAT DDMMYY10.

  FROM RESULT.CLIENTS;
QUIT;

TITLE;

PROC TRANSPOSE DATA= RESULT.AUDIT_CLIENTS
	OUT=RESULT.AUDIT_CLIENTS
	(RENAME =( _NAME_=INDICATEUR COL1 = VALEUR));	
RUN;

PROC PRINT DATA=RESULT.AUDIT_CLIENTS; RUN;



/*Audit de la base de données commande */

PROC SQL;
  TITLE "Audit de la base de données des COMMANDE";
  CREATE TABLE RESULT.AUDIT_COMMANDES AS
  SELECT
          /* Le nombre de clients */
        COUNT(DISTINCT(NUM_CLIENT))         AS NB_NUM_CLIENT,
	      /* Le nombre de clients */
        COUNT(DISTINCT(NUMERO_COMMANDE))     AS NB_NUMERO_COMMANDE,
	     /* Le nombre de clients */
        COUNT(NUMERO_COMMANDE)               AS NB_LIGNES_COMMANDES
	 FROM RESULT.COMMANDES;
QUIT;

TITLE;


PROC MEANS DATA=RESULT.COMMANDES MAXDEC=2;
	VAR MONTANT_DES_PRODUITS REMISE_SUR_PRODUITS MONTANT_LIVRAISON REMISE_SUR_LIVRAISON MONTANT_TOTAL_PAYE DATE;
	OUTPUT OUT=RESULT.STATS (DROP=_TYPE_ _FREQ_)
					 NMISS = NMISS_MONTANT NMISS_REMISE_PRODUITS NMISS_LIVRAISON NMISS_REMISE_LIVRAISON NMISS_TOTAL NMISS_DATE_COMMANDE
					 MIN = MIN_MONTANT MIN_REMISE_PRODUITS MIN_LIVRAISON MIN_REMISE_LIVRAISON MIN_TOTAL MIN_DATE_COMMANDE
					 MAX = MAX_MONTANT MAX_REMISE_PRODUITS MAX_LIVRAISON MAX_REMISE_LIVRAISON MAX_TOTAL MAX_DATE_COMMANDE
					 MEDIAN = MED_MONTANT MED_REMISE_PRODUITS MED_LIVRAISON MED_REMISE_LIVRAISON MED_TOTAL
					 MEAN = MEAN_MONTANT MEAN_REMISE_PRODUITS MEAN_LIVRAISON MEAN_REMISE_LIVRAISON MEAN_TOTAL;

RUN;
PROC TRANSPOSE DATA=RESULT.STATS 
	OUT=RESULT.STATS_COMMANDES(DROP=_LABEL_ RENAME=(_NAME_ = INDICATEUR COL1 = VALEUR));	
RUN;

PROC PRINT DATA=RESULT.STATS_COMMANDES; RUN;



/*Concaténation*/
DATA RESULT.INDICATEURS;
	SET RESULT.AUDIT_CLIENTS RESULT.STATS_COMMANDES ;
RUN;
