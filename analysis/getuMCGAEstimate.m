function [estimate] = getuMCGAEstimate(results,propName)
%Function [estimate] = getuMCGAEstimate(results,'name')
%Function returns the 'propName' estimates from the results struct

fnames = fieldnames(results.bestMembers);

sizeInfo = size(results.bestMembers.run1.params.set1.(propName));

%initialize estimate
estimate = zeros(sizeInfo(1),sizeInfo(2)).*NaN;


%get the estimates

for i=1:length(fnames)
    
   estimate(:,i) = results.bestMembers.(fnames{i}).params.set1.(propName);
   
end

end