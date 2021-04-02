%Calculates the standard deviation of sensor data over time.
%N is the number of datapoints to take the standard deviation of.

function [out] = stddev_list(sig,N)

len = floor(length(sig)/N);
out = zeros(len,1);

if len ~= length(sig)/N
    disp('WARNING: Not all datapoints considered. (Length of signal)/(N points per sample) is not an integer.')
end


for i = 1:len
    list = sig(1+(i-1)*N:i*N);

    SqrSum = 0;
    mu = mean(list(:,1));

    for j = 1:length(list)
        SqrSum = SqrSum + (list(j)-mu)^2;
    end

    out(i) = sqrt(SqrSum/(N-1));
end