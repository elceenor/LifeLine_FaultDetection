%Given two sets of data sampled at different rates, expands the dataset
%sampled slower to the dataset sampled faster
function [set1,set2] = expand(set1,set2,time_col)

if ~exist('time_col','var')
    time_col = [1 1];
end


set1_SR = round( 1/(set1(2,time_col(1))-set1(1,time_col(1))) );
set2_SR =        1/(set2(2,time_col(2))-set2(1,time_col(2)))  ;

if set1_SR > set2_SR
    bg = set1;
    bg_SR = set1_SR;
    sm = set2;
    sm_SR = set2_SR;
    truth = 1;
else
    bg = set2;
    bg_SR = set2_SR;
    sm = set1;
    sm_SR = set1_SR;
    truth = 0;
end

expand_num = round(bg_SR/sm_SR);
if expand_num<1
    error('Something went wrong when calculating expansion size.')
end



[n,m] = size(sm);
sm_expand = zeros(n*expand_num,m);
temp_expand = zeros(expand_num,m);
for i = 1:n
    line = sm(i,:);
    
    for j = 1:expand_num
        temp_expand(j,:) = line;
    end
    
    sm_expand(i*expand_num-(expand_num-1):i*expand_num,:) = temp_expand;
end 

if truth
    set1 = bg;
    set2 = sm_expand;
else
    set1 = sm_expand;
    set2 = bg;
end
