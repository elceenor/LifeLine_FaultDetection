function [fileName,freqsOut,thresholdOut] = AFFT_thresholds(K_thr,r_bins,num_fft,bin_width,fileName,dataDirectory,outputDirectory)

    fileName = strcat(outputDirectory,'\',fileName);

    threshold = zeros(num_fft,length(r_bins));

    list = find_files(dataDirectory);
    
    %Loop over each file
    for i = 1:length(list)
        %Load variables
        load(list(i),'data_raw','life')
        %Expand other data to match lifeline output
        [data_exp,~] = expand(data_raw,life);
        %Format data for processing
        life = life(1:size(data_exp,1),:);
        data_exp(:,1) = life(:,1);
        %Calculated FFT and preallocate rotor speed averages matrix
        [freqs,amps] = FFT_array(life(:,4),50,num_fft);
        rots_ar = zeros(1,floor(length(data_exp)/num_fft));
        %Loop over all data and calculate average rotorspeed per FFT
        for j = 1:floor(length(data_exp)/num_fft)
            low = j*num_fft - (num_fft-1);
            high = j*num_fft;

            rots = data_exp(low:high,3);
            rots_ar(j) = mean(rots);
        end
        %Learn thresholds
        [threshold] = learn_thresh_l(amps,freqs,K_thr,rots_ar,threshold,r_bins,bin_width);
    end
    
    %saveList = find(freqs>=0 & freqs<=10);
    %freqsOut = freqs(saveList);
    %thresholdOut = threshold(saveList,:);
    thresholdOut = threshold;
    freqsOut = freqs;
    
    %Delete files if they already exist
    if exist(fileName,'file')==2
        delete(fileName)
    end
    
    %Save data to files
    fID = fopen(fileName,'w');
    for i = 1:size(thresholdOut,2)
        nums = thresholdOut(:,i);
        onestring = sprintf('%.4f,',nums);
        onestring = onestring(1:end-1);
        formatted = sprintf('#%.1f,%s\n',r_bins(i),onestring);
        fprintf(fID, formatted);
    end
    fclose(fID);
end


