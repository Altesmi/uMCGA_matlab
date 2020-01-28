function membersToCrossover = chooseMembersToCrossover(parentProbability)
%Choose two members wrt. their probability to be chosen to the
%crossover.
%INPUT:
%   parentProbability: cumulative sum of the normalized probabilities.
%
%OUTPUT:
%   membersToCrossover: 2x1 index vector which can be used to reference the
%                       right elements in generation struct.


%Get random integer between ]0,1[.
u = rand(1);

%Find the space where u belongs in the parentProbabilities.

membersToCrossover(1) = find(u>=parentProbability,1,'last');

%Set the second member to the same value and loop until the second
%value is different from the first.

membersToCrossover(2) = membersToCrossover(1);

while(membersToCrossover(2) == membersToCrossover(1))
    
    u = rand(1);
    membersToCrossover(2) = find(u>=parentProbability,1,'last');
    
end

end

