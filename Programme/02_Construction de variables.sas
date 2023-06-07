
/********************************************************************************************************************/
/*                                                  FEATURES ENGINEERING                                            */
/********************************************************************************************************************/

/*---------------------------------------------Partie3------------------------------------*/
/*    Cette partie regroupe:                                                              */
/*                                                                                        */
/*    1 - Jointures de la base de données client et commande                              */
/*    2 - Création des variables : Age, Anciennété, Tranche d'âge, Tranche d'anciennété   */
/*    3 - Analyse exploratoire des variables créées                                       */
/*----------------------------------------------------------------------------------------*/



/* Définition des libnames*/

LIBNAME INPUT "C:\Users\ekeun\OneDrive\Bureau\Projet SAS\Données";
LIBNAME PGM "C:\Users\ekeun\OneDrive\Bureau\Projet SAS\Programmes";
LIBNAME RESULT "C:\Users\ekeun\OneDrive\Bureau\Projet SAS - Copie\Résultats";

/* Jointure des deux bases de données */

PROC SORT DATA=RESULT.CLIENTS; BY NUM_CLIENT;RUN;
PROC SORT DATA=RESULT.COMMANDES; BY NUM_CLIENT;RUN;

DATA RESULT.CLIENTS_COMMANNDES;
	MERGE   RESULT.CLIENTS   (IN=inCLIENTS)
			RESULT.COMMANDES (IN=inCOMMANDES);
	BY NUM_CLIENT;
	IF inCLIENTS & inCOMMANDES;
RUN;

DATA RESULT.CLIENTS_COMMANNDES; 
	SET RESULT.CLIENTS_COMMANNDES;

	ATTRIB AGE                     LENGTH=3     FORMAT=3.;
	ATTRIB TRANCHE_AGE             LENGTH=$18.  FORMAT=$18.;
	ATTRIB TRANCHE_ANCIENNETE      LENGTH=$18.  FORMAT=$18.;
	ATTRIB MOIS_INSCRIPTION        LENGTH=3     FORMAT=3.;
	ATTRIB ANCIENNETE              LENGTH=3     FORMAT=3.;
	ATTRIB MOIS_COMMANDES          LENGTH=7     FORMAT=MONYY7.;
	

	/* Age du client */
	AGE = INTCK("YEAR",DATE_NAISSANCE, "01JAN2023"d);
	
	/* Tranche d'âge */
	IF          AGE < 25 AND AGE NE . THEN TRANCHE_AGE = "Moins de 25 ans";
	ELSE IF 25<=AGE < 35 AND AGE NE . THEN TRANCHE_AGE = "Entre 25 et 35 ans";
	ELSE IF 35<=AGE < 45 AND AGE NE . THEN TRANCHE_AGE = "Entre 35 et 45 ans";
	ELSE IF 45<=AGE < 55 AND AGE NE . THEN TRANCHE_AGE = "Entre 45 et 55 ans";
	ELSE IF 55<=AGE < 65 AND AGE NE . THEN TRANCHE_AGE = "Entre 55 et 65 ans";
	ELSE IF 65<=AGE < 75 AND AGE NE . THEN TRANCHE_AGE = "Entre 65 et 75 ans";
	ELSE IF    AGE >= 75 AND AGE NE . THEN TRANCHE_AGE = "Supérieur à 75 ans";
	ELSE 					               TRANCHE_AGE = "Inconnu";	
	
	/* Mois d'inscription */
	MOIS_INSCRIPTION = MONTH(DATE_CREATION_COMPTE);

	/* Ancienneté du client */
	IF ACTIF = 1 THEN
		ANCIENNETE  = INTCK("YEAR",DATE_CREATION_COMPTE, "01JAN2023"d);
	ELSE ANCIENNETE = 99;

	/* Tranche d'ancienneté */
	IF        ANCIENNETE <= 2   THEN TRANCHE_ANCIENNETE = "2 ans";
	ELSE IF 2<ANCIENNETE <= 5   THEN TRANCHE_ANCIENNETE = "Entre 2 et 5 ans";
	ELSE IF 5<ANCIENNETE <= 10  THEN TRANCHE_ANCIENNETE = "Entre 5 et 10 ans";
	ELSE 	                         TRANCHE_ANCIENNETE = "Non actif";	

	/* Mois de commandes */
	MOIS_COMMANDES   = DATE;
RUN;

PROC FREQ DATA=RESULT.CLIENTS_COMMANNDES;
	TABLE AGE ANCIENNETE TRANCHE_AGE ANCIENNETE TRANCHE_ANCIENNETE ;
RUN;
