function goodnessOfFit = gof2(problem,member)
    
    %initialize goodnessOfFit
    goodnessOfFit = 0;
    
    %get the fieldnames of the simulations and data
    
    dataFnames = fieldnames(problem.data);
    simulationFnames = fieldnames(member.simulations);
    
    for i=1:length(dataFnames) % assumes length(dataFnames) == length(simulationFnames)
        
        %See which one of the data and simulation of the member is longer
        
        if(length(problem.data.(dataFnames{i}))<length(member.simulations.(simulationFnames{i})))
            dataShorter = problem.data.(dataFnames{i});
            dataLonger = member.simulations.(simulationFnames{i});
        else
            dataLonger = problem.data.(dataFnames{i});
            dataShorter = member.simulations.(simulationFnames{i});
        end
        
        %Discretize the longer data and find match for the shorter data
        
        edges = [-inf,mean([dataLonger(2:end,1),dataLonger(1:end-1,1)],2)',+inf];
        dataLongerIndicesForComparison = discretize(dataShorter(:,1),edges);
        
        
        dataShorter(dataShorter == 0) = 1e-10; %to avoid division by zero
        
        %Calculate goodness of fit as sum of RMSE of individual data sets    
        goodnessOfFit = goodnessOfFit + sqrt(mean(((dataShorter(:,2)-dataLonger(dataLongerIndicesForComparison,2))./dataShorter(:,2)).^2));
    end
end