function candidate = crossover(problem,members)
%Function creates a new solution candidate from two old solutions.
%
%INPUT:
%       problem: The optimization problem.
%
%       members: two members from which the candidate solution is created
%
%OUTPUT:
%       candidate: a new candidate solution likely containing properties
%                  of both members.

%Get the names of the fit parameters.

fitparamFnames = fieldnames(problem.fitparams);

%Get the names of the members.

memberFnames = fieldnames(members);

%Get the names of the parameter sets

paramSetFnames = fieldnames(members.(memberFnames{1}).params); %should be the same in every member

%Create the candidate

penaltyValue = 1;
while(penaltyValue)
    candidate = struct;
    for i=1:length(paramSetFnames)
        candidate.params.(paramSetFnames{i}) = members.(memberFnames{1}).params.(paramSetFnames{i}); %initialization
    end
    
    
    for i=1:length(fitparamFnames)
        
        
        for j=1:size(candidate.params.(paramSetFnames{1}).(fitparamFnames{i}),1)
            u = rand(1); %choose the value with equal probability
            chosenMember = struct;
            if(u<0.5)
                chosenMember = members.(memberFnames{1});
            else
                chosenMember = members.(memberFnames{2});
            end
            candidate.params.(paramSetFnames{1}).(fitparamFnames{i})(j,:) = chosenMember.params.(paramSetFnames{1}).(fitparamFnames{i})(j,:);
            
        end
        
    end
    
    if(isfield(problem,'penaltyFunction'))
        candidate.params.(paramSetFnames{1}).redraw = 0;
        penaltyFunction = str2func(problem.penaltyFunction);
        
        [penaltyValue, candidate.params.(paramSetFnames{1})] = penaltyFunction(candidate.params.(paramSetFnames{1}));
        
    else %No penalty function
        penaltyValue = 0;
    end
end

%copy the properties to other parametersets

for i=2:length(paramSetFnames)
    for j=1:length(fitparamFnames)
        candidate.params.(paramSetFnames{i}).(fitparamFnames{j}) = candidate.params.(paramSetFnames{1}).(fitparamFnames{j});
    end
end

%Loop through the fit parameters again and normalize quantities that must be
%normalized.

for i=1:length(fitparamFnames)
    for j=1:length(paramSetFnames)
        if(isfield(problem.fitparams.(fitparamFnames{i}),'normalize') && problem.fitparams.(fitparamFnames{i}).normalize == 1)
            candidate.params.(paramSetFnames{j}).(fitparamFnames{i}) = candidate.params.(paramSetFnames{j}).(fitparamFnames{i})./sum(candidate.params.(paramSetFnames{j}).(fitparamFnames{i}));
        end
    end
    
    
end
    
end

