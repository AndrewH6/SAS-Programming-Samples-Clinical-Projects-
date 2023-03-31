/*******************************************************************
* Client: XXXX                                                           
* Project:  COVID-19 AA                                                   
* Program: LIS8_1_AH.SAS  
*
* Program Type: Listing
*
* Purpose: To produce 16.2.2.2 Serious Adverse Events Leading to Death       
* Usage Notes: 
*
* SAS® Version: 9.4
* Operating System:                    
*
* Author: Andrew Huang
* Date Created: 29-Mar-2023
* Modification History:
*******************************************************************/

/*TO ACCESS THE DATA*/

LIBNAME ADAM "G:\COVID08_042023\ADAM datasets";

%include "G:\COVID08_042023\PROGRAMS\_RTFSTYLE_.sas";
%_RTFSTYLE_;

PROC CONTENTS DATA=ADAM.ADAE;
RUN;

DATA ADAE;
SET ADAM.ADAE;
IF AESER EQ 'Y' AND AEOUT IN ("DEATH", "FATAL");
RUN;

PROC SQL NOPRINT;
SELECT COUNT(*) INTO: NBR FROM ADAE;
QUIT;
%PUT &NBR;

DATA ADAE;
TEXT = "NO OBSERVATIONS";
RUN;

TITLE1 J=L "COVID-19 AA";
TITLE2 J=L "Protocol: 043";
TITLE3 J=C "16.2.2.2 Serious Adverse Events Leading to Death";

FOOTNOTE1 J=L "G:\COVID08_042023\AH_Work\LIS8_1_AH.SAS";

OPTIONS ORIENTATION=LANDSCAPE;
ODS ESCAPECHAR='^';
ODS RTF FILE="G:\COVID08_042023\OUTPUTS\L_16_2_2_2.RTF" STYLE=styles.test;
PROC REPORT DATA=ADAE SPLIT="|" STYLE={OUTPUTWIDTH=100%} NOWD;
COLUMN TEXT;

DEFINE TEXT/" "
STYLE(HEADER)={JUST=C CELLWIDTH=15%}
STYLE(COLUMN)={JUST=C CELLWIDTH=15%};

COMPUTE AFTER _PAGE_;
LINE@1 "^{STYLE [OUTPUTWIDTH=100% BORDERTOPWIDTH=0.5PT]}";
ENDCOMP;
RUN;

ODS _ALL_ CLOSE;



