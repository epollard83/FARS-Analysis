/*Importing the Data*/
/*FARS Dataset*/
ods graphics off;
options validvarname=any;
options nolabel;

%web_drop_table(WORK.accident);
FILENAME REFFILE '/home/u62699350/sasuser.v94/DATA 4400/accident.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=WORK.accident;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=WORK.accident; RUN;
%web_open_table(WORK.accident);

/*Keep statement*/
data work.accidentKeep;
	set work.accident;
	keep MONTH DAY_WEEK STATENAME STATE ST_CASE PERNOTMVIT PVH_INVL PERMVIT
	MONTHNAME DAY DAY_WEEKNAME FUNC_SYS FUNC_SYSNAME  LATITUDE LATITUDENAME LONGITUD LONGITUDNAME
	MAN_COLLNAME MAN_COLL WEATHERNAME FATALS COUNTYNAME;
	rename MAN_COLLNAME = "Collision Direction"n;
Run;

/*
Identifier Variables:
	ST_STATE
Categorical Variables:
	STATENAME MONTHNAME DAY DAY_WEEKNAME FUNC_SYSNAME MAN_COLLNAME WEATHERNAME
Quantitative Variables:
	PERNOTMVIT VE_TOTAL PVH_INVL PERMVIT YEAR LATITUDENAME LONGITUDENAME FATALS
*/

/*For Categorical: Frequency Tables*/
proc freq data=work.accidentKeep;
	tables STATENAME MONTHNAME DAY DAY_WEEKNAME FUNC_SYSNAME "Collision Direction"n WEATHERNAME COUNTYNAME;
run;

/*For Quantitative: Proc Means: n min q1 median q3 max qrange (IQR) mean std dev*/

proc means data=work.accidentKeep n min q1 median q3 max qrange mean stddev maxdec=2;
	var PERNOTMVIT PVH_INVL PERMVIT LATITUDENAME LONGITUDNAME FATALS;
run;

/*Proc Univariate for Quantitative Variables*/
*Title "Figure 1: QQ Plots of Quantitative Variables";
proc univariate data = work.accidentKeep normaltest plots;
	Var PERNOTMVIT PVH_INVL PERMVIT LATITUDENAME LONGITUDNAME FATALS;
Run;
*Title;

/*Ordering ordinal Variables*/
/*Use the numerical values of the values to key in the wanted order.*/
/*Month Name*/
data work.accidentKeep;
	set work.accidentKeep;
	length Month_ordered $9;
	
	if MONTH = 1 then Month_ordered = 'A';
	else if MONTH = 2 then Month_ordered = 'B';
	else if MONTH = 3 then Month_ordered = 'C';
	else if MONTH = 4 then Month_ordered = 'D';
	else if MONTH = 5 then Month_ordered = 'E';
	else if MONTH = 6 then Month_ordered = 'F';
	else if MONTH = 7 then Month_ordered = 'G';
	else if MONTH = 8 then Month_ordered = 'H';
	else if MONTH = 9 then Month_ordered = 'I';
	else if MONTH = 10 then Month_ordered = 'J';
	else if MONTH = 11 then Month_ordered = 'K';
	else if MONTH = 12 then Month_ordered = 'L';
Run;

Proc format;
	Value $monthFormat 'A' = "January" 'B' = "February" 'C'="March"
	'D' = "April" 'E'="May" 'F'="June" 'G'="July" 'H'="August"
	'I'="September" 'J'="October" 'K'="November" 'L' = "December";
run;

data work.accidentKeep;
	set work.accidentKeep;
	format Month_ordered $monthFormat.;
run;

proc freq data=work.accidentKeep order=internal;
	tables Month_ordered;
Run;

/*Ordering day of the week*/
data work.accidentKeep;
	set work.accidentKeep;
	length Weekday_ordered $9;
	
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

data work.accidentKeep;
	set work.accidentKeep;
	format Weekday $dayFormat.;
run;

proc freq data=work.accidentKeep order=internal;
	tables Weekday;
run;

