%Code to try and replicate some of the weirdo frequency plots
clear all
close all



omeg = 114;

order = omeg/60;

t_sample = 0.01;

t = 0:0.0001:50;

t_resample = 0:t_sample:50;


mults = [50,75];

%Loop over every multiple of rotor frequency


for i = mults
    vib = sin(i*2*pi.*t);
    
    vib_resample = [];
    num = 0;
    %resample data
    for j = t_resample
        ind = find(abs(t-j)<0.00001);
        num=num+1;
        vib_resample = [vib_resample vib(ind)];
    end
    
    %{
    figure(1);
    hold on
    plot(t,vib)
    plot(t_resample,vib_resample)
    xlim([0 0.5])
    %}
    [freq,amp] = FFT_array(vib_resample,1/t_sample,1024);
    
    plot(freq,mean(amp,2));
    xlim([0 10])
    string = sprintf('Multiple of rotor speed:%d',i);
    title(string)
    
    
    
    
    pause(0.05)
end
    



