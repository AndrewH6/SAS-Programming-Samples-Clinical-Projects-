*******************************************************************
* Client: XXXX                                                           
* Project:  COVID-19 AA                                                   
* Program: FIG1_AH.SAS  
*
* Program Type: Figures
*
* Purpose: To produce Figure 16.1.1 Distribution of Hemotology Values by Treatment
* Usage Notes: 
*
* SAS® Version: 9.4
* Operating System:                    
*
* Author: Andrew Huang
* Date Created: 29-Mar-2023
* Modification History:
*******************************************************************/

/*TO ACCESS THE DATA*/;

LIBNAME ADAM "G:\COVID08_042023\ADAM datasets";

%include "G:\COVID08_042023\PROGRAMS\_RTFSTYLE_.sas";
%_RTFSTYLE_;

DATA LB1;
SET ADAM.ADLB;
LABEL VALUE="Analysis value";
IF PARCAT1 EQ 'HEMATOLOGY' AND TRT01A NE '';
TEST=PARAMCD;
DRUG=TRT01A;
VALUE=AVAL;
KEEP TEST DRUG VALUE;
RUN;

TITLE1 J=L "COVID-19 AA";
TITLE2 J=L "Protocol: 043";
TITLE3 J=C "Figure 16.1.1 ";
TITLE4 J=C "Distribution of Hemotology Values by Treatment";

OPTIONS ORIENTATION=LANDSCAPE;
ODS ESCAPECHAR='^';
ODS RTF FILE="G:\COVID08_042023\OUTPUTS\16_1_1.RTF" STYLE=styles.test;

ODS GRAPHICS ON / WIDTH=10in;
ODS GRAPHICS ON / HEIGHT=4in;

PROC SGPLOT DATA=LB1;
	VBOX VALUE / CATEGORY=TEST GROUP=DRUG;
	XAXIS LABEL="Treatment";
	KEYLEGEND / TITLE="Drug Type";
RUN;


ODS _ALL_ CLOSE;



