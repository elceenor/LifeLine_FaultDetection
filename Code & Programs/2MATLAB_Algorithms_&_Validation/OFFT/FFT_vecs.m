%/========================================================================\
%|   PURPOSE: Calculates the complex vector outputs of an FFT             |
%|------------------------------------------------------------------------|
%|   INPUTS:    accel - Acceleration vector                               |
%|                  n - Size of FFT to take                               |
%|                rot - Rotor speed vector                                |
%|------------------------------------------------------------------------|
%|   OUTPUTS:   freqs - Frequencies of vectors                            |
%|            vectors - Complex FFT vectors                               |
%|               rots - Average rotor speed of each FFT                   |
%|------------------------------------------------------------------------|
%|   Luke Costello, 9/12/20                                               |
%\========================================================================/
function [freqs,vectors,rots] = FFT_vecs(accel,n,rot)

n = 2^nextpow2(n);
%Find the number of FFTs to take
num_vec = ceil(length(accel)/n);
vectors = zeros(n,num_vec);
rots = zeros(1,num_vec);

%Loop over number of FFTs to take
for i = 1:num_vec
    %Extract n datapoints, or however many are left
    if i*n > length(accel)
        accel_i = accel(i*n-(n-1):end);
        rot_i = rot(i*n-(n-1):end);
    else
        accel_i = accel(i*n-(n-1):i*n);
        rot_i = rot(i*n-(n-1):i*n);
    end
    vecs     = fft(accel_i,n)';
    vecs_0   = vecs(1);
    vecs_pos = vecs(2:(n/2+1));
    vecs_neg = vecs((n/2+2):end);
    
    vector_combine = [vecs_neg;vecs_0;vecs_pos];
    
    vectors(:,i) = [vecs_neg;vecs_0;vecs_pos];
    rots(i) = mean(rot_i);
end

d = ReVIm_prop();
Fs = d(2);
freqs = Fs/n*linspace(-n/2,n/2,n)';