function population = createInitialPopulation(problem)
%Function creates the parameters in the members, runs the simulations
%and calculates member fitness. Problem params and fitparams are used.
%
%INPUT:
%       problem: the optimization problem. Needs to include the params and
%                fitparams for using the models.
%
%OUTPUT:
%       population: a structure containing problem.populationSize
%                   substrucutres. Each substruct contains the parameters,
%                   simulations and a fitness value.

population = struct; %initialization
populationExtra = struct;

%Save the fitparameter fieldnames for setting them to member.params.
fitparamFnames = fieldnames(problem.fitparams);

%initialize fnames
fnames = cell(problem.populationSizeExtra,1);

%save the parameterset fnames

paramSetFnames = fieldnames(problem.params);

%Loop the population extra size times and create a single member
i = 1;
while i<=problem.populationSizeExtra
    disp(i);
    %A running fieldname.
    fnames{i} = ['member',num2str(i)];
    
    for j=1:length(paramSetFnames)
        populationExtra.(fnames{i}).params.(paramSetFnames{j}) = problem.params.(paramSetFnames{j}); %initialize
    end
    
    for j=1:length(fitparamFnames)
        
        %Set the fitparameter to a random value between min and max
        
        %If the parameter is logarithmic handle it separately in order
        %to have correct sampling in the interval.
        if(problem.fitparams.(fitparamFnames{j}).log)
            
            populationExtra.(fnames{i}).params.(paramSetFnames{1}).(fitparamFnames{j}) = 10.^(rand(length(populationExtra.(fnames{i}).params.(paramSetFnames{1}).(fitparamFnames{j})),1).* ...
                (log10(problem.fitparams.(fitparamFnames{j}).max)-log10(problem.fitparams.(fitparamFnames{j}).min)) ... %*(max-min)
                +log10(problem.fitparams.(fitparamFnames{j}).min)); %+min
            
            %If the parameter needs to be normalized, do it.
            if(isfield(problem.fitparams.(fitparamFnames{j}),'normalize'))
                if(problem.fitparams.(fitparamFnames{j}).normalize)
                    populationExtra.(fnames{i}).params.(paramSetFnames{1}).(fitparamFnames{j}) = populationExtra.(fnames{i}).params.(paramSetFnames{1}).(fitparamFnames{j})./sum(populationExtra.(fnames{i}).params.(paramSetFnames{1}).(fitparamFnames{j}));
                end
            end
        else
            %If the parameter is linear determine it's value
            %linearly.
            populationExtra.(fnames{i}).params.(paramSetFnames{1}).(fitparamFnames{j}) = rand(length(populationExtra.(fnames{i}).params.(paramSetFnames{1}).(fitparamFnames{j})),1).* ...
                (problem.fitparams.(fitparamFnames{j}).max - problem.fitparams.(fitparamFnames{j}).min) ... %*(max-min)
                +problem.fitparams.(fitparamFnames{j}).min; %+min
            
            %If the parameter needs to be normalized, do it.
            if(isfield(problem.fitparams.(fitparamFnames{j}),'normalize'))
                if(problem.fitparams.(fitparamFnames{j}).normalize)
                    populationExtra.(fnames{i}).params.(paramSetFnames{1}).(fitparamFnames{j}) = populationExtra.(fnames{i}).params.(paramSetFnames{1}).(fitparamFnames{j})./sum(populationExtra.(fnames{i}).params.(paramSetFnames{1}).(fitparamFnames{j}));
                end
            end
            
        end
        
        
    end
    
    %Set all the other paramSetFnames to the same values as the first on
    

%Check the penalty value
if(isfield(problem,'penaltyFunction'))
    penaltyFunction = str2func(problem.penaltyFunction);
    populationExtra.(fnames{i}).params.(paramSetFnames{1}).redraw = 1;
    [penaltyValue, populationExtra.(fnames{i}).params.(paramSetFnames{1})] = penaltyFunction(populationExtra.(fnames{i}).params.(paramSetFnames{1}));
    if(penaltyValue)
        continue;
    end
    
end


for j=2:length(paramSetFnames)
    for k=1:length(fitparamFnames)
        populationExtra.(fnames{i}).params.(paramSetFnames{j}).(fitparamFnames{k}) = populationExtra.(fnames{i}).params.(paramSetFnames{1}).(fitparamFnames{k});
    end
end

%run the simulation on the new member candidate
populationExtra.(fnames{i}) = simulate(problem,populationExtra.(fnames{i}));

i = i+1;

end


%Get the fitnesses of the population.

fitnesses = getFitnesses(populationExtra);

%add another column to fitnesses which labels them

fitnesses(:,2) = (1:length(fitnesses))';

%sort the fitnesses

fitnesses = sortrows(fitnesses,1);

%choose NElite simulations to the first generation

for i=1:problem.NElite
    name = ['simulation' num2str(i)];
    population.(name) = populationExtra.(fnames{fitnesses(i,2)});
end

%choose randomly N-NElite simulations
indAll = randperm(problem.populationSizeExtra-problem.NElite);
ind = indAll(1:(problem.populationSize-problem.NElite))+problem.NElite;

for i=1:length(ind)
    
    name = ['simulation', num2str(i+problem.NElite)];
    population.(name) = populationExtra.(fnames{fitnesses(ind(i),2)});
    
end

end

