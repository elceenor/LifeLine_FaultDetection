%/========================================================================\
%|  PURPOSE: Extract the complex vectors of acceleration data             |
%|           within the range of frequencies specified by the range       |
%|           variable.                                                    |
%|------------------------------------------------------------------------|
%|  INPUTS:   accel_fft - FFT of acceleration data                        |
%|                range - 2-component vector specifying the range of      |
%|                        frequencies to collect corresponding complex    |
%|                        FFT vectors.                                    |
%|------------------------------------------------------------------------|
%|  OUTPUTS:    vectors - Complex vectors of FFT data                     |
%|                freqs - Vector of frequencies corresponding to data     |
%|                        in the vectors variable.                        |
%|------------------------------------------------------------------------|
%|  Code by Luke Costello, 8/28/2020                                      |
%\========================================================================/

function [vectors,freqs] = Extract_Components(accel_fft,range)

%Define parameters
d = ReVIm_prop();                         %Get data
Fs = d(2);                          %Get samplerate
L = length(accel_fft);              %Get length of dataset

f_step = Fs/L;                      %Steps in frequencies
f = Fs/2*linspace(-1,1,L);          %Calc all frequencies up to nyquist frequency
f_mod = f(length(f)/2:end);         %Modified frequency vector; only contains positive frequencies

index_1 = floor(range(1)/(f_step));
index_2 = ceil(range(2)/(f_step));

n = length(index_1:index_2);
vectors = zeros(n,1);
freqs = zeros(n,1);
n=1;
for i = index_1:index_2
    vectors(n) = accel_fft(i);
    freqs(n)   = f_mod(i);
    n = n+1;
end