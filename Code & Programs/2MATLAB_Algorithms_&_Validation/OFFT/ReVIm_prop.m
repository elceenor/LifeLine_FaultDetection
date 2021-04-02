function [d,rng] = ReVIm_prop(K_tune)

%   t_L: Sample rate of acceleration
%     k: Number of steps per revolution
% l_col: Column # of lifeline variable to monitor
% r_col: Column # of rotorspeed variable to monitor
%   t_r: Sample rate of rotor speed
%K_tune: Algorithm tuning parameter

d=[];

t_L   = 1/50;
k     = 16;
l_col = 4;
r_col = 3;
t_r     = 1;

if ~exist('K_tune','var')
    K_tune = 4.5;
end


    % 1    2   3      4      5    6
d = [t_L, k, l_col, r_col, t_r, K_tune];

rng = [0.9 1.1];