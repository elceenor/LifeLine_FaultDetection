%|========================================================================|
%|   PURPOSE: Calculates the new likelihood ratio of a sequence for a new |
%|            datapoint added to the sequence.                            |
%|------------------------------------------------------------------------|
%|   INPUTS:  x    - New datapoint to test                                |
%|            lk_0 - Likelihood ratio, without taking new datapoint into  |
%|                   account.                                             |
%|            j    - Hypothesis to test.                                  |
%|                     1 == mu  = +M  sig = sig(trained_data)             |
%|                     2 == mu  = -M, sig = sig(trained_data)             |
%|                     3 == mu  =  0, sig = V*sig(trained_data)           |
%|                     4 == mu  =  0, sig = (1/V)*sig(trained_data)       |
%|            S    - Vector containing SPRT parameters                    |
%|                     S[1] = sig(trained_data) || S[2] = M  ||  S[3] == V|
%|------------------------------------------------------------------------|
%|   OUTPUTS: lk_1 - Likelihood ratio after taking new datapoint into     |
%|                   account.                                             |
%|------------------------------------------------------------------------|
%|   Luke Costello, 10/6/2020                                             |
%|========================================================================|


function [lk_1] = LR(x,lk_0,j,S)

%Extract SPRT parameters
sig_tr = S(1);
M      = S(2);
V      = S(3);

%Determine hypothesis to test
[mu_test, sig_test] = hypothesis(j,S);


H_0 = normal_prob(x,0,sig_tr);
H_j = normal_prob(x,mu_test,sig_test);

if 1 == 2
    fprintf('Datapoint: %2.2f || Mu_test: %2.2e || Sig_test: %2.2e\n',x,mu_test,sig_test)
    fprintf('Null hypothesis probability: %2.4e || Alternative hypothesis probability: %2.4e\n',H_0,H_j)
end
    
lk_i = H_j/H_0;

lk_1 = lk_0 * lk_i;