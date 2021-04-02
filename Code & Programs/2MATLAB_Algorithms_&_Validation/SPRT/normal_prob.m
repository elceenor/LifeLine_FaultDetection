%=========================================================================%
%   PURPOSE: Checks the probability that a datapoint is from a normal     %
%            distribution.                                                %
%-------------------------------------------------------------------------%
%   INPUTS:  x    - datapoint to be checked                               %
%            mu   - mean value of distribution                            %
%            sig  - standard devation of distribution                     %
%-------------------------------------------------------------------------%
%   OUTPUTS: prob - probability of x residing in distribution             %
%-------------------------------------------------------------------------%
%   Luke Costello, 10/6/2020                                              %
%=========================================================================%


function [prob] = normal_prob(x,mu,sig)
    prob = (sig*sqrt(2*pi))^-1 * exp(-0.5 * ((x-mu)/sig)^2);
    
end