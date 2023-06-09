/*******************************************************************
* Client: XXXX                                                           
* Project:  COVID-19 AA                                                   
* Program: LIS5_2_AH.SAS  
*
* Program Type: Listing
*
* Purpose: To produce 16.2.1.5 Abnormal Biochemistry Values and
*                     16.2.1.6 Abnormal Hematology Values
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

OPTIONS MPRINT MLOGIC SYMBOLGEN;
%MACRO LAB (v1=,v2=,v3=,v4=);

DATA ADLB;
SET ADAM.ADLB;

IF PARCAT1 = "&V1" AND ANRIND NOT IN ("NORMAL","");

LOW=STRIP(PUT(ANRLO,BEST.));
HIGH=STRIP(PUT(ANRHI,BEST.));
L_H=STRIP(LOW)||"-"||STRIP(HIGH);
ADTM_C=STRIP(PUT(ADTM,DATETIME20.));

KEEP USUBJID PARAMN PARAM AVISITN AVISIT L_H ADTM_C AVALC ANRIND;
RUN;

/*PAGE NUMBER HANDLING*/
DATA ADLB;
SET ADLB;
RETAIN LNT 0 PAGE1 1;
LNT + 1;

IF LNT>20 THEN DO;
	PAGE1=PAGE1+1;
	LNT=1;
END;
RUN;

TITLE1 J=L "COVID-19 AA";
TITLE2 J=L "Protocol: 043";
TITLE3 J=C "&V2";

FOOTNOTE1 J=L "G:\COVID08_042023\AH_Work\&V3..SAS";

OPTIONS ORIENTATION=LANDSCAPE;
ODS ESCAPECHAR='^';
ODS RTF FILE="G:\COVID08_042023\OUTPUTS\&V4..RTF" STYLE=styles.test;

PROC REPORT DATA=ADLB SPLIT="|" STYLE={OUTPUTWIDTH=100%} NOWD;
COLUMN PAGE1 USUBJID PARAMN PARAM AVISITN AVISIT L_H ADTM_C AVALC ANRIND;

DEFINE PAGE1/ORDER NOPRINT;
DEFINE USUBJID/ORDER "Subject|Number"
STYLE (HEADER)={JUST=LEFT CELLWIDTH=15%}
STYLE (COLUMN)={JUST=LEFT CELLWIDTH=15%};

DEFINE PARAMN/ORDER NOPRINT;
DEFINE PARAMN/ORDER "Test"
STYLE (HEADER)={JUST=LEFT CELLWIDTH=26%}
STYLE (COLUMN)={JUST=LEFT CELLWIDTH=26%};

DEFINE AVISITN/ORDER NOPRINT;
DEFINE AVISIT/ORDER "Visit"
STYLE (HEADER)={JUST=LEFT CELLWIDTH=17%}
STYLE (COLUMN)={JUST=LEFT CELLWIDTH=17%};

DEFINE L_H/"Normal Range"
STYLE (HEADER)={JUST=LEFT CELLWIDTH=10%}
STYLE (COLUMN)={JUST=LEFT CELLWIDTH=10%};

DEFINE ADTM_C/"Date/Time of|Measurement"
STYLE (HEADER)={JUST=LEFT CELLWIDTH=16%}
STYLE (COLUMN)={JUST=LEFT CELLWIDTH=16%};

DEFINE AVALC/"Result"
STYLE (HEADER)={JUST=LEFT CELLWIDTH=5%}
STYLE (COLUMN)={JUST=LEFT CELLWIDTH=5%};

DEFINE ANRIND/"Flag"
STYLE (HEADER)={JUST=LEFT CELLWIDTH=8%}
STYLE (COLUMN)={JUST=LEFT CELLWIDTH=8%};

COMPUTE BEFORE _PAGE_;
LINE@1 "^{STYLE [OUTPUTWIDTH=100% BORDERTOPWIDTH=0.5PT]}";
ENDCOMP;

COMPUTE AFTER _PAGE_;
LINE@1 "^{STYLE [OUTPUTWIDTH=100% BORDERTOPWIDTH=0.5PT]}";
ENDCOMP;

BREAK AFTER PAGE1/PAGE;
RUN;

ODS _ALL_ CLOSE;

%MEND;
%LAB (V1=CHEMISTRY,
     V2=%STR(16.2.1.5 Abnormal Biochemistry Values),
     V3=%STR(LIS5_1_AH),
	 V4=%STR(L_16_2_1_5));

 %LAB (V1=HEMATOLOGY,
     V2=%STR(16.2.1.6 Abnormal Hematology Values),
     V3=%STR(LIS5_2_AH),
	 V4=%STR(L_16_2_1_6));

