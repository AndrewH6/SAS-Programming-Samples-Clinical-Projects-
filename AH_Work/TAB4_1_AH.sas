/*******************************************************************
* Client: XXXX                                                           
* Project:  COVID-19 AA                                                   
* Program: TAB4_1_AH.SAS  
*
* Program Type: Tables
*
* Purpose: To produce Table 14.1.5  Subject Demographics (Safety Population)
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
IF SAFFL EQ 'Y';
OUTPUT;
TRT01AN=3;
TRT01A="ALL";
OUTPUT;
KEEP USUBJID TRT01A TRT01AN;
RUN;

PROC FREQ DATA=ADSL;
TABLES TRT01AN*TRT01A/OUT=CT (DROP=PERCENT RENAME=(COUNT=BIGN));
RUN;

/*CONVERTING THE COUNTS INTO MACRO VARIBALE*/

PROC SQL NOPRINT;
SELECT BIGN INTO: N1 -:N3 FROM CT;
QUIT;
%PUT &N1 &N2 &N3;

/*BODY PART SECTION COUNTS*/

DATA ADSL2;
SET ADAM.ADSL;
IF SAFFL EQ 'Y';
OUTPUT;
TRT01AN=3;
TRT01A="ALL";
OUTPUT;
KEEP USUBJID TRT01A TRT01AN BBMISI BHGHTSI BWGHTSI;
RUN;

%MACRO SUMM(V1=,V2=,V3=,V4=);
PROC SUMMARY DATA = ADSL2 NWAY;
CLASS TRT01AN TRT01A;
VAR &V1;
OUTPUT OUT=ADSL_SUM
n=_n mean=_mean median=_median std=_sd min=_min max=_max;
RUN;

/*decimal adjustment as per shell*/

DATA ADSL_SUM2;
SET ADSL_SUM;
cn=LEFT(PUT(_n,4.));
cmin=LEFT(PUT(_min,4.));
cmax=LEFT(PUT(_max,4.));

cmean=LEFT(PUT(_mean,5.1));
cmedian=LEFT(PUT(_median,5.1));

cstd=LEFT(PUT(_median,5.1));
OD=&V2;

PROC TRANSPOSE DATA=ADSL_SUM2 OUTPUT=ADSL_SUM3;
BY OD;
ID TRT01AN;
VAR cn cmean cmedian cstd cmin cmax;
RUN;

/*giving lables as per mock*/

DATA ADSL_SUM4;
SET ADSL_SUM3;
LENGTH STAT $100.;
IF _NAME_='cn' THEN DO;STAT='N';STATORD=1;END;
IF _NAME_='cmean' THEN DO;STAT='Mean';STATORD=2;END;
IF _NAME_='cstd' THEN DO;STAT='SD';STATORD=3;END;
IF _NAME_='cmedian' THEN DO;STAT='Median';STATORD=4;END;
IF _NAME_='cmin' THEN DO;STAT='Minimum';STATORD=5;END;
IF _NAME_='cmax' THEN DO;STAT='Maximum';STATORD=6;END;
RUN;

DATA LABEL;
LENGTH STAT $100.;
STAT="&V3";
STATORD=0;
OD=&V2;
RUN;

DATA &V4;
SET LABEL ADSL_SUM4;
DROP _NAME_;
RUN;

PROC SORT;BY OD STATORD;RUN;
%MEND;

%SUMM(V1=BHGHTSI,
V2=1,
V3=%STR(Height (cm)),
V4=HT
);

%SUMM(V1=BWGHTSI,
V2=2,
V3=%STR(Weight (Kg)),
V4=WT
);

%SUMM(V1=BBMISI,
V2=3,
V3=%STR(BMI (kg/m2)),
V4=BMI
);

DATA FINAL;
SET HT WT BMI;
RUN;

TITLE1 J=L "COVID-19 AA";
TITLE2 J=L "Protocol: 043";
TITLE3 J=C "Table 14.1.5  Subject Demographics (Safety Population)";

FOOTNOTE1 J=L "G:\COVID08_042023\AH_Work\TAB4_1_AH.SAS";

OPTIONS ORIENTATION=LANDSCAPE;
ODS ESCAPECHAR='^';
ODS RTF FILE="G:\COVID08_042023\OUTPUTS\T_14_1_5.RTF" STYLE=styles.test;

PROC REPORT DATA=final SPLIT="|" STYLE={OUTPUTWIDTH=100%} NOWD;
COLUMN OD STATORD STAT _1 _2 _3;

DEFINE OD/ORDER NOPRINT;
DEFINE STATORD/ORDER NOPRINT;

DEFINE STAT/ORDER "CATEGORY"
STYLE (HEADER)={JUST=L CELLWIDTH=39%}
STYLE (COLUMN)={JUST=L CELLWIDTH=39%};

DEFINE _1/ "DRUG A|(N=&N1)"
STYLE (HEADER)={JUST=L CELLWIDTH=20%}
STYLE (COLUMN)={JUST=L CELLWIDTH=20%};

DEFINE _2/ "DRUG B|(N=&N2)"
STYLE (HEADER)={JUST=L CELLWIDTH=20%}
STYLE (COLUMN)={JUST=L CELLWIDTH=20%};

DEFINE _3/ "ALL|(N=&N3)"
STYLE (HEADER)={JUST=L CELLWIDTH=20%}
STYLE (COLUMN)={JUST=L CELLWIDTH=20%};

COMPUTE BEFORE _PAGE_;
LINE@1 "^{STYLE [OUTPUTWIDTH=100% BORDERTOPWIDTH=0.5PT]}";
ENDCOMP;

COMPUTE AFTER _PAGE_;
LINE@1 "^{STYLE [OUTPUTWIDTH=100% BORDERTOPWIDTH=0.5PT]}";
ENDCOMP;

COMPUTE BEFORE OD;
LINE '';
ENDCOMP;
RUN;

ODS _ALL_ CLOSE;
