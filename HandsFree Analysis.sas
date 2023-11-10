/*Importing the Data*/
options nolabel;
options validvarname=any;
/* FARS Dataset 2021 */
%web_drop_table(WORK.accident21);
FILENAME REFFILE '/home/u62699350/sasuser.v94/DATA 4400/accident.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=WORK.accident21;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=WORK.accident21; RUN;
%web_open_table(WORK.accident21);

/* FARS Dataset 2020 */
%web_drop_table(WORK.accident20);
FILENAME REFFILE '/home/u62699350/sasuser.v94/DATA 4400/accident2020.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=WORK.accident20;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=WORK.accident20; RUN;
%web_open_table(WORK.accident20);

/*FARS Dataset 2019*/
%web_drop_table(WORK.accident19);
FILENAME REFFILE '/home/u62699350/sasuser.v94/DATA 4400/accident2019.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=WORK.accident19;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=WORK.accident19; RUN;
%web_open_table(WORK.accident19);

/* FARS Dataset 2018 */
%web_drop_table(WORK.accident18);
FILENAME REFFILE '/home/u62699350/sasuser.v94/DATA 4400/accident2018.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=WORK.accident18;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=WORK.accident18; RUN;
%web_open_table(WORK.accident18);

/* FARS Dataset 2017 */
%web_drop_table(WORK.accident17);
FILENAME REFFILE '/home/u62699350/sasuser.v94/DATA 4400/accident2017.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=WORK.accident17;
	GETNAMES=YES;
RUN;
PROC CONTENTS DATA=WORK.accident17; RUN;
%web_open_table(WORK.accident17);

/* FARS Dataset 2016 */
%web_drop_table(WORK.accident16);
FILENAME REFFILE '/home/u62699350/sasuser.v94/DATA 4400/accident2016.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=WORK.accident16;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=WORK.accident16; RUN;
%web_open_table(WORK.accident16);

/* FARS Dataset 2015 */
%web_drop_table(WORK.accident15);
FILENAME REFFILE '/home/u62699350/sasuser.v94/DATA 4400/accident2015.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=WORK.accident15;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=WORK.accident15; RUN;
%web_open_table(WORK.accident15);

/*Keep Statements: Individual because Varible types are inconsistent*/
data work.accident2021;
	set work.accident21 (where=(STATENAME eq 'Georgia'));
	keep YEAR MONTH MONTHNAME DAY DAY_WEEK FUNC_SYS FUNC_SYSNAME FATALS
	WEATHERNAME WEATHER MAN_COLL MAN_COLLNAME;
run;

data work.accident2020;
	set work.accident20 (where=(STATENAME eq 'Georgia'));
	keep YEAR MONTH MONTHNAME DAY DAY_WEEK FUNC_SYS FUNC_SYSNAME FATALS
	WEATHERNAME WEATHER MAN_COLL MAN_COLLNAME;
run;

data work.accident2019;
	set work.accident19 (where=(STATENAME eq 'Georgia'));
	keep YEAR MONTH MONTHNAME DAY DAY_WEEK FUNC_SYS FUNC_SYSNAME FATALS
	WEATHERNAME WEATHER MAN_COLL MAN_COLLNAME;
run;

data work.accident2018;
	set work.accident18 (where=(STATENAME eq 'Georgia'));
	keep YEAR MONTH MONTHNAME DAY DAY_WEEK FUNC_SYS FUNC_SYSNAME FATALS
	WEATHERNAME WEATHER MAN_COLL MAN_COLLNAME;
run;

data work.accident2017;
	set work.accident17 (where=(STATENAME eq 'Georgia'));
	keep YEAR MONTH MONTHNAME DAY DAY_WEEK FUNC_SYS FUNC_SYSNAME FATALS
	WEATHERNAME WEATHER MAN_COLL MAN_COLLNAME;
run;

data work.accident2016;
	set work.accident16 (where=(STATENAME eq 'Georgia'));
	keep YEAR MONTH MONTHNAME DAY DAY_WEEK FUNC_SYS FUNC_SYSNAME FATALS
	WEATHERNAME WEATHER MAN_COLL MAN_COLLNAME;
run;	

data work.accident2015;
	set work.accident15 (where=(STATENAME eq 'Georgia'));
	keep YEAR MONTH MONTHNAME DAY DAY_WEEK FUNC_SYS FUNC_SYSNAME FATALS
	WEATHERNAME WEATHER MAN_COLL MAN_COLLNAME;
run;

/*Finding the longest length for MAN_COLLNAME as to not truncate the data*/
proc contents data=work.accident2017;
run;
proc contents data=work.accident2018;
run;
proc contents data=work.accident2019;
run;
proc contents data=work.accident2020;
run;
proc contents data=work.accident2021;
run;
/*77*/

