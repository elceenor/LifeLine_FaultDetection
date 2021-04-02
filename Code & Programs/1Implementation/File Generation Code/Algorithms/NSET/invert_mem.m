%/========================================================================\
%|   PURPOSE: Computes the weighting vector for NSET given a memory       |
%|            matrix and a new observed sensor vector.                    |
%|------------------------------------------------------------------------|
%|   INPUTS:  mem - Memory Matrix                                         |
%|            obs - Observed sensor vector                                |
%|------------------------------------------------------------------------|
%|   OUTPUTS: out - Weighting Vector                                      |
%|------------------------------------------------------------------------|
%|   Luke Costello, 8/25/20                                               |
%\========================================================================/
function [invers] = invert_mem(mem)

    %Calculate size of input matrices
    n = size(mem,1);
    m = size(mem,2);

    %Preallocate memory for matrices
    Dt_D = zeros(m,m);

    %Compute Euclidian distance between each memory vector, as well as each
    %memory vector and observation vector
    for i = 1:m
        for j = 1:m
            Dt_D(i,j) = euclid(mem(:,i),mem(:,j));
        end
    end
    
    invers = inv(Dt_D);
end