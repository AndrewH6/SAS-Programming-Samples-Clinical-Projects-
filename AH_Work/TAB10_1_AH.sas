/*******************************************************************
* Client: XXXX                                                           
* Project:  COVID-19 AA                                                   
* Program: TAB10_1_AH.SAS  
*
* Program Type: Tables
*
* Purpose: To produce Table 14.1.12 Summary of Hospitalization Due to COVID-19 Symptomswitha 2x2 Contingency Table
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

/*Header part capital/Big N counts*/

DATA ADSL;
SET ADAM.ADSL;
IF SAFFL EQ 'Y';
KEEP USUBJID TRT01P TRT01PN;
RUN;

PROC FREQ DATA=ADSL;
TABLES TRT01PN*TRT01P/OUT=CT (DROP=PERCENT RENAME=(COUNT=BIGN));
RUN;

/*CONVERTING THE COUNTS INTO MACRO VARIBALE*/

PROC SQL NOPRINT;
SELECT BIGN INTO: N1 - :N2 FROM CT;
QUIT;

%PUT &N1 &N2;

/*BODY PART SECTION COUNTS*/

DATA ADSL;
SET ADAM.ADSL;
IF HOSPCOFL EQ '' THEN HOSPCOFL='N';
IF TRT01P NE '';
KEEP USUBJID TRT01PN TRT01P HOSPCOFL;
RUN;

/*n (%)*/

PROC SQL NOPRINT;
CREATE TABLE CNT AS
SELECT TRT01PN, TRT01P, HOSPCOFL, COUNT(DISTINCT USUBJID) AS n
FROM ADSL
GROUP BY TRT01PN, TRT01P, HOSPCOFL
ORDER BY TRT01PN, TRT01P, HOSPCOFL;
QUIT;

PROC SORT DATA=CNT OUT=FINAL;BY TRT01PN;RUN;
PROC SORT DATA=CT;BY TRT01PN;RUN;

/*MERGE n DATASET WITH Bign n DATASET*/

DATA PCT;
MERGE FINAL (IN=A) CT;
BY TRT01PN;
IF A;

GRP=PUT(n,4.)||"("||PUT(n/BIGN*100,5.1)||")";
RUN;

DATA PCT_Y;
SET PCT;
IF HOSPCOFL='Y';
NEW='n (%)';
RUN;

PROC TRANSPOSE DATA=PCT_Y OUT=PCT2;
BY NEW;
ID TRT01PN;
VAR GRP;
RUN;

DATA _1;
SET PCT2;
LENGTH C0 C1 C2 $100.;
C0=STRIP(NEW);
C1=STRIP(_1);
C2=STRIP(_2);
OD=1;
KEEP OD C0 C1 C2;
RUN;

/*95% CI for Hospitalization Rate[a]*/
/*STAT'S WILL PROVIDE YOU THE SYNTAX*/

ODS TRACE ON;
ODS OUTPUT BinomialCLs=CI;

PROC FREQ DATA=PCT;
BY TRT01PN;
TABLES HOSPCOFL/BINOMIAL (LEVEL="Y" EXACT);
WEIGHT n/ZEROS;
RUN;

ODS TRACE OFF;

DATA CI1;
SET CI;
n="("|| STRIP (PUT (LowerCL,5.2))||", "||STRIP (PUT (UpperCL,5.2))||")";
RUN;

DATA CI2;
SET CI1;
NEW='95% CI for Hospitalization Rate[a]';
RUN;

PROC TRANSPOSE DATA=CI2 OUT=CI3;
BY NEW;
ID TRT01PN;
VAR N;
RUN;

DATA _2;
SET CI3;
LENGTH C0 C1 C2 $100.;
C0=STRIP(NEW);
C1=STRIP(_1);
C2=STRIP(_2);
OD=2;
KEEP OD C0 C1 C2;
RUN;

/*p-value[b]*/

ODS TRACE ON;
ODS OUTPUT FishersExact=PVAL (WHERE=(Name1='XP2_FISH'));
PROC FREQ DATA=PCT;
TABLES TRT01PN*HOSPCOFL/CHISQ;
WEIGHT n;
RUN;
ODS TRACE OFF;

DATA _3;
SET PVAL;
LENGTH C0 C1 C2 $100.;
C0='p-value[b]';
C1=PUT(nValue1,6.4);
C2='';
OD=3;
KEEP OD C0 C1 C2;
RUN;

DATA FINAL;
SET _1 _2 _3;
RUN;

TITLE1 J=L "COVID-19 AA";
TITLE2 J=L "Protocol: 043";
TITLE3 J=C "Table 14.1.12 Summary of Hospitalization Due to COVID-19 Symptomswitha 2x2 Contingency Table";

FOOTNOTE1 J=L "p-value is provided byFisher Exact test";
FOOTNOTE2 J=L "G:\COVID08_042023\AH_Work\TAB10_1_AH.SAS";

OPTIONS ORIENTATION=LANDSCAPE;
ODS ESCAPECHAR='^';
ODS RTF FILE="G:\COVID08_042023\OUTPUTS\T_14_1_12.RTF" STYLE=styles.test;

PROC REPORT DATA=FINAL SPLIT="|" STYLE={OUTPUTWIDTH=100%} NOWD;
COLUMN OD C0 C1 C2;

DEFINE OD/ORDER NOPRINT;
DEFINE C0/ORDER "Statistic"
STYLE(HEADER)={JUST=L CELLWIDTH=39%}
STYLE(COLUMN)={JUST=L CELLWIDTH=39%};

DEFINE C1/"Tafenoquine|(N=&N1)"
STYLE(HEADER)={JUST=L CELLWIDTH=20%}
STYLE(COLUMN)={JUST=L CELLWIDTH=20%};

DEFINE C2/"Placebo|(N=&N2)"
STYLE(HEADER)={JUST=L CELLWIDTH=20%}
STYLE(COLUMN)={JUST=L CELLWIDTH=20%};

COMPUTE BEFORE _PAGE_;
LINE@1 "^{STYLE [OUTPUTWIDTH=100% BORDERTOPWIDTH=0.5PT]}";
ENDCOMP;

COMPUTE AFTER _PAGE_;
LINE@1 "^{STYLE [OUTPUTWIDTH=100% BORDERTOPWIDTH=0.5PT]}";
ENDCOMP;

RUN;

ODS _ALL_ CLOSE;

























