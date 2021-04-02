%=========================================================================%
%   PURPOSE: Loads MATLAB .mat files and processes them into a format     %
%            useful by the NSET+SPRT algorithms. Data files must be a .mat%
%            file with the desired dataset variable "data"                %
%-------------------------------------------------------------------------%
%   INPUTS:  fileName - The name of the file to be loaded, as a string    %
%-------------------------------------------------------------------------%
%   OUTPUTS: array    - The output array, ready for processing by NSET    %
%-------------------------------------------------------------------------%
%   Luke Costello, 9/26/2020                                              %
%=========================================================================%

function [array] = load_file(fileName)
    global loud
    
    if loud
        fprintf('Loading file: %s\n',fileName)
    end
    clear data
    
    load(fileName)
    [sv,nrml,~] = prop();
    
    %Save only the sensors specified in prop()
    array = data(:,sv);
    array = array';
    
    %Normalize each sensor by values specified in prop()
    for i = 1:length(nrml)
        array(i,:)=array(i,:)/nrml(i);
    end
    
    %Compute power
    array(3,:) = array(3,:).*array(4,:);
    array(4,:) = [];
end