/*Merging Datasets into Georgia*/
data work.Georgia;
	length MAN_COLLNAME $77;
	set work.accident2015 work.accident2016 work.accident2017 work.accident2018 
	work.accident2019 work.accident2020 work.accident2021;
	rename MAN_COLLNAME = "Collision Direction"n;
run;

proc freq data=work.Georgia;
	tables "Collision Direction"n WEATHERNAME FUNC_SYSNAME;
run;

data work.Georgia;
	set work.Georgia;
	length 'Road Type'n $24;
	
	if FUNC_SYS IN (1, 2) then 'Road Type'n = 'A';
	else if FUNC_SYS = 3 then 'Road Type'n = 'B';
	else if FUNC_SYS IN (5, 6) then 'Road Type'n = 'C';
	else if FUNC_SYS IN (4, 7) then 'Road Type'n = 'D';
	else 'Road Type'n = 'E';

Run;

Proc format;
	Value $funcFormat 'A' = "Interstates and Freeways" 'B' = "Metropolitan Roads" 'C'="Collectors"
	'D' = "Lower Density Roads" 'E' = "Unknown";
run;

data work.Georgia;
	set work.Georgia;
	format 'Road Type'n $funcFormat.;
run;

/*Ordering Weekday*/
data work.Georgia;
	set work.Georgia;
	length Weekday $9;
	
	if DAY_WEEK = 1 then Weekday = 'A';
	else if DAY_WEEK = 2 then Weekday = 'B';
	else if DAY_WEEK = 3 then Weekday = 'C';
	else if DAY_WEEK = 4 then Weekday = 'D';
	else if DAY_WEEK = 5 then Weekday = 'E';
	else if DAY_WEEK = 6 then Weekday = 'F';
	else if DAY_WEEK = 7 then Weekday = 'G';
Run;

Proc format;
	Value $dayFormat 'A' = "Sunday" 'B' = "Monday" 'C'="Tuesday"
	'D' = "Wednesday" 'E'="Thursday" 'F'="Friday" 'G'="Saturday" ;
run;

data work.Georgia;
	set work.Georgia;
	format Weekday $dayFormat.;
run;

/*Creating Weather Type*/
data work.Georgia;
	set work.Georgia;
	length 'Weather Condition'n $24;
	
	if WEATHERNAME eq 'Clear' then 'Weather Condition'n = 'A';
	else if WEATHERNAME eq 'Cloudy' then 'Weather Condition'n = 'B';
	else if WEATHERNAME eq 'Rain' or WEATHERNAME eq 'Freezing Rain or Drizzle' then 'Weather Condition'n = 'C';
	else if WEATHERNAME eq 'Blowing Snow' or WEATHERNAME eq 'Sleet or Hail' or WEATHERNAME eq 'Snow' then 'Weather Condition'n = 'D';
	else 'Weather Condition'n = 'E';
Run;
/*attaching the format*/
Proc format;
	Value $weatherFormat 'A' = "Clear" 'B' = "Cloudy" 'C'="Rain"
	'D' = "Snowy" 'E'="Unknown" ;
run;

data work.Georgia;
	set work.Georgia;
	format 'Weather Condition'n $weatherFormat.;
run;
/*Checking that the formats applied*/
proc freq data=work.Georgia;
	tables Weekday 'Road Type'n 'Weather Condition'n;
run;

/* Frequency Table of Year */
proc freq data=work.Georgia;
	tables Year;
run;

/*Adding rows for dates where there were not fatal accidents*/
/*How is Jan 1, 2015 stored in sas? What is Dec 31, 2021?*/
/*Creating a row for the date as a sas value*/
data work.Georgia;
  set work.Georgia;
  Date=mdy(MONTH,DAY,YEAR); /* SAS Function to turn 3 inputs into 1 date */
  format Date mmddyy10.;
run;


/*Beginning to change the unit of observation from fatal accidents to day*/
data work.dates;
	firstDate = '01JAN2015'd; /*Finding how SAS stores the first date of the observation period*/
	lastDate = '31DEC2021'd;  /*Finding how SAS stores the last date of the observation period*/
run;
/* Jan 1, 2015 20089	Dec 31, 2021 22645	 */
/*Creating the total number of accidents and fatalities per day*/
/* Sorting in order of date */
proc sort data=work.Georgia;
	by Date;
run;

/*Making each row one day with the total number of accidents and fatalities*/
proc summary data=work.Georgia;
	var FATALS;
	by Date;
	output out=work.byDay sum=;
run;
/*Making the dataset more readable*/
data work.byDay;
	set work.byDay;
	drop _TYPE_;
	rename _FREQ_ = "Number of Accidents"n;
	rename FATALS = "Number of Fatalities"n;
