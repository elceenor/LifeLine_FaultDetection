
function [plot_mat] = campbell(i)

rot_range = [30 300];
r_lims = [0 400];




r_spd = 0:0.1:400;

P1 = r_spd./60;
P2 = 2*r_spd./60;
P3 = 3*r_spd./60;

str_modes = [0.81 4.7 13];

wk_modes = [0.59 2.97 8.05 15.08];
wk_props = {'-b',':b','-.b','--b'};


w_nr = 16.25;
alf = 0.0024463;
w_r = sqrt(w_nr^2 + alf.*r_spd.^2);

figure(1)
box on
hold on
grid on
%title('Weak Axis Campbell Diagram')
lim1 = fill([0 rot_range(1) rot_range(1) 0 ],[0 0 30 30],'r','FaceAlpha',0.2,'EdgeColor','None');
plot(r_spd,P1,'k',r_spd,P2,':k',r_spd,P3,'--k','LineWidth',3);
plot(r_spd,w_r,'g','LineWidth',2)

for i = 1:length(wk_modes)
    plot(r_lims,[wk_modes(i) wk_modes(i)],wk_props{i},'LineWidth',2)
end
plot([wk_modes.*60 wk_modes.*60/2 wk_modes.*60/3],[wk_modes wk_modes wk_modes],'r*','MarkerSize',10,'LineWidth',2)
xlim([0 325])
ylim([0 25])

    
    

lim2 = fill([rot_range(2) r_lims(2) r_lims(2) rot_range(2)],[0 0 30 30],'r','FaceAlpha',0.2,'EdgeColor','None');
legend('Outside Operating Range','1X Rotor Speed','2X Rotor Speed','3X Rotor Speed','Blade Natural Frequency','1st Mode','2nd Mode','3rd Mode','4th Mode','Possible Resonant Points','Location','EastOutside')

xlabel('Rotor Speed [RPM]')
ylabel('Frequency [Hz]')
set(gcf,'Position',[0 50 700 400])

figure(2)
box on
hold on
grid on
%title('Strong Axis Campbell Diagram')
lim1 = fill([0 rot_range(1) rot_range(1) 0 ],[0 0 30 30],'r','FaceAlpha',0.2,'EdgeColor','None');
plot(r_spd,P1,'k',r_spd,P2,':k',r_spd,P3,'--k','LineWidth',3);
plot(r_spd,w_r,'g','LineWidth',2)
for i = 1:length(str_modes)
    plot(r_lims,[str_modes(i) str_modes(i)],wk_props{i},'LineWidth',2)
end
plot([str_modes.*60 str_modes.*60/2 str_modes.*60/3],[str_modes str_modes str_modes],'r*','MarkerSize',10,'LineWidth',2)
xlim([0 325])
ylim([0 25])

    
    

lim2 = fill([rot_range(2) r_lims(2) r_lims(2) rot_range(2)],[0 0 30 30],'r','FaceAlpha',0.2,'EdgeColor','None');
legend('Outside Operating Range','1X','2X','3X','Blade Natural Frequency','1st Mode','2nd Mode','3rd Mode','Possible Resonant Points','Location','EastOutside')


xlabel('Rotor Speed [RPM]')
ylabel('Frequency [Hz]')
set(gcf,'Position',[700 50 700 400])