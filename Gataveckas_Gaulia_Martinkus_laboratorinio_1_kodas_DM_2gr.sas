PROC IMPORT DATAFILE='/home/u45871880/diabetes_cleaned.csv'
	DBMS=CSV
	OUT=data;
	GETNAMES=YES;
RUN;


%MACRO boxplot(column);
ods graphics / reset width=6.4in height=4.8in imagemap;

proc sgplot data=WORK.DATA;
	vbox &column / category=Outcome;
	yaxis grid;
run;
%MEND;

%boxplot(Pregnancies);
%boxplot(Glucose);
%boxplot(BloodPressure);
%boxplot(SkinThickness)
%boxplot(Insulin);
%boxplot(Age);
%boxplot(DiabetesPedigreeFunction);
%boxplot(BMI);


* Modelis su visomis kovariantėmis;
PROC LOGISTIC DATA=data DESCENDING 
	plots(only)=(roc(ID=cutpoint) effect(X=(Pregnancies Glucose BloodPressure SkinThickness 
											Insulin Age DiabetesPedigreeFunction BMI) CLBAND=YES ALPHA=0.05));
MODEL Outcome = Pregnancies Glucose BloodPressure SkinThickness 
Insulin BMI DiabetesPedigreeFunction Age / 
RSQUARE CTABLE PPROB=(0.1 TO 0.9 BY 0.1) EXPB LACKFIT scale=none clparm=wald;
RUN;



* Pažingsninė regresija kovariančių atrinkimui;
PROC LOGISTIC DATA=data DESCENDING plots(only)=(roc);
MODEL Outcome = Pregnancies Glucose BloodPressure SkinThickness 
Insulin BMI DiabetesPedigreeFunction Age / 
CTABLE PPROB=(0.1 TO 0.9 BY 0.1) EXPB
scale=none clparm=wald outroc=performance SELECTION=stepwise;
RUN;
 
 
* Atsižvelgiai į uždavinio specifiką
* Sukuriamas Precision-Recall grafikas alternativių slenksninių reikšmių parinkimui;
data precision_recall;
set performance;
precision = _POS_/(_POS_ + _FALPOS_);
recall = _POS_/(_POS_ + _FALNEG_);
F_stat = harmean(precision,recall);
if mod(_N_, 20) = 0 then _PROB_=_PROB_;
	else _PROB_ = .;
run;


Proc SQL;
create table precision_recall as
Select *
From precision_recall
having _step_ = max(_step_);
Quit;

proc sort data=precision_recall;
by recall;
run; 
 
 
ods graphics / reset width=6.4in height=4.8in imagemap;
proc sgplot data=WORK.PRECISION_RECALL;
	 SERIES X = recall Y = precision / DATALABEL=_PROB_;
run;
ods graphics / reset;