/*Creating Seasons*/
data work.accidentKeep;
	set work.accidentKeep;
	length Season $6;
	if MONTH IN (4, 5) or (MONTH = 3 AND DAY >=20) or (MONTH = 6 and DAY<20) then Season = 'A';
	else if MONTH IN (7,8) or (MONTH = 6 AND DAY >=20) or (MONTH = 9 and DAY<22)then Season ='B';
	else if MONTH IN (10, 11) or (MONTH = 9 AND DAY >=22) or (MONTH = 12 and DAY<21) then Season ='C';
	else if MONTH IN (1,2) or (MONTH = 12 AND DAY >=21) or (MONTH = 3 and DAY<20)then Season = 'D';
Run;

Proc format;
	Value $seasonFormat 'A' = "Spring" 'B' = "Summer" 'C'="Fall"
	'D' = "Winter";
run;

data work.accidentKeep;
	set work.accidentKeep;
	format Season $seasonFormat.;
run;

proc freq data=work.accidentKeep order=internal;
	tables Season;
run;


/*Creating Functional System*/
data work.accidentKeep;
	set work.accidentKeep;
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

data work.accidentKeep;
	set work.accidentKeep;
	format 'Road Type'n $funcFormat.;
run;

/*Creating the Weather Condition Variable*/
/*Grouping the snowy and rainy weather*/
data work.accidentKeep;
	set work.accidentKeep;
	length 'Weather Type'n $24;
	
	if WEATHERNAME eq 'Clear' then 'Weather Condition'n = 'A';
	else if WEATHERNAME eq 'Cloudy' then 'Weather Condition'n = 'B';
	else if WEATHERNAME eq 'Rain' or WEATHERNAME eq 'Freezing Rain or Drizzle' then 'Weather Condition'n = 'C';
	else if WEATHERNAME eq 'Blowing Snow' or WEATHERNAME eq 'Sleet or Hail' or WEATHERNAME eq 'Snow' 
    then 'Weather Condition'n = 'D';
	else 'Weather Condition'n = 'E';
Run;
/*attaching the format*/
Proc format;
	Value $weatherFormat 'A' = "Clear" 'B' = "Cloudy" 'C'="Rain"
	'D' = "Snowy" 'E'="Unknown" ;
run;

data work.accidentKeep;
	set work.accidentKeep;
	format 'Weather Condition'n $weatherFormat.;
run;

/*Checking that the numbers are correct and the groups were correctly made*/
proc freq data=work.accidentKeep;
	tables WEATHERNAME 'Weather Condition'n;
run;

/*Tests*/

/********************************************************************************************************************************************/
/* Univariate Analysis **********************************************************************************************************************/
/********************************************************************************************************************************************/

/* Weekday */
/* Chi Square in Excel */
/* Bar Chart of Weekday*/
proc freq data=work.accidentKeep;
table Weekday/out=freq1;
quit;
proc sgplot data=work.freq1 pctlevel=graph;
vbar Weekday /
response = percent
datalabel datalabelattrs=(size=11)
stat=percent
filltype=solid
fillattrs=(color='#9FA221')
outlineattrs=(color=black);
styleattrs 
wallcolor=white
backcolor=white;
refline 0.1429571429 / axis=y lineattrs=(color='#E26A44');  
refline 0.146583907 / axis=y lineattrs=(pattern=26 color='#022B4A');
refline 0.139130379 / axis=y lineattrs=(pattern=26 color='#022B4A');
*title height = 1.25 'Figure ##:  Bar Chart for Percentage of Fatal Accidents by Weekday';
*title2 height = 1.2 '(n = 39508)';
yaxis label = 'Percentage' labelattrs=(size=13) valueattrs=(size=12);
xaxis label = 'Weekday' labelattrs=(size=13) valueattrs=(size=12);
run;
*title;

/* Functional System */
data work.func;
	set work.accidentKeep (where=('Road Type'n ne 'E'));
	keep "Road Type"n;
run;

proc freq data=work.func;
table 'Road Type'n/out=freq2;
quit;
proc sgplot data=work.freq2 pctlevel=graph;
vbar 'Road Type'n /
response=percent
datalabel datalabelattrs=(size=11)
stat=percent
filltype=solid
fillattrs=(color='#EDCC83')
outlineattrs=(color=black);
styleattrs 
wallcolor=white
backcolor=white;
*title height=1.25 'Figure ##:  Bar Chart for Percentage of Fatal Accidents by Road Type';
*title2 height=1.2 '(n = 39271)';
yaxis label = 'Percentage' labelattrs=(size=13) valueattrs=(size=12);
xaxis label = 'Road Type' labelattrs=(size=13) valueattrs=(size=12);
run;
*title;

