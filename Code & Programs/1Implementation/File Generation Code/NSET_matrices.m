function [fileNames,mem_long] = NSET_matrices(rcondThresh,saveIndices,fileNames,dataDirectory,outputDirectory)

    %Extract file names
    memName = fileNames(1);
    memName = strcat(outputDirectory,'\',memName);
    invName = fileNames(2);
    invName = strcat(outputDirectory,'\',invName);

    %Generate list of files to memorize
    list = find_files(dataDirectory);

    %Load files and format before memorization
    dataMem = [];
    for i = 1:length(list)
        dataMem = [dataMem load_file(list(i))];
    end

    %Create memory matrix and find [mem' (bun) mem]
    [mem_long] = memorize(dataMem,rcondThresh);
    mem = mem_long(saveIndices,:);
    
    [inverse] = invert_mem(mem);
    
    
    
    %Delete files if they already exist
    if exist(memName,'file')==2
        delete(memName)
    end
    if exist(invName,'file')==2
        delete(invName)
    end
    
    %Save data to files
    fIDMem = fopen(memName,'w');
    for i = 1:size(mem,1)
        row = mem(i,:);
        row_str = sprintf('%.14f,',row);
        row_str = row_str(1:end-1);
        formatted = strcat(row_str,'\n');
        fprintf(fIDMem,formatted);
    end
    fclose(fIDMem);
    
    fIDInv = fopen(invName,'w');
    for i = 1:size(inverse,1)
        row = inverse(i,:);
        row_str = sprintf('%.14f,',row);
        row_str = row_str(1:end-1);
        formatted = strcat(row_str,'\n');
        fprintf(fIDInv,formatted); 
    end
    fclose(fIDInv);
end
