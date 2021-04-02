%Creates an FFT of the given data every N datapoints
%Fs = Sample frequency
%Data = Input data vector
%N    = Number Datapoints per FFT
function [freqs,amps] = FFT_array(data,Fs,N)

if ~any(size(data)==1)
    error('ERROR: Input data must be a 1-by-N or N-by-1 vector')
end

data = data - mean(data);

num_fft = floor(length(data)/N);

a = 2;
b = 1;

for i = 1:num_fft
    data_i = data(i*N-(N-1):i*N);
    
    ffts(:,i) = fft(data_i,N);
    amp_zero = abs((ffts(1,i)).^b/N);
    amp_pos = a.*abs((ffts(2:N/2,i)).^b/N);
    amp_neg = a.*abs((ffts(N/2+1:end,i)).^b/N);

    amps(:,i) = [amp_neg;amp_zero;amp_pos];

end

freqs_re = Fs/N*linspace(0,N/2,N/2+1);
freqs_ng = Fs/N*linspace(-N/2,0,N/2+1);
freqs = [freqs_ng(1:end-1) freqs_re(1:end-1)]';
%freqs = Fs/N*linspace(-N/2,N/2,N)';
