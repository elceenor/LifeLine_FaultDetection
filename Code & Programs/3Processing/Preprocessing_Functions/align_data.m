function [t_shift] = align_data(life_RMS,data)

data_col = [3];

life_RMS(:,2:4) = life_RMS(:,2:4)/16384;

%for i = data_col(1):data_col(end)
%    data(:,i) = data(:,i)./max(data(:,i));
%end

t_shift = 0;

i = 1;
run = true;

size(life_RMS)
while run
    
    figure(i)
    clf
    subplot(3,1,1)
    hold on
    yyaxis left
    plot(life_RMS(:,1)+t_shift,life_RMS(:,2))
    yyaxis right
    plot(data(:,1),data(:,data_col))
    plot(life_RMS(:,1)+t_shift,life_RMS(:,5));

    subplot(3,1,2)
    hold on
    yyaxis left
    plot(life_RMS(:,1)+t_shift,life_RMS(:,3))
    ylabel('Acceleration [g]')
    yyaxis right
    plot(data(:,1),data(:,data_col))
    ylabel('Rotor Speed [RPM]')
    xlabel('Time [s]')
    
    legend('RMS data','Rotor Speed','Location','NorthEast')


    subplot(3,1,3)
    hold on
    yyaxis left
    plot(life_RMS(:,1)+t_shift,life_RMS(:,4))
    yyaxis right
    plot(data(:,1),data(:,data_col))
    
    legend('RMS data','Rotor Speed','Location','NorthEast')
    
    i=2;
    reply = input('Do you want to offset the data? Y/N\n','s');
    if isempty(reply)
        reply = 'Y';
    end
    if reply ~= 'Y'
        run = false;
        continue
    end
    
    while true
        reply = input('Enter time to offset data. Positive values offset acceleration to right.\n');
        try
            t_shift = t_shift + floor(reply);
            break
        catch
            fprintf('Reply unable to be interpreted by MATLAB. Make sure you entered a number.\n')
        end
    end
    
end

