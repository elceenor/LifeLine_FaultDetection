%For a N-by-M-by-P matrix, average the P dimension into a N-by-M-by-1
%matrix.
function [out] = avg_signal(sig)

N = size(sig,1);
M = size(sig,2);
P = size(sig,3);

out = zeros(N,M);

for i = 1:N
    out(i,1) = mean(sig(i,1,:));
    out(i,2) = mean(sig(i,2,:));
    out(i,3) = mean(sig(i,3,:));
end


    
