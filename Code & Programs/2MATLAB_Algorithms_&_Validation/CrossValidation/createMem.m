


function [] = createMem()

path(path,'C:\Users\lukec\OneDrive\Documents\2School\MastersThesis\Code\MATLAB\Modeling\Crossvalidation_Study\Datasets\Healthy')
path(path,'C:\Users\lukec\OneDrive\Documents\2School\MastersThesis\Code\MATLAB\Modeling\Crossvalidation_Study\Datasets\Faulty')
path(path,'C:\Users\lukec\OneDrive\Documents\2School\MastersThesis\Code\MATLAB\Modeling\NSET')

[list] = find_files('C:\Users\lukec\OneDrive\Documents\2School\MastersThesis\Code\MATLAB\Modeling\Crossvalidation_Study\Datasets\Healthy');
[fault] = find_files('C:\Users\lukec\OneDrive\Documents\2School\MastersThesis\Code\MATLAB\Modeling\Crossvalidation_Study\Datasets\Faulty');

[data_mem,data_test,data_fault] = pick_data(list,[1:10],fault);

data_mem([2 3],:) = [];

mem = memorize(data_mem);

X_obs = ones(size(data_mem,1),1);

[~,inverse] = weight(mem,X_obs);


writematrix(mem,'memory.txt')
writematrix(inverse,'inverse.txt')