function candidate = createCandidate(problem,parentProbability,generation,fitnesses)
% Creates one new candidate from the generation.
%
%INPUT
%   problem: The problem structure
%   parentProbability: Probability for each member in the generation to be
%                      chosen to be the parent of the new member.
%   generation: The previous generation. Includes Npop member substructures
%   fitnesses: all the fitness values of the members in the generation
%
%OUTPUT
% candidate: a new solution candidate. Has the same fields as every member
%            in the generation

%Get the fieldnames of the generation
memberFieldnames = fieldnames(generation);

%Choose members to crossover
%membersToCrossover is a index vector which can be used to
%reference the elemnts in generationFieldnames cell.

membersToCrossover = chooseMembersToCrossover(parentProbability);

%Create newMember solution.
crossoverMembers = struct;
crossoverMembers.first = generation.(memberFieldnames{membersToCrossover(1)});
crossoverMembers.second = generation.(memberFieldnames{membersToCrossover(2)});

newMember = struct;
newMember.fitness = problem.badFitness; %init

newMember = crossover(problem, crossoverMembers);

%Mutation

newMember = mutation(problem,newMember);

%Calculate simulation (model output)

newMember = simulate(problem,newMember);

%Determine if the newMember is accepted to the next
%generation.
u = rand(1); %Metropolis step

if(newMember.fitness <= max(fitnesses) || (max(fitnesses)./newMember.fitness) < u)
    
    %If the fitness of the newMember is better than the
    %worst fitness in the previous generation, accept the
    %newMember to the next generation.
    candidate = newMember;
    
else
    %If the fitness was worse accept one of the members in
    %the crossover with probability equal to their fitness.
    
    candidate = chooseMember(membersToCrossover,generation);
    
end

end