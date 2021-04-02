%/========================================================================\
%|  PURPOSE: Calculates the RCond number (see L. Costello's Thesis report |
%|           or MATLAB's rcond function documentation for more details)   |
%|------------------------------------------------------------------------|
%|  INPUTS:   mem - Matrix to compute RCond # for                         |
%|------------------------------------------------------------------------|
%|  OUTPUTS:  out - RCond Number                                          |
%|------------------------------------------------------------------------|
%|  Luke Costello, 8/28/2020                                              |
%\========================================================================/
function [out] = rcond_e(mem)

    m = size(mem,2);
    Dt_D = zeros(m);

    for i = 1:m
        for j = 1:m
            Dt_D(i,j) = euclid(mem(:,i),mem(:,j));
        end
    end

    out = rcond(Dt_D'*Dt_D);
end