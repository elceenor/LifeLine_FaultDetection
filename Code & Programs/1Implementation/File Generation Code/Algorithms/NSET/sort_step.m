%/========================================================================\
%|   PURPOSE: Sorts sensor vectors into a memory matrix. This is done by  |
%|            determining the range of operating data for each sensor and |
%|            and dividing into 1/k steps. The vector with sensor         |
%|            measurement closest to each step is saved into the memory   |
%|            matrix. k is progressively increased (for each sensor)      |
%|            until a memory matrix is create where each vector is        |
%|            sufficiently unique that the Rcond # is greater than the    |
%|            threshold set by prop().                                    |
%|------------------------------------------------------------------------|
%|   INPUTS:  data - Input Sensor Data                                    |
%|------------------------------------------------------------------------|
%|   OUTPUTS: mem  - Formed memory matrix                                 |
%|------------------------------------------------------------------------|
%|   Luke Costello, 10/12/20                                              |
%\========================================================================/

function [mem] = sort_step(data,rcondThresh)

    n = size(data,1);
    min_max = zeros(n,2);
    
    k_n = 0.01*ones(n,1);
    
    %Find minimum and maximum values for each sensor
    for i = 1:n
        min_max(i,1) = min(data(i,:));
        min_max(i,2) = max(data(i,:));
    end
    
    %Calc difference between min & max values
    diff = min_max(:,2) - min_max(:,1);
    
    %Start sorting data
    done = false;
    while ~done
        num_steps = 1./k_n;
        
        test_mem = [];
        test_data = data;
        rcond_mat = zeros(n,1);
        restart = false;
        %Loop over each sensor
        for i = 1:n
            test_mem_i = [];
            %Calculate step size for sensor i
            step_val = (diff(i)/num_steps(i));
            %Loop over each step
            for j = 1:num_steps(i)
                %Calculate value to search for
                search_val = min_max(i,1) + j*step_val;
                %Search for value
                [~,ind] = min(abs(test_data(i,:) - search_val));
                
                %fprintf('Sensor: %d || Search value: %4.2f || Index chosen: %4.2f\n',i,search_val,ind)
                test_mem_i = [test_mem_i test_data(:,ind)];
                test_data(:,ind) = [];
                
                %pause
                
                if isempty(ind)
                    break
                end
            end
            
            if isempty(ind)
                k_n = k_n + 0.01;
                restart = true;
                break
            end
            
            rcond_mat(i) = rcond_e(test_mem_i);
            test_mem = [test_mem test_mem_i];
        end
        
        if restart
            continue
        end
        
        rcond_curr = rcond_e(test_mem);
        if rcond_curr > rcondThresh
            done = true;
        else
            [~,ind] = min(rcond_mat);
            k_n(ind) = k_n(ind) + 0.01;
            %fprintf('Rcond too small (%2.2s)! Increasing step size for sensor %d and continuing...\n',rcond_curr,ind)
        end
    end
    
    mem = test_mem;
end