function population = createInitialPopulationParallel(problem)
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

%Create the fnames for populationExtra

for i=1:problem.populationSizeExtra
    fnames{i} = ['member',num2str(i)];
end

%Parfor needs a cell dummy to store the generated solutions
populationExtraCell = cell(problem.populationSizeExtra,1);

%Loop the population extra size times and create a single member

parfor i=1:problem.populationSizeExtra
    while 1 %Loop breakes when the simulate returns something else than badFitness
        newMember = struct; %A dummy which each worker creates
        for j=1:length(paramSetFnames)
            newMember.params.(paramSetFnames{j}) = problem.params.(paramSetFnames{j}); %initialize
        end
        
        for j=1:length(fitparamFnames)
            
            %Set the fitparameter to a random value between min and max
            
            %If the parameter is logarithmic handle it separately in order
            %to have correct randomness in the interval.
            if(problem.fitparams.(fitparamFnames{j}).log)
                
                newMember.params.(paramSetFnames{1}).(fitparamFnames{j}) = 10.^(rand(length(newMember.params.(paramSetFnames{1}).(fitparamFnames{j})),1).* ...
                    (log10(problem.fitparams.(fitparamFnames{j}).max)-log10(problem.fitparams.(fitparamFnames{j}).min)) ... %*(max-min)
                    +log10(problem.fitparams.(fitparamFnames{j}).min)); %+min
                
                
            else
                %If the parameter is linear determine it's value
                %linearly.
                newMember.params.(paramSetFnames{1}).(fitparamFnames{j}) = rand(length(newMember.params.(paramSetFnames{1}).(fitparamFnames{j})),1).* ...
                    (problem.fitparams.(fitparamFnames{j}).max - problem.fitparams.(fitparamFnames{j}).min) ... %*(max-min)
                    +problem.fitparams.(fitparamFnames{j}).min; %+min
                
            end
            
            %If the parameter needs to be normalized, do it.
            if(isfield(problem.fitparams.(fitparamFnames{j}),'normalize'))
                if(problem.fitparams.(fitparamFnames{j}).normalize)
                    newMember.params.(paramSetFnames{1}).(fitparamFnames{j}) = newMember.params.(paramSetFnames{1}).(fitparamFnames{j})./sum(newMember.params.(paramSetFnames{1}).(fitparamFnames{j}));
                end
            end
            
            
        end
        
        %Set all the other paramSetFnames to the same values as the first
        %one
        
        if(isfield(problem,'penaltyFunction'))
            %disp(problem.penaltyFunction)
            penaltyFunction = str2func(problem.penaltyFunction);
            newMember.params.(paramSetFnames{1}).redraw = 1;
            %disp(penaltyFunction)
            [penaltyValue, newMember.params.(paramSetFnames{1})] = penaltyFunction(newMember.params.(paramSetFnames{1}));
            if(penaltyValue)
                continue;
            end
            
        end
        
        for j=2:length(paramSetFnames)
            for k=1:length(fitparamFnames)
                newMember.params.(paramSetFnames{j}).(fitparamFnames{k}) = newMember.params.(paramSetFnames{1}).(fitparamFnames{k});
            end
        end
        
        %run the simulation on the new member candidate
        newMember = simulate(problem,newMember);
        
        %If the penaltyfunction in simulate returns problem.badFitness create a
        %new member

        if(newMember.fitness == problem.badFitness)
            continue;
        else %The member is accepted         
            break;
        end

        
    end
     populationExtraCell{i} = newMember;
end

%Set the cell array to populationSizeExtra

for i=1:problem.populationSizeExtra
    
   populationExtra.(fnames{i}) = populationExtraCell{i};
   
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

