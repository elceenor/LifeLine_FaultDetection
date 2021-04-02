
path(path,'C:\Users\lukec\OneDrive\Documents\2School\MastersThesis\Code\MATLAB\SignalProcessing\Preprocessing_Functions')
path(path,'C:\Users\lukec\OneDrive\Documents\2School\MastersThesis\Code\MATLAB\Modeling\A_FFT')

%%Plots a waterfall plot for a given signal

OrderAnalysis = false;
FFT_col = 4;
rot_spd_bins = 30:5:210;
num_FFT = 750;

if ~OrderAnalysis
    [data_exp,~] = expand(data_raw,life);
    [freqs,amps] = FFT_array(life(:,FFT_col)./16384,50,num_FFT);
    rot_spds = zeros(1,floor(length(data_exp)/num_FFT));
    for i = 1:floor(length(data_exp)/num_FFT)
        rot_spds(i) = mean(data_exp(i*num_FFT-(num_FFT-1):i*num_FFT,3));
    end
end

amps_sorted = cell(1,length(rot_spd_bins));
for i = 1:length(rot_spds)
    [~,bin_num] = min(abs(rot_spds(i) - rot_spd_bins));
    amps_sorted{bin_num} = [amps_sorted{bin_num} amps(:,i)];
end

for i = 1:length(amps_sorted)
    amps_sorted{i} = mean(amps_sorted{i},2);
    if isempty(amps_sorted{i})
        amps_sorted{i} = amps_sorted{i-1};
    end
    
end

AMPS = cell2mat(amps_sorted);
[ROTS,FREQS] = meshgrid(rot_spd_bins,freqs);

spd = 30:210;
frq_1P = spd./60;
frq_2P = spd./30;
frq_3P = spd./20;
zz = 0.0065*ones(1,length(spd));
bending_modes = [0.6 0.6;2.97 2.97;8 8];
bending_modes_RPM = bending_modes.*60;
spd_s = [30 210];


figure(1)
hold on
surface = surf(ROTS,FREQS,AMPS);
plot3(spd,frq_1P,zz,'-','LineWidth',5,'Color',[0 0 0])
plot3(spd,frq_2P,zz,'--','LineWidth',5,'Color',[0 0 0])
plot3(spd,frq_3P,zz,':','LineWidth',5,'Color',[0 0 0])
plot3([160 160],[0 10],[0.0075 0.0075],'r-','LineWidth',5)
plot3([30 210],bending_modes(1,:),[0.0075 0.0075],'y-','LineWidth',3)
plot3([30 210],bending_modes(2,:),[0.0075 0.0075],'m-','LineWidth',3)
plot3([30 210],bending_modes(3,:),[0.0075 0.0075],'g-','LineWidth',3)%'Color',[0.4 0.4 0.4])
caxis([0.005 0.04])
zlim([0 0.25])
surface.FaceColor = 'interp';
surface.EdgeColor = [0.4 0.4 0.4];


box on
grid on
set(gca,'YDir','reverse')
ylim([0 10])
xlim([30 210])
zlabel('Magnitude [g]')
ylabel('Response Frequency [Hz]')
xlabel('Rotor Speed [RPM]')
xticks([20:20:200])
view([-92 46])
legend('FFT of Vibration Response','1P Frequency','2P Frequency','3P Frequency','160RPM','1st Bending Mode','2nd Bending Mode','3rd Bending Mode','Location','NorthEast')
set(gcf,'Position',[600 100 900+200 550+106])