%/========================================================================\
%|   PURPOSE: Memorizes the input dataset 'data'. It is expected this     |
%|            data adheres to NSET matrix convention, that is, each       |
%|            column is a vector of sensor values and each row is         |
%|            additional vectors in time.                                 |
%|------------------------------------------------------------------------|
%|   INPUTS:  data - Input dataset to be memorized                        |
%|------------------------------------------------------------------------|
%|   OUTPUTS: mem  - Memorized matrix                                     |
%|------------------------------------------------------------------------|
%|   Luke Costello, 10/12/20                                              |
%\========================================================================/
function [mem] = memorize(data,rcondThresh)
    global loud

    %Find extreme sensor data
    [mem1,data] = find_extremes(data);
    %Sort sensor data & form the largest memory matrix possible
    [mem2] = sort_step(data,rcondThresh);

    %Combine sets and report 
    mem = [mem1 mem2];
    val = rcond_e(mem);
    if loud
        fprintf('RCond # of formed memory matrix is: %2.2s\n',val);
    end
end