/* Collision Type */
data work.Coll;
	set work.accidentKeep (where=((MAN_COLL = 1 or MAN_COLL = 2 
	or MAN_COLL = 6	or MAN_COLL = 7 or MAN_COLL = 8)));
	keep "Collision Direction"n;
run;

proc freq data=work.Coll;
table "Collision Direction"n/out=freq3;
quit;
proc sgplot data=work.freq3 pctlevel=graph;
vbar "Collision Direction"n /
response=percent
datalabel datalabelattrs=(size=11)
stat=percent
filltype=solid
fillattrs=(color='#487546')
outlineattrs=(color=black);
styleattrs 
wallcolor=white
backcolor=white;
*title height=1.25 'Figure ##:  Bar Chart for Percentage of Fatal Accidents by Collision Direction';
*title2 height=1.2 '(n = 15611)';
yaxis label = 'Percentage' labelattrs=(size=13) valueattrs=(size=12);
xaxis label = 'Collision Direction' labelattrs=(size=13) valueattrs=(size=10);
run;
*title;

/* Weather */
data work.weather;
	set work.accidentKeep (where=("Weather Condition"n ne 'E'));
	keep "Weather Condition"n;
run;

proc freq data=work.weather;
table "Weather Condition"n/out=freq4;
quit;
proc sgplot data=work.freq4 pctlevel=graph;
vbar "Weather Condition"n /
response=percent
datalabel datalabelattrs=(size=11)
stat=percent
filltype=solid
fillattrs=(color='#E26A44')
outlineattrs=(color=black);
styleattrs 
wallcolor=white
backcolor=white;
*title height=1.25 'Figure ##:  Bar Chart for Percentage of Fatal Accidents by Weather Condition';
*title2 height = 1.2 '(n = 37577)';
yaxis label = 'Percentage' labelattrs=(size=13) valueattrs=(size=12);
xaxis label = 'Weather Condition' labelattrs=(size=13) valueattrs=(size=12);
run;
*title;

/********************************************************************************************************************************************/
/* Bivariate Analysis ***********************************************************************************************************************/
/********************************************************************************************************************************************/


/* looking at the interaction between functional system and Weekday */
data work.FuncWeek;
	set work.accidentKeep (where=('Road Type'n ne 'E'));
	keep Weekday 'Road Type'n;
run;

proc freq data = work.FuncWeek;
	tables 'Road Type'n Weekday;
run;

proc freq data=work.FuncWeek;
run;

/*Chi Square to check expected counts and Significance*/
proc freq data=work.FuncWeek order=internal;
	Tables Weekday*'Road Type'n / chisq nocol nocum nopercent cellchi2 expected;
run;
/* Chi Square with propotions, better picture of what it means */
proc freq data=work.FuncWeek order=internal;
	Tables Weekday*'Road Type'n / chisq;
run;
/* 100% Barchart of Fatal accidents on Functional Systems by Weekday */
proc freq data=work.FuncWeek;
table Weekday*'Road Type'n/out=freq outpct;
quit;
proc sgplot data=freq pctlevel=group;
vbar Weekday /
response=percent
group='Road Type'n
groupdisplay=stack
datalabel datalabelattrs=(size=11) 
seglabel seglabelattrs=(size=11 color=white)
stat=percent
filltype=solid
outlineattrs=(color=black);
keylegend / valueattrs=(Size=12) titleattrs=(size=13);
styleattrs
wallcolor=white
backcolor=white
datacolors=('#9FA221' '#487546' '#3C6087' '#888888');
*title height=1.25 'Figure ##: 100% Stacked Bar Chart for Road Type by Weekday';
*title2 height=1.2 '(n=39271)';
yaxis label = 'Road Type' labelattrs=(size=13) valueattrs=(size=12);
xaxis label = 'Weekday' labelattrs=(size=13) valueattrs=(size=12);
run;
*title;