run;
/*Creating a dataset of all of the dates from Jan 1, 2015 to Dec 31, 2021 to compare to*/
data work.blanks;
	do Date = 20089 to 22645; /*The range of values that sas stores from 1-1-15 to 12-31-21*/
	output;
	end;
	format Date mmddyy10.; /*Applying the format that has the value appear as a readable date*/
run;

/* Make sure I know exactly how this works and can explain it */
/*Creating a second dataset taht has zeros for the days that there was not a fatal accident in Georgia from 2015-2021*/
data work.allDays;
	merge
	work.byDay
	work.blanks;  /*Combining the Data sets, if there is a row for the date in byDay the data is kept, if there*/
	by Date; /*is no row then blanks fill in from "blanks" and a '.' is inserted for the # of accidents and fatalities*/
run;

/* Replacing '.'s with zeros*/
data work.allDays;
	set work.allDays;
	if "Number of Accidents"n eq . then "Number of Accidents"n = 0;
	if "Number of Fatalities"n eq . then "Number of Fatalities"n = 0;
run;

/*Checking my work*/
proc freq data=work.allDays;
run;
/*n=2557*/

proc freq data=work.byDay;
run;
/* n=2494 */

/*Hands Free Law went into effect July 1st, 2018. Grouping by whether there were more accidents before or after July 1st. */
/*Data set with every day from Jan 1, 2015 to Dec 31, 2021*/
/***************************************************************************************************/
/* What is July 1st, 2018 stored as in SAS? FINDING THE SASDATE (NUMBER OF DAYS SINCE JAN 1ST 1960 (=0))*/
/***************************************************************************************************/
data mydate;
mydate = '01JUL2018'd;
run;
/*21366*/


data work.allDays;
	set work.allDays;
	length "Hands-Free Law"n $6;
	if Date < 21366 then "Hands-Free Law"n = 'A';
	else if Date >= 21366 then "Hands-Free Law"n = 'B';
Run;

Proc format;
	Value $handsFormat 'A' = "Before" 'B' = "After";
run;

data work.allDays;
	set work.allDays;
	format "Hands-Free Law"n $handsFormat.;
run;

proc freq data=work.AllDays order=internal;
	tables "Hands-Free Law"n;
run;


/*Is there a significant difference in the number of accidents?*/
Proc ttest data=work.allDays Order=data plots sides=2 H0=0 alpha=0.05;
	Class "Hands-Free Law"n;
	Var "Number of Accidents"n;
run;


ods graphics on / height=2.5 in width=5.5 in;
*TITLE height=1.25 "Figure #: 95% Confidence Intervals for the Number of Accidents per Day in Georgia";
*title2 height=1.2 "Before and After the Hands-free Law, 2015-2021 (n=2557)";
proc sgplot data=work.allDays;
    dot "Hands-Free Law"n / response="Number of Accidents"n stat=mean limitstat=CLM alpha=0.05;
    yaxis label="Hands-Free Law";
    xaxis label="Number of Accidents";
run;
ods graphics off;
*title;

/* Applying the hands free format to the data set with the unit of observation being accidents */
data work.Georgia;
	set work.Georgia;
	length "Hands-Free Law"n $6;
	if Date < 21366 then "Hands-Free Law"n = 'A';
	else if Date >= 21366 then "Hands-Free Law"n = 'B';
Run;

Proc format;
	Value $handsFormat 'A' = "Before" 'B' = "After";
run;

data work.Georgia;
	set work.Georgia;
	format "Hands-Free Law"n $handsFormat.;
	rename fatals = 'Number of Fatalities'n;
run;

proc freq data=work.Georgia;
run;

proc freq data=work.Georgia order=internal;
	tables "Hands-Free Law"n;
run;

ods graphics on;
Proc ttest data=work.Georgia Order=data plots sides=2 H0=0 alpha=.05;
	Class "Hands-Free Law"n;  
	Var "Number of Fatalities"n;
run;
ods graphics off;

ods graphics on / height=2.5 in width=5.5 in;
*TITLE height=1.25 "Figure #: 95% Confidence Intervals for the Number of Fatalities per Accident in Georgia";
*title2 height=1.2 "Before and After the Hands-free Law, 2015-2021 (n=10166)";
proc sgplot data=work.Georgia;
    dot "Hands-Free Law"n / response="Number of Fatalities"n stat=mean limitstat=CLM alpha=0.05;
    yaxis label="Hands-Free Law";
    xaxis label="Number of Fatalities";
run;
ods graphics off;
*title;


