function plotuMCGAEstimatesAndFit(results,propNames)
%function plotuMCGAEstimatesAndFit(results,propNames)
%Function plots the simulated curves againts measurements and the 
%propNames designated estimates

%INPUT: results = results structure from uMCGA
%       propNames = cell array of strings where each element corresponds to
%       a fitParam

%OUTPUT: Figures

%Calculate the subplot placements

Nplots = length(propNames)+1;
if(Nplots <= 3)
    rows = 1;
    cols = Nplots;
elseif(Nplots<=6)
    rows = 2;
    cols = ceil(Nplots./2);
    
elseif(Nplots<=9)
    rows = 3;
    cols = ceil(Nplots./3);
end

Nruns = results.problem.Nrun;

runFnames = fieldnames(results.bestMembers);
simFnames = fieldnames(results.bestMembers.run1.simulations);

Nsims = length(simFnames);

Ndata = results.problem.Ndataset;

dataFnames = fieldnames(results.problem.data);
%plot measurements
h = figure;
subplot(rows,cols,1)
title('Model simulations')
hold on;
colors = jet(Ndata);

for i=1:Ndata
    
   meas = results.problem.data.(dataFnames{i});
   plot(meas(:,1),meas(:,2),'s','markerEdgeColor','k','markerFaceColor',colors(i,:));
    
end

%plot the fits
for i=1:Nruns
    for j=1:Nsims
        sim = results.bestMembers.(runFnames{i}).simulations.(simFnames{j});
        plot(sim(:,1),sim(:,2),'-','color',colors(j,:));
    end
    
end


%plot the other estimates
l = 2;
for i=1:length(propNames)
    subplot(rows,cols,l)

    estimate = getuMCGAEstimate(results,propNames{i});
    if(size(estimate,2)>1)
        boxplot(flipud(estimate)');
    else
        boxplot(estimate);
    end
    title(propNames{i})
    l = l+1;
end


end