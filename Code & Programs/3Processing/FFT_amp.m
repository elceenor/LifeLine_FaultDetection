%=========================================================================%
%   PURPOSE: Compute fast-fourier transform of data and transform it into %
%            a form than can be easily interpreted.                       %
%-------------------------------------------------------------------------%
%   INPUTS:  signal - N-by-1 array signal input to be transformed         %
%            rate   - The data sample rate in Hz                          %
%-------------------------------------------------------------------------%
%   OUTPUTS: frq    - N-by-1 array of the frequency of each amplitude     %
%                     in the amp array                                    %
%            amp    - N-by-1 array of the amplitude of each frequency     %
%-------------------------------------------------------------------------%
%   Luke Costello, 4/26/2020                                              %
%=========================================================================%

function [frq,amp] = FFT_amp(signal,rate)

n = length(signal);
ScanRate = rate;
z = fft(signal,n);
halfn = floor(n/2)+1;
deltaf = 1/(n/ScanRate);
frq = (0:(halfn-1))*deltaf;
amp(1)=abs(z(1))./(n);
amp(2:(halfn-1)) = abs(z(2:(halfn-1)))./(n/2);
amp(halfn) = abs(z(halfn))./(n);

