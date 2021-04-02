function [out] = LineLength(sig,N,warn)
%Computes the line length of a set of data. Interval is able to be
%specified, which increased the length of each line segment.

t = 0.02;

len = floor(length(sig)/N);

if ~exist('warn','var')
    warn = false;
end

if warn
    if len ~= length(sig)/N
        disp('Warning! Not all datapoints considered. (Length of signal)/(N points per sample) is not an integer.')
    end
end
    
out = zeros(len,1);

for i = 1:len
    list = sig(1+(i-1)*N:i*N);
    
    for j = 2:length(list)
        out(i) = out(i) + sqrt((list(j) - list(j-1))^2 + t^2);
    end
end
    
    
    
    
% %Computes line length
%  for i = 1:length(data)-1   
%      dist = (data(i) - data(i+1))^2;
%      currLen = sqrt(interval^2 + dist^2);
%      len = currLen + len;
%  end