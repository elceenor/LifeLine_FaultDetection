%% The central driver script used for executing the cross-validation study
%% of Luke Costello's M.S. thesis. 

clear all

%Prints additional debugging info if debug is set to true
global debug %Print extra info for debugging each loop
global loud  %Be loud!
global show_faults %Plot stuff if a fault occurs
debug = true;
loud = true;

path(path,'C:\Users\lukec\OneDrive\Documents\2School\MastersThesis\Code\MATLAB\Modeling\NSET')
path(path,'C:\Users\lukec\OneDrive\Documents\2School\MastersThesis\Code\MATLAB\Modeling\Crossvalidation_Study')
path(path,'C:\Users\lukec\OneDrive\Documents\2School\MastersThesis\Code\MATLAB\Modeling\SPRT')
path(path,'C:\Users\lukec\OneDrive\Documents\2School\MastersThesis\Code\MATLAB\Modeling\Crossvalidation_Study\Datasets\Healthy')
path(path,'C:\Users\lukec\OneDrive\Documents\2School\MastersThesis\Code\MATLAB\Modeling\Crossvalidation_Study\Datasets\Faulty')
path(path,'C:\Users\lukec\OneDrive\Documents\2School\MastersThesis\Code\MATLAB\Modeling\A_FFT')
path(path,'C:\Users\lukec\OneDrive\Documents\2School\MastersThesis\Code\MATLAB\Modeling\Re_Im_FFT')
path(path,'C:\Users\lukec\OneDrive\Documents\2School\MastersThesis\Code\MATLAB\Modeling\LSCh')
path(path,'C:\Users\lukec\OneDrive\Documents\2School\MastersThesis\Code\MATLAB\SignalProcessing\Preprocessing_Functions')


fprintf('<strong>GATHERING DATA</strong>\n')



[list] = find_files('C:\Users\lukec\OneDrive\Documents\2School\MastersThesis\Code\MATLAB\Modeling\Crossvalidation_Study\Datasets\Healthy');
[fault] = find_files('C:\Users\lukec\OneDrive\Documents\2School\MastersThesis\Code\MATLAB\Modeling\Crossvalidation_Study\Datasets\Faulty');

fault = fault(1);


