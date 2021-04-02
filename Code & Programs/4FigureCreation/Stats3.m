clear all
close all

path(path,'C:\Users\lukec\OneDrive\Documents\2School\MastersThesis\Code\MATLAB\Modeling\NSET')
path(path,'C:\Users\lukec\OneDrive\Documents\2School\MastersThesis\Code\MATLAB\SignalProcessing\Preprocessing_Functions')


fold_hlth = 'C:\Users\lukec\OneDrive\Documents\2School\MastersThesis\Code\MATLAB\FigureStuff\Data\Healthy\';
fold_50g = 'C:\Users\lukec\OneDrive\Documents\2School\MastersThesis\Code\MATLAB\FigureStuff\Data\50g\';
fold_100g = 'C:\Users\lukec\OneDrive\Documents\2School\MastersThesis\Code\MATLAB\FigureStuff\Data\100g\';
fold_200g = 'C:\Users\lukec\OneDrive\Documents\2School\MastersThesis\Code\MATLAB\FigureStuff\Data\200g\';

list_H = fold_hlth + find_files(fold_hlth);
list_50g = fold_50g + find_files(fold_50g);
list_100g = fold_100g + find_files(fold_100g);
list_200g = fold_200g + find_files(fold_200g);

lbls = {'Wind Speed [MPH]','Rotor Speed [RPM]','Rotor Std Dev','Gen Voltage [V]','Gen Current [A]',...
        'Power Output [W]','Yaw Error [deg]','RMS Acceleration [g]','RMS Acceleration [g]',...
        'RMS Acceleration [g]','Line Length','Line Length','Line Length','Crest Factor','Crest Factor',...
        'Crest Factor','Shape Factor','Shape Factor','Shape Factor','Kurtosis','Kurtosis','Kurtosis',...
        'Std Dev','Std Dev','Std Dev','AR 1','AR 2','AR 3','AR 4','AR 5','AR 6','AR 7','AR 8','AR 9',...
        'AR 10','AR 11','AR 12','AR 13','AR 14','AR 15','AR 16','AR 17','AR 18','AR 19','AR 20'};
%            1       2       3        4       5       6        7     8-10 11-13 14-16 17-19
%         [wnd_av rot_av rot_std gen_v_av gen_c_av pow_av wnd_diff_av RMS  LL     CF    SF];
x_ax = 2;
y_ax = 9;
z_ax = 12;
r_spd_bins  = 30:5:210;
wnd_bins    = 9:1:20;

%%Process healthy data
datas = [];
lifes = [];
for i = 1:4
    load(list_H(i))
    %Expand data to length of lifeline signal
    [data_exp,~] = expand(data_raw,life);
    
    %Delete extra data from lifeline, and save the lifeline time column to
    %the data time column
    life = life(1:size(data_exp,1),:);
    
    lifes = [lifes;life];
    datas = [datas;data_raw];
end

[out,R,W,RW] = CalcFeat2(datas,lifes,r_spd_bins,wnd_bins);

%%Process faulty data
datas = [];
lifes = [];
for i = 1:4
    load(list_200g(i))
    %Expand data to length of lifeline signal
    [data_exp,~] = expand(data_raw,life);
    
    %Delete extra data from lifeline, and save the lifeline time column to
    %the data time column
    life = life(1:size(data_exp,1),:);
    
    lifes = [lifes;life];
    datas = [datas;data_raw];
end

[out_f,R_f,W_f,RW_f] = CalcFeat2(datas,lifes,r_spd_bins,wnd_bins);

size(R,2)

