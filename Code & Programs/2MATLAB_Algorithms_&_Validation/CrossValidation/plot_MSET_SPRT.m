function [] = plot_MSET_SPRT(residual,SPRT_sv,range,S,i,data)

plt_sv = [2];
n = length(plt_sv) + 1;
A = range(1);
B = range(2);

SPRT_sv(SPRT_sv == A) = A-0.1;
SPRT_sv(SPRT_sv == B) = B+0.1;

figure(i)

subplot(3,1,1)
box on
plot(200.*data(2,:));
ylabel('Rotor Speed [RPM]')
grid on
ylim([0 220])


%Plot residual
%subplot(n,6,[1 2 3])
subplot(3,1,2)
title('NSET Residual')
hold on
plot(residual,'b.-')
plot([0 length(residual)],[0 0],'k')
xlim([0,length(residual)])
ylim([-0.3 0.1])
ylabel('Residual')
set(gca,'XMinorTick','on')
box on



for j = 1:length(plt_sv)
    %subplot(n,6,[j*6+1,j*6+2,j*6+3])
    subplot(3,1,3)
    title('SPRT Testing')
    plt = SPRT_sv(plt_sv(j),:);
    hold on
    plot([0 length(residual)],[A A],'-b','LineWidth',2)
    plot([0 length(residual)],[B B],'-r','LineWidth',2)
    ylim([A-0.5,B+0.5])
    xlim([0,length(residual)])
    plot(plt,'k.-')
    ylabel('SPRT Index')
    set(gca,'XMinorTick','on')
    box on
    legend('A (Healthy Decision)','B (Fault Decision)','SPRT Result','Location','NorthWest')

    
end

xlabel('Sequential Datapoint #')




%{
hyp_plt = [];
for j = 1:length(plt_sv) + 1
    hyp_plt = [hyp_plt j*6-2 j*6-1 j*6];
end


subplot(n,6,hyp_plt)
num_bins = 15;
min_pl = round(min(residual),3);
max_pl = round(max(residual),3);
step_size = round((max_pl-min_pl)/num_bins,3);

bins = [min_pl:step_size:max_pl];
counter = zeros(1,length(bins));


%Organize data into bins
for i = 1:length(residual)
    [~,ind] = min(abs(residual(i) - bins));
    counter(ind) = counter(ind) + 1;
end
%Plot distribution of residual, and theoretical distributions

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
plot(x,probs/max(probs),'k-','LineWidth',1)

lines = {'-','--',':','-.'};
colors= {[0 0 1],[0 0 1],[0.9 0.5 0.1],[0.9 0.5 0.1]};

for i = 2:2
    [mu,sig] = hypothesis(i,S);
    probs = [];
    x = mu-0.5:0.0005:mu+0.5;
    for j = 1:length(x)
        probs = [probs normal_prob(x(j),mu,sig)];
    end
    plot(x,probs/max(probs),lines{i},'LineWidth',1,'Color',colors{i})
end

legend('Data','H_0','H_2','Location','EastOutside')
%}