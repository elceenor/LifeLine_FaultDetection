function [out] = cond_e(mem)

m = size(mem,2);
Dt_D = zeros(m);

for i = 1:m
    for j = 1:m
        Dt_D(i,j) = euclid(mem(:,i),mem(:,j));
    end
end

out = cond(Dt_D'*Dt_D);