/* ******************************************************************************************************* */
/* Is there a significant difference in the proportion of accidents by road type and collision type ********/
/***********************************************************************************************************/
proc freq data=work.accidentKeep;
	tables "Collision Direction"n;
run;

data work.FuncColl;
	set work.accidentKeep (where=('Road Type'n ne 'E' & (MAN_COLL = 1 or MAN_COLL = 2 or MAN_COLL = 6
		or MAN_COLL = 7 or MAN_COLL = 8)));
	keep 'Road Type'n "Collision Direction"n;
run;

proc freq data = work.FuncColl;
run;

proc freq data = work.funcColl;
	tables 'Road Type'n*"Collision Direction"n;
run;

/*Chi Square to check expected counts and Significance*/
proc freq data=work.FuncColl order=internal;
	Tables 'Road Type'n*"Collision Direction"n / chisq nocol nocum nopercent cellchi2 expected;
run;
/* Chi Square with proportions, better picture of what it means */
proc freq data=work.FuncColl order=internal;
	Tables 'Road Type'n*"Collision Direction"n / chisq;
run;

/*100% Bar Chart of Collision Type by Road Type********************************************/
proc freq data=work.FuncColl;
table 'Road Type'n*"Collision Direction"n/out=freq outpct;
quit;
proc sgplot data=freq pctlevel=group;
vbar 'Road Type'n/
response=percent
group="Collision Direction"n
groupdisplay=stack
datalabel datalabelattrs=(size=11)
seglabel seglabelattrs=(size=11 color=white)
stat=percent
filltype=solid
outlineattrs=(color=black);
keylegend / valueattrs=(Size=12) titleattrs=(size=13);
styleattrs
wallcolor=white
backcolor=white
datacolors=('#9FA221' '#487546' '#3C6087' '#022B4A' '#888888');
*title height=1.25 'Figure ##: 100% Stacked Bar Chart of Collision Direction by Road Type';
*title2 height=1.2 '(n=15588)';
yaxis label = 'Collision Direction' labelattrs=(size=13) valueattrs=(size=12);
xaxis label = 'Road Type' labelattrs=(size=13) valueattrs=(size=12);
run;
*title;



/********************************************************************************************************/
/*******************************Cleaning for Word Cloud**************************************************/
/********************************************************************************************************/
data work.cloud;
	set work.accident (where=(STATENAME eq 'Georgia'));
	keep STATENAME COUNTYNAME;
run;

/*Checking to make sure only Georgia counties were outputted*/
proc freq data=work.cloud;
run;

/* Trimming the digits and paranthesis off the names */
data work.cloud;
	set work.cloud;
	County = COMPRESS(COUNTYNAME,'()1234567890');
run;

proc sort data=work.cloud;
	by County;
run;

/*Increasing the count for each instance of the countyname*/
data work.cloud;
	set work.cloud;
	keep County count;
	count +1;
	by COUNTY;
	if first.COUNTY then count = 1;
run;

/*Putting the count in descending order so that the frequency is the first entry for each county*/
proc sort data=work.cloud out=work.cloud; 
 by COUNTY descending count; 
run;

/*Outputting the frequency back to cloud1*/
data work.cloud1;
 set work.cloud;
 by COUNTY;
 if first.COUNTY; * first member of the group then output;
run;

proc sort data=work.cloud1;
	by count;
run;

proc print data=work.cloud1;
run;

/**********************************************************************************************/

/*******************************************************************************************/
/*Looking into Collision type by Weather type for Interstates and freeways******************/
/*******************************************************************************************/
/*Keeping only Interstates and Freeways*/
data work.weatherIF;
	set work.accidentKeep (where = ('Road Type'n = 'A' & 'Weather Condition'n ne 'E' & (MAN_COLL = 1 or MAN_COLL = 2 
	or MAN_COLL = 6	or MAN_COLL = 7 or MAN_COLL = 8)));
run;
/*Looking at the counts of the collision types by weather type*/
proc freq data = work.weatherIF;
	tables 'Weather Condition'n*"Collision Direction"n;
run;

