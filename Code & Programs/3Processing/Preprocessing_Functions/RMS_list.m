%Computes the RMS value of a signal 
% Sig: Signal to be processed
% N  : Number of datapoints to be sampled

function [out] = RMS_list(sig,N,warn)

len = floor(length(sig)/N);
out = zeros(len,1);

if ~exist('warn','var')
    warn = false;
end

if warn
    if len ~= length(sig)/N
        disp('WARNING: Not all datapoints considered. (Length of signal)/(N points per sample) is not an integer.')
    end
end
    
    
for i = 1:len
    list = sig(1+(i-1)*N:i*N);

    SqrSum = 0;

    for j = 1:length(list)
        SqrSum = SqrSum + (list(j))^2;
    end

    out(i) = sqrt(SqrSum/N);
end