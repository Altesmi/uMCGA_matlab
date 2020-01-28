function goodnessOfFit = gof(problem,member)
    
    %See which one of the data and simulation of the member is longer
    
    if(length(problem.data.data1)<length(member.simulations.simulation1))
        dataShorter = problem.data.data1;
        dataLonger = member.simulations.simulation1;
    else
        dataLonger = problem.data.data1;
        dataShorter = member.simulations.simulation1;
    end
    
    %Discretize the longer data and find match for the shorter data
    
    edges = [-inf,mean([dataLonger(2:end,1),dataLonger(1:end-1,1)],2)',+inf];
    dataLongerIndicesForComparison = discretize(dataShorter(:,1),edges);
    
    dataShorter(dataShorter == 0) = 1e-10;
    %Calculate goodness of fit as RMSE

    goodnessOfFit = sqrt(mean((dataShorter(:,2)-dataLonger(dataLongerIndicesForComparison,2)).^2));
    
end