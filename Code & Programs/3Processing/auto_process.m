%This file automatically processes data in the data path specified by
%the data_path variable. In addition, data must be organized into
%subfolders hardcoded in the auto_prop() file.

function [] = auto_process()


addpath('C:\Users\lukec\OneDrive\Documents\2School\MastersThesis\Code\MATLAB\SignalProcessing\Preprocessing_Functions')
data_path = 'C:\Users\lukec\OneDrive\Documents\2School\MastersThesis\Data';
path(path,'C:\Users\lukec\OneDrive\Documents\2School\MastersThesis\Code\MATLAB\SignalProcessing')


folders = auto_prop();
%Loop over each folder to search through
for i = 1:length(folders)
    %Add current folder to search path
    curr_path = [data_path,'\',folders{i}];
    cd(curr_path)    
    folder = dir;
    nums = find(vertcat(folder.isdir));
    
    %Loop over contents of nums
    for j = 3:length(nums)
        foldName = folder(j).name;
        file_path = [curr_path,'\',folder(j).name];
        cd(file_path)
        [listNames,~] = file_collect();
        for n = 1:length(listNames)
            for m = 1:length(listNames)
                txt = char(listNames(n));
                csv = char(listNames(m));
                if txt(1) == csv(1)
                    continue
                end
                if n == m
                    continue
                end
                try
                    txt(3:end) == csv(4:end);
                catch
                    continue
                end
                if txt(3:end) == csv(4:end)
                    svname = [foldName,'_',txt(3:end),'.mat'];
                    txt = [txt,'.txt'];
                    csv = [csv,'.csv'];
                    fprintf('Saving files from: \\%s\\%s\\ \n  Lifeline: %s\n  Data: %s\n  Output file: %s\n\n',folders{i},foldName,txt,csv,svname)
                    answ = input('Type K to skip: ','s');
                    if answ == 'K' | answ == 'k'
                        continue
                    end
                    [life,data,data_raw] = process(txt,csv);
                    
                    if i == 2
                        cd('C:\Users\lukec\OneDrive\Documents\2School\MastersThesis\Data\ProcessedData\Balanced')
                    elseif i == 1
                        cd('C:\Users\lukec\OneDrive\Documents\2School\MastersThesis\Data\ProcessedData\Unbalanced')
                    end
                    save(svname,'data','life','data_raw')
                    cd(file_path)
                end
            end
        end
    end
end
cd 'C:\Users\lukec\OneDrive\Documents\2School\MastersThesis\Code\MATLAB\SignalProcessing'