/*Applying the Hands_Free format to the dataset that does NOT include the days with zero accidents and fatalities*/
data work.byDay;
	set work.byDay;
	length "Hands-Free Law"n $6;
	if Date < 21366 then "Hands-Free Law"n = 'A';
	else if Date >= 21366 then "Hands-Free Law"n = 'B';
Run;

Proc format;
	Value $handsFormat 'A' = "Before" 'B' = "After";
run;

data work.byDay;
	set work.byDay;
	format "Hands-Free Law"n $handsFormat.;
run;

proc freq data=work.byDay;
run;


/* Is there a difference in the number of fatalities before and after the hands free law for the different junciton types?*/
data work.GeorgiaFunc;
	set work.Georgia (where=('Road Type'n ne 'E'));
run;

proc freq data= work.GeorgiaFunc; 
	tables "Hands-Free Law"n*'Road Type'n;
run;
/*Lowest cell count is 705*/ 

/*Sorting by Hands free then Road Type*/
proc sort data=work.GeorgiaFunc; 
	by "Hands-Free Law"n 'Road Type'n;
run;

proc means data=work.GeorgiaFunc mean stddev maxdec=4; 
	class "Hands-Free Law"n 'Road Type'n;
	var "Number of Fatalities"n;
run;
/*0.4511/0.2553 = 1.767 < 2 The data can be considered homogeneous enough*/ 

/*Global F Test for interaction*/
*title 'Table #: Does a combination of the Hands-Free Law and Functional System Predict the Number of Fatalities in a Fatal Accident?'; 
proc glm data=work.GeorgiaFunc plots=none order=internal;
	class "Hands-Free Law"n 'Road Type'n;
	Model "Number of Fatalities"n = "Hands-Free Law"n 'Road Type'n "Hands-Free Law"n*'Road Type'n /SS3;
run;
*title;
/*
Global F: Significant: p=0.0002
Interaction NOT Significant: p=0.4644
Proceed to testing the Main Effects
*/
*title 'Table #: Does the Hands-Free Law or Functional System Predict the Number of Fatalities in a Fatal Accident?'; 
proc glm data=work.GeorgiaFunc plots=none order=internal;
	class "Hands-Free Law"n 'Road Type'n;
	Model "Number of Fatalities"n = "Hands-Free Law"n 'Road Type'n /SS3;
run;
*title;
/*
Hands_Free:		   		p = 0.2199 Eliminate
Road Type:p	<.0001
*/
proc glm data=work.GeorgiaFunc plots=none order=internal;
	class 'Road Type'n;
	Model "Number of Fatalities"n = 'Road Type'n /SS3;
run;

/* Road Type p<0.001 
   Best Model: Functional System Predicts the Number of Fatalities in a Fatal Accident*/

*title 'Table #: Does the Functional System Predict the Number of Fatalities in a Fatal Accident?'; 
proc glm data=work.GeorgiaFunc plots=none;
	class 'Road Type'n;
	Model "Number of Fatalities"n ='Road Type'n /SS3;
	means 'Road Type'n /bon tukey lsd lines;
run;
*title;

/*Chi Square of hands free and junction type*/
/*Chi Square to check expected counts and Significance*/
proc freq data=work.GeorgiaFunc order=internal; 
	Tables "Hands-Free Law"n*'Road Type'n / chisq nocol nocum nopercent cellchi2 expected;
run;
/* Chi Square with propotions, better picture of what it means */ 
proc freq data=work.GeorgiaFunc order=internal;
	Tables "Hands-Free Law"n*'Road Type'n / chisq;
run;

/* 100% Barchart of Fatal accidents on Functional Systems by Weekday */  
proc means data=work.GeorgiaFunc; 
	var "Number of Fatalities"n;
	class "Hands-Free Law"n 'Road Type'n;
run;

proc freq data=work.GeorgiaFunc; 
table "Hands-Free Law"n*'Road Type'n/out=freq outpct;
quit;
proc sgplot data=freq pctlevel=group; 
vbar "Hands-Free Law"n /
response=percent
group='Road Type'n
groupdisplay=stack
datalabel datalabelattrs=(size=11)
seglabel seglabelattrs=(size=11 color=white)
stat=percent
filltype=solid
outlineattrs=(color=black);
keylegend / valueattrs=(Size=11) titleattrs=(size=11);
styleattrs
wallcolor=white
backcolor=white
datacolors=('#9FA221' '#487546' '#3C6087' '#888888');
*title height=1.25 'Figure ##: 100% Stacked Bar Chart for Road Type by Hands-free Law';
*title2 height=1.2 '(n=10165)';
yaxis label = 'Road Type' labelattrs=(size=13) valueattrs=(size=12);
xaxis label = 'Hands-Free Law' labelattrs=(size=13) valueattrs=(size=12);
run;
*title; 







