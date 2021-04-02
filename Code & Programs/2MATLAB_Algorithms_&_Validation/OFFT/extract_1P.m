%Extracts the 1P component from accelerations
function [freqs,vectors] = extract_1P(freqs,vecs)

[~,rng] = ReVIm_prop();

%Find indices closest to range
[~,ind1] = min(abs(freqs - rng(1)));
[~,ind2] = min(abs(freqs - rng(2)));
%Extract components
freqs = freqs(ind1:ind2,1);
vectors  = vecs(ind1:ind2,1);