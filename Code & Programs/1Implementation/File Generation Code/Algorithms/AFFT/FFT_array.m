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

for i = 1:num_fft
    data_i = data(i*N-(N-1):i*N);
    
    ffts(:,i) = fft(data_i,N);
    
    ind = floor(N/2);
    
    
    amps_big = abs(ffts/N);
    amp_zero = abs(ffts(1,i)/N);
    amp_pos = abs(ffts(2:ind,i)/N);
    amp_neg = abs(ffts(ind+1:end,i)/N);

    amps(:,i) = [amp_zero;amp_pos;amp_neg];

end

if rem(N,2) == 0
    freqs_re = [1:1:N/2-1].*(Fs/N);
    freqs_im = [-N/2:1:-1].*(Fs/N);
else
    freqs_re = [1:1:(N-1)/2].*(Fs/N);
    freqs_im = [-(N-1)/2:1:-1].*(Fs/N);
end

freqs = [0,freqs_re,freqs_im]';


%freqs_re = Fs/N*linspace(0,N/2,N/2+1);
%freqs_ng = Fs/N*linspace(-N/2,0,N/2+1);
%freqs = [freqs_ng(1:end-1) freqs_re(1:end-1)]';
%freqs = Fs/N*linspace(-N/2,N/2,N)';
