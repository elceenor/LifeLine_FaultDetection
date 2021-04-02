function [out] = read_text(fileName,saveType)

%Open file
fID = fopen(fileName);
%Set save index
n=1;
time_1024 = (0:1/50:20.46)';
curr_time = 0.02;
%While file pointer is not at end, do stuff
%Note: file pointer denotes the character at which MATLAB will continue
%reading the file.
while ~feof(fID)
    %Get current location of file pointer, then get a new line
    locationIs = ftell(fID);
    line=fgetl(fID);
    %If line is empty, skip it
    if isempty(line)
        continue
    %If line starts with ~, reset the pointer to the start of the line
    %and perform a textscan operation, then join the columns and save to a
    %cell
    elseif line(1) == '~'
        fseek(fID,locationIs,'bof');
        data = textscan(fID, '%c%f%f%f%f%f%f%f%s','Delimiter',',');
        
        %If the dataset was incomplete due to a write error, delete the
        %last row (which is where the write error occured)
        if length(data{end}) ~= length(data{2})
            for i = 2:length(data)
                data{i} = data{i}(1:length(data{end}));
            end
        end
        
        %Try to convert textscan operation to a matrix. If not, move on.
        %This should probably never happen anymore (with above check) but
        %I'm keeping it for now.
        try
            attempt = cell2mat(data(2:end-1));
        catch
            disp("Couldn't resolve datasets. Moving on...")
            continue
        end
        
        %If the dataset is 1024 points long, keep it; otherwise, delete it.
        %Also, attach a timestamp to the dataset.
        if length(attempt) == 1024
            times = time_1024 + curr_time;
            curr_time = times(end)+0.02;
            intermediate{n} = [times attempt];
            n=n+1;
        else
            times = length(attempt)/50;
            curr_time = curr_time + times;
        end
        
    end
end

out = [];

if saveType == 1
    out = intermediate;

elseif saveType == 2
    for i = 1:length(intermediate)
        array = cell2mat(intermediate(i));
        out = [out;array];
    end
    out = out(:,1:6);
end


fclose(fID);
