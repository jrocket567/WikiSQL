function [sqlquery, returnTable2]=ClassificationElso(query)
% Use text analytics to break apart queries into sections
% not using LSTM
% J Penick July 2018
ECMO=evalin('base','ECMO');
%query='Average time on ECMO for neonatal patients with VV';
%query='Survival rate of ECMO for neonatal patients';
%query='Maximum survival rate of ECMO for pediatric patients in 2002';
%% Clean up input Query

query=erasePunctuation(query);
query=lower(query);

Tquery=tokenizedDocument(query);
Tquery=removeWords(Tquery,stopWords);
Tquery=removeWords(Tquery,{'ecmo','elso','patient','patients'});
Tquery=normalizeWords(Tquery);

% maximum time ge pump
queryString=string(Tquery);

%% Different portions of an SQL Query:
% Aggregation MAX MIN COUNT SUM AVG
% Conditional = > < OP >= <=
% Syms SELECT WHERE

%% Aggregation
% Renditions of MAX
maxCommons=["best";
    "maximal";
    "outside";
    "superlative";
    "top";
    "ultimate";
    "biggest";
    "greatest";
    "largest";
    "most";
    "mostest";
    "paramount";
    "supreme";
    "topmost";
    "max";
    "maximum"];

minCommons=["minimal";
    "least possible";
    "littlest";
    "merest";
    "slightest";
    "smallest";
    "tiniest";
    "min";
    "minimum"];

countCommons=["Count";"total";"many"];

sumCommons=["sum";"total";"summation";"addition";"add";"amount";
    "bulk";
    "quantity";
    "value";
    "worth";
    "aggregate";
    "body";
    "entirety";
    "entity";
    "epitome";
    "gross";
    "integral";
    "mass";
    "reckoning";
    "score";
    "structure";
    "summary";
    "summation";
    "synopsis";
    "system";
    "tally";
    "totality";
    "whole";
    "works"];

avgCommons=["avg";"mean";"average"];

% Run Commons through tokenize/normalize:
maxCommons=preProcessCommonLists(maxCommons);
avgCommons=preProcessCommonLists(avgCommons);
minCommons=preProcessCommonLists(minCommons);
countCommons=preProcessCommonLists(countCommons);
sumCommons=preProcessCommonLists(sumCommons);

% See if the query matches any of the Commons
MaxTFvec=contains(queryString,maxCommons);
MinTFvec=contains(queryString,minCommons);
CountTFvec=contains(queryString,countCommons);
SumTFvec=contains(queryString,sumCommons);
AvgTFvec=contains(queryString,avgCommons);

MaxTF=sum(MaxTFvec);
MinTF=sum(MinTFvec);
CountTF=sum(CountTFvec);
SumTF=sum(SumTFvec);
AvgTF=sum(AvgTFvec);

% Find position and delete "used" word
if MaxTF>=1
    queryString=queryString(~MaxTFvec);
elseif MinTF>=1
    queryString=queryString(~MinTFvec);
elseif CountTF>=1
    queryString=queryString(~CountTFvec);
elseif SumTF>=1
    queryString=queryString(~SumTFvec);
elseif AvgTF>=1
    queryString=queryString(~AvgTFvec);
end


% Determine if there is any AGG portion
if MaxTF+MinTF+CountTF+SumTF>1
    AggString='AggFailure';
elseif MaxTF==1
    AggString="MAX";
elseif MinTF==1
    AggString="MIN";
elseif CountTF==1
    AggString="COUNT";
elseif SumTF==1
    AggString="SUM";
elseif AvgTF==1
    AggString="AVERAGE";
else
    AggString=' ';
end

%% Determine what columns are wanted in columnsOfInterest

[columnsOfInterest, queryString, outColumnIndex]=ColumnSelectionFunction(queryString);


%% Create WHERE conditionals

% This is the only section left, so all words left in string should go to
% some sort of WHERE conditional. Therefore loop through until all words
% are removed from query.
Conditional=string;

% Break down by patient age
% neonatal= <29 days
% Pediatric= 29 days:18 yrs (6570 d)
% Adult >18 yrs

neonatalCommons=["neonatal";"neonat";"neo";"premature";"infant"];
pediatricCommons=["pediatric";"pedi";"child";"adolescent";"ped"];
adultCommons=["adult";"grown";"elderly";"old"];

neonatalCommons=preProcessCommonLists(neonatalCommons);
pediatricCommons=preProcessCommonLists(pediatricCommons);
adultCommons=preProcessCommonLists(adultCommons);

