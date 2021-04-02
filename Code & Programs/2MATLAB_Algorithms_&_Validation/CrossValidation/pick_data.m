%/========================================================================\
%|   PURPOSE: Picks data from a list based on the input parameter i, which|
%|            can be a vector.                                            |
%|------------------------------------------------------------------------|
%|   INPUTS:  list - Input Sensor Data                                    |
%|             i   - Position in list to save from                        |
%|------------------------------------------------------------------------|
%|   OUTPUTS: data_mem  - Data saved to memory matrix                     |
%|            data_test - Data saved to SPRT test                         |
%|------------------------------------------------------------------------|
%|   Luke Costello, 10/12/20                                              |
%\========================================================================/
function [data_mem,data_test,data_fault] = pick_data(list,i,fault)
    global loud
    
    nums = 1:length(list);
    %Load training data
    if loud
        fprintf('Training Data:\n')
    end
    data_mem = [];
    for j = 1:length(i)
        fprintf('%d ',i(j))
        data_mem = [data_mem load_file(list(i(j)))];
    end
    fprintf('\n\n')
    %Remove training data from list
    num_sv = nums;
    num_sv(i) = [];
    data_test = [];
    

    %Load testing data
    if loud
        fprintf('Testing Data:\n')
    end
    
    for j = 1:length(num_sv)
        fprintf('%d',num_sv(j))
        data_test_j = load_file(list(num_sv(j)));
        data_test = [data_test data_test_j];
    end
    fprintf('\n\n')
    
    %Load faulty data
    if loud
        fprintf('Faulty Data:\n')
    end
    data_fault = [];
    for k = 1:length(fault)
        data_fault_k = load_file(fault(k));
        data_fault = [data_fault data_fault_k];
    end
    
end
