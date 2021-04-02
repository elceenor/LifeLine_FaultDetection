


function [slope,intercept] = GetParams(X,Y)
    %Fit linear model
    sys = fitlm(X,Y);
    %Get parameter table
    params = table2array(sys.Coefficients);
    %Extract slope and intercept
    slope = params(2,1);
    intercept = params(1,1);
end
