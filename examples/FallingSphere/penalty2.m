function [value,params] = penalty2(params)

    if(params.startingHeight > 1e3)
        value = 1;
    else
        value = 0; 
    end
    
    %check that mass is correct
    
    if(params.mass ~= 1)
        value = 0;
    end

end