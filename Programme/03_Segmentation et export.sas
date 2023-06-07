/********************************************************************************************************************/
/*                                                  	SEGMENTATION   		                                        */
/********************************************************************************************************************/

/*-------------------------------------------Partie3--------------------------------------*/
/*    Cette partie regroupe:                                                              */
/*                                                                                        */
/*    1 - Clcul des indicateurs RFM                                                       */
/*    2 - Définition des seuils pour la segmentation                                      */
/*    3 - Application des seuils pour la segmentation                                     */
/*    4 - Exportation de la base finale                                                   */
/*----------------------------------------------------------------------------------------*/



/* Définition des libnames*/

LIBNAME INPUT "C:\Users\ekeun\OneDrive\Bureau\Projet SAS\Données";
LIBNAME PGM "C:\Users\ekeun\OneDrive\Bureau\Projet SAS\Programmes";
LIBNAME RESULT "C:\Users\ekeun\OneDrive\Bureau\Projet SAS - Copie\Résultats";


/* CALCUL DES INDICATEURS RFM */

PROC SQL;
	CREATE TABLE RESULT.INDICATEUR_RFM
	AS SELECT NUM_CLIENT,
	MIN(INTCK("MONTH", DATE, "01JAN2023"d)) AS RECENCE,
	COUNT(DISTINCT(NUMERO_COMMANDE)) AS FREQUENCE,
	MEAN(MONTANT_TOTAL_PAYE) AS MONTANT
	FROM RESULT.CLIENTS_COMMANNDES
	WHERE MONTANT_TOTAL_PAYE NE .
	GROUP BY NUM_CLIENT;
QUIT;

/*Définition des seuils pour la segmentation */

PROC FREQ DATA = RESULT.INDICATEUR_RFM;
	TABLE RECENCE FREQUENCE;
RUN;

PROC RANK DATA = RESULT.INDICATEUR_RFM
		  OUT = RESULT.RANG_MONTANT
		  GROUPS = 10;
		  VAR  MONTANT;
		  RANKS RANG;
RUN;

PROC SUMMARY DATA = RESULT.RANG_MONTANT;
	CLASS RANG;
	VAR MONTANT;
	OUTPUT OUT  = RESULT.MONTANT_RANG
			MIN = MONTAN_MIN
			MAX = MONTANT_MAX;
RUN;

PROC PRINT DATA=RESULT.MONTANT_RANG; RUN;

/*Application des seuils pour la segmentation */

DATA RESULT.RFM_1;
	SET RESULT.INDICATEUR_RFM;

	/* Recence */
	IF       12 < RECENCE         THEN SEG_RECENCE = "R1"; /* moins récent */
	ELSE IF  6  < RECENCE <= 12   THEN SEG_RECENCE = "R2";
	ELSE IF       RECENCE <=6     THEN SEG_RECENCE = "R3"; /* plus récent */
	ELSE SEG_RECENCE = "IN";

	/* Fréquence */
	IF            FREQUENCE = 1   THEN SEG_FREQUENCE = "F1"; /* pas régulier */
	ELSE IF  2 <= FREQUENCE <=3   THEN SEG_FREQUENCE = "F2";
	ELSE IF  3  < FREQUENCE       THEN SEG_FREQUENCE = "F3"; /* régulier */
	ELSE SEG_FREQUENCE = "IN";

	/* Montant */
	IF              MONTANT < 50  THEN SEG_MONTANT = "M1";   /* dépense moins */
	ELSE IF  50  <= MONTANT < 100 THEN SEG_MONTANT = "M2";
	ELSE IF  100 <= MONTANT       THEN SEG_MONTANT = "M3";   /* dépense plus  */
	ELSE SEG_MONTANT = "IN";

RUN;

PROC FREQ DATA = RESULT.RFM_1;
	TABLE SEG_RECENCE SEG_FREQUENCE SEG_MONTANT;
RUN;



PROC FREQ DATA = RESULT.RFM_1;
	TABLE SEG_RECENCE*SEG_FREQUENCE/NOFREQ NOCOL NOROW;
RUN;



/*
------------------ Interprétation --------------------------
R1*F1 --> il y'a plus de 12 mois il a commandé une seule fois 
R1*F2 --> il y'a plus de 12 mois il a commandé 2 ou 3 fois 
R1*F3 --> il y'a plus de 12 mois il a commandé plus de 3 fois

R2*F1 --> il y'a plus de 6 mois et moins de 12 mois il a commandé une seule fois 
R2*F2 --> il y'a plus de 6 mois et moins de 12 mois il a commandé 2 ou 3 fois 
R2*F3 --> il y'a plus de 6 mois et moins de 12 mois il a commandé plus de 3 fois

R3*F1 --> il y'a moins de 6 mois il a commandé une seule fois
R3*F2 --> il y'a moins de 6 mois il a commandé 2 ou 3 fois
R3*F3 --> il y'a moins de 6 mois il a commandé plus de 3 fois


-------------------  Regroupement  --------------------------
RF1 : R1*F1 & R1*F2 --> il a passé 3 commandes ou moins il y'a plus de 12 mois
RF2 : R2*F1 & R2*F2 & R1*F3 & R3*F1 --> 
RF3 : R2*F3 & R3*F2 & R3*F3 --> il a commandé 2 fois ou plus il y'a moins de 12 mois

*/
DATA RESULT.RFM_2;
	SET RESULT.RFM_1;

	/* RF1 */
	/* il a passé 3 commandes ou moins il y'a plus de 12 mois */
	IF (SEG_RECENCE = "R1" &  SEG_FREQUENCE = "F1") OR 
	   (SEG_RECENCE = "R1" &  SEG_FREQUENCE = "F2")
	THEN RECENCE_FREQUENCE = "RF1";

	/* RF2 */
	/*  */
	IF (SEG_RECENCE = "R2" &  SEG_FREQUENCE = "F1") OR 
	   (SEG_RECENCE = "R2" &  SEG_FREQUENCE = "F2") OR
	   (SEG_RECENCE = "R1" &  SEG_FREQUENCE = "F3") OR
	   (SEG_RECENCE = "R3" &  SEG_FREQUENCE = "F1")
	THEN RECENCE_FREQUENCE = "RF2";

	/* RF3 */
	/* il a commandé 2 fois ou plus il y'a moins de 12 mois */
	IF (SEG_RECENCE = "R2" &  SEG_FREQUENCE = "F3") OR 
	   (SEG_RECENCE = "R3" &  SEG_FREQUENCE = "F2") OR
	   (SEG_RECENCE = "R3" &  SEG_FREQUENCE = "F3")
	THEN RECENCE_FREQUENCE = "RF3";

