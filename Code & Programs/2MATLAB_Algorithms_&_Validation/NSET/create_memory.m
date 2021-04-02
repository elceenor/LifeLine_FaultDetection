[list] = find_files();

num = length(list);

data = [];

%Load files and combine into one array
for i = 1:num
    [out] = load_file(list(i));
    data = [data out];
end

mem = memorize(data);