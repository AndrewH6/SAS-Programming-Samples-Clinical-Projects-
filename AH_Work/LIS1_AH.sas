/*******************************************************************
* Client: XXXX                                                           
* Project:  COVID-19 AA                                                   
* Program: LIS1.SAS  
*
* Program Type: Listing
*
* Purpose: To produce 16.2.1.1 Assignment to Analysis Populations
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

DATA ADSL;
SET ADAM.ADSL;
KEEP USUBJID SAFFL ITTFL PPROTFL RANDFL;
RUN;

/*PAGE NUMBER HANDLING*/
DATA ADSL;
SET ADSL;
RETAIN LNT 0 PAGE1 1;
LNT+1;

IF LNT>20 THEN DO;
	PAGE1=PAGE1+1;
	LNT=1;
END;
RUN;

TITLE1 J=L "COVID-19 AA";
TITLE2 J=L "Protocol: 043";
TITLE3 J=C "16.2.1.1 Assignment to Analysis Populations";

FOOTNOTE1 J=L "G:\COVID08_042023\AH_Work\LIS1_AH.SAS";

OPTIONS ORIENTATION=LANDSCAPE;
ODS ESCAPECHAR='^';
ODS RTF FILE = "G:\COVID08_042023\OUTPUTS\L_16_2_1_1.RTF" STYLE=styles.test;

PROC REPORT DATA=ADSL SPLIT="|" STYLE={OUTPUTWIDTH=100%} NOWD;
COLUMN PAGE1 USUBJID SAFFL ITTFL PPROTFL RANDFL;

DEFINE PAGE1/ORDER NOPRINT;

DEFINE USUBJID/ORDER "Subject|Number"
STYLE (HEADER)={JUST=LEFT CELLWIDTH=20%}
STYLE (COLUMN)={JUST=LEFT CELLWIDTH=20%};

DEFINE SAFFL/ "Safety|Population"
STYLE (HEADER)={JUST=LEFT CELLWIDTH=20%}
STYLE (COLUMN)={JUST=LEFT CELLWIDTH=20%};

DEFINE ITTFL/ "Intent-To-Treat|Population"
STYLE (HEADER)={JUST=LEFT CELLWIDTH=20%}
STYLE (COLUMN)={JUST=LEFT CELLWIDTH=20%};

DEFINE PPROTFL/ "Per-Protocol|Population"
STYLE (HEADER)={JUST=LEFT CELLWIDTH=20%}
STYLE (COLUMN)={JUST=LEFT CELLWIDTH=20%};

DEFINE RANDFL/ "Randomized|Population"
STYLE (HEADER)={JUST=LEFT CELLWIDTH=19%}
STYLE (COLUMN)={JUST=LEFT CELLWIDTH=19%};

COMPUTE BEFORE _PAGE_;
LINE@1 "^{STYLE [OUTPUTWIDTH=100% BORDERTOPWIDTH=0.5PT]}";
ENDCOMP;

COMPUTE AFTER _PAGE_;
LINE@1 "^{STYLE [OUTPUTWIDTH=100% BORDERTOPWIDTH=0.5PT]}";
ENDCOMP;

BREAK AFTER PAGE1/PAGE;
RUN;

ODS _ALL_ CLOSE;