RUN;

PROC FREQ DATA = RESULT.RFM_2;
	TABLE RECENCE_FREQUENCE*SEG_MONTANT/NOFREQ NOCOL NOROW;
RUN;

/*
------------------ Interprétation --------------------------
R1*F1 --> il y'a plus de 12 mois il a commandé une seule fois 
R1*F2 --> il y'a plus de 12 mois il a commandé 2 ou 3 fois 
R1*F3 --> il y'a plus de 12 mois il a commandé plus de 3 fois

R2*F1 --> il y'a plus de 6 mois et moins de 12 mois il a commandé une seule fois 
R2*F2 --> il y'a plus de 6 mois et moins de 12 mois il a commandé 2 ou 3 fois 
R2*F3 --> il y'a plus de 6 mois et moins de 12 mois il a commandé plus de 3 fois

R3*F1 --> il y'a moins de 6 mois il a commandé une seule fois
R3*F2 --> il y'a moins de 6 mois il a commandé 2 ou 3 fois
R3*F3 --> il y'a moins de 6 mois il a commandé plus de 3 fois


-------------------  Regroupement  --------------------------
RF1 : R1*F1 & R1*F2 --> il a passé 3 commandes ou moins il y'a plus de 12 mois
RF2 : R2*F1 & R2*F2 & R1*F3 & R3*F1 --> 
RF3 : R2*F3 & R3*F2 & R3*F3 --> il a commandé 2 fois ou plus il y'a moins de 12 mois

*/

DATA RESULT.RFM_3;
	SET RESULT.RFM_2;
	IF      RECENCE_FREQUENCE = "RF1" & SEG_MONTANT = "M1" THEN RECENCE_FREQUENCE_MONTANT = "RFM1";
	ELSE IF RECENCE_FREQUENCE = "RF1" & SEG_MONTANT = "M2" THEN RECENCE_FREQUENCE_MONTANT = "RFM2";
	ELSE IF RECENCE_FREQUENCE = "RF1" & SEG_MONTANT = "M3" THEN RECENCE_FREQUENCE_MONTANT = "RFM3";
	ELSE IF RECENCE_FREQUENCE = "RF2" & SEG_MONTANT = "M1" THEN RECENCE_FREQUENCE_MONTANT = "RFM4";
	ELSE IF RECENCE_FREQUENCE = "RF2" & SEG_MONTANT = "M2" THEN RECENCE_FREQUENCE_MONTANT = "RFM5";
	ELSE IF RECENCE_FREQUENCE = "RF2" & SEG_MONTANT = "M3" THEN RECENCE_FREQUENCE_MONTANT = "RFM6";
	ELSE IF RECENCE_FREQUENCE = "RF3" & SEG_MONTANT = "M1" THEN RECENCE_FREQUENCE_MONTANT = "RFM7";
	ELSE IF RECENCE_FREQUENCE = "RF3" & SEG_MONTANT = "M2" THEN RECENCE_FREQUENCE_MONTANT = "RFM8";
	ELSE IF RECENCE_FREQUENCE = "RF3" & SEG_MONTANT = "M3" THEN RECENCE_FREQUENCE_MONTANT = "RFM9";
	ELSE RECENCE_FREQUENCE_MONTANT = "INC";
RUN;

/* Export des bases de données sous Excel */


/* Jointure des bases de données */
PROC SORT DATA = RESULT.CLIENTS_COMMANNDES; BY NUM_CLIENT;RUN;
PROC SORT DATA = RESULT.RFM_3; BY NUM_CLIENT;RUN;

DATA RESULT.BASE_FINALE;
	MERGE RESULT.CLIENTS_COMMANNDES (IN = A)
		  RESULT.RFM_3 (IN = B);
	BY NUM_CLIENT;
	IF A AND B;
RUN;
			
PROC EXPORT DATA = RESULT.BASE_FINALE
         OUTFILE = "C:\Users\ekeun\OneDrive\Bureau\Projet SAS - Copie\Résultats"
            DBMS = EXCEL REPLACE ;
   SHEET = "data" ; /* nom de la feuille Excel créée */
RUN ;
PROC EXPORT DATA = RESULT.INDICATEURS
         OUTFILE = "C:\Users\ekeun\OneDrive\Bureau\Projet SAS - Copie\Résultats"
            DBMS = EXCEL REPLACE ;
   SHEET = "indic" ; /* nom de la feuille Excel créée */
RUN ;

