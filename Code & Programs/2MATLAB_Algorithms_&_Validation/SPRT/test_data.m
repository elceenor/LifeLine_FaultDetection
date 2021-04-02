%|========================================================================|
%|   PURPOSE: Computes a SPRT for new data, using learned memory matrix   |
%|            and new data.                                               |
%|------------------------------------------------------------------------|
%|   INPUTS:  H_j     - Hypothesis to test.                               |
%|                     1 == mu  = +M  sig = sig(trained_data)             |
%|                     2 == mu  = -M, sig = sig(trained_data)             |
%|                     3 == mu  =  0, sig = V*sig(trained_data)           |
%|                     4 == mu  =  0, sig = (1/V)*sig(trained_data)       |
%|------------------------------------------------------------------------|
%|   OUTPUTS: mu_test  - The mean value of the alternative hypothesis     |
%|            sig_test - The standard deviation of the alternative        |
%|                       hypothesis                                       |
%|------------------------------------------------------------------------|
%|   Luke Costello, 10/6/2020                                             |
%|========================================================================|


function [alarms,SPRT_sv,range] = test_data(X_n,S,rots)
    global loud
    
    %Extract SPRT data
    sig = S(1);
    M = S(2);
    V = S(3);
    alph   = S(4);
    beta   = S(5);
    
    num_hyp  = 4; %Number of hypotheses to test
    
    %Define testing parameters
    A = log(beta/(1-alph));
    B = log((1-beta)/alph);
    range = [A B];
    
    decision = zeros(num_hyp,1);
    lk_0 = ones(num_hyp,1);
    lk_i = ones(num_hyp,1);
    alarms = zeros(num_hyp,2);

    %Test new data against training data
    %Loop over each datapoint
    for i = 1:size(X_n,2)
        
        %Extract datapoint to test
        %X_i = X_n(test_row,i);
        X_i = X_n(i);
        
        
        %if rem(i,50) == 0
        %    fprintf('On datapoint %d\n',i)
        %end
        
        %Loop over each hypothesis to test
        
        for j = 1:num_hyp
            
            %Compute likelihood ratio for new datapoint
            lk_i(j) = LR(X_i,lk_0(j),j,S);
            if isnan(lk_i(j))
                lk_i(j) = lk_0(j);
            end
            lk_0(j) = lk_i(j);
            %Compute SPRT index
            SPRT_i = log(lk_i(j));

            %Compare SPRT index to boundaries
            if SPRT_i >= A && SPRT_i <= B
                decision(j) = 1;
            elseif SPRT_i < A
                decision(j) = 2;
                SPRT_i = A;
            elseif SPRT_i > B
                decision(j) = 3;
                SPRT_i = B;
            end
            
            SPRT_sv(j,i) = SPRT_i;
            
            if rots(i) > 120
                if decision(j) ~= 1

                    if decision(j) == 2
                        alarms(j,1) = alarms(j,1) + 1;
                    elseif decision(j) == 3
                        alarms(j,2) = alarms(j,2) + 1;
                    end
                    decision(j) = 1;
                    lk_0(j) = 1;
                end
            end
            
            if 1 == 2
                figure(3);
                hold on
                subplot(1,num_hyp,j)
                xlim([A,B])
                ylim([0,size(X_n,2)])
                plot(SPRT_i,i,'k.')
                pause
            end
            
        end
        

    end
    
    if 1 == 2
        ind = 1:size(SPRT_sv,2);
        figure(3);
        ylabel('Number Datapoints [N]')
        xlabel('Detection Range [A,B]')
        subplot(1,4,1)
        hold on
        plot(SPRT_sv(1,:),ind,'k.')
        plot([A A],[0 ind(end)],'-r')
        plot([B B],[0 ind(end)],'-r')
        xlim([A-0.5,B+0.5])
        ylim([0,size(X_n,2)])

        subplot(1,4,2)
        hold on
        plot(SPRT_sv(2,:),ind,'k.')
        plot([A A],[0 ind(end)],'-r')
        plot([B B],[0 ind(end)],'-r')
        xlim([A-0.5,B+0.5])
        ylim([0,size(X_n,2)])

        subplot(1,4,3)
        hold on
        plot(SPRT_sv(3,:),ind,'k.')
        plot([A A],[0 ind(end)],'-r')
        plot([B B],[0 ind(end)],'-r')
        xlim([A-0.5,B+0.5])
        ylim([0,size(X_n,2)])

        subplot(1,4,4)
        hold on
        plot(SPRT_sv(4,:),ind,'k.')
        plot([A A],[0 ind(end)],'-r')
        plot([B B],[0 ind(end)],'-r')
        xlim([A-0.5,B+0.5])
        ylim([0,size(X_n,2)])
    end
    %{
    if loud
        fprintf('         # Alarms:\n')

        fprintf('H_0:      1     2      3     4\n      ')
        disp(alarms')
    end
    %}
    
end