while true
    
    %{
    mean_h = mean(R(:,y_ax,1));
    mean_f = mean(R_f(:,y_ax,1));
    per_chg = ( mean_f - mean_h )/abs(mean_h) * 100;
    
    fprintf('Average value: Healthy = %2.4f  Faulty = %2.4f\n',mean_h,mean_f);
    fprintf('Percent change: %2.1f \n',per_chg)
    %}
    
    y_ax = input('\nInput new parameter to check:');
    
    figure(1)
    clf
    hold on
    plot(R(:,2,1),R(:,y_ax,1),'ob','LineWidth',2,'MarkerSize',3)
    errorbar(R(:,2,1),R(:,y_ax,1),-R(:,y_ax,2),R(:,y_ax,2),-R(:,2,2),R(:,2,2),'LineStyle','None','Color','k','HandleVisibility','off')
    set(gcf,'Position',[600 100 900 450])
    box on
    xlabel('Rotor Speed [RPM]')
    ylabel(lbls{y_ax})
    
    
    plot(R_f(:,2,1),R_f(:,y_ax,1),'or','LineWidth',2,'MarkerSize',3)
    errorbar(R_f(:,2,1),R_f(:,y_ax,1),-R_f(:,y_ax,2),R_f(:,y_ax,2),-R_f(:,2,2),R_f(:,2,2),'LineStyle','None','Color','k','HandleVisibility','off')
    legend('Balanced Rotor','200g Imbalance')
    
    
    figure(2)
    hold on
    plot(out(:,x_ax),out(:,y_ax),'ob','LineWidth',2,'MarkerSize',3)
    
    figure(3)
    clf
    hold on
    plot3(out(:,x_ax),out(:,y_ax),out(:,z_ax),'.b','LineWidth',2,'MarkerSize',3)
    plot3(out_f(:,x_ax),out_f(:,y_ax),out_f(:,z_ax),'.r','LineWidth',2,'MarkerSize',3)
    xlabel('X axis')
    ylabel('Y axis')
    zlabel('Z axis')
    grid on
    box on
    
    
    plt = z_ax;
    mat = zeros(length(r_spd_bins),length(wnd_bins));
    for i = 1:size(RW,1)
        for j = 1:size(RW,3)
            mat(i,j) = RW(i,plt,j);
        end
    end
    
    figure(4);
    [ROTS,WNDS] = meshgrid(r_spd_bins,wnd_bins);
    surface = surf(ROTS,WNDS,mat');
    surface.FaceColor = 'interp';
    xlabel('Rotor Speed [RPM]')
    ylabel('Wind Speed [MPH]')
    zlabel('Line Length')

    mat = zeros(length(r_spd_bins),length(wnd_bins));
    for i = 1:size(RW_f,1)
        for j = 1:size(RW_f,3)
            mat(i,j) = RW_f(i,plt,j);
        end
    end
    
    figure(5);
    [ROTS,WNDS] = meshgrid(r_spd_bins,wnd_bins);
    surface = surf(ROTS,WNDS,mat');
    surface.FaceColor = 'interp';
    xlabel('Rotor Speed [RPM]')
    ylabel('Wind Speed [MPH]')
    zlabel('Line Length')



    
    figure(6)
    clf
    hold on
    plot(W(:,1,1),W(:,y_ax,1),'ob','LineWidth',2,'MarkerSize',3)
    errorbar(W(:,1,1),W(:,y_ax,1),-W(:,y_ax,2),W(:,y_ax,2),-W(:,1,2),W(:,1,2),'LineStyle','None','Color','k','HandleVisibility','off')

    plot(W_f(:,1,1),W_f(:,y_ax,1),'or','LineWidth',2,'MarkerSize',3)
    errorbar(W_f(:,1,1),W_f(:,y_ax,1),-W_f(:,y_ax,2),W_f(:,y_ax,2),-W_f(:,1,2),W_f(:,1,2),'LineStyle','None','Color','k','HandleVisibility','off')
    set(gcf,'Position',[0 100 900 450])
    box on
    xlabel('Wind Speed [MPH]')
    ylabel(lbls{y_ax})
    legend('Balanced Rotor','200g Imbalance')
    
    axes = input('Input new axes for plotting: [x_ax y_ax z_ax]\n');
    x_ax = axes(1);
    y_ax = axes(2);
    z_ax = axes(3);
    
end




    