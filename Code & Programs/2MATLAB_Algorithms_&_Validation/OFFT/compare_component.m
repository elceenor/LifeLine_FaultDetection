%/========================================================================\
%|   PURPOSE: Compares the FFT vectors to the complex threshold           |
%|------------------------------------------------------------------------|
%|   INPUTS:  vectors - Vectors to compare to threshold                   |
%|             center - Center of complex threshold                       |
%|             radius - Radius of complex threshold                       |
%|             alarms - Number of alarms before test                      |
%|              tests - Number of tests before this test                  |
%|------------------------------------------------------------------------|
%|   OUTPUTS:  alarms - Number of alarms after this test                  |
%|              tests - Number of tests after this test                   |
%|------------------------------------------------------------------------|
%|   Luke Costello, 10/12/20                                              |
%\========================================================================/
function [alarms,tests] = compare_component(vectors,center,radius,alarms,tests)

center_re = real(center);
center_im = imag(center);


alarm = false;

%subsequent = 0;

for i = 1:(size(vectors,1)*size(vectors,2))
    vec_re = real(vectors(i));
    vec_im = imag(vectors(i));
    
    dist = sqrt((vec_re - center_re)^2 + (vec_im - center_im)^2);
    
    %alarm_now = false;
    if dist > radius
        %alarms = alarms + 1;
        alarm = true;
        %alarm_now = true;
    end
    %tests = tests+1;
%     
%     if alarm_now
%         subsequent = subsequent + 1;
%     else
%         subsequent = 0;
%     end
%     
%     if subsequent = 3
%         fprintf('MORE THAN 3 SUBSEQUENT ALARMS DETECTED! PANIC!\n')
%     end
    
    
end

if alarm
    alarms = alarms+1;
end

tests = tests + 1;
