/*******************************************************************
* Client: XXXX                                                           
* Project:  COVID-19 AA                                                   
* Program: LIS8_3_AH.SAS  
*
* Program Type: Listing
*
* Purpose: To produce 16.2.2.4 Adverse Events
* Usage Notes: 
*
* SAS� Version: 9.4
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

DATA ADAE;
SET ADAM.ADAE;
IF AETERM NE '';
SPA=CATX("/",AETERM, AEBODSYS,AEDECOD);
KEEP USUBJID SPA AESTDTC AEENDTC AESER AACN AREL AEOUT;
RUN;

PROC SQL NOPRINT;
SELECT COUNT(*) INTO: NBR FROM ADAE;
QUIT;
%PUT &NBR;

/*PAGE NUMBER HANDLING*/

DATA ADAE;
SET ADAE;
RETAIN LNT 0 PAGE1 1;
LNT+1;

IF LNT>7 THEN DO;
PAGE1=PAGE1+1;
LNT=1;
END;
RUN;

TITLE1 J=L "COVID-19 AA";
TITLE2 J=L "Protocol: 043";
TITLE3 J=C "16.2.2.4  Adverse Events ";

FOOTNOTE1 J=L "G:\COVID08_042023\AH_Work\LIS8_3_AH.SAS";

OPTIONS ORIENTATION=LANDSCAPE;
ODS ESCAPECHAR='^';
ODS RTF FILE ="G:\COVID08_042023\OUTPUTS\L_16_2_2_4.RTF" STYLE=styles.test;

PROC REPORT DATA=ADAE SPLIT="|" STYLE={OUTPUTWIDTH=100%} NOWD;
COLUMN PAGE1 USUBJID SPA AESTDTC AEENDTC AESER AACN AREL AEOUT;

DEFINE PAGE1/ORDER NOPRINT;
DEFINE USUBJID/ORDER "Subject|Number"
STYLE (COLUMN) ={JUST=L CELLWIDTH=12%}
STYLE (HEADER) ={JUST=L CELLWIDTH=12%};

DEFINE SPA/ORDER "Adverse Event/Primary System Organ|Class/Preffered term"
STYLE (COLUMN) ={JUST=L CELLWIDTH=15%}
STYLE (HEADER) ={JUST=L CELLWIDTH=15%};

DEFINE AESTDTC/DISPLAY "Start|Date/Time"
STYLE (COLUMN) ={JUST=L CELLWIDTH=10%}
STYLE (HEADER) ={JUST=L CELLWIDTH=10%};

DEFINE AEENDTC/DISPLAY "End |Date/Time"
STYLE (COLUMN) ={JUST=L CELLWIDTH=10%}
STYLE (HEADER) ={JUST=L CELLWIDTH=10%};

DEFINE AESER/DISPLAY "Serious|Event"
STYLE (COLUMN) ={JUST=L CELLWIDTH=6%}
STYLE (HEADER) ={JUST=L CELLWIDTH=6%};

DEFINE AACNN/ORDER NOPRINT;
DEFINE AACN/DISPLAY "Action taken"
STYLE (COLUMN) ={JUST=L CELLWIDTH=8%}
STYLE (HEADER) ={JUST=L CELLWIDTH=8%};

DEFINE ARELN/ORDER NOPRINT;
DEFINE AREL/DISPLAY "Relationship|to|Study Drug"
STYLE (COLUMN) ={JUST=L CELLWIDTH=10%}
STYLE (HEADER) ={JUST=L CELLWIDTH=10%};

DEFINE AEOUT/"Outcome"
STYLE (COLUMN) ={JUST=L CELLWIDTH=9%}
STYLE (HEADER) ={JUST=L CELLWIDTH=9%};

COMPUTE BEFORE _PAGE_;
LINE@1 "^{STYLE [OUTPUTWIDTH=100% BORDERTOPWIDTH=0.5PT]}";
ENDCOMP;

COMPUTE AFTER _PAGE_;
LINE@1 "^{STYLE [OUTPUTWIDTH=100% BORDERTOPWIDTH=0.5PT]}";
ENDCOMP;

BREAK AFTER PAGE1/PAGE;
RUN;

ODS _ALL_ CLOSE;
