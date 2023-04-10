/*******************************************************************
* Client: XXXX                                                           
* Project:  COVID-19 AA                                                   
* Program: TAB5_1_AH.SAS  
*
* Program Type: Tables
*
* Purpose: To produce Table 14.1.6 Subject Demographics -Sex and Race  (Safety Population)
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

/*Header part capital/Big N counts*/

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
SELECT BIGN INTO: N1 - :N3 FROM CT;
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
KEEP USUBJID TRT01A TRT01AN SEX RACE;
RUN;

/*to get the count*/
/*sex cat*/

PROC FREQ DATA=ADSL2;
TABLES SEX*TRT01AN/OUT=GEN1 (DROP=PERCENT RENAME=(COUNT=N));
RUN;

DATA GEN2;
SET GEN1;
LENGTH CAT STAT $50.;
CAT='Gender';
CATN=1;
IF SEX='M' THEN DO;STAT="Male";OD=1;END;
IF SEX="F" THEN DO;STAT="Female";OD=2;END;
RUN;

PROC SORT; BY CATN OD;RUN;

/*race cat*/

PROC FREQ DATA=ADSL2;
TABLES RACE*TRT01AN/OUT=RACE1 (DROP=PERCENT RENAME=(COUNT=N));
RUN;

PROC SORT; BY TRT01AN RACE;RUN;

/*creating dummy*/

PROC SORT DATA=RACE1 OUT=RACE_D (KEEP=TRT01AN) NODUPKEY;
BY TRT01AN;
RUN;

DATA DUMMY_RACE;
SET RACE_D;
LENGTH RACE $200.;
DO RACE='AMERICAN INDIAN OR ALASKA NATIVE', 
	    'ASIAN',
        'BLACK OR AFRICAN AMERICAN', 
		'NATIVE HAWAIIAN OR OTHER PACIFIC ISLANDER',
		'WHITE',
		'DECLINED TO ANSWER',
		'OTHER';
   OUTPUT;
END;
RUN;

PROC SORT;BY TRT01AN RACE;RUN;

DATA RACE2;
MERGE DUMMY_RACE RACE1;
BY TRT01AN RACE;
IF N EQ . THEN N=0;
RUN;

DATA RACE2;
SET RACE2;
LENGTH CAT STAT $50.;
CAT='Race';
CATN=2;

IF RACE="AMERICAN INDIAN OR ALASKA NATIVE" THEN DO;
	OD=1;
	STAT='American indian or alaska native';
	END;

IF RACE="ASIAN" THEN DO;
	OD=2;
	STAT='Asian';
	END;

IF RACE="BLACK OR AFRICAN AMERICAN" THEN DO;
	OD=3;
	STAT='Black or african american';
	END;

IF RACE="NATIVE HAWAIIAN OR OTHER PACIFIC ISLANDER" THEN DO;
	OD=4;
	STAT='Native hawaiian or other pacific islander';
	END;

IF RACE="WHITE" THEN DO;
	OD=5;
	STAT='White';
	END;

IF RACE="DECLINED TO ANSWER" THEN DO;
	OD=6;
	STAT='Declined to answer';
	END;

IF RACE="OTHER" THEN DO;
	OD=7;
	STAT='Other';
	END;

RUN;

PROC SORT;BY CATN OD;RUN;

DATA FINAL;
RETAIN CATN CAT OD STAT N TRT01AN;
SET GEN2 RACE2;
KEEP CATN CAT OD STAT N TRT01AN;
RUN;

PROC SORT DATA=FINAL;BY TRT01AN;RUN;

PROC SORT DATA=CT;BY TRT01AN;RUN;

/*MERGE n DATASET WITH Bign n DATASET*/

DATA PCT;
MERGE FINAL (IN=A) CT;
BY TRT01AN;
IF A;
GRP=PUT(N,4.)||"("||PUT(N/BIGN*100,5.1)||")";
RUN;

PROC SORT;BY CATN CAT OD STAT;RUN;

PROC TRANSPOSE DATA=PCT OUT=PCT1 (DROP=_NAME_);
BY CATN CAT OD STAT;
ID TRT01AN;
VAR GRP;
RUN;

DATA TAB5_1_FINAL;
SET PCT1;
IF COMPRESS(_1) IN ('','0(0.0)') THEN _1='  0';
IF COMPRESS(_2) IN ('','0(0.0)') THEN _2='  0';
IF COMPRESS(_3) IN ('','0(0.0)') THEN _3='  0';
RUN;

TITLE1 J=L "COVID-19 AA";
TITLE2 J=L "Protocol: 043";
TITLE3 J=C "Table 14.1.6 Subject Demographics -Sex and Race  (Safety Population)";

FOOTNOTE1 J=L "G:\COVID08_042023\AH_Work\TAB5_1_AH.SAS";

OPTIONS ORIENTATION=LANDSCAPE;
ODS ESCAPECHAR='^';
ODS RTF FILE="G:\COVID08_042023\OUTPUTS\T_14_1_6.RTF" STYLE=styles.test;

PROC REPORT DATA=TAB5_1_FINAL SPLIT="|" STYLE={OUTPUTWIDTH=100%} NOWD;
COLUMN CATN CAT OD STAT _1 _2 _3;

DEFINE CATN/ORDER NOPRINT;

DEFINE CAT/ORDER "Category"
STYLE (HEADER)={JUST=L CELLWIDTH=10%}
STYLE (COLUMN)={JUST=L CELLWIDTH=10%};

DEFINE OD/ORDER NOPRINT;

DEFINE STAT/ORDER "Statistic"
STYLE (HEADER)={JUST=L CELLWIDTH=29%}
STYLE (COLUMN)={JUST=L CELLWIDTH=29%};

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

COMPUTE BEFORE CATN;
LINE '';
ENDCOMP;
RUN;

ODS _ALL_ CLOSE;
