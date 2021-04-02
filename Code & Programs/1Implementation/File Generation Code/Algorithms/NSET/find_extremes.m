%/========================================================================\
%|   PURPOSE: Finds extreme sensor values for the sensors in position 2   |
%|            and position 3.                                             |
%|------------------------------------------------------------------------|
%|   INPUTS:  array - Input dataset to be memorized                       |
%|------------------------------------------------------------------------|
%|   OUTPUTS: out   - Memorized matrix                                    |
%|            array - Returns the input array without the memorized       |
%|                    values so that later memorization algorithms do not |
%|                    use them as well.                                   |
%|------------------------------------------------------------------------|
%|   Luke Costello, 10/12/20                                              |
%\========================================================================/
function [out,array] = find_extremes(array)

    [~,i] = min(array(2,:));
    out = [array(:,i)];
    array(:,i) = [];

    [~,k] = min(array(3,:));
    out = [out array(:,k)];
    array(:,k) = [];

    [~,j] = max(array(2,:));
    out = [out array(:,j)];
    array(:,j) = [];

    [~,l] = max(array(3,:));
    out = [out array(:,l)];
    array(:,l) = [];

end
