%/========================================================================\
%|  PURPOSE: Return an estimated control state for the Cal Poly Wind      |
%|           Turbine based on the input rotor speed.                      |
%|                                                                        |
%|           Operating States:                                            |
%|            0:  Braked                                                  |
%|            1:  Speeding up                                             |
%|            2:  Operating at control speed                              |
%|            3:  Braked from operating speed                             |
%|------------------------------------------------------------------------|
%|  INPUTS:  rpm   - The operating rotor speed, collected as 1Hz          |
%|                   timeseries data.                                     |
%|------------------------------------------------------------------------|
%|  OUTPUTS: state - Estimated wind turbine state vector, returned as 1Hz |
%|------------------------------------------------------------------------|
%|  Code by Luke Costello, 7/18/2020                                      |
%\========================================================================/

function [state] = state_est(rpm)

len = length(rpm);

state(1:len,1) = NaN;

for i = 3:len-2
   curr = rpm(i-2:i+2);
   %State 3           
   if (curr(5) < 10) && (curr(1) > 30)
       for j = 1:5
           if isnan(state(i+j-3))
               state(i+j-3) = 3;
           end
       end
   end
   %State 0
   if curr < 10
       state(i-2:i+2) = 0;
   end
   %State 1
   if (curr(5) - curr(1)) > 20
       for j = 1:5
           if isnan(state(i+j-3))
               state(i+j-3) = 1;
           end
       end
   end
   %State 2
   if (curr(5) - curr(1)) < 20 && curr(5) > 5
       for j = 1:5
           if isnan(state(i+j-3))
               state(i+j-3) = 2;
           end
       end
   end         

end

for i = 1:len
    if isnan(state(i))
        state(i) = 4;
    end
end

err = sum(state==4);
if err ~= 0
    fprintf('Warning! State of %1d datapoints unable to be determined\n',err)
end
