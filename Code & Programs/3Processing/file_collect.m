%=========================================================================%
%   PURPOSE: Return a list of all filenames and extensions within the     %
%            current MATLAB folder. (NOTE: change the current folder with %
%            the command "cd(path)")                                      %
%-------------------------------------------------------------------------%
%   INPUTS:  None                                                         %
%-------------------------------------------------------------------------%
%   OUTPUTS: listNames - string array of all file and folder names in     %
%                        the current folder.                              %
%            listExt   - string array of all files in the current folder. %
%                        Note that the indices of this string correspond  %
%                        to the exact indices of listNames. Also, folders %
%                        have the extension ""                            %
%-------------------------------------------------------------------------%
%   Luke Costello, 9/10/20                                                %
%=========================================================================%
function [listNames,listExt] = file_collect()
    
    FolderInfo = dir;

    listNames = strings(1,length(FolderInfo)-2);
    listExt = strings(1,length(FolderInfo)-2);

    for i = [3:length(FolderInfo)]
        [~,name,ext] = fileparts(FolderInfo(i).name);
        try
            listNames(i-2) = name;
            listExt(i-2) = ext;
        catch
            disp('Error saving name to string array.')
        end
    end
end
