%% Import data from spreadsheet
% Script for importing data from the following spreadsheet:
%
%    Workbook: C:\Users\jbpenick\Documents\PMASE\Capstone\ECMO.deident.7.20.2018.xlsx
%    Worksheet: pllist
%
% To extend the code for use with different selected data or a different
% spreadsheet, generate a function instead of a script.

% Auto-generated by MATLAB on 2018/07/20 10:52:35

%% Import the data, extracting spreadsheet dates in Excel serial date format
[~, ~, raw, dates] = xlsread('C:\Users\jbpenick\Documents\PMASE\Capstone\ECMO.deident.7.20.2018.xlsx','pllist','A2:BT1235','',@convertSpreadsheetExcelDates);
raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};
stringVectors = string(raw(:,[3,4,5,7,10,12,17,18,35,41,45,46,48,49,50,51,52,53,54,55,56,57,58,62,63,64,65,66,67,68,70,71,72]));
stringVectors(ismissing(stringVectors)) = '';
raw = raw(:,[1,2,8,9,13,14,15,16,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,36,39,40,42,43,44,47,60,61,69]);
dates = dates(:,[6,11,37,38,59]);

%% Replace blank cells with NaN
R = cellfun(@(x) isempty(x) || (ischar(x) && all(x==' ')),raw);
raw(R) = {NaN}; % Replace blank cells
R = cellfun(@(x) isempty(x) || (ischar(x) && all(x==' ')),dates);
dates(R) = {NaN}; % Replace blank cells

%% Create output variable
data = reshape([raw{:}],size(raw));

%% Create table
ECMO = table;