/*Running a Chi Square*/
proc freq data=work.weatherIF order=internal;
	Tables 'Weather Condition'n*"Collision Direction"n / chisq nocol nocum nopercent cellchi2 expected;
run;

/* 3/20 observations <5 15%*/

/* Chi Square with proportions, better picture of what it means */
proc freq data=work.weatherIF order=internal;
	Tables 'Weather Condition'n*"Collision Direction"n / chisq;
run;

/*100% Stacked Bar Chart*/
proc freq data=work.weatherIF;
table 'Weather Condition'n*"Collision Direction"n/out=freq outpct;
quit;
proc sgplot data=freq pctlevel=group;
vbar 'Weather Condition'n /
response=percent
group="Collision Direction"n
groupdisplay=stack
datalabel datalabelattrs=(size=11) /*Changes the size of the 100% at the top of the bar*/
seglabel seglabelattrs=(size=11 color=white) /*Changes the size of the percentages inside the bar*/
stat=percent
filltype=solid
outlineattrs=(color=black);
keylegend / valueattrs=(Size=12) titleattrs=(size=13);
styleattrs
wallcolor=white
backcolor=white
datacolors=('#9FA221' '#487546' '#3C6087' '#022B4A' '#888888');
*title height=1.25 'Figure ##: 100% Stacked Bar Chart for Collision Direction by Weather Condition';
*title2 height=1.2 'Interstates and Freeways (n = 2360)';
yaxis label = 'Collision Direction' labelattrs=(size=13) valueattrs=(size=12);
xaxis label = 'Weather Condition' labelattrs=(size=13) valueattrs=(size=12);
run;
*title;

/*Does Manner of Collision for the First Harmful event and Junction type Predict the Number of Fatalities?*/
data work.CollJunc;
	set work.accidentKeep (where=('Road Type'n ne 'E' & (MAN_COLL = 1 or MAN_COLL = 2 
	or MAN_COLL = 6	or MAN_COLL = 7 or MAN_COLL = 8)));
	keep 'Road Type'n "Collision Direction"n FATALS;
	rename FATALS = Fatalities;
run;

proc freq data=work.CollJunc;
	tables 'Road Type'n*"Collision Direction"n;
run;
/*Smallest Number of Observations: 33 (CLT applies)*/

proc sort data=work.collJunc;
	by 'Road Type'n "Collision Direction"n;
run;

proc means data=work.collJunc mean stddev maxdec=4;
	class 'Road Type'n "Collision Direction"n;
	var Fatalities;
run;
/*0.7070/0.1754 = 4.031 NOT HOMOGENEOUS*/

/*How to do a Two-way ANOVA on the ranks (mean of the ranks)*/
proc rank data=work.collJunc out=work.collJuncRanks;
	var Fatalities;
	ranks 'Rank of Fatalities'n;
run;

/* Check if your code worked. */
proc print data=work.collJuncRanks (obs=10);
run;


/*Test on Ranks of Fatalities*/
/*Global F Test for interaction*/
*title color=black height=1.25 'Table #: Does a combination of the Road Type and Collision Direction Predict the Rank of Fatalities in a Fatal Accident?';
proc glm data=work.collJuncRanks plots=none order=internal;
	class 'Road Type'n "Collision Direction"n;
	Model 'Rank of Fatalities'n = 'Road Type'n "Collision Direction"n 'Road Type'n*"Collision Direction"n /SS3;
run;
*title;
/*
Global F: Significant: p<0.001
Interaction is Significant: p<0.001
*/

proc summary data=work.collJuncRanks NWAY order=internal;
	Class 'Road Type'n "Collision Direction"n;
	Var 'Rank of Fatalities'n;
	Output out = Outfile mean = 'Rank of Fatalities'n;
run;

PROC GPLOT DATA = Outfile;
   PLOT  'Rank of Fatalities'n * 'Road Type'n = "Collision Direction"n;   /*Variable with the Quantitative variable is the x axis on the interaction plot. */
   SYMBOL1 V = dot H = 2 I = join COLOR = '#9FA221';
   SYMBOL2 V = dot H = 2 I = join COLOR = '#487546';
   SYMBOL3 V = dot H = 2 I = join COLOR = '#888888';
   SYMBOL4 V = dot H = 2 I = join COLOR = '#3C6087';
   SYMBOL5 V = dot H = 2 I = join COLOR = '#E26A44';
