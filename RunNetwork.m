% Set up training network
%
%
%

%% Clean up and pad data

queries=queryString(~ismissing(queryString));
questions=questionstring(~ismissing(queryString));
numQueries=length(queries);

for idx=1:numQueries
queryLength(idx)=strlength(queries(idx));
questionLength(idx)=strlength(questions(idx));
end

[sequenceLengths,idy]=sort(questionLength);
questions=questions(idy);
queries=queries(idy);
% tokenize strings
queries=erasePunctuation(queries);
queries=lower(queries);
tokenized_queries=tokenizedDocument(queries);

questions=erasePunctuation(questions);
questions=lower(questions);
tokenized_questions=tokenizedDocument(questions);


%% Embeddings
embeddingDimension=100;
embeddingEpochs=50;

emb = trainWordEmbedding(tokenized_questions, ...
    'Dimension',embeddingDimension, ...
    'NumEpochs',embeddingEpochs, ...
    'Verbose',0);

% kill strings that are >6sigma
% range [0:6sigma];

sigma=std(sequenceLengths);
sixSigma=6*sigma;

tooBig=sequenceLengths>sixSigma;

tokenized_questions=tokenized_questions(~tooBig);
tokenized_queries=tokenized_queries(~tooBig);


XTrain=doc2sequence(emb,tokenized_questions);

for i = 1:numel(XTrain)
    XTrain{i} = leftPad(XTrain{i},sequenceLengths);
end






%% Set up NN

miniBatchSize=14;
inputSize=length(questions);
numHiddenUnits=100;
numClasses=12;

layers=[...
    sequenceInputLayer(inputSize)
    bilstmLayer(numHiddenUnits,'OutputMode','last')
    bilstmLayer(numHiddenUnits,'OutputMode','last')
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer];

maxEpochs = 100;


options = trainingOptions('adam', ...
    'ExecutionEnvironment','cpu', ...
    'GradientThreshold',1, ...
    'MaxEpochs',maxEpochs, ...
    'MiniBatchSize',miniBatchSize, ...
    'SequenceLength','longest', ...
    'Shuffle','never', ...
    'Verbose',0, ...
    'Plots','training-progress');

net=trainNetwork(XTrain,tokenized_queries,layers,options);



function C=doc2sequence(emb,documents)

parfor i=1:numel(documents)
    words=string(documents(i));
    idx=~ismember(emb,words);
    words(idx)=[];
    C{i}=word2vec(emb,words)';
end
end


function MPadded=leftPad(M,N)

[dimension, sequenceLength]= size(M);
paddingLength=N-sequenceLength;
MPadded=[zeros(dimension,paddingLength) M];

end