%% Allocate imported array to column variable names
ECMO.NUM = data(:,1);
ECMO.YEARNO = data(:,2);
ECMO.LASTNAME = stringVectors(:,1);
ECMO.FIRSTNAME = stringVectors(:,2);
ECMO.ALIAS = stringVectors(:,3);
ECMO.REFERDATE = datetime([dates{:,1}].', 'ConvertFrom', 'Excel');
ECMO.TYPE = categorical(stringVectors(:,4));
ECMO.ACCT = data(:,3);
ECMO.MR = data(:,4);
ECMO.REFERHOSP = stringVectors(:,5);
ECMO.BD = datetime([dates{:,2}].', 'ConvertFrom', 'Excel');
ECMO.GENDER = categorical(stringVectors(:,6));
ECMO.APGAR1MINUTE = data(:,5);
ECMO.APGAR5MINUTES = data(:,6);
ECMO.EGA = data(:,7);
ECMO.WEIGHT = data(:,8);
ECMO.NEONATEAGEHRS = hours(str2double(stringVectors(:,7)));
ECMO.PEDAGEMOS = calmonths(uint8((str2double(stringVectors(:,8)))));
ECMO.PREPT = data(:,9);
ECMO.PREFBG = data(:,10);
ECMO.PREPLATELETS = data(:,11);
ECMO.PRELACTATE = data(:,12);
ECMO.HIGHESTPH = data(:,13);
ECMO.LOWESTPH = data(:,14);
ECMO.HIGHESTPCO2 = data(:,15);
ECMO.LOWESTPCO2 = data(:,16);
ECMO.LOWESTPO2 = data(:,17);
ECMO.PREFiO2 = data(:,18);
ECMO.PREPO2 = data(:,19);
ECMO.PREPCO2 = data(:,20);
ECMO.MAPATECMO = data(:,21);
ECMO.PIPATECMO = data(:,22);
ECMO.DELTAP = data(:,23);
ECMO.PEEPATECMO = data(:,24);
ECMO.HFOVPRE = categorical(stringVectors(:,9));
ECMO.INTUBDAYSPRE = data(:,25);
ECMO.ONECMO = datetime([dates{:,3}].', 'ConvertFrom', 'Excel');
ECMO.OFFECMO = datetime([dates{:,4}].', 'ConvertFrom', 'Excel');
ECMO.ECMOHOURS = data(:,26);
ECMO.ECMODays = data(:,27);
ECMO.ECMOTYPE = categorical(stringVectors(:,10));
ECMO.PRBC = data(:,28);
ECMO.PLTS = data(:,29);
ECMO.FFP = data(:,30);
ECMO.MECHCOMP = stringVectors(:,11);
ECMO.HEMORRHAGIC = categorical(stringVectors(:,12));
ECMO.ICHGRADE05 = data(:,31);
ECMO.NEUROLOGIC = categorical(stringVectors(:,13));
ECMO.RENAL = categorical(stringVectors(:,14));
ECMO.CARDIOPULM = categorical(stringVectors(:,15));
ECMO.PULMONARY = categorical(stringVectors(:,16));
ECMO.INFECTIOUS = categorical(stringVectors(:,17));
ECMO.METABOLIC = categorical(stringVectors(:,18));
ECMO.TOTALVENTDAYS = categorical(stringVectors(:,19));
ECMO.EXTUBTORADAYS = str2double(stringVectors(:,20));
ECMO.TOTALHOSPDAYS = str2double(stringVectors(:,21));
ECMO.SURV = categorical(stringVectors(:,22));
ECMO.NOTES = stringVectors(:,23);
ECMO.DATEOFINTUBATION = datetime([dates{:,5}].', 'ConvertFrom', 'Excel');
ECMO.TIMEONECMO = data(:,32);
ECMO.TIMEOFFECMO = data(:,33);
ECMO.ICD9PRIMARY = categorical(stringVectors(:,24));
ECMO.ICD9SECONDARY = categorical(stringVectors(:,25));
ECMO.ICD9DEATH = stringVectors(:,26);
ECMO.VENOUSDRAIN = categorical(stringVectors(:,27));
ECMO.VENOUSDRAIN2 = stringVectors(:,28);
ECMO.ARTERIALRETURN = categorical(stringVectors(:,29));
ECMO.CLASSIFICATION = categorical(stringVectors(:,30));
ECMO.ELSONUM = data(:,34);
ECMO.UNIT = stringVectors(:,31);
ECMO.TRANSPORT = stringVectors(:,32);
ECMO.PUMPTYPE = categorical(stringVectors(:,33));

% For code requiring serial dates (datenum) instead of datetime, uncomment
% the following line(s) below to return the imported dates as datenum(s).

% ECMO.REFERDATE=datenum(ECMO.REFERDATE);
% ECMO.BD=datenum(ECMO.BD);
% ECMO.ONECMO=datenum(ECMO.ONECMO);
% ECMO.OFFECMO=datenum(ECMO.OFFECMO);
% ECMO.DATEOFINTUBATION=datenum(ECMO.DATEOFINTUBATION);

%% Clear temporary variables
clearvars data raw dates stringVectors R;

%% Clean up imported data
numrecords=height(ECMO);
ECMO.ACCT=randi([111111111 999999999],numrecords,1);
ECMO.MR=randi([11111111 99999999],numrecords,1);

a=days(ECMO.TIMEONECMO);
a.Format='hh:mm:ss';
ECMO.TIMEONECMO=a;

a=days(ECMO.TIMEOFFECMO);
a.Format='hh:mm:ss';
ECMO.TIMEOFFECMO=a;

ECMO.StartTime=ECMO.ONECMO+ECMO.TIMEONECMO;
ECMO.StopTime=ECMO.OFFECMO+ECMO.TIMEOFFECMO;
ECMO.Duration=ECMO.StopTime-ECMO.StartTime;

ECMO.Age=days(ECMO.StartTime-ECMO.BD);

%Create combined ECMOTYPE category

ECMO.ParentECMOTYPE=ECMO.ECMOTYPE;
ECMO.ParentECMOTYPE=mergecats(ECMO.ParentECMOTYPE,{'VVDL+V','VV(DL)','VV to VA','VV+VV','VVDL+V'},'VV');

%% Create database

% dbfile=fullfile(pwd,'ECMO_db.db');
% conn=sqlite(dbfile,'create');

%% Create a list of categories
fn=fieldnames(ECMO);
isCat=false(length(fn),1);
for idx=1:length(fn)-3
    isCat(idx)=iscategorical(ECMO.(fn{idx}));
end


catData=ECMO(:,isCat);
cDfn=fieldnames(catData);
for idn=1:width(catData)
   
    
    
end

