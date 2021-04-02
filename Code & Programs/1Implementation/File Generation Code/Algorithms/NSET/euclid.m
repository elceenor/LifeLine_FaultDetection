%/========================================================================\
%|   PURPOSE: Calculates the Euclidean distance between 2 vectors         |
%|------------------------------------------------------------------------|
%|   INPUTS:  vec1 - Vector 1                                             |
%|            vec2 - Vector 2                                             |
%|------------------------------------------------------------------------|
%|   OUTPUTS: out  - Euclidean Distance                                   |
%|------------------------------------------------------------------------|
%|   Luke Costello, 9/12/20                                               |
%\========================================================================/
function [out] = euclid(vec1,vec2)

    len_vec1 = length(vec1);
    len_vec2 = length(vec2);

    s = 0;

    for i = 1:len_vec1
        s = s + (vec1(i) - vec2(i))^2;
    end 

    out = sqrt(s);
end