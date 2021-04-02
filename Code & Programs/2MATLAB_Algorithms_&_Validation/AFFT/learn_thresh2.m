%/========================================================================\
%|   PURPOSE: Tests the FFT of vibration data against an adaptive         |
%|            threshold set earlier in the program.                       |
%|------------------------------------------------------------------------|
%|   INPUTS:       amps - Amplitude of most recent FFT                    |
%|                freqs - Frequencies corresponding to amplitudes of FFT  |
%|                K_thr - Threshold multiplier                            |
%|              rots_ar - Array of rotor speeds, to sort newly formed     |
%|                        thresholds into bins                            |
%|            threshold - The currently formed threshold, so it can be    |
%|                        compared against the next FFT                   |
%|------------------------------------------------------------------------|
%|   OUTPUTS: threshold - The latest formed threshold                     |
%|------------------------------------------------------------------------|
%|   Luke Costello, 10/6/2020                                             |
%\========================================================================/

function [threshold] = learn_thresh2(amps,freqs,K_thr,rots_ar,threshold)
global debug


%%Sort each FFT into bins based on rotorspeed
[~,r_bins,d] = AFFT_prop(K_thr);

bin_width = d(3);                   %Frequency width per threshold
frq_step = (freqs(2)-freqs(1));     %Step size per FFT datapoint [Hz]
num_steps = ceil(bin_width/frq_step);     %Steps per frequency width bin [#]
num_1side = ceil(num_steps/2);      %Steps on one side per peak



amps_cell = cell(1,length(r_bins));

for i = 1:size(amps,2)
    [~,x] = min(abs(rots_ar(i) - r_bins));
    amps_cell{x} = [amps_cell{x} amps(:,i)];
end


%%Loop over each bin of rotorspeed
for i = 1:length(amps_cell)
    amps_lrn = amps_cell{i};
    amps_lrn = max(amps_lrn,[],2);
    if any(size(amps_lrn) == [0 0])
        continue
    end
    
    for j = 1:length(amps_lrn)
        low = j-num_1side;
        high = j+num_1side;
        if low < 1
            low = 1;
        elseif high > length(amps_lrn)
            high = length(amps_lrn);
        end
        
        lrns = amps_lrn(low:high);
        max_lrns = K_thr * max(lrns,[],1);
        max_all = max([max_lrns,threshold(j,i)]);
        threshold(j,i) = max_all;
    end
    
    if debug
        figure(1);
        clf
        hold on
        size(amps_lrn)
        plot(freqs,amps_lrn,'-k')
        plot(freqs,threshold(:,i),'-r')
        xlim([-25,25])
        ylim([0 0.2])
        box on
        xlabel('Frequency [Hz]')
        ylabel('Amplitude [g]')
        string = sprintf('Rotor Speed: %2.0f RPM',r_bins(i));
        text(-23,0.18,string)
        fill([freqs;25;-25],[threshold(:,i);max(threshold(:,i))+0.2;max(threshold(:,i))+0.2],'r','FaceAlpha','0.1','LineStyle','None')
        fileName = sprintf('GIF%d.png',i);
        saveas(gcf,fileName)
        pause
    end
end
        
        
    
    




