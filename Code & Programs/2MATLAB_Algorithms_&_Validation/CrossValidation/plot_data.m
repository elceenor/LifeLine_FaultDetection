

function [] = plot_data(est,resid,data,i,SPRT_sv,range,S)

index = 1:length(est);


[s,n,~] = prop();

rotor_norm = s(3);

A = range(1);
B = range(2);


%% Plot MSET stuff
figure(i);
 
ylabel('Number Datapoints [N]')
subplot(3,1,1);
plot(index,est(2,:)*n(2),'--r',index,data(2,:)*n(2),':b')
legend('Estimated Rotorspeed','Actual Rotorspeed')
subplot(3,1,2);
plot(index,resid)
legend('Residual')
subplot(3,1,3);
plot(index,est(5,:),'--r',index,data(5,:),':b')
legend('Estimated Transverse Accels','Actual Transverse Accels')

%if i ~= 2
%    return
%end

%% Plot SPRT tests
ind = 1:size(SPRT_sv,2);

%Sequential Testing
figure(i+1);

subplot(1,4,1)
title('1')
hold on
plot(SPRT_sv(1,:),ind,'k.-')
plot([A A],[0 ind(end)],'-r')
plot([B B],[0 ind(end)],'-r')
xlim([A-0.5,B+0.5])
ylim([0,size(est,2)])
ylabel('Number Datapoints [N]')

subplot(1,4,2)
title('2')
hold on
plot(SPRT_sv(2,:),ind,'k.-')
plot([A A],[0 ind(end)],'-r')
plot([B B],[0 ind(end)],'-r')
xlim([A-0.5,B+0.5])
ylim([0,size(est,2)])

subplot(1,4,3)

xlabel('Detection Range [A,B]')
title('3')
hold on
plot(SPRT_sv(3,:),ind,'k.-')
plot([A A],[0 ind(end)],'-r')
plot([B B],[0 ind(end)],'-r')
xlim([A-0.5,B+0.5])
ylim([0,size(est,2)])

subplot(1,4,4)
title('4')

hold on
plot(SPRT_sv(4,:),ind,'k.-')
plot([A A],[0 ind(end)],'-r')
plot([B B],[0 ind(end)],'-r')
xlim([A-0.5,B+0.5])
ylim([0,size(est,2)])

%Plot Distrbution of Datapoints and Hypotheses

%Setup bins

num_bins = 15;
min_pl = round(min(resid),3);
max_pl = round(max(resid),3);
step_size = round((max_pl-min_pl)/num_bins,3);

bins = [min_pl:step_size:max_pl];
counter = zeros(1,length(bins));


%Organize data into bins
for i = 1:length(resid)
    [~,ind] = min(abs(resid(i) - bins));
    counter(ind) = counter(ind) + 1;
end
%Plot distribution of residual, and theoretical distributions
figure(i+2);
bar(bins,counter,1,'FaceColor','#b6cdd1')
xlim([min_pl-0.1,max_pl+0.1])
hold on
yyaxis right
sig = S(1);
mu = 0;

probs = [];
x = mu-0.5:0.0005:mu+0.5;
for j = 1:length(x)
    probs = [probs normal_prob(x(j),mu,sig)];
end
plot(x,probs/max(probs),'LineWidth',2)

for i = 1:4
    [mu,sig] = hypothesis(i,S);
    probs = [];
    x = mu-0.5:0.0005:mu+0.5;
    for j = 1:length(x)
        probs = [probs normal_prob(x(j),mu,sig)];
    end
    plot(x,probs/max(probs),'LineWidth',2)
end

legend('Histogram','Null Hypothesis','Hypothesis 1','Hypothesis 2','Hypothesis 3','Hypothesis 4','Location','WestOutside')
%legend('Histogram','Null Hypothesis','Location','WestOutside')




