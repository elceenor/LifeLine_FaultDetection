%=========================================================================%
%   PURPOSE: Read files from a  %
%            a form than can be easily interpreted.                       %
%-------------------------------------------------------------------------%
%   INPUTS:  signal - N-by-1 array signal input to be transformed         %
%            rate   - The data sample rate in Hz                          %
%-------------------------------------------------------------------------%
%   OUTPUTS: frq    - N-by-1 array of the frequency of each amplitude     %
%                     in the amp array                                    %
%            amp    - N-by-1 array of the amplitude of each frequency     %
%-------------------------------------------------------------------------%
%   Luke Costello, 4/26/2020                                              %
%=========================================================================%
function [list] = find_files(name)

    %If no argument for name supplied, write default
    if ~exist('name')
        name = 'C:\Users\lukec\OneDrive\Documents\2School\MastersThesis\Code\MATLAB\Modeling\NSET\Memory';
    end

    fprintf('Reading files from: %s\n',name)

    %Create list of files
    files = dir(name);
    %Calculate number of files (# = fileNum - 2)
    fileNum = length(files);
    %Create empty list of filenames
    list = strings(fileNum-2,1);
    %Loop over all files and save name data as a string
    for i = 3:fileNum
        list(i-2) = files(i).name;
    end
end