%/========================================================================\
%|  PURPOSE: Determines the parameters of the hypothesis test             |
%|------------------------------------------------------------------------|
%|  INPUTS:  H_j     - Hypothesis to test.                                |
%|                    1 == mu  = +M  sig = sig(trained_data)              |
%|                    2 == mu  = -M, sig = sig(trained_data)              |
%|                    3 == mu  =  0, sig = V*sig(trained_data)            |
%|                    4 == mu  =  0, sig = (1/V)*sig(trained_data)        |
%|           S       - SPRT Parameters                                    |
%|------------------------------------------------------------------------|
%|  OUTPUTS: mu_test  - The mean value of the alternative hypothesis      |
%|           sig_test - The standard deviation of the alternative         |
%|                      hypothesis                                        |
%|------------------------------------------------------------------------|
%|  Luke Costello, 10/6/2020                                              |
%\========================================================================/


function [mu_test, sig_test] = hypothesis(H_j,S)

    %Extract SPRT parameters
    sig_tr = S(1);
    M      = S(2);
    V      = S(3);
    
    %Determine hypothesis to test
    if H_j == 1
        mu_test = M;
        sig_test = sig_tr;
    elseif H_j == 2
        mu_test = -M;
        sig_test = sig_tr;
    elseif H_j == 3
        mu_test = 0;
        sig_test = V*sig_tr;
    elseif H_j == 4
        mu_test = 0;
        sig_test = (1/V)*sig_tr;
    end

end