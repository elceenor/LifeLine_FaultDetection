%Saves properties for the AFFT
function [K,R_SPD_bins,d] = AFFT_prop(K)

if ~exist('K','var')
    K = 1.5;
end
    
R_SPD_bins = [32.5:5:207.5];


%Sample frequency
Fs = 50;
%Number datapoints per FFT
N = 1024;
%Width of Frequency Bins
bin_width = 1;

d = [Fs,N,bin_width];