for idy=1:length(queryString)
    % look for age words
    
    neoTFvec=contains(queryString(idy),neonatalCommons);
    pedTFvec=contains(queryString(idy),pediatricCommons);
    adultTFvec=contains(queryString(idy),adultCommons);
    
    neoTF=sum(neoTFvec);
    pedTF=sum(pedTFvec);
    adultTF=sum(adultTFvec);
    
    
    if neoTF==1
        Conditional=[Conditional "AGE <=28"];  %#ok<AGROW>
        returnTable=ECMO(ECMO.Age<=28,:);
    elseif pedTF==1
        Conditional=[Conditional "AGE >28 AND AGE <=6570"]; %#ok<AGROW>
        returnTable=ECMO(ECMO.Age>28 && ECMO.Age<=6570,:);
    elseif adultTF==1
        Conditional=[Conditional "AGE >6570"]; %#ok<AGROW>
        returnTable=ECMO(ECMO.Age>657028,:);
    end
        
    % look for VV or VA
    
    TypeCategories=["VA to VV";
        "VA(+V)";
        "VA+A";
        "VA+V";
        "VV to VA";
        "VV(DL)";
        "VV+V";
        "VV+VV";
        "VVDL+V"];
    ParentTypeCategories=["VV";"VA"];
    
    typeTF=strcmpi(queryString(idy),TypeCategories);
    parentTypeTF=strcmpi(queryString(idy),ParentTypeCategories);
    
    if sum(typeTF)>=1
        selectedCat=TypeCategories(typeTF);
        if strlength(Conditional)==0
            Conditional=["ECMOTYPE = '" selectedCat "'"];
            
        else
            Conditional=[Conditional "AND ECMOTYPE = '" selectedCat "'"];%#ok<AGROW>
        end
        
        returnTable=returnTable(returnTable.ECMOTYPE==selectedCat,:);
        
    elseif sum(parentTypeTF)>=1
        selectedCat=ParentTypeCategories(parentTypeTF);
        if strlength(Conditional)==0
            Conditional=["ECMOTYPE is " selectedCat];
        else
            Conditional=[Conditional "AND ECMOTYPE = '" selectedCat "'"];%#ok<AGROW>
        end
        returnTable=returnTable(returnTable.ParentECMOTYPE==selectedCat,:);
    end
    
    
    
end


%% Paste it all together

sqlquery=["SELECT " AggString columnsOfInterest "FROM ELSO "  "WHERE " Conditional];

% Take returnTable that is filtered on conditionals and only return
% columnsOfInterest

returnTable2=returnTable(:,logical(outColumnIndex));
returnTable2=[returnTable(:,1) returnTable2];



sqlquery=join(sqlquery);

 end

%% Supporting Functions

function outString=preProcessCommonLists(CommonList)

% Run Commons through tokenize/normalize:
mC=tokenizedDocument(CommonList);
mC=normalizeWords(mC);
outString=joinWords(mC);

end

function [outColumnList, queryString, outColumnIndex]=ColumnSelectionFunction(queryString)

ECMO=evalin('base','ECMO');
% See if we get lucky and a column name matches database
columnNames=fieldnames(ECMO);
columnNames=lower(columnNames);
matches=false(length(columnNames),1);
for idx=1:length(queryString)
    matches=strcmp(queryString(idx),columnNames)+matches;
end

matches=logical(matches);
matchedColumnNames=columnNames(matches);

% Some common word definitions

timeCommons=["time";"hours";"days";"duration"];
timeCommons=preProcessCommonLists(timeCommons);

survivalCommons=["survival";"death"];
survivalCommons=preProcessCommonLists(survivalCommons);

% Other column selections can go here.... focusing on time and survival to start.


% See if the query matches any of the Commons
timeTFvec=contains(queryString,timeCommons);
survivalTFvec=contains(queryString,survivalCommons);

timeTF=sum(timeTFvec);
survivalTF=sum(survivalTFvec);

% Determine if there is any columnNames portion
if timeTF+survivalTF>1
    ColumnNames='ColumnFailure';
elseif timeTF==1
    ColumnNames='Duration';
elseif survivalTF==1
    ColumnNames='SURV';
elseif ~isempty(matchedColumnNames) %had a hit on a matched name. Dont select all.
    ColumnNames=' ';
else %Just return everything
    ColumnNames='*';
end

% Find position and delete "used" word
if timeTF>=1
    queryString=queryString(~timeTFvec);
elseif survivalTF>=1
    queryString=queryString(~survivalTFvec);
end

outColumnList=[matchedColumnNames ColumnNames];
clearvars matches
matches=false(length(outColumnList),1);
for idx=1:length(outColumnList)
    matches=strcmpi(outColumnList(idx),columnNames)+matches;
end

outColumnIndex=matches;
end


