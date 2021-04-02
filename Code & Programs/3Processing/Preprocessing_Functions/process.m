function [life,data,data_raw] = process(text,csv,filePath)



%Add filepath to path if specified
if exist('filePath','var')==1
    addpath(filePath)
end

%Read data from file
life = read_text(text,2);
data = read_csv(csv);
data_raw = data;

life = [round(life(:,1),2) life(:,2:end)];


%Calculate RMS of acceleration data, for 50 datapoint intervals (1s)
[life_RMS,~] = calc_features(life,50);

%Determine time to shift lifeline data to align with other data

t_shift = align_data(life_RMS,data);

life(:,1) = life(:,1) + t_shift;


%Cleanup lifeline and other data such that output files only contain data
%for times that both lifeline and other data have data for
[life,data] = clean(life,data);
[~,data_raw] = clean(life,data_raw);

%Calc RMS, LineLength, and 5s average of data
[life_RMS,life_LL] = calc_features(life,500);

%wind_stddev = stddev_list(data(:,2),10);

data = average_data(data,10);

size(life)
life(:,6) = [];

life_RMS(:,5) = [];
life_LL(:,5) = [];

data = [data life_RMS(:,2:end) life_LL(:,2:end)]; %wind_stddev];