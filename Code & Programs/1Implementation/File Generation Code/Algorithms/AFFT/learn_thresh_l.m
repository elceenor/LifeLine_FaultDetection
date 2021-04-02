

function [threshold] = learn_thresh_l(amps,freqs,K_thr,rots_ar,threshold,r_bins,bin_width)
global debug

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
    
    length_amps_lrn = length(amps_lrn);
    for j = 1:length(amps_lrn)
        low = j-num_1side;
        high = j+num_1side;
        if low < 1
            low = 1;
        end
        if high > length(amps_lrn)
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
        %fill([freqs;25;-25],[threshold(:,i);max(threshold(:,i))+0.04;max(threshold(:,i))+0.04],'r','FaceAlpha','0.1','LineStyle','None')
        pause
    end
end
        
        
    
    




