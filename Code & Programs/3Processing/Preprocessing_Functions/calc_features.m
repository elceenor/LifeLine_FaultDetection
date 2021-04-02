function [life_RMS,life_LL] = calc_features(life,n)

col = [3 4 5 6];
t_col = 1;
SR = 1/(life(2,t_col)-life(1,t_col));

num_rows = floor(size(life,1)/n);
num_cols = length(col);

time = zeros(num_rows,1);
life_RMS = zeros(num_rows,num_cols);
life_LL = life_RMS;

for i = 1:num_rows
    time(i) = mean(life(i*n-(n-1):i*n,t_col));
end

    
for i = 1:length(col)
    life_RMS(:,i) = RMS_list(life(:,col(i)),n);
end

for i = 1:length(col)
    life_LL(:,i) = LineLength(life(:,col(i)),n);
end

life_RMS = [time life_RMS];
life_LL  = [time life_LL ];

end