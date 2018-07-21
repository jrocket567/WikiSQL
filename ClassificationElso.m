% Use text analytics to break apart queries into sections
% not using LSTM
% J Penick July 2018



query='Maximum time on ECMO with GE pump';
%% Clean up input Query

query=erasePunctuation(query);
query=lower(query);
Tquery=tokenizedDocument(query);
Tquery=removeWords(Tquery,stopWords);
Tquery=removeWords(Tquery,{'ecmo','elso'});
Tquery=normalizeWords(Tquery);

% maximum time ge pump
queryString=string(Tquery);

%% Different portions of an SQL Query:
% Aggregation MAX MIN COUNT SUM AVG
% Conditional = > < OP >= <=
% Syms SELECT WHERE



sqlquery=['SELECT ' aggregation ' ' columnsofInterest 'FROM ' elsoDatabase 'WHERE' Conditionals];


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


% See if the query matches any of the Commons

MaxTF=sum(contains(queryString,maxCommons));
MinTF=sum(contains(queryString,minCommons));
CountTF=sum(contains(queryString,countCommons));
SumTF=sum(contains(queryString,sumCommons));

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
else
    AggString=' ';
end




