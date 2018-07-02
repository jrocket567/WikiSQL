% Import database tables and convert to MATLAB tables.
%
%
%
%
%
%%

numfailedstrings=0;
filename='dev.tables.jsonl';

importdata=loadjson(filename);

for idx=1:length(importdata)
    currentStruct=importdata{1,idx};
    TableName=matlab.lang.makeValidName(currentStruct.id);
    DataStruct.(TableName)=struct2table(currentStruct,'AsArray',true);
end

clearvars filename importdata TableName currentStruct idx

%% import question table
filename='dev.jsonl';

importdata=loadjson(filename,'SimplifyCells',0);



%% Concatenate query strings and reconstitute truth queries
% <col>; "column name string" ; <sql>: "sql language constructs"; <question>; "query string"
agg_ops = ["MAX", "MIN","COUNT", "SUM", "AVG"];
cond_ops = ['=', '>', '<', 'OP'];
syms = ['SELECT', 'WHERE']; %, 'AND', 'COL', 'TABLE', 'CAPTION', 'PAGE', 'SECTION', 'OP', 'COND', 'QUESTION', 'AGG', 'AGGOPS', 'CONDOPS'];

sql_tokens=[syms agg_ops cond_ops];

for idy=1:length(importdata)
    try
        
        datatableid=importdata{1,idy}.table_id;
        datatablename=matlab.lang.makeValidName(datatableid);
        columnheaders=DataStruct.(datatablename).header;
        questionstring(idy,:)=strjoin(["<col>" columnheaders "; " "<sql>" sql_tokens ";" "<question>" importdata{1,idy}.question],' ');
        
        if ~iscell(importdata{1,idy}.sql.conds(1)) %if it is a cell array, otherwise its a numeric array.
            importdata{1,idy}.sql.conds=num2cell(importdata{1,idy}.sql.conds);
        end
        
        
        if importdata{1,idy}.sql.agg==0
            selectPart=["SELECT " columnheaders(importdata{1,idy}.sql.sel+1) " FROM" datatablename];
        else
            selectPart=["SELECT " agg_ops(importdata{1,idy}.sql.agg) " " columnheaders(importdata{1,idy}.sql.sel+1) " FROM " datatablename];
        end
        
        
        try
        whereIndex=importdata{1,idy}.sql.conds{1,1}(2);
        if isstring(whereIndex)
        whereIndex=str2double(whereIndex);
        end
        if iscell(whereIndex)
            whereIndex=whereIndex{1,1};
        end
        catch
          whereIndex=importdata{1,idy}.sql.conds{2};  
        end
        
        
        if whereIndex==0 %Does not have a WHERE condition
            wherePart=string();
        else
            wherePart=string();
            for idq=1:length(importdata{1,idy}.sql.conds) %multiple conditions
                
                columnIndex=importdata{1,idy}.sql.conds{idq,1}(1);
                if isstring(columnIndex)
                    columnIndex=str2double(columnIndex);
                end
                
                condIndex=importdata{1,idy}.sql.conds{idq,1}(2);
                if isstring(condIndex)
                    condIndex=str2double(condIndex);
                end
                
                condition=importdata{1,idy}.sql.conds{idq,1}(3);
                if ~isstring(condition)
                    condition=num2str(condition);
                end
                
                wherePart=[wherePart "WHERE " columnheaders(columnIndex+1) cond_ops(condIndex+1) condition];
                
            end
            
        end
        
        queryString(idy,:)=strjoin([selectPart wherePart],' ');
        
    catch
        numfailedstrings=numfailedstrings+1;
        fprintf('Total String Failures is at %f This string index is %f\n',numfailedstrings,idy);
        
    end
end
    
    
    
    
    
    
    
