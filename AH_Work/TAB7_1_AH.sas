/*******************************************************************
* Client: XXXX                                                           
* Project:  COVID-19 AA                                                   
* Program: TAB7_1_AH.SAS  
*
* Program Type: Tables
*
* Purpose: To produce Table 14.1.9 Summary of Changes in Vital Signs from Baseline to Final Visit (Safety Population)
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

PROC SUMMARY DATA=ADAM.ADVS NWAY;
WHERE SAFFL EQ 'Y';
CLASS PARAMN PARAM TRT01AN TRT01A AVISITN AVISIT;
VAR AVAL;
OUTPUT OUT=ADSL_AVAL_SUM
n=_n mean=_mean median=_median std=_sd min=_min max=_max;
RUN;

/*decimal adjustment as per shell*/

DATA ADSL_AVAL_SUM2;
SET ADSL_AVAL_SUM;

cn=LEFT(PUT(_n,4.));
cmin=LEFT(PUT(_min,4.));
cmax=LEFT(PUT(_max,4.));

cmean=LEFT(PUT(_mean,5.1));
cmedian=LEFT(PUT(_median,5.1));

cstd=LEFT(PUT(_sd,6.2));

KEEP PARAMN PARAM TRT01AN TRT01A AVISITN AVISIT C:;
RUN;

/*CHANGE FROM BASELINE STATISTICS*/

PROC SUMMARY DATA=ADAM.ADVS NWAY;
WHERE SAFFL EQ 'Y' AND AVISITN GT 1;
/* DISPLAY ONLY AFTER THE SCR VISIT*/

CLASS PARAMN PARAM TRT01AN TRT01A AVISITN AVISIT;
VAR CHG;
OUTPUT OUT=ADSL_CHG_SUM
n=_n mean=_mean median=_median std=_sd min=_min max=_max;
RUN;

/*decimal adjustment as per shell*/

DATA ADSL_CHG_SUM2;
SET ADSL_CHG_SUM;
hn=LEFT(PUT(_n,4.));
hmin=LEFT(PUT(_min,4.));
hmax=LEFT(PUT(_max,4.));

hmean=LEFT(PUT(_mean,5.1));
hmedian=LEFT(PUT(_median,5.1));

hstd=LEFT(PUT(_sd,6.2));
KEEP PARAMN PARAM TRT01AN TRT01A AVISITN AVISIT H:;
RUN;

DATA FINAL;
MERGE ADSL_AVAL_SUM2 ADSL_CHG_SUM2;
BY PARAMN PARAM TRT01AN TRT01A AVISITN AVISIT;
RUN;

/*PAGE NUMBER HANDLING*/

DATA TAB7_1_FINAL;
SET FINAL;
RETAIN LNT 0 PAGE1 1;
LNT + 1;
IF LNT>15 OR FIRST.PARAMN THEN DO;
	PAGE1=PAGE1+1;
	LNT=1;
END;
RUN;

TITLE1 J=L "COVID-19 AA";
TITLE2 J=L "Protocol: 043";
TITLE3 J=C "Table 14.1.9 Summary of Changes in Vital Signs from Baseline to Final Visit (Safety Population)";

FOOTNOTE1 J=L "G:\COVID08_042023\AH_Work\TAB7_1_AH.SAS";

OPTIONS ORIENTATION=LANDSCAPE;
ODS ESCAPECHAR='^';
ODS RTF FILE="G:\COVID08_042023\OUTPUTS\T_14_1_9.RTF" STYLE=styles.test;

PROC REPORT DATA=TAB7_1_FINAL SPLIT="|" STYLE={OUTPUTWIDTH=100%} NOWD MISSING;
COLUMN PAGE1 PARAMN PARAM TRT01AN TRT01A AVISITN AVISIT

("Observed" "--------------------------------------"
cn cmean cmedian cstd cmin cmax)

("Change from baseline " "--------------------------------------"
hn hmean hmedian hstd hmin hmax);

DEFINE PAGE1/ORDER NOPRINT;
DEFINE PARAMN/ORDER NOPRINT;
DEFINE PARAM/ORDER NOPRINT;
DEFINE TRT01AN/ORDER NOPRINT;

DEFINE TRT01A/ORDER "Treatment"
STYLE(HEADER)={JUST=L CELLWIDTH=8%}
STYLE(COLUMN)={JUST=L CELLWIDTH=8%};

DEFINE AVISITN/ORDER NOPRINT;
DEFINE AVISIT/ORDER "Visit"
STYLE(HEADER)={JUST=L CELLWIDTH=15%}
STYLE(COLUMN)={JUST=L CELLWIDTH=15%};

DEFINE cn/ORDER "n"
STYLE(HEADER)={JUST=L CELLWIDTH=3%}
STYLE(COLUMN)={JUST=L CELLWIDTH=3%};

DEFINE cmean/ORDER "Mean"
STYLE(HEADER)={JUST=L CELLWIDTH=5%}
STYLE(COLUMN)={JUST=L CELLWIDTH=5%};

DEFINE cmedian/ORDER "Median"
STYLE(HEADER)={JUST=L CELLWIDTH=5%}
STYLE(COLUMN)={JUST=L CELLWIDTH=5%};

DEFINE cstd/ORDER "SD"
STYLE(HEADER)={JUST=L CELLWIDTH=5%}
STYLE(COLUMN)={JUST=L CELLWIDTH=5%};

DEFINE cmin/ORDER "Min"
STYLE(HEADER)={JUST=L CELLWIDTH=5%}
STYLE(COLUMN)={JUST=L CELLWIDTH=5%};

DEFINE cmax/ORDER "Max"
STYLE(HEADER)={JUST=L CELLWIDTH=5%}
STYLE(COLUMN)={JUST=L CELLWIDTH=5%};

DEFINE hn/ORDER "n"
STYLE(HEADER)={JUST=L CELLWIDTH=3%}
STYLE(COLUMN)={JUST=L CELLWIDTH=3%};

DEFINE hmean/ORDER "Mean"
STYLE(HEADER)={JUST=L CELLWIDTH=5%}
STYLE(COLUMN)={JUST=L CELLWIDTH=5%};

DEFINE hmedian/ORDER "Median"
STYLE(HEADER)={JUST=L CELLWIDTH=5%}
STYLE(COLUMN)={JUST=L CELLWIDTH=5%};

DEFINE hstd/ORDER "SD"
STYLE(HEADER)={JUST=L CELLWIDTH=5%}
STYLE(COLUMN)={JUST=L CELLWIDTH=5%};

DEFINE hmin/ORDER "Min"
STYLE(HEADER)={JUST=L CELLWIDTH=5%}
STYLE(COLUMN)={JUST=L CELLWIDTH=5%};

DEFINE hmax/ORDER "Max"
STYLE(HEADER)={JUST=L CELLWIDTH=5%}
STYLE(COLUMN)={JUST=L CELLWIDTH=5%};

COMPUTE BEFORE _PAGE_;
LINE@1 "Parameter:" param $;
LINE@1 "^{STYLE [OUTPUTWIDTH=100% BORDERBOTTOMWIDTH=0.5PT]}";
ENDCOMP;

COMPUTE AFTER _PAGE_;
LINE@1 "^{STYLE [OUTPUTWIDTH=100% BORDERTOPWIDTH=0.5PT]}";
ENDCOMP;
BREAK AFTER PARAMN/PAGE;
RUN;

ODS _ALL_ CLOSE;
