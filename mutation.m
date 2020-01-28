function member = mutation(problem,member)
%Calculates mutation for a member
%
%INPUT:
%       problem: The optimization problem.
%
%       member: A candidate for which the mutation is calculated.
%
%OUTPUT:
%       member: The same member which has undergone mutation

%Get the parameter set fnames
paramSetFnames = fieldnames(member.params);

%Get the fit parameter fnames.

fitparamFnames = fieldnames(problem.fitparams);

%Check if the mutation happens

u=rand(1);
if(u<problem.mutationProbability) %Draw all free parameters again for the first parameter set
    penaltyValue = 1;
    while(penaltyValue)
       
        for i=1:length(fitparamFnames)
            if(problem.fitparams.(fitparamFnames{i}).log)
                %If the parameter is logarithmic determine it's value
                %from a log uniform distribution
                
                member.params.(paramSetFnames{1}).(fitparamFnames{i}) = 10.^(rand(length(member.params.(paramSetFnames{1}).(fitparamFnames{i})),1).* ...
                    (log10(problem.fitparams.(fitparamFnames{i}).max)-log10(problem.fitparams.(fitparamFnames{i}).min)) ... %*(max-min)
                    +log10(problem.fitparams.(fitparamFnames{i}).min)); %+min
                
            else
                %If the parameter is linear determine it's value
                %from a uniform distribution
                member.params.(paramSetFnames{1}).(fitparamFnames{i}) = rand(length(member.params.(paramSetFnames{1}).(fitparamFnames{i})),1).* ...
                    (problem.fitparams.(fitparamFnames{i}).max - problem.fitparams.(fitparamFnames{i}).min) ... %*(max-min)
                    +problem.fitparams.(fitparamFnames{i}).min; %+min
                
            end
            
            %If the parameter needs to be normalized, do it.
            if(isfield(problem.fitparams.(fitparamFnames{i}),'normalize'))
                if(problem.fitparams.(fitparamFnames{i}).normalize)
                    member.params.(paramSetFnames{1}).(fitparamFnames{i}) = member.params.(paramSetFnames{1}).(fitparamFnames{i})./sum(member.params.(paramSetFnames{1}).(fitparamFnames{i}));
                end
            end
            
            %Check the penalty value
            
            if(isfield(problem,'penaltyFunction'))
                penaltyFunction = str2func(problem.penaltyFunction);
                member.params.(paramSetFnames{1}).redraw = 1;
                [penaltyValue, member.params.(paramSetFnames{1})] = penaltyFunction(member.params.(paramSetFnames{1}));
                
            else %No penalty function
                penaltyValue = 0;
            end

            
        end
    end
    
end

%Set all paramsets to have the same values
for j=2:length(paramSetFnames)
    for k=1:length(fitparamFnames)
        member.params.(paramSetFnames{j}).(fitparamFnames{k}) = member.params.(paramSetFnames{1}).(fitparamFnames{k});
    end
end

end

