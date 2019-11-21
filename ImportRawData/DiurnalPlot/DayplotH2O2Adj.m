%%Plots all days on the same 24h axis, with lowest value adjusted to zero
%ROS data is converted to H2O2 equivalents [nmol/m3]

load('SignalAdjusted.mat')  %Loads cleaned fluorescence data

RtimeVec=datevec(Rtime);
RAdjH2O2=(RsignalAdj-570)./2800.3.*400;    %Conversion to H2O2 equivalents, uses lowest signal to subtract background
                                           %Replace with values from appropriate calibration 

Rdayshift=find(diff(RtimeVec(1:end,3))~=0);     %Finds the indices of the row closes for a shift between days

RtimeOnly=Rtime;

RtimeOnly.Year=[4444];                          % Replaces all years with same fictional year to enable plotting of all data on same 24-h scale
RtimeOnly.Day=[4];                              % Replaces all days with same fictional day to enable plotting of all data on same 24-h scale
RtimeOnly.Month=[4];                            % Replaces all months with same fictional month to enable plotting of all data on same 24-h scale

%% splitting the data into a cell array where each row contains data from a different day

RdailyAdj{1,1}=RtimeOnly(1:Rdayshift(1));  
RdailyAdj{1,2}=RAdjH2O2(1:Rdayshift(1));
RdailyAdj{1,3}=Rtime(1);
RdailyAdj{length(Rdayshift)+1,1}=RtimeOnly(Rdayshift(length(Rdayshift))+1:end);
RdailyAdj{length(Rdayshift)+1,2}=RAdjH2O2(Rdayshift(length(Rdayshift))+1:end);
RdailyAdj{length(Rdayshift)+1,3}=Rtime(Rdayshift(length(Rdayshift))+1);

for i=2:(length(Rdayshift));
    RdailyAdj{i,1}=RtimeOnly((Rdayshift(i-1)+1):(Rdayshift(i)));
    RdailyAdj{i,2}=RAdjH2O2((Rdayshift(i-1)+1):(Rdayshift(i))); 
    RdailyAdj{i,3}=Rtime(Rdayshift(i-1)+1);
end

%% plotting of the diurnal patterns in H2O2 equivalent

RColor=cool(length(Rdayshift)+1);    %assigns plot colors

figure

        hlineR(1)=plot(RdailyAdj{1,1},RdailyAdj{1,2},'LineStyle','none','Marker','.','Markersize',5,'Color',RColor(1,1:3));
        hold on
        for i=2:(length(Rdayshift)+1)
            hlineR(i)=plot(RdailyAdj{i,1},RdailyAdj{i,2},'LineStyle','none','Marker','.','Markersize',5,'Color',RColor(i,1:3));
        end
        lgd = legend(datestr([RdailyAdj{:,3}]','dd-mmm-yyyy'),'Location','bestoutside');    % legend to distinguish between different days
        
hold off

%% figure formatting

ylim([-10 120]);        
ax = gca;
ax.XAxis.FontSize = 18;
ax.YAxis.FontSize = 18;
ax.XAxis.FontWeight = 'bold';
ax.YAxis.FontWeight = 'bold';
ax.XAxis.LineWidth = 2;
ax.YAxis.LineWidth = 2;
t = annotation('textbox','String','Summer 2017','LineStyle','none','FontSize', 34, 'FontWeight','bold','Position',[0.15 0.8 0.1 0.1]);
xlabel('Time of day [hh:mm]','FontSize', 26, 'FontWeight','bold');
ylabel('H_2O_2 eq. concentration [nmol/m^3]','FontSize', 26, 'FontWeight','bold');
% ax.XTickLabelMode='manual';   % removes the annoying axis label showing the date, but also removes scaling when zooming. Use only for generating nice final figure for printing
set(gcf, 'Position', [0, 0, 1000, 700])
