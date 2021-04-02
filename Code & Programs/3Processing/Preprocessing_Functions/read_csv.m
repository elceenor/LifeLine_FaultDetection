%=========================================================================%
%   PURPOSE: Read data from CSV files taking during Wind Turbine Testing  %
%            Two variables can be set within the file: skip, and format.  %
%            Skip specifies the number of lines to skip before reading.   %
%            Format specifies the expected format of the resulting data.  %
%-------------------------------------------------------------------------%
%   INPUTS:  fileName - The name of the CSV file, input as a string:      %
%                       'fileName.csv'                                    %
%-------------------------------------------------------------------------%
%   OUTPUTS: out      - Matrix of data read from the .csv file            %
%-------------------------------------------------------------------------%
%   Luke Costello, 9/10/2020                                              %
%=========================================================================%
function [out] = read_csv(fileName)
%Open file
fID = fopen(fileName);

%Set reading parameters
skip = 26;
formatSpec = '%D%s%f%f%f%f%f%f%f';

%Skip predefined # of lines
while skip ~= 0
    fgetl(fID);
    skip = skip - 1;
end

%Grab data
data = textscan(fID, formatSpec,'Delimiter',',');

%Convert time array to seconds
time_array = zeros(length(data{1}),1);
time_start = data{1}(1);
for i = 1:length(data{1})
    time_now = data{1}(i);
    time_array(i) = seconds(diff([time_start time_now]));
end
data{1} = time_array+1;

%Delete 2nd column (which is a string), set output, and close file
data(2) = [];

%If data file had an issue, fix it by deleting error
if size(data{1},1) ~= size(data{end},1)
    for i = 1:length(data)
        data{i} = data{i}(1:size(data{end},1));
    end
end

out = cell2mat(data);

fclose(fID);