*   TITLE1 height=1.25 'Figure #:  Interaction Plot for Rank of Fatalities versus';
*   Title2 height=1.2 'Road Type and Collision Direction (n=15588)';
RUN;quit;

/*On the MEDIAN of the Data DOES NOT WORK: Cannot use because of the predominance of 1s and all medians are 1*/
/*On the Mean of the DATA*/
proc summary data=work.collJunc NWAY order=internal;
	Class 'Road Type'n "Collision Direction"n;
	Var Fatalities;
	Output out = Outfile mean = Fatalities;
run;

PROC GPLOT DATA = Outfile;
   PLOT Fatalities * 'Road Type'n = "Collision Direction"n;   /*Variable with the Quantitative variable is the x axis on the interaction plot. */
   SYMBOL1 V = dot H = 2 I = join COLOR = '#9FA221';
   SYMBOL2 V = dot H = 2 I = join COLOR = '#487546';
   SYMBOL3 V = dot H = 2 I = join COLOR = '#888888';
   SYMBOL4 V = dot H = 2 I = join COLOR = '#3C6087';
   SYMBOL5 V = dot H = 2 I = join COLOR = '#E26A44';
 *  TITLE1 height=1.25 'Figure #:  Interaction Plot for Fatalities versus';
 *  Title2 height=1.2 'Road Type and Collision Direction (n=15588)';
RUN;quit;
title;


/*Does Day of the week have an impact on fatalities?*/
data work.weekFatal;
	set work.accidentKeep;
	keep Weekday FATALS;
	rename fatals = Fatalities;
run;

proc sort data=work.weekFatal;
	by Weekday;
run;

proc means data=work.weekFatal mean median stddev maxdec=3;
	var Fatalities;
	class Weekday;
run;
/* all n>30 so CLT applies */
/* 0.383/0.336  =1.139<2 the data can be considered homogeneous */

/*One-way ANOVA*/
*title color=black 'Figure ##: One-way ANOVA of the Number';
*title2 color=black 'of Fatalities and Weekday (n = 39508)';
proc ANOVA data=work.weekFatal plots=none;
	class Weekday;
	model Fatalities = Weekday;
	means Weekday /hovtest=levene(type=square);
run;
*title;


/*p=0.0201<0.05: significant*/	
*title height = 1.25 'Figure ##: Lines for the Number of Fatalities and Weekday';
*title2 height = 1.2 '(n = 39508)';
proc ANOVA data=work.weekFatal plots=none;
	class Weekday;
	model Fatalities = Weekday;
	means Weekday /lines lsd bon tukey alpha=0.05;
run;
*title;

*title color=black 'Figure ##: Fisher LSD Lines for the Number of Fatalities and Weekday';
*title2 color=black '(n = 39508)';
proc ANOVA data=work.weekFatal plots=none;
	class Weekday;
	model Fatalities = Weekday;
	means Weekday /lines lsd alpha=0.05;
run;
*title;
	
/************************Geolocational Maps***************************************/
data work.map;
	set work.accidentKeep (where=(LATITUDE < 777.7777 & LONGITUD < 777.7777 & LONGITUD > -135 &
	LATITUDE<50)); /* Excluding Alaska and Hawaii */
	keep latitude LONGITUD SEASON ;
	rename latitude = lat;
	rename longitud = long;
run;

/*Finding the N for the Continental United States*/
proc means data=work.map;
run;
/*39220*/

/*Creating a dataset for maps with just Just Georgia*/
data work.map2;
	set work.accidentKeep (where=(STATENAME eq "Georgia" & 'Road Type'n ne 'E'));
	keep latitude Longitud 'Road Type'n;
	rename latitude = lat;
	rename longitud = long;
run;

proc freq data=work.map2;
	tables 'Road Type'n;
