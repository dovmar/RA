PROC IMPORT DATAFILE='/home/u45871880/diabetes.csv'
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
 