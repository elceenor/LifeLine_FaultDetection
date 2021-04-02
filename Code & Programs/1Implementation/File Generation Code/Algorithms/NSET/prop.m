%Defines properties of the memory/measurement vectors to be memorized.
%s: List of columns to save
%n: Quantities to normalize each column
%d: Other data, including searching bins and thresholds
function [s,n,d] = prop()
    
    %Define array of column # to save
    % 1 = Time Column [s]
    % 2 = Wind Speed [MPH]
    % 3 = Rotor Speed [RPM]
    % 4 = Gen Voltage [VDC]
    % 5 = Gen Current [ADC]
    % 6 = Battery Voltage [VDC]
    % 7 = Nacelle angle [°]
    % 8 = Wind angle [°]
    % 9 = RMS Accel in rotor direction
    % 10= RMS Accel in transverse horz direction
    % 11= RMS Accel in transverse vert direction
    % 12= Line Length in rotor direction
    % 13= Line Length in transverse horz direction
    % 14= Line Length in transverse vert direction
    s = [2,3,4,5,9,10,11,12,13,14];
    
    pow = [4 5];
    
    %Define quantity to normalize each column # by
    n = [30,300,300,5,4*1024,4*1024,18*1024,5E5,5E5,5E5];
    
    %Define other properties for searching
    %findRPM  = divisions for RPM
    %deltR    = 0.5*distance between divisons for RPM
    %findWind = divisions for windspeed
    %deltW    = 0.5*distance between divisons for windspeed
    findRPM  = (30:10:180)/n(3);
    deltR = 0.5*(findRPM(2)-findRPM(1));
    findWind = (8:23)/n(2);
    deltW = 0.5*(findWind(2)-findWind(1));
    rcondThresh = 10E-9;

    
    d = {findRPM,deltR,findWind,deltW,rcondThresh,pow};
    
end
    
    