run;
/*
Interstates and Freeways	283	
Metropolitan Roads	415	
Collectors	277	
Lower Density Roads	695	

*/
/*Map of Entire United States, plotted by Longitude and Latitude*/
*title height=1.25 "Fatal Accidents in the United States";
*title2 height=1.2 '(n=39220)';
proc sgmap plotdata=work.map noautolegend;
OPENSTREETMAP;
scatter x=long y=lat / markerattrs=(size=1px symbol=CircleFilled color='#9FA221');
run;

/* Creating Maps for Georgia by Functional System */
/* Interstates and Freeways */
data work.gfe;
	set work.map2 (where=('Road Type'n eq "A"));
run;

/* Metropolitan Roads */
data work.gm;
	set work.map2 (where=('Road Type'n eq "B"));
run;

/* Collectors */
data work.gc;
	set work.map2 (where=('Road Type'n eq "C"));
run;

/* Lower Density Roads */
data work.gl;
	set work.map2 (where=('Road Type'n eq "D"));
run;

/*Creating the Maps*/
*title height=1.25 "Fatal Accidents in Georgia by Road Type";
*title2 height=1.2 'Interstates and Freeways (n=283)';
proc sgmap plotdata=work.gfe noautolegend;
OPENSTREETMAP;
scatter x=long y=lat / markerattrs=(size=4px symbol=CircleFilled color='#487546') transparency=0.5;
run;

*title height=1.25 "Fatal Accidents in Georgia by Road Type";
*title2 height=1.2 'Metropolitan Roads (n=415)';
proc sgmap plotdata=work.gm noautolegend;
OPENSTREETMAP;
scatter x=long y=lat / markerattrs=(size=4px symbol=CircleFilled color='#9FA221') transparency=0.5;
run;

*title height=1.25 "Fatal Accidents in Georgia by Road Type";
*title2 height=1.2 'Collectors (n=277)';
proc sgmap plotdata=work.gc noautolegend;
OPENSTREETMAP;
scatter x=long y=lat / markerattrs=(size=4px symbol=CircleFilled color='#E26A44') transparency=0.5;
run;

*title height=1.25 "Fatal Accidents in Georgia by Road Type";
*title2 height=1.2 'Lower Density Roads (n=695)';
proc sgmap plotdata=work.gl noautolegend;
OPENSTREETMAP;
scatter x=long y=lat / markerattrs=(size=4px symbol=CircleFilled color='#3C6087') transparency=0.5;
run;

/* Continental United States by Season */
data work.Spring;
	set work.map (where=(Season eq "A"));
run;

data work.Summer;
	set work.map (where=(Season eq "B"));
run;

data work.Fall;
	set work.map (where=(Season eq "C"));
run;

data work.Winter;
	set work.map (where=(Season eq "D"));
run;

/* Finding the frequencies of the fatal accidents in the continetal united states by season */
proc freq data=map;
	tables Season;
run;

/*
Spring	9997	
Summer	11010	
Fall	10257	
Winter	7956	
*/

*title height=1.25 "Figure #: Fatal Accidents in United States by Season";
*title2 height=1.2 'Spring (n=9997)';
proc sgmap plotdata=work.Spring noautolegend;
OPENSTREETMAP;
scatter x=long y=lat / markerattrs=(size=2px symbol=CircleFilled color='#487546') transparency=0.5;
run;

*title height=1.25 "Figure #: Fatal Accidents in United States by Season";
*title2 height=1.2 'Summer (n=11010)';
proc sgmap plotdata=work.Spring noautolegend;
OPENSTREETMAP;
scatter x=long y=lat / markerattrs=(size=2px symbol=CircleFilled color='#9FA221') transparency=0.5;
run;

*title height=1.25 "Figure #: Fatal Accidents in United States by Season";
*title2 height=1.2 'Fall (n=10257)';
proc sgmap plotdata=work.Spring noautolegend;
OPENSTREETMAP;
scatter x=long y=lat / markerattrs=(size=2px symbol=CircleFilled color='#E26A44') transparency=0.5;
run;

*title height=1.25 "Figure #: Fatal Accidents in United States by Season";
*title2 height=1.2 'Winter (n=7956)';
proc sgmap plotdata=work.Spring noautolegend;
OPENSTREETMAP;
scatter x=long y=lat / markerattrs=(size=2px symbol=CircleFilled color='#3C6087') transparency=0.5;
run;