%Overcomplicated code, creating a matrix of tests to run
num_memorize = 9;               %Number of datasets to save to memory
in = ones(1,length(list))*2;    
list_mem = fullfact(in)-1;      %List all possible binary numbers up to 2^(length(list))
list_mem_i = [];
%Remove any number where (Number of 1's =/= num_memorize)
for i = 1:length(list_mem)
    if sum(list_mem(i,:)) == num_memorize
        list_mem_i=[list_mem_i;list_mem(i,:)];
    end
end
list_mem = list_mem_i;



%Column of acceleration to test
accel_col = 8;

%List of tests to run
tests = [1];

%Loop over each test to run

OFFT_mat_out = cell(1,length(list));
AFFT_mat_out = cell(1,length(list));

NSET_SPRT_mat_out = cell(1,length(list));
for x = 1:length(list)
    close all
    %% Pick Data
    pick_list = find(list_mem(x,:));
    not_pick = find(~list_mem(x,:));
    
    [data_mem,data_test,data_fault] = pick_data(list,pick_list,fault);
    
    NSET_SPRT_mat = [];
    AFFT_mat = [];
    OFFT_mat = [];
    
    if any(tests==1)
        %% NSET + SPRT
        fprintf('\n<strong>BEGIN NSET+SPRT</strong>\n')
        fprintf('Memorizing data...\n')
        tic
        [mem] = memorize(data_mem);
        fprintf('Done memorizing. (%2.2f seconds elapsed)\n',toc)
        %Estimate the sensor values using MSET
        fprintf('\nEstimating data...\n')
        tic
        est_mem = estimate_sensors(data_mem,mem);
        est_test = estimate_sensors(data_test,mem);
        est_fault = estimate_sensors(data_fault,mem);
        
        %Calculate residuals
        resid_mem = est_mem(accel_col,:)-data_mem(accel_col,:);
        resid_test = est_test(accel_col,:)-data_test(accel_col,:);
        resid_fault = est_fault(accel_col,:)-data_fault(accel_col,:);
        
        [~,norml,~] = prop();
        rot_test = data_test(2,:).*norml(2);
        rot_fault = data_fault(2,:).*norml(2);
        
        std_mem = std(resid_mem);
        std_test = std(resid_test);
        fprintf('Standard deviation of mem: %2.6f || Standard deviation of test: %2.6f\n',std_mem,std_test)
        
        
        if loud
            fprintf('(Sum of residual/Residual Length): [MEMORY]  -   %2.2e\n',sum(resid_mem)/length(resid_mem))
            fprintf('                                     [TEST]  -   %2.2e\n',sum(resid_test)/length(resid_test))
            fprintf('                                    [FAULT]  -   %2.2e\n',sum(resid_fault)/length(resid_fault))
        end
        
        fprintf('Done estimating. (%2.2f seconds elapsed)\n',toc)

        fprintf('\nComputing SPRT...\n')
        tic
        sig_tr = std(resid_mem);
        
        m = 3;
        V = 2;
        alph = 0.01;
        beta = 0.005;

        m = 4;
        V = 1;
        alph = 0.005;
        beta = 0.005;
        
        S = [sig_tr,m*sig_tr,V,alph,beta];
        RHEALTH_t = {};
        RHEALTH_f = {};


        ms = 1:1:6;
        Vs = 1:1:6;
        betas = 0.005:0.005:0.2;
        alphs = 0.005:0.005:0.2;
        
        %ms = 4;
        %Vs = 1;
        %alphs = 0.2;
        %betas = 0.005;
        
        S = [sig_tr,m*sig_tr,V,alph,beta];
        
        
        %data_test = [data_test data_fault];
        %resid_test = [resid_test resid_fault];
        %rot_test = [rot_test rot_fault];
        
        [alarms_t,SPRT_sv_t,range_t] = test_data(resid_test,S,rot_test);
        [alarms_f,SPRT_sv_f,range_f] = test_data(resid_fault,S,rot_fault);
        
        %{
        %Loop over all possible values of m and V 
        for i = 1:length(ms)
            m = ms(i);
            for j = 1:length(Vs)
                %Loop over all possible values of alpha and beta
                V = Vs(j);
                %R_t = temp;
                %R_f = temp;
                for k = 1:length(alphs)
                    alph = alphs(k);
                    for l = 1:length(betas)
                        beta = betas(l);
                        S = [sig_tr,m*sig_tr,V,alph,beta];
                        

                        [alarms_t,~,~] = test_data(resid_test,S,rot_test);
                        [alarms_f,~,~] = test_data(resid_fault,S,rot_fault);

                        %G_t = alarms_t(1,2);
                        %B_t = alarms_t(2,2);
                        %SR_t = G_t/(G_t+B_t);
                        
                        TN = alarms_t(2,1); %True Negatives
                        TP = alarms_f(2,2); %True Positives
                        FP = alarms_t(2,2); %False Positives
                        FN = alarms_f(2,1); %False Negatives
        
                        %{
                        T_tot = TN+TP;
                        T_mod = 100/T_tot;
                        TN = TN*T_mod;
                        TP = TP*T_mod;
        
                        F_tot = FN+FP;
                        F_mod = 100/F_tot;
                        FN = FN*F_mod;
                        FP = FP*F_mod;
                        
                        %}
                        TP_rate = TP/(TP + FN);
                        FP_rate = FP/(FP + TN);
                        
                        Precision = TP/(TP+FP);
                        Recall = TP_rate;
                        
                        F_score = 2*Precision*Recall/(Precision+Recall);
                        
                        NSET_SPRT_mat = [NSET_SPRT_mat; m V alph beta TP_rate FP_rate F_score]; 

                        %G_f = alarms_f(2,2) + alarms_f(4,2);
                        %B_f = alarms_f(1,2) + alarms_f(3,2);
                        %G_f = alarms_f(1,2);
                        %B_f = alarms_f(2,2);
                        %SR_f = G_f/(G_f+B_f);

                        %kl{k,l} = [alph beta];
                        %R_t(k,l) = SR_t;
                        %R_f(k,l) = SR_f;

                    end
                end

                %test_mat(i,j) = {kl};
                %RHEALTH_t(i,j) = {R_t};
                %RHEALTH_f(i,j) = {R_f};

            end

            fprintf('%d ',i);


        end
        %}
        
        %plot(NSET_SPRT_mat(:,6),NSET_SPRT_mat(:,5),'o');
        
        %NSET_SPRT_mat_out{x} = NSET_SPRT_mat;
        
        
        %Compute SPRT
        %[alarms_t,SPRT_sv,range] = test_data(resid_test,S,rot_test);
        fprintf('\nDone with SPRT. (%2.2f seconds elapsed)\n',toc)

        %plot_data(est_mem,resid_mem,data_mem,1,SPRT_sv_t,range_t,S)
        %plot_data(est_test,resid_test,data_test,4,SPRT_sv_t,range_t,S)
        %plot_data(est_fault,resid_fault,data_fault,7,SPRT_sv_f,range_f,S)
        
        plot_MSET_SPRT(resid_test,SPRT_sv_t,range_t,S,1,data_test)
        plot_MSET_SPRT(resid_fault,SPRT_sv_f,range_f,S,2,data_fault)
        
        %NSET_SPRT_mat_out{x} = NSET_SPRT_mat;
        
    end
    pause
    
    %% Adaptive FFT
    if any(tests==2)
        fprintf('\n<strong>BEGIN ADAPTIVE FFT</strong>\n')
        tic
        %Load training data, and learn adaptive threshold
        K_thresh = 2;
        thresh_mat = zeros(1024,36);
        thresh_mat_i = [];
        %Loop over each data file to learn threshold
        for i = 1:length(list(pick_list))
            
            ind = pick_list(i);
            load(list(ind));
            life(:,3:5) = (life(:,3:5)/(16*1024));
            if size(life,1)/size(data,1) ~= 500
                num_del = (size(life,1)/size(data,1)-500)*size(data,1) - 1;
                life(end-num_del:end,:) = [];
            end
                
            
            [thresh_mat_i,freqs] = learn_thresh(life,data,K_thresh,thresh_mat_i);
            thresh_mat(:,:,i) = thresh_mat_i;

        end
        %Take the maximum threshold for each frequency as new threshold
        thresh_mat = max(thresh_mat,[],3);
        
        
        %Create a waterfall plot of the created threshold
        [~,R_spd_bins,~] = AFFT_prop();
        waterfall_FFT(freqs,R_spd_bins,thresh_mat,true,10+x);

        
        %Test progressive sets of data
        count_healthy = 0;
        for i = 1:length(list(not_pick))
            
            ind = not_pick(i);
            load(list(ind));
            life(:,3:5) = (life(:,3:5)/(16*1024));
            if size(life,1)/size(data,1) ~= 500
                num_del = (size(life,1)/size(data,1)-500)*size(data,1) - 1;
                life(end-num_del:end,:) = [];
            end
            
            [amp_mat,freqs,count_healthy] = test_thresh(life,data,thresh_mat,count_healthy);
            if 1 == 1
                waterfall_FFT(freqs,R_spd_bins,thresh_mat,true,11,amp_mat);
            end
            
        end
        
        %Test faulty data
        count_fault = 0;
        for j = 1:length(fault)
            
            load(fault(j));
            
            life(:,3:5) = (life(:,3:5)/(16*1024));
            if size(life,1)/size(data,1) ~= 500
                num_del = (size(life,1)/size(data,1)-500)*size(data,1) - 1;
                life(end-num_del:end,:) = [];
            end
            
            [amp_mat,freqs,count_fault] = test_thresh(life,data,thresh_mat,count_fault);
            if 1 == 1
                waterfall_FFT(freqs,R_spd_bins,thresh_mat,true,12,amp_mat);
            end
        end
        fprintf('Done with Adaptive FFT. (%2.2f seconds elapsed)\n',toc)
    end
    
    %% Real vs Imag FFT
    if any(tests==3)
        fprintf('\n<strong>BEGIN RE V. IMAG FFT</strong>\n')
        tic
        
        num_FFT = 4096;
        K = 4.5;
        
        fprintf('Learning Healthy Data...\n')
        vecs1P = [];
        for i = 1:length(list(pick_list))

            ind = pick_list(i);
            load(list(ind));
            %
            %Interpolate acceleration to constant rotor-step rather than
            %constant timestep


            [t,accel_interp,rot_interp] = Interp_Angle_2(life,data_raw);
            accel_len = length(accel_interp);
            debug = false;
            if debug
                hold on
                plot(t,accel_interp/16384,'ob')
                plot(life(:,1),life(:,4)/16834,'-*r')
                legend('Interpolated','Raw')
                box on
                xlabel('Time [s]')
                ylabel('Acceleration [g]')
                pause
            end

            %Take the FFT of the interpolated data every N datapoints
            [freqs,vectors,rots] = FFT_vecs(accel_interp,num_FFT,rot_interp);

            %Extract the 1P component from each column of complex vectors

            for j = 1:size(vectors,2)
                vectors_j = vectors(:,j);
                [freq1P,vec1P] = extract_1P(freqs,vectors_j);
                vecs1P = [vecs1P;vec1P];
            end

            %figure(21);
            %hold on
            %plot(vecs1P,'o')
            %pause
        end
        
        for K = 3.5:0.2:5.5
            alarm_num_h = 0;
            tests_h = 0;
            alarm_num_f = 0;
            tests_f = 0;
            
            %Loop over healthy data to memorize




            %Learn threshold for 1P component vectors
            fprintf('Learning more :D\n')
            [center,radius] = Learn_Components(vecs1P,K);
            fprintf('Done learning.\nTesting healthy data...\n')


            %Loop over healthy data to test
            for i = 1:length(not_pick)
                %Load dataset
                ind = not_pick(i);
                load(list(ind));
                %Interpolate each
                [t,accel_interp,rot_interp] = Interp_Angle_2(life,data_raw);
                %Take FFT
                [freqs,vecs,rots] = FFT_vecs(accel_interp,num_FFT,rot_interp);

                vecs1P_t = [];
                alarms = 0;
                subsequent = 0;
                comparisons = 0;
                %Extract 1P component and compare to threshold
                for j = 1:size(vecs,2)
                    vectors_j = vecs(:,j);
                    rots_j = rots(j);
                    
                    [freq1P,vec1P] = extract_1P(freqs,vectors_j);
                    %vecs1P_t = [vecs1P_t;vec1P];
                    if rots_j > 120
                        [alarm_num_h,tests_h] = compare_component(vec1P,center,radius,alarm_num_h,tests_h);
                    end
                    
                    
                    
                    %if alarm_num ~= 0
                    %    subsequent = subsequent + 1;
                    %    alarms = alarms + 1;
                    %else
                    %    subsequent = 0;
                    %end

                    %if subsequent > 3
                    %    fprintf('ALARM! Subsequent alarms: %d\n',subsequent)
                    %end
                    %comparisons = comparisons + 1;
                end
                %SR = (comparisons - alarms)/comparisons;
                %fprintf('Done with set of data. Statistics: \n%d Comparisons || %d Alarms || %2.2f Rotorhealth\n\n',comparisons,alarms,SR)

                %Compare to threshold
                %plot_ReIm(vecs1P_t,center,radius,true,22);


            end
            fprintf('Done testing healthy data.\n')
            fprintf('Testing faulty data...\n')


            %Loop over unhealthy data
            for i = 1:length(fault)
                load(fault(i));
                [t,accel_interp,rot_interp] = Interp_Angle_2(life,data_raw);

                [freqs,vecs,rots] = FFT_vecs(accel_interp,num_FFT,rot_interp);

                vecs1P_f = [];
                alarms = 0;
                subsequent = 0;
                for j = 1:size(vecs,2)
                    vectors_j = vecs(:,j);
                    rots_j = rots(j);
                    
                    [freq1P,vec1P] = extract_1P(freqs,vectors_j);
                    
                    if rots_j > 120
                        [alarm_num_f,tests_f] = compare_component(vec1P,center,radius,alarm_num_f,tests_f);
                    end
                    %if alarm_num_f ~= 0
                    %    subsequent = subsequent + 1;
                    %    alarms = alarms + 1;
                    %else
                    %    subsequent = 0;
                    %end
                    %
                    %if subsequent > 3
                    %    fprintf('ALARM! Subsequent alarms: %d\n',subsequent)
                    %end
                    %comparisons = comparisons + 1;
                end
                %SR = (comparisons - alarms)/comparisons;
                %if loud
                %    fprintf('Done with set of data. Statistics: \n%d Comparisons || %d Alarms || %2.2f Rotorhealth\n\n',comparisons,alarms,SR)
                %end



            end

            FP = alarm_num_h;
            TN = tests_h - alarm_num_h;


            TP = alarm_num_f;
            FN = tests_f - alarm_num_f;
            
            
            TP_rate = TP/(TP+FN);
            Precision = TP/(TP+FP);
            FP_rate = FP/(FP+TN);

            F_score = 2*(Precision*TP_rate)/(Precision+TP_rate);

            OFFT_mat=[OFFT_mat; FP_rate TP_rate F_score K];
            
            fprintf('FP Rate: %2.2f | TP Rate: %2.2f | F_score: %2.2f \n',FP_rate,TP_rate,F_score);
            
            
        end
        
        fprintf('Done with Re v. Imag FFT. (%2.2f seconds elapsed)\n',toc)
    end
    
    OFFT_mat_out{x} = OFFT_mat;
    
    if any(tests==4)
        fprintf('\n<strong>BEGIN AFFT</strong>\n')
        tic
        
        for K_thr = 2:0.1:4
            %%Learn healthy data
            num_fft = 1024;

            [~,r_bins] = AFFT_prop();

            threshold = zeros(num_fft,length(r_bins));
            debug = true;
            for i = 1:length(list(pick_list))
                ind=pick_list(i);
                load(list(ind))

                %Expand data to length of lifeline signal
                [data_exp,~] = expand(data_raw,life);

                %Delete extra data from lifeline, and save the lifeline time column to
                %the data time column
                life = life(1:size(data_exp,1),:);
                data_exp(:,1) = life(:,1);

                [freqs,amps] = FFT_array(life(:,4)/16384,50,num_fft);
                rots_ar = zeros(1,floor(length(data_exp)/num_fft));
                for j = 1:floor(length(data_exp)/num_fft)
                    low = j*num_fft - (num_fft-1);
                    high = j*num_fft;

                    rots = data_exp(low:high,3);
                    rots_ar(j) = mean(rots);
                end

                [threshold] = learn_thresh2(amps,freqs,K_thr,rots_ar,threshold); 
            end

            debug = false;
            show_faults = false;
            nums_h = [0 0]; %[num_tested,num_positive]
            frq_pos_h = [];
            for i = 1:length(not_pick)
                ind = not_pick(i);
                load(list(ind))

                %Expand data to length of lifeline signal
                [data_exp,~] = expand(data_raw,life);

                %Delete extra data from lifeline, and save the lifeline time column to
                %the data time column
                life = life(1:size(data_exp,1),:);
                data_exp(:,1) = life(:,1);

                [freqs,amps] = FFT_array(life(:,4)/16384,50,num_fft);
                rots_ar = zeros(1,floor(length(data_exp)/num_fft));
                for j = 1:floor(length(data_exp)/num_fft)
                    low = j*num_fft - (num_fft-1);
                    high = j*num_fft;

                    rots = data_exp(low:high,3);
                    rots_ar(j) = mean(rots);
                end

                [nums_h,frq_pos_h] = test_thresh2(threshold,freqs,amps,rots_ar,r_bins,nums_h,frq_pos_h);
            end

            debug = false;
            show_faults = false;
            nums_f = [0 0]; %[num_tested,num_positive]
            frq_pos_f = [];
            for i = 1:length(fault)
                load(fault(i))

                %Expand data to length of lifeline signal
                [data_exp,~] = expand(data_raw,life);

                %Delete extra data from lifeline, and save the lifeline time column to
                %the data time column
                life = life(1:size(data_exp,1),:);
                data_exp(:,1) = life(:,1);

                [freqs,amps] = FFT_array(life(:,4)/16384,50,num_fft);
                rots_ar = zeros(1,floor(length(data_exp)/num_fft));
                for j = 1:floor(length(data_exp)/num_fft)
                    low = j*num_fft - (num_fft-1);
                    high = j*num_fft;

                    rots = data_exp(low:high,3);
                    rots_ar(j) = mean(rots);
                end

                [nums_f,frq_pos_f] = test_thresh2(threshold,freqs,amps,rots_ar,r_bins,nums_f,frq_pos_f);
            end

            TP = nums_f(2);             %True positives
            FN = nums_f(1) - nums_f(2); %False negatives
            TN = nums_h(1) - nums_h(2); %True negatives
            FP = nums_h(2);             %False positives
            
            %f_nrm = 100/nums_f(1);
            %h_nrm = 100/nums_h(1);
            
            %TP = TP*f_nrm;
            %FN = FN*f_nrm;
            %TN = TN*h_nrm;
            %FP = FP*h_nrm;

            TP_rate = TP/(TP+FN);
            Precision = TP/(TP+FP);
            FP_rate = FP/(FP+TN);

            F_score = 2*(Precision*TP_rate)/(Precision+TP_rate);

            AFFT_mat=[AFFT_mat; FP_rate TP_rate K_thr F_score];

        end
        plot(AFFT_mat(:,1),AFFT_mat(:,2),'o');
        fprintf('Done with AFFT. (%2.2f seconds elapsed)\n',toc)
    end
    AFFT_mat_out{x} = AFFT_mat;
    %{
    figure(1)
    clf
    hold on
    plot(NSET_SPRT_mat(:,6),NSET_SPRT_mat(:,5),'^g')
    plot(AFFT_mat(:,1),AFFT_mat(:,2),'ob')
    plot(OFFT_mat(:,1),OFFT_mat(:,2),'*r')
    legend('NSET+SPRT','AFFT','OFFT')
    box on
    xlabel('False Positive Rate')
    ylabel('True Positive Rate')
    %}
    
    if any(tests==5)
        slopes = [];
        intercepts = [];
        figure(2)
        hold on
        RMS = [];
        pow = [];
        fprintf('Calc-ing a healthy\n')
        for i = 1:length(list)
            load(list(i))
            data(end-10:end,:) = []; 
            RMS = [RMS;data(:,10)];
            pow = [pow;data(:,4).*data(:,5)];
        end
        RMS = RMS./16384;
        
        
        RMS_av = [];
        pow_av = [];
        for i = 1:ceil(length(RMS)/60)
            low = i*60-59;
            high = i*60;
            if high>length(RMS)
                high = length(RMS);
            end

            RMSs = RMS(low:high,:);
            RMS_av = [RMS_av mean(RMSs)];

            pows = pow(low:high,:);
            pow_av = [pow_av mean(pows)];
        end


        [slope,intercept] = GetParams(RMS_av,pow_av);
        slopes = [slopes slope];
        intercepts = [intercepts intercept];
        Xs = 0:0.001:1;
        Ys = slope*Xs + intercept;
        plot(RMS_av,pow_av,'b.',Xs,Ys,'b-');
        pause
        
        
        RMS = [];
        pow = [];
        fprintf('Calc-ing a fault\n')
        for i = 1:length(fault)
            load(fault(i))
            data(end-10:end,:) = []; 
            RMS = [RMS;data(:,10)];
            pow = [pow;data(:,4).*data(:,5)];
        end
        RMS = RMS./16384;
        
        RMS_av = [];
        pow_av = [];
        for i = 1:ceil(length(RMS)/60)
            low = i*60-59;
            high = i*60;
            if high>length(RMS)
                high = length(RMS);
            end

            RMSs = RMS(low:high,:);
            RMS_av = [RMS_av mean(RMSs)];

            pows = pow(low:high,:);
            pow_av = [pow_av mean(pows)];
        end
        
        [slope,intercept] = GetParams(RMS_av,pow_av);
        slopes = [slopes slope];
        intercepts = [intercepts intercept];
        Xs = 0:0.001:1;
        Ys = slope*Xs + intercept;
        plot(RMS_av,pow_av,'r.',Xs,Ys,'r-');

        box on
        xlim([0 0.2])
        ylim([0 1000])
        xlabel('RMS Acceleration [g]')
        ylabel('Power Output [W]')
        legend('Healthy Data','Healthy Regression','Imbalanced Data','Imbalanced Regression','Location','EastOutside')
        pause

        figure(1);
        subplot(2,1,1)
        plot(slopes)
        subplot(2,1,2)
        plot(intercepts)
    end

end

%{
load('NSET_out.mat')
load('Output.mat')

figure(1)
clf
hold on
plot(NSET_SPRT_mat(:,6),NSET_SPRT_mat(:,5),'^g')
plot(AFFT_mat(:,1),AFFT_mat(:,2),'ob')
plot(OFFT_mat(:,1),OFFT_mat(:,2),'*r')
legend('NSET+SPRT','AFFT','OFFT')
box on
xlabel('False Positive Rate')
ylabel('True Positive Rate')
%}
out = zeros([size(NSET_SPRT_mat),10]);

for i = 1:10
    out(:,:,i) = cell2mat(NSET_SPRT_mat_out(i));
end

out_avg = mean(out,3);
plot(out_avg(:,6),out_avg(:,5),'.')


