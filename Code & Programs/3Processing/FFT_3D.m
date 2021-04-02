%/========================================================================\
%|  PURPOSE: Calculate a 3-dimensional FFT for a signal. Formatted for    |
%|           a sensor with 3 outputs, represented by additional columns   |
%|           in the matrix. Signal is expected to be an N-by-M-by-P       |
%|           matrix, with the P dimension as additional FFT's, the M      |
%|           dimension as additional outputs, and the N dimension as      |
%|           consecutive datapoints.                                      |
%|------------------------------------------------------------------------|
%|  SYNTAX:  [frq,amp] = FFT_3D(sig)                                      |
%|------------------------------------------------------------------------|
%|  INPUTS:  sig - N-by-M-by-P signal                                     |                                    
%|------------------------------------------------------------------------|
%|  OUTPUTS: frq - Frequency output vector from FFT                       |
%|           amp - Amplitude output vector from FFT                       |
%|------------------------------------------------------------------------|
%|  Code by Luke Costello, 7/28/2020                                      |
%\========================================================================/
function [frq,amp] = FFT_3D(sig)
close all

%Center data
sig_center = sig - mean(sig);
sig = sig_center;

%Calculate size of signal
N = size(sig,1);
M = size(sig,2);
P = size(sig,3);

%Calculate FFT
for i = 1:P
    [frq,amp(:,1,i)] = FFT_amp(sig(:,1,i),50);
    [~,amp(:,2,i)] = FFT_amp(sig(:,2,i),50);
    [~,amp(:,3,i)] = FFT_amp(sig(:,3,i),50);
end

