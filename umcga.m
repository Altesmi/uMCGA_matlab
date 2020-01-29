function results = umcga(problem)
%% Universal MCGA solver for optimization problems
%
%INPUT:
% problem: Structure that describes the optimization problem. 
%           Needs to include fields.
%
%	populationSize: Size of the population in the genetic algorithm part.
%
%   populationSizeExtra: Size of the population in the Monte Carlo part.
%
%   NElite: Number of elite candidates that are always moved to the next
%           generation.
%
%   Ngen: Number of generations. The MC part is the first generation hence
%         there will be (Ngen-1) generations in the GA part.
%
%   Nrun: Number of independent optimization runs.
%
%   Ndataset: Number of data sets that are used in the optimization.
%
%   mutationProbability: The probability value between 0-1 for the mutation
%                        to happen in the genetic algorithm. When mutation
%                        happens the free parameters of a candidate are
%                        drawn again randomly for their set intervals (see
%                        fitparams structure for free parameter definition)
%
%   models: Name of the file (string) that needs to be called to run each
%           model. The models are specified as sub structres like
%           models.model1 = name of first model
%           models.model2 = name of the second model
%           models.modelNdataset = name of the Nth model.
%
%   params: Parameters for the numerical models that describe the system
%           which produces the measured values. These are specified as
%           params.set1 = parameters for the first model
%           params.set2 = parameteters for the second model
%           params.setNdataset = parameters for the Nth model.
%
%   data:   Data sets against which the output of the models is compared
%           the first data set is compared against the output of the first
%           model, the second data set against the output of the second
%           model and so on. The data sets are speciefied as
%           data.data1 = first data set
%           data.data2 = second data set
%           data.dataNdataset = Nth data set.
%
%   gofFunction: Name of the goodness-of-fit function. The gof function
%                needs to take two arguments as gofFunction(problem,member)
%                where problem is the problem structure defined as the
%                input to the umcga and member is a structure containing 
%                the output of each model in a candidate solution. 
%                The fields in a 'member' are
%                   member.params = parameters of the candidate in the same
%                                   order as in the problem.params
%                   member.simulations = model outputs in sub structers
%                                        simulations.simulation1 = output
%                                                   of the first model
%                                        simulations.simulation2 = output
%                                                   of the second model
%               The gofFunction needs to return a single value for the
%               goodness-of-fit. NB! The MCGA algorithm tries to minimize
%               this function.
%
%   badFitness: Goodness-of-fit value assigned to a candidate whose model 
%               output can not be calculated. This should be a high number
%               wrt. the typical fitness values given by the gofFunction.
%                 
%   penaltyFunction: (optional) Function that takes in the 
%                    problem.params structure and returns both a boolean
%                    value and the same params structure in this order. If
%                    the boolean value is 1 the candidate is not accepted
%                    and the fitted parameters are drawn again. If the
%                    boolean value is 0 the parameters of the candidate are
%                    accepted. This function can be used to restrict some
%                    parts of the free parameter space.
%
%  includeToPenaltyFunction: (optional) cell of strings containing the
%                            names of the parameters that are passed also 
%                            to the penalty function in addition to the 
%                            fitparams (see below).
%
%   fitparams: This structure marks which of the parameters in the params
%              structure are marked as free parameters and whose values 
%              the MCGA algorithm tries to change such that the model 
%              output(s) would match the data sets. Free parameters are
%              defined as substructures like
%              fitparams.paramName1 = name of the first free parameter.
%              Each new fitparam needs to have fields
%              paramName1.min: the minimum value the parameter can have
%              paramName1.max: the maximum value the parameter can have
%              paramName1.log: Boolean value. If 0 the parameter values
%                               are drawn from a uniform distribution 
%                               if 1 the values are drawn from log-uniform
%                               distribution
%             paramName1.normalize: Boolean value. If 1 the values in this
%                                    free parameter are normalized to unity
%   parallel: Boolean value describing whether or not to parallelize
%             calculations
%OUTPUT:
%   results: Structure containing results of the optimization. Fields are
%       problem: The input problem structure.
%       bestMembers.runN: The best fit candidate in the Nth run each runN
%                         includes fields.
%           params: The params structure from the problem structure and the
%                   values for the free parameters that best fit the data.
%           simulations: Model outputs in sub structers.
%               simulations.simulationN: output of the Nth model.
%           fitness: goodness-of-fit value for this best-fit candidate.
%
%      bestSolutions.runN.generationN: The best-fit candidate in the Nth
%                                      run after the Nth generation had 
%                                      been created.
%
%     fitnesses: all the goodness-of-fit function values the dimensions 
%                are Nrun x Ngen x NPop

%Define results struct components.
results.bestSolutions = struct; %best solutions during iteration for history plotting

results.bestMembers = struct; %best members from each optimization run

results.fitnesses = zeros(problem.Nrun,problem.Ngen,problem.populationSize).*NaN; % all the fitnesses

%Define variables for iterating.

generation = struct; %Current generation is held in this struct.

parentProbability = zeros(problem.populationSize,1).*NaN; %Probabilities of each member in generation to be chosen to crossover

%Start to calculate solutions (altogether problem.Nrun independent
%optimizations are done)

for runNumber = 1:problem.Nrun
    
    %Define the fieldname for this run.
    runFieldname = ['run',num2str(runNumber)];
    
    %Define generation fieldName.
    %This is static here but dynamic when the generation loop is
    %entered
    
    generationFieldname = 'generation1';
    
    %Create the first generation by randomly choosing solutions.
    %This is the MC part of the algorithm (see Documentation for details).
    if(isfield(problem,'parallel') && problem.parallel == 1)
        disp([datestr(datetime), '>> Run ',num2str(runNumber),': Started to create initial population'])
        generation = createInitialPopulationParallel(problem);
        %Save the fitnesses and find the best solution in the first generation.
        results.fitnesses(runNumber,1,:) = getFitnesses(generation);
        disp([datestr(datetime), '>> Run ',num2str(runNumber),': Initial population created | Fitness: ', num2str(min(min(results.fitnesses(runNumber,:,:))))])
    else
        generation = createInitialPopulation(problem);
        %Save the fitnesses and find the best solution in the first generation.
        results.fitnesses(runNumber,1,:) = getFitnesses(generation);
        disp([datestr(datetime), '>> Run ',num2str(runNumber),': Initial population created | Fitness: ', num2str(min(min(results.fitnesses(runNumber,:,:))))])
    end
    
    %Save the fieldnames for reading the next generation with same
    %fieldnames.
    memberFieldnames = fieldnames(generation);
    
    results.bestSolutions.(runFieldname).(generationFieldname) = findBestMember(generation, results.fitnesses(runNumber,1,:));
    
    results.bestSolutions.(runFieldname).best = results.bestSolutions.(runFieldname).(generationFieldname); %initialization
    
    %Initialize NtimesStop which is used as alternative stopping criterion.
    NtimesStop = 1;
    
    %Start the GA part of the algorithm.
    
    for generationNumber=2:problem.Ngen
        
        %Update the generationFieldname.
        generationFieldname = ['generation',num2str(generationNumber)];
        
        %Set next generation to an empty struct.
        nextGeneration = struct;
        
        %Pick NElite members to the next generation
        currentFitness = results.fitnesses(runNumber,generationNumber-1,:);
        currentFitness = reshape(currentFitness,length(currentFitness),1);
        currentFitness(:,2) = (1:length(currentFitness))';
        currentFitness = sortrows(currentFitness,1);
        
        for eliteI = 1:problem.NElite
            
            nextGeneration.(memberFieldnames{eliteI}) = generation.(memberFieldnames{currentFitness(eliteI,2)});
            
        end
        
        %Calculate the probabilities of every member to be chosen to
        %crossover.
        fitnessPrev = reshape(results.fitnesses(runNumber,generationNumber-1,:),problem.populationSize,1);
        parentProbability = 1./fitnessPrev;
        parentProbability = parentProbability./sum(parentProbability);
        parentProbability = cumsum(parentProbability); %cumulative sum
        parentProbability = [0; parentProbability]; %add 0 to make the calculations work
        
        %Start to create the next generation.
        
        if(isfield(problem,'parallel') && problem.parallel == 1)
            
            %Parfor needs a cell dummy to store the candidates
            nextGenerationCell = cell(problem.populationSize-problem.NElite,1);
            
            parfor i = 1:(problem.populationSize-problem.NElite)
                
                candidate = createCandidate(problem,parentProbability,generation,fitnessPrev);
                nextGenerationCell{i} = candidate;
                
            end
            
            i = 1;
            for memberNumber = ((problem.NElite)+1):problem.populationSize
                nextGeneration.(memberFieldnames{memberNumber}) = nextGenerationCell{i};
                i = i+1;
            end
            disp([datestr(datetime), '>> Run ',num2str(runNumber),': Gen ',num2str(generationNumber),' created | Fitness: ', num2str(min(min(results.fitnesses(runNumber,:,:))))])
        else
            for memberNumber = ((problem.NElite)+1):problem.populationSize

                candidate = createCandidate(problem,parentProbability,generation,fitnessPrev);
                
                nextGeneration.(memberFieldnames{memberNumber}) = candidate;
                
                
            end
            disp([datestr(datetime), '>> Run ',num2str(runNumber),': Gen ',num2str(generationNumber),' created | Fitness: ', num2str(min(min(results.fitnesses(runNumber,:,:))))])
        end
        
        %Now the next generation is created,
        %set it as the current generation.
        generation = nextGeneration;
        
        %Calculate the new fitnesses.
        results.fitnesses(runNumber,generationNumber,:) = getFitnesses(generation);
        
        %Update the best solutions.
        
        results.bestSolutions.(runFieldname).(generationFieldname) = findBestMember(generation,results.fitnesses(runNumber,generationNumber,:));
        
        if(results.bestSolutions.(runFieldname).best.fitness > results.bestSolutions.(runFieldname).(generationFieldname).fitness)
            results.bestSolutions.(runFieldname).best = results.bestSolutions.(runFieldname).(generationFieldname);
        end
        
    end
    
    %set the best member from this run to bestMembers
    results.bestMembers.(runFieldname) = results.bestSolutions.(runFieldname).best;
end
%set problem struct to results
results.problem = problem;

disp('Optimization completed');
end
