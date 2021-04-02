function [] = preprocess(lifeName,sqrName,saveName,inputPath,balanced)

if ~exist('inputPath')
    error('No path given for datafiles.')
end

if balanced
    outputPath = 'C:\Users\lukec\OneDrive\Documents\2School\MastersThesis\Data\ProcessedData\Balanced\';
else
    outputPath = 'C:\Users\lukec\OneDrive\Documents\2School\MastersThesis\Data\ProcessedData\Unbalanced\';
end

path(path,inputPath)
path(path,'C:\Users\lukec\OneDrive\Documents\2School\MastersThesis\Code\MATLAB\SignalProcessing\Preprocessing_Functions\')

[life_out_raw,sqr_out_raw,index_raw] = main_processor(lifeName,sqrName,'',false);

[life_out,life_RMS_out,sqr_out,life_time,sqr_time] = alignData(life_out_raw,sqr_out_raw);

[life_clean,life_RMS_clean,sqr_clean,sqr_time_clean,life_time_clean,index_clean] = cleanup(life_out,life_RMS_out,sqr_out,sqr_time,life_time,index_raw);

accelData = [life_clean,index_clean];
accelTime = life_time_clean;
vectorData   = [life_RMS_clean,sqr_clean,sqr_clean(:,3).*sqr_clean(:,4)];
vectorTime   = sqr_time_clean;

fullSaveName = [outputPath,saveName];

save(fullSaveName,'accelData','accelTime','vectorData','vectorTime')