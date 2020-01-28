function fitnesses= getFitnesses(generation)

    %define fieldnames
    fnames = fieldnames(generation);
    
    fitnesses = zeros(length(fnames),1).*NaN;
    for i=1:length(fnames)
       
        fitnesses(i,1) = generation.(fnames{i}).fitness;
        
    end

end

