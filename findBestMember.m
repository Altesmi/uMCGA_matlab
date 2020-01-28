function bestMember = findBestMember(generation,fitness)
%Find the best member (lowest goodness-of-fit value) in a generation.
%
%INPUT:
%       generation: struct of the possible solutions from which to choose
%       fitness: fitnesses of these solutions in the same order as they are
%                in the generation struct.
%
%OUTPUT:
%       bestMember: solution struct which has the lowest fitness in the
%                   generation.

%Define fieldnames of the generation.
fnames = fieldnames(generation);

%Find the index of the minimum value.
[~,ind] = min(fitness);

%Save the bestMember.
bestMember = generation.(fnames{ind});

end