%plots OPROSI raw data against date for multiple files
%v.1.2   
%Flow rates above 4.9 considered acceptable
        
%% Variables data import and smoothing

SignalFolder = 'SignalFiles';                            % Folder containing the fluorescence data
VoltFolder = 'VoltFiles';                            % Folder containing the HEPA data
filter = 'none';                                     % rolling averages filter input

%% Get file names
SignalFilesList=dir(SignalFolder);                                              % Get all fluorescences files                                                     
SignalFilesList=SignalFilesList(~ismember({SignalFilesList.name},{'.','..'}));

VoltFilesList=dir(VoltFolder);
VoltFilesList=VoltFilesList(~ismember({VoltFilesList.name},{'.','..'}));    % Get all HEPA files

%% Data import

RawDcell=[];

for i=1:length(SignalFilesList)                                              %import raw data for the spectroscopic signal from original files
    fid=fopen(strcat('SignalFiles\',SignalFilesList(i).name));
    CurrentSpectrum = textscan(fid, '%*f %f %*f %f %*f %*f');  % loads only the second and fourth column
    fclose(fid);
    RawDcell=[RawDcell;CurrentSpectrum];
end

 RawD = cell2mat(RawDcell);

VoltageDcell=[];

for i=1:length(VoltFilesList)                                              %import raw data for the HEPA tracking from original files
    fid=fopen(strcat('VoltFiles\',VoltFilesList(i).name));
    CurrentVolt = textscan(fid, '%*f %f %*f %*f %*f %*f %*f %f %*f %*f');  % loads only the second and fourth column
    fclose(fid);
    VoltageDcell=[VoltageDcell;CurrentVolt];
end

VoltageD = cell2mat(VoltageDcell);

%% Assign and convert time data

        EpochNI = datenum('1904-01-01 00:00:00','yyyy-mm-dd HH:MM:SS');
        timeSig = EpochNI+(RawD((1:end),1)-900+28800)./(60*60*24);          % ROS time is shifted by 15 min to account for reaction time delay
        timeSigF = datetime(timeSig,'ConvertFrom','datenum');               % converting to Matlab's new daytime format
        timeVolt=EpochNI+(VoltageD((1:end),1)+28800)./(60*60*24);      
        timeVoltF = datetime(timeVolt,'ConvertFrom','datenum');             % converting to Matlab's new daytime format
%         timeStr=datestr(timeVoltF(1:10000), 'yyyy-mm-dd HH:MM:SS');

%% y data smoothing

if filter == 'none'
        Signal=RawD(1:end,2);
    elseif mod(filter,2) == 1 & filter>1
        Signal=smooth(RawD(1:end,2),filter,'moving');      
    else
        warning('This in not a valid input argument for selecting a smoothing method. Choose ''none'', or any odd number >1 for calculating moving averages.')
        return
end

%% Finding indicesiof HEPA switching on and off

HepaOnIndex=find(diff(VoltageD(1:end,2))==1);
HepaOffIndex=find(diff(VoltageD(1:end,2))==-1);


%% Plot raw data for signal and HEPA tracking

figure(1)

yyaxis left
hLine1 = plot(timeSigF,Signal,'LineStyle','-','Marker','none','Markersize',2);

yyaxis right
hLine2 = plot(timeVoltF,VoltageD(1:end,2),'LineStyle','-','Marker','none','Markersize',2,'Color',[0.8 0.0 0.2]);

% xlim([min(min(timeSig),min(timeVolt)) max(max(timeSig),max(timeVolt))]);
ax = gca;

yyaxis left
ylim([0 1.2e3]);
xlabel('Time','FontSize', 16, 'FontWeight','bold');
ylabel('Signal Intesity [cts]','FontSize', 16, 'FontWeight','bold');
ax.YTick = [0 300 400 500 600 700 800 1000];

yyaxis right
ylim([-0.2 1.2]);
ylabel('HEPA on/off','FontSize', 16, 'FontWeight','bold');
ax.YAxis(2).Color = [0.8 0.0 0.2];
ax.YTick = [0 1];
ax.YTickLabel = {'off', 'on'};

hold on

yL= get(ax,'YLim');


%%
load('Ctimes.mat');             % Load file with time period of manually selected problematic data
Crap=datenum(Ctimes - minutes(15));
CrapDT=datetime(Crap,'ConvertFrom','datenum'); %convert to datetime format for plotting

for i=1:length(Crap)
    fill([CrapDT(i,1) CrapDT(i,1) CrapDT(i,2) CrapDT(i,2)],[yL(1) yL(2) yL(2) yL(1)],[1 0.682 0],'EdgeColor','none','facealpha',.3);
end

%%
load('Mtimes.mat');             % Load file with manually selected periods of chemical refilling times
Maintenance=datenum(Mtimes - minutes(15));
MaintenanceDT=datetime(Maintenance,'ConvertFrom','datenum'); %convert to datetime format for plotting

for i=1:length(Maintenance)
    fill([MaintenanceDT(i,1) MaintenanceDT(i,1) MaintenanceDT(i,2) MaintenanceDT(i,2)],[yL(1) yL(2) yL(2) yL(1)],[0.812 1 0.439],'EdgeColor','none','facealpha',.5);
end

%%
for i=1:length(HepaOnIndex)
    fill([timeVoltF(HepaOnIndex(i)) timeVoltF(HepaOnIndex(i)) timeVoltF(HepaOffIndex(i)) timeVoltF(HepaOffIndex(i))],[yL(1) yL(2) yL(2) yL(1)],[0.8 0.0 0.2],'EdgeColor','none','facealpha',.3);
end


%%
% load('Itimes.mat');             % Load file with times of manually selected incidents
% Incident=datenum(Itimes - minutes(15));
% IncidentDT=datetime(Incident,'ConvertFrom','datenum'); %convert to datetime format for plotting
% 
% for i= 1:length(Incident)
%     line([IncidentDT(i) IncidentDT(i)], yL, 'LineWidth', 3, 'Color', [0 1 1]);
% end

hold off

ax.XTickLabelRotation = 45;
title('ROS signal','FontSize', 28, 'FontWeight','bold');

%% Changing axes

startdate = '2016-11-23 00:00:00';             % Input time in format 'yyyy-mm-dd HH:MM:SS' or use 'default' to plot from earliest data point
enddate = '2016-12-01 00:00:00';               % Input time in format 'yyyy-mm-dd HH:MM:SS' or use 'default' to plot up to last data point

% startdate = 'default';        
% enddate = 'default';      

if strcmp(startdate,'default') & strcmp(enddate,'default')
     xlim([datetime(min(timeSig),'ConvertFrom','datenum') datetime(max(timeSig),'ConvertFrom','datenum')]);

elseif strcmp(startdate,'default')
     xlim([datetime(min(timeSig),'ConvertFrom','datenum') datetime(enddate,'InputFormat','yyyy-MM-dd HH:mm:ss')]);

elseif strcmp(enddate,'default')
     xlim([datetime(startdate,'InputFormat','yyyy-MM-dd HH:mm:ss') datetime(max(timeSig),'ConvertFrom','datenum')]);

else 
     xlim([datetime(startdate,'InputFormat','yyyy-MM-dd HH:mm:ss') datetime(enddate,'InputFormat','yyyy-MM-dd HH:mm:ss')]);

end
