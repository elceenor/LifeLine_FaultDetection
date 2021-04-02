function [avg] = average_data(data,seconds)

time_col = 1;

SR = 1/(data(2,time_col)-data(1,time_col));

num_avg = seconds*SR;

num_points = size(data,1)/num_avg;

avg = zeros(floor(num_points),size(data,2));

for i = 1:floor(num_points)
    st = i*num_avg-(num_avg-1);
    nd = i*num_avg;
    
    if st>size(data,1)
        st = size(data,1);
    end
    if nd>size(data,1)
        nd = size(data,1);
    end
    
    list = data(st:nd,:);
    for j = 1:size(list,2)
        avg(i,j) = mean(list(:,j));
    end
end
