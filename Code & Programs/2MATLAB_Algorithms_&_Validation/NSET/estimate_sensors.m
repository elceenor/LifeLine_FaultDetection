%/========================================================================\
%|   PURPOSE: Estimates the expected sensor data given a memory matrix    |
%|------------------------------------------------------------------------|
%|   INPUTS:  data - Dataset to be estimated                              |
%|            mem  - Memory Matrix                                        |
%|------------------------------------------------------------------------|
%|   OUTPUTS: est  - Estimated sensor values                              |
%|------------------------------------------------------------------------|
%|   Luke Costello, 10/15/20                                              |
%\========================================================================/
function [est] = estimate_sensors(data,mem)

    [sv,nrml,~] = prop();

    array = data;


    for n = 1:size(data,2)
        obs = array(:,n);
        [out] = weight(mem,obs);
        est(:,n) = mem*out;
    end

    index = 1:n;
end