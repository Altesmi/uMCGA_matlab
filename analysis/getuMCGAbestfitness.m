function [minI,minF] = getuMCGAbestfitness(res)

   [minF,minI]=min(min(min(permute(res.fitnesses,[3,2,1]))));

end
