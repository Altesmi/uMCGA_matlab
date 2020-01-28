function chosenMember = chooseMember(ind,generation)
%Chooses randomly a member from members specified by ind. The probability
%of a member to be chosen is relative to it's fitness
%
%INPUT: 
%       ind: indexes which match the generation fieldnames. These indexes
%            specify the members from which a member is chosen.
%
%       generation: struct containting all the solutions to the
%                   minimization problem. Each solutions must have at least
%                   a fitness value in a variable 'fitness'
%
%OUTPUT:
%       chosenMember: Member that is randomly picked from the possible
%                     members.

%Get the fieldnames of the generation

fnames = fieldnames(generation);

%Get all the fitnesses
fitnesses = zeros(length(fnames),1);

for i=1:length(ind)
fitnesses(i,1) = 1./generation.(fnames{ind(i)}).fitness;
end

%Normalize the fitnesses to unity

fitnesses = fitnesses./sum(fitnesses);
fitnesses = cumsum(fitnesses);

%set 0 at the start of the fitnesses to make the matrix work with find

fitnesses = [0;fitnesses];

%choose one member

u = rand(1);

chosenInd = find(u>=fitnesses,1,'last');

chosenMember = generation.(fnames{ind(chosenInd)});

end