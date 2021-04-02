%/========================================================================\
%|  PURPOSE: Learn the complex vectors of acceleration data in the        |
%|           frequency domain. The end result is an complex vector        |
%|           representing the average complex vector, and a circle        |
%|           surrounding this vector.                                     |
%|                                                                        |
%|           It is expected that the FFT of acceleration data has         |
%|           already been taken constant angle steps.                     |
%|------------------------------------------------------------------------|
%|  INPUTS:   accel_fft - FFT of acceleration data                        |
%|------------------------------------------------------------------------|
%|  OUTPUTS:     center - Complex datapoint representing avg value of     |
%|                        vectors                                         |
%|               radius - Radius of alarm circle; new vectors outside     |
%|                        this circle will raise an alarm.                |
%|------------------------------------------------------------------------|
%|  Code by Luke Costello, 8/28/2020                                      |
%\========================================================================/

function [center, radius] = Learn_Components(accel_fft,K)

d = ReVIm_prop(K);
K = d(6);

Re = real(accel_fft);
Im = imag(accel_fft);

Re_X0 = mean(Re);
Im_X0 = mean(Im);

Re_std = std(Re);
Im_std = std(Im);
max_std = max([Re_std,Im_std]);

center = Re_X0 + Im_X0*1i;
radius = K*max_std;