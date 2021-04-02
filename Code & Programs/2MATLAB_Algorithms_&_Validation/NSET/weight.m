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
function [out,invers] = weight(mem,obs)

    %Calculate size of input matrices
    n = size(mem,1);
    m = size(mem,2);

    if size(obs,1) ~= n
        error('Observed vector is not the same length as memorized vectors.')
    end

    %Preallocate memory for matrices
    Dt_D = zeros(m,m);

    Dt_X = zeros(m,1);

    %Compute Euclidian distance between each memory vector, as well as each
    %memory vector and observation vector
    for i = 1:m
        for j = 1:m
            Dt_D(i,j) = euclid(mem(:,i),mem(:,j));
        end
        Dt_X(i) = euclid(mem(:,i),obs);
    end
    
    
    %Compute inv(Dt_D)*Dt_X
    
    invers = inv(Dt_D);
    out = Dt_D\Dt_X;
end