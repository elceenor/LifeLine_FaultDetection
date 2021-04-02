%/========================================================================\
%|   PURPOSE: Interpolates accceleration data from constant time-step     |
%|            format to a constant angle-step format                      |
%|------------------------------------------------------------------------|
%|   INPUTS:          life - Acceleration data from the LifeLine          |
%|                    data - Data output from the squirrel DAQ            |
%|------------------------------------------------------------------------|
%|   OUTPUTS:            t - Vector of times interpolated to              |
%|            accel_interp - Interpolated acceleration                    |
%|              rot_interp - Interpolated rotor speed                     |
%|------------------------------------------------------------------------|
%|   Luke Costello, 9/12/20                                               |
%\========================================================================/
function [t,accel_interp,rot_interp] = Interp_Angle_2(life,data)

%Load Properties
d = ReVIm_prop();
        k = d(2);
accel_col = d(3);
   t_incr = d(5);


accel = life(:,accel_col);

[data_exp,~] = expandData(data,life);
rot_exp = data_exp(:,3);

if length(accel) > length(rot_exp)
    diff = length(accel) - length(rot_exp);
    extras = rot_exp(end-diff+1 : end);
    rot_exp = [rot_exp;extras];
    
    accel = accel(1:length(rot_exp));
elseif length(rot_exp) > length(accel)
    rot_exp = rot_exp(1:length(accel));
end

%Create list of time vectors to interpolate to
t = [data(1,1)];
i = 1;

while t(end)<life(end,1)
    if i > length(data)
        break
    end
    
    data_vec = data(i,:);
    time = data_vec(1);
    RPM = data_vec(3);
    
    omeg = RPM*2*pi/60;
    if omeg < 0
        omeg = -omeg;
    end
    
    tht_diff = 2*pi/k;
    t_diff = tht_diff/omeg;
    
    while t(end) < time + t_incr
        t = [t;t(end) + t_diff];
    end
    i=i+1;
end

%Preallocate Memory
accel_interp = zeros(1,length(t));
rot_interp = zeros(1,length(t));
time_uninterp = life(:,1);

%Loop over times to interpolate to
for i = 1:length(t)-1
    time_interp = t(i);
    %Find the index such that t(index) < t(ik) < t(index+1)
    [~,ind] = min(abs(time_uninterp - time_interp));
    if ind == length(time_uninterp)
        ind = ind-1;
    elseif time_interp < time_uninterp(ind)
        ind = ind-1;
    end

    %Interpolate Accels
    accel_interp(i) = accel(ind) + (t(i) - life(ind,1))/(life(ind+1,1) - life(ind))*(accel(ind+1) - accel(ind));
    rot_interp(i) = rot_exp(ind) + (t(i) - life(ind,1))/(life(ind+1,1) - life(ind))*(rot_exp(ind+1) - rot_exp(ind));
    
    
    %Panic?
    panic_plot = false;
    if panic_plot
        accel_plt = [accel(ind) accel(ind+1)];
        time_plt = [life(ind,1) life(ind+1,1)];
        figure(10)
        clf
        hold on
        plot(time_plt,accel_plt,'k')
        plot(t(i),accel_interp(i),'ro')
        legend('Uninterpolated data','Interpolated Datapoint')
        pause
    end
end