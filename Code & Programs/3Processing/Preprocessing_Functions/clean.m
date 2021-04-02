function [life,data] = clean(life,data)
tic
%Define time column for life and data
%        Life  Data
t_col = [ 1     1 ];



life_nums = [];
data_nums = data(:,t_col(2));

for i = 1:length(life)
    if round(life(i,t_col(1)),2) == round(life(i,t_col(1)),0)
        if (size(life,1)-i)>=50
            life_nums = [life_nums;round(life(i,t_col(1)))];
        end
    end
end


eof = false;
i=1;
sv_life = [];
for i = 1:size(life,1)
    if any(life(i,1) == life_nums) && any(life(i,1) == data_nums)
        sv_life = [sv_life;(i:i+49)'];
    end
end

sv_data = [];
for i = 1:size(data,1)
    if any(data(i,1) == life_nums)
        sv_data = [sv_data;i];
    end
end

life = life(sv_life,:);
data = data(sv_data,:);


%{
while ~eof
    if i>size(life,1)
        eof = true;
        continue
    end
    
    if ~ismember(round(life(i,t_col(1)),2),life_nums) && ~ismember(round(life(i,t_col(1)),2),data_nums)
        life(i,:) = [];
    else
        i=i+1;
    end
    
    if rem(i,2) == 0
        disp(i)
    end
end
i
eof = false;
i=1;
while ~eof
    if i>size(data,1)
        eof = true;
        continue
    end
    
    if ~ismember(round(data(i,t_col(2)),2),life_nums) && ~ismember(round(data(i,t_col(2)),2),data_nums)
        data(i,:) = [];
    end
    
    i=i+1;
end

%}
%{
eof = false;
i=1;
while ~eof
    if ~(any( round(data(i,t_col(2))) == round(life(:,t_col(1)),2)))
        data(i,:) = [];
    else
        i=i+1;
    end
    
    if i>size(data,1)
        eof=true;
    end
end
toc
%}