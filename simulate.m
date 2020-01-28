function member = simulate(problem,member)
%Function runs the simulations specified in the problem.
%The models in the problem structure need to run with
%the params struct in the problem struct
%
%INPUT: 
%       problem: The problem struct. This function also handles calculating
%                the fitnesses of the solutions thus the datasets in 
%                problem struct are needed.
%
%       member: A solution candidate, includes the params struct for 
%               running the models.
%
%OUTPUT:
%       member: The same member that is in the input but the output 
%       includes the simulations field and the value of the goodness-of-fit function 
%       in structure 'simulations' and fitness, respectively.


%construct function from the strings in the problem

modelFnames = fieldnames(problem.models);


%Get the names of the parameter sets

paramSetNames = fieldnames(member.params);

%Get the names of the fit parameters

fitParamFnames = fieldnames(problem.fitparams);

%See if there is a penaltyfunction in the problem
if(isfield(problem,'penaltyFunction'))%see if the penalties are violated
    penaltyFunction = str2func(problem.penaltyFunction);
    fitParams = struct;
    for i=1:length(fitParamFnames)
        fitParams.(fitParamFnames{i}) = member.params.(paramSetNames{1}).(fitParamFnames{i});
    end
    
    if(isfield(member.params.(paramSetNames{1}),'includeToPenaltyFunction'))
        for i=1:length(member.params.(paramSetNames{1}).includeToPenaltyFunction)
            fitParams.(member.params.(paramSetNames{1}).includeToPenaltyFunction{i}) = ... 
                member.params.(paramSetNames{1}).(member.params.(paramSetNames{1}).includeToPenaltyFunction{i});
        end
    end
    [val, fitParams] = penaltyFunction(fitParams);
    if(val)
        member.fitness = problem.badFitness;
        return;
    end
    for i=1:length(modelFnames) %set all the params to be the same
       
        for j=1:length(fitParamFnames)
            member.params.(paramSetNames{i}).(fitParamFnames{j}) = fitParams.(fitParamFnames{j});
        end
        
    end
    
end

%cast model string to functions
modelFunctions = cell(length(modelFnames),1); %initialization

for i=1:length(modelFnames)
    
    modelFunctions{i} = str2func(problem.models.(modelFnames{i}));
    
end

%create simulations substruct and run the simulations

simulationsFnames = cell(length(modelFnames),1);

for i=1:length(modelFnames)
    params = member.params.(paramSetNames{i});
    simulationsFnames{i} = ['simulation',num2str(i)];
    member.simulations.(simulationsFnames{i}) = modelFunctions{i}(params);
end
    
%calculate goodness-of-fit

gofFunction = str2func(problem.gofFunction);

member.fitness = gofFunction(problem,member);

end

