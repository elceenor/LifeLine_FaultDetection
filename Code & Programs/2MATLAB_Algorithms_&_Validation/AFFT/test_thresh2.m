%/========================================================================\
%|   PURPOSE: Tests the FFT of vibration data against an adaptive         |
%|            threshold set earlier in the program.                       |
%|------------------------------------------------------------------------|
%|   INPUTS:   thresh - Array of currently formed thresholds              |
%|              freqs - Array of frequencies corresponding to threshold   |
%|                      and FFT                                           |
%|               amps - Amplitude of FFT to compare to threshold          |
%|            rots_ar - Array of rotor speeds of data being tested        |
%|             r_bins - Array of rotor speed bins to sort data into       |
%|               nums - A vector of the number of detections:             |
%|                      [Number of Tests, Number of Positives]            |
%|            frq_pos - A vector of positive frequencies at which a fault |
%|                      has been detected.                                |
%|------------------------------------------------------------------------|
%|   OUTPUTS: nums    - A vector of the number of detections:             |
%|                      [Number of Tests, Number of Positives]            |
%|            frq_pos - Vector of the frequencies at which a positive     |
%|                      detection occurs.                                 |
%|------------------------------------------------------------------------|
%|   Luke Costello, 10/6/2020                                             |
%\========================================================================/
function [nums,frq_pos] = test_thresh2(thresh,freqs,amps,rots_ar,r_bins,nums,frq_pos)
    global debug
    global show_faults
    
    num_tests = nums(1);
    num_pos = nums(2);
    
    %Sort FFT output into cells based on rotor speed
    amps_cell = cell(1,length(r_bins));

    for i = 1:size(amps,2)
        [~,x] = min(abs(rots_ar(i) - r_bins));
        amps_cell{x} = [amps_cell{x} amps(:,i)];
    end
    
    %Loop over each rotor speed
    for i = 1:length(amps_cell)
        amps_test = amps_cell{i};
        %Loop over each FFT at the current rotorspeed
        for k = 1:size(amps_test,2)
            
            amp_test = amps_test(:,k);
            thresh_test = thresh(:,i);
            test = find(amp_test>thresh_test);

            if debug
                figure(1);
                clf
                hold on
                plot(freqs,amp_test,'-k')
                plot(freqs,thresh(:,i),'-r')
                fill([freqs;25;-25],[thresh(:,i);max(thresh(:,i))+0.04;max(thresh(:,i))+0.04],'r','FaceAlpha','0.1','LineStyle','None')
                pause
            end
            

            
            %If test isn't empty, than a fault has been detected
            if ~isempty(test)
                pos_detect = false;
                for j = 1:length(test)
                    frq_fault = 60*freqs(test(j))/r_bins(i);
                    frq_pos = [frq_pos;frq_fault];
                    
                    if (((frq_fault > 0.75) && (frq_fault < 1.25)) || ((frq_fault > 2.75) && (frq_fault < 3.25))) && ~pos_detect
                        pos_detect = true;
                        if r_bins(i) > 140
                            num_pos = num_pos + 1;
                        end
                    end
                end

                if show_faults
                    figure(1);
                    clf
                    hold on
                    plot(freqs,amp_test,'-k')
                    plot(freqs,thresh(:,i),'-r')
                    fill([freqs;25;-25],[thresh(:,i);max(thresh(:,i))+0.2;max(thresh(:,i))+0.2],'r','FaceAlpha','0.1','LineStyle','None')
                    pause
                end
            end
            if r_bins(i) > 120
                num_tests = num_tests+1;
            end

            
        end
    end
    
    nums = [num_tests num_pos];